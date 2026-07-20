---
type: Cross-Link
title: AI + Human Timeline Estimates (cross-link)
description: Cross-link to the canonical AI + human timeline estimate format in software-architecture-essentials. Applies to AI agents estimating and reporting work.
tags: [estimation, timelines, cross-link, ai-assisted-dev]
timestamp: 2026-07-18T00:00:00Z
canonical: ../software-architecture-essentials/ai-human-timeline-estimates.md
---

# AI + Human Timeline Estimates (cross-link)

**Canonical source**: [software-architecture-essentials/ai-human-timeline-estimates.md](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/ai-human-timeline-estimates.md)

## Why this matters to AI agents

AI agents routinely estimate work in pre-AI "human days" units ("3-5 days of
engineering"). These estimates are no longer valid units — they were
calibrated to a world where the human wrote the code, ran the tests, debugged
the failures, and iterated. With AI-assisted development, the human reviews
and the AI executes, and the cost axis has shifted.

This produces two kinds of bad recommendations:

1. **Rejecting low-risk, AI-cheap changes** because their pre-AI cost
   estimate is high (e.g., rejecting better-auth from day one because "the
   middleware is 3-5 days of engineering" — when it is AI-cheap and
   well-trodden).
2. **Accepting high-risk, AI-expensive changes** because their pre-AI cost
   estimate looks comparable (e.g., treating "migrate auth later" as cheap
   — when the migration's real cost is unbounded tail risk on paying users,
   which AI assistance does not reduce).

## AI-agent-specific application

- **Do not** report estimates as "X days of engineering". Report on four
  axes: AI execution, human review, verification, tail risk.
- **Do** distinguish what collapses with AI (well-trodden patterns,
  boilerplate, iteration, test generation) from what does not (security
  verification, migration risk on live systems, novel work, compliance/audit).
- **Do** pair every estimate with a
  [Tech Decision Risk Assessment](tech-decision-risk-assessment.md) — the
  risk axis is primary; the cost axis is secondary.
- **Do not** say "it's just an hour of AI coding" — that understates
  verification and tail risk. AI execution is one axis, not the whole cost.

## See also

- [Tech Decision Risk Assessment](tech-decision-risk-assessment.md) — the
  risk axis this estimate format pairs with
- [Canonical: AI + Human Timeline Estimates](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/ai-human-timeline-estimates.md)
  — the full four-axis format, what collapses vs. what does not, and worked
  example
