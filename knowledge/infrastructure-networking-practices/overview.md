---
type: Synthesis
title: Infrastructure Networking Practices Overview
description: Synthesis of infrastructure networking practices — NetBird zero-trust platform, multi-exit node architecture (Direct/NordVPN/Tor), infrastructure variable consolidation, and backup connectivity patterns.
tags: [infrastructure, networking, vpn, zero-trust, netbird, tailscale, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-001-netbird-cloud-controlplane
    resource: shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md
    title: infrahub
  - id: adr-20260625001-multi-exit-node-architecture
    resource: shared/active/08-docs/adr/adr-20260625001-multi-exit-node-architecture.md
    title: infrahub
  - id: adr-20260625001-infrastructure-consolidation
    resource: shared/active/08-docs/adr/adr-20260625001-infrastructure-consolidation.md
    title: infrahub
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Infrastructure Networking Practices Overview

This bundle documents practices for infrastructure networking in a multi-platform
homelab/cloud environment. Each concept was extracted from real infrahub ADRs —
the decisions that ensure secure remote access, flexible exit routing, and
consistent infrastructure topology management.

## The Networking Stack

```
zero-trust-platform → exit-nodes → backup-connectivity → variable-consolidation
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Platform | [NetBird Zero-Trust Platform](netbird-zero-trust-platform.md) | Incomplete VPN solutions, poor cross-platform support, no identity-based access |
| Exit | [Multi-Exit Node Architecture](multi-exit-node-architecture.md) | Single exit point, no privacy options, no high-anonymity path |
| Backup | [Backup Connectivity Pattern](backup-connectivity-pattern.md) | Complete lockout when primary VPN fails |
| Config | [Infrastructure Variable Consolidation](infrastructure-variable-consolidation.md) | Port collisions, IP conflicts, domain fragmentation, inconsistent naming |

## Scope

This bundle covers **infrastructure networking** — VPN platforms, exit node
architecture, connectivity patterns, and infrastructure topology management. It
does **not** cover:

- Container runtime hardening — see
  [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md).
- Security audit practices — see
  [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md).

## Sources

- `shared/active/08-docs/adr/adr-001-netbird-cloud-controlplane.md` — infrahub (255 lines)
- `shared/active/08-docs/adr/adr-20260625001-multi-exit-node-architecture.md` — infrahub (303 lines)
- `shared/active/08-docs/adr/adr-20260625001-infrastructure-consolidation.md` — infrahub (122 lines)

## Related Knowledge Bundles

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) — Containers
  run on the network infrastructure
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — Security practices
  for networked services
- [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md) — Secret
  management across network infrastructure
- [cloud-provider-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/cloud-provider-essentials/overview.md) — Cloud
  provider infrastructure best practices (AWS, Azure, GCP, OCI) including VPC,
  VNet, and VCN networking configurations that complement these networking
  patterns.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

