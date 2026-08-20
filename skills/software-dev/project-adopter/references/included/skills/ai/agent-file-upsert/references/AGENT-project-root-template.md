
# {project name}

## Project Snapshot
- Type: [Monorepo/Polyrepo]
- Category: [e.g. "TypeScript SaaS", "Rust CLI toolkit", "Python data pipeline"] — high-level only, not the full toolchain

## <purpose>
2-3 sentences what it does and who it's for.
</purpose>

## <install>
User-facing install/deploy instructions — how a consumer or operator obtains and runs this project. Examples: `nix profile add ...`, `pnpm dlx skills add ...`, `brew install ...`, `docker pull`/`docker run`, deploy commands, hosted-service signup URL. Omit this section entirely if the project has no user-facing install step (e.g. a pure internal library). Do NOT put dev-environment setup here — that belongs in the Developer Guide.
</install>

## JIT Index
- Web: `apps/web/` -> [Guide](apps/web/AGENTS.md)
- API: `apps/api/` -> [Guide](apps/api/AGENTS.md)
- Developer Guide: [`.agents/knowledge/developer.md`](.agents/knowledge/developer.md) - Setup, build commands, environment tooling, workflows, repo structure, code style, boundaries, and PR checklist for developers working on this project

## Knowledge Bundles

Canonical practice bundles from [levonk/skills-releases](https://github.com/levonk/skills-releases/knowledge) are copied into [`.agents/knowledge/bundles/`](.agents/knowledge/bundles/) for offline agent access. Domain-specific bundles are URL-referenced and fetched on demand only when the task touches that domain.

### Installed (offline-ready)

| Bundle | Applies when |
|--------|--------------|
| [software-architecture-essentials](.agents/knowledge/bundles/software-architecture-essentials/) | Universal — any project |
| [dev-environment-practices](.agents/knowledge/bundles/dev-environment-practices/) | Universal — any project |
| [devsecops-codeguard](.agents/knowledge/bundles/devsecops-codeguard/) | Universal — any project |
| [cicd-testing-practices](.agents/knowledge/bundles/cicd-testing-practices/) | Universal — any project |
| [build-system-essentials](.agents/knowledge/bundles/build-system-essentials/) | Universal — any project |
| [typescript-monorepo-best-practices](.agents/knowledge/bundles/typescript-monorepo-best-practices/) | TypeScript / Node.js detected |
| [rust-development-practices](.agents/knowledge/bundles/rust-development-practices/) | Rust detected |
| [python-services-practices](.agents/knowledge/bundles/python-services-practices/) | Python detected |
| [java-best-practices](.agents/knowledge/bundles/java-best-practices/) | Java detected |
| [frontend-stack-practices](.agents/knowledge/bundles/frontend-stack-practices/) | Frontend web detected |
| [nix-build-practices](.agents/knowledge/bundles/nix-build-practices/) | Nix-heavy build detected |
| [container-best-practices](.agents/knowledge/bundles/container-best-practices/) | Docker / Kubernetes detected |
| [data-engineering-best-practices](.agents/knowledge/bundles/data-engineering-best-practices/) | Data pipelines detected |

### URL-referenced (fetched on demand)

| Bundle | Read when working on… |
|--------|-----------------------|
| [api-auth-payment-practices](https://github.com/levonk/skills-releases/knowledge/api-auth-payment-practices) | Auth, payments, billing |
| [infrastructure-networking-practices](https://github.com/levonk/skills-releases/knowledge/infrastructure-networking-practices) | Network topology, VPN, DNS |
| [secrets-egress-security](https://github.com/levonk/skills-releases/knowledge/secrets-egress-security) | Secrets management, egress firewalls |
| [cloud-provider-essentials](https://github.com/levonk/skills-releases/knowledge/cloud-provider-essentials) | AWS / Azure / GCP / OCI |
| [web-resource-catalog](https://github.com/levonk/skills-releases/knowledge/web-resource-catalog) | UI components, stock media, color palettes |
| [upstream-contribution-practices](https://github.com/levonk/skills-releases/knowledge/upstream-contribution-practices) | Contributing to upstream OSS |
| [ai-primitives](https://github.com/levonk/skills-releases/knowledge/ai-primitives) | AI tooling, prompt engineering |

**Installation**: Run `uv run --script scripts/install-knowledge-bundles.py <project-root>` (from the `project-adopter` skill) to populate `.agents/knowledge/bundles/`. Universal bundles install by default; pass `--bundles <name1>,<name2>` for stack-matched bundles.

## Out of Scope
For information about what this repo does NOT do, see [`internal-docs/oos/`](internal-docs/oos/).

## Improvements
For potential improvements to architecture, standards, and processes, see [`internal-docs/improvements/INDEX.md`](internal-docs/improvements/INDEX.md). These are suggestions to consider — not decisions yet. Check before proposing changes to avoid re-proposing already-evaluated improvements.

## Anti-Patterns
For things explicitly NOT to do (practices found harmful or inferior), see [`internal-docs/anti-patterns/INDEX.md`](internal-docs/anti-patterns/INDEX.md). These are negative findings — do NOT implement any approach listed there.

## Universal Contracts
- User-binding rules only (licensing, distribution, usage constraints). Build, environment, and workflow rules live in the Developer Guide.

## Agent Interaction Protocol

---
description: Shared ask-user protocol — anytime the AI has a question for the user, present the question, a recommendation, and the reasoning. Lightweight default for general project work; clarifying-questions.md escalates from this base for artifact generation.
---

---
description: Shared communication shorthand — short codes (D1, O1, F1, R1, Q1, A1) for referring to findings, decisions, options, risks, questions, and actions across a conversation. Assigned when presenting 3+ items of a kind, preserved throughout the session, never reused for a different point. Included by ask-user.md so the shorthand is available wherever questions are asked.
---

### Communication Shorthand



When presenting **three or more** findings, decisions, options, risks,
questions, or actions, assign each one a short code. Use markdown headings
or bold labels so the codes are scannable.

#### Standard Codes

| Code | Used for | Example |
|---|---|---|
| **D1, D2, Dn** | Decisions | `D1 — Commit the auth module first` |
| **O1, O2, On** | Options | `O1 — Use pnpm (recommended)` |
| **F1, F2, Fn** | Findings | `F1 — The test suite is flaky on macOS` |
| **R1, R2, Rn** | Risks | `R1 — Migration is irreversible without backup` |
| **Q1, Q2, Qn** | Questions | `Q1 — Should I squash or merge?` |
| **A1, A2, An** | Actions | `A1 — Add the missing PEP 723 header` |

Invent new code prefixes for sections that do not fit the standard set. For
example, `S1` for suggestions, `G1` for goals, `C1` for constraints. Use
the same prefix+number pattern and document the prefix on first use.

#### Rules

- **Assign codes only when there are 3+ items of a kind.** Do not code a
  single finding or a pair of options — just state them. Codes are for
  navigation, not decoration
- **Preserve the same codes throughout the conversation.** If `D1` was
  "commit the auth module first" in the first response, `D1` means that
  same decision for the rest of the session. Do not reassign
- **Do not reuse a number for a different point.** `D1` cannot mean
  "commit the auth module" in one message and "fix the unit test" in the
  next. If a new decision arises, assign it the next available number
  (`D2`, `D3`, etc.) — never recycle a used number
- **Do not create codes for short, simple answers.** If the answer is one
  sentence, just answer. Codes add value when the user needs to refer back
  to a specific point in a longer exchange
- **Number sequentially within a prefix.** `D1`, `D2`, `D3` — do not skip
  numbers or use gaps
- **Bullets do not need trailing periods.** A bullet ending mid-sentence
  or at a phrase is fine without a period. Full sentences in prose get
  periods; list items do not require them

#### Example

```text
### Findings

- F1 — The CI pipeline runs `just test` but not `just bats`. Script
  failures are invisible to CI
- F2 — Two skill scripts reference `npx` instead of `pnpm dlx`,
  violating the tech-stack rule
- F3 — The `handoff` skill's `scan-artifacts.sh` is not materialized
  into the built output

### Decisions

- D1 — Add `just bats` to the CI workflow (recommended — closes the
  script-test gap with no downside)
- D2 — Fix the `npx` references in a separate commit (keeps the CI
  change reviewable on its own)

### Actions

- A1 — Add `just bats` to `.github/workflows/build-and-publish.yml`
- A2 — Replace `npx` with `pnpm dlx` in the two scripts
- A3 — Materialize `scan-artifacts.sh` into the handoff skill
```

The user can now reply "do D1 and A1, skip D2 for now" and the reference
is unambiguous.


### Ask the User (Question + Recommendation + Why)

Anytime you have a question for the user — mid-task, at a decision point, or
when ambiguity blocks progress — present it as **question + recommendation +
why**, in that order. Do not ask a bare question and wait. The user should be
able to reply with a single letter, a "yes/no", or "go ahead" without typing
out the reasoning himself.

#### Required Format

For each question, present:

1. **The question** — one sentence, plain language. Number it if there is
   more than one.
2. **Recommendation** — the option you would pick, labeled `(recommended)`.
   If you genuinely don't have a recommendation, say so and explain why
   (e.g. "no recommendation — both options are reasonable for your use
   case, depends on X").
3. **Why** — one or two sentences on the trade-off. Name what breaks, what
   is gained, or what is lost if the user picks the other option.

#### Example (single question)

```text
Q1. Should I add the new helper to the existing `utils.ts` or create a
    separate `helpers/` directory?

    Recommendation: B (separate `helpers/` directory) — recommended
    Why: `utils.ts` is already 600 lines and growing. Splitting now keeps
    each file under the 500-line guideline and makes the new helpers
    discoverable. The cost is one extra import path.
```

#### Example (multiple questions)

```text
Q1. Which auth flow should I implement first?
    A. Email + password (recommended) — fastest to ship, covers the
       happy path; can layer OAuth on top later.
    B. OAuth-only — better security posture upfront, but blocks the
       demo for users without a Google/GitHub account.

Q2. Should the audit log live in the same DB as the app data?
    A. Same DB (recommended) — simpler transactions, one connection
       pool; acceptable until write volume forces a split.
    B. Separate DB — cleaner isolation, but adds a second connection
       pool and a cross-store consistency problem.
```

#### When to Escalate

This is the **base** protocol — use it for ordinary mid-task decisions. For
high-stakes trade-offs (architecture, data model, destructive actions,
one-way doors) or before generating/updating an artifact, escalate to the
full **clarifying-questions** protocol (8-area gap analysis + Decision Brief
format) — see `clarifying-questions.md`.

#### When NOT to Ask

- The answer is already clear from the prompt, the codebase, or prior
  context — proceed and state your assumption.
- The decision is reversible and low-stakes — pick the default, note it,
  and move on. Only ask if the user would want to be consulted.
- You have already asked and the user answered — do not re-ask the same
  question.


This protocol applies to every interaction in this repo — mid-task decisions,
clarifications, and escalation points. For high-stakes trade-offs (architecture,
data model, destructive actions) or before generating/updating an artifact,
escalate to the full clarifying-questions protocol.

## Developer Guide
For workflows, repository structure, code style, boundaries, known gotchas, and the Definition of Done checklist, see [`.agents/knowledge/developer.md`](.agents/knowledge/developer.md).
