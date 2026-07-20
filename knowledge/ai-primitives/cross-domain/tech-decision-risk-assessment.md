---
type: Cross-Link
title: Tech Decision Risk Assessment (cross-link)
description: Cross-link to the canonical tech-decision risk hierarchy in software-architecture-essentials. Applies to AI agents making technology decisions between paths.
tags: [risk, decision-making, cross-link, architecture]
timestamp: 2026-07-18T00:00:00Z
canonical: ../software-architecture-essentials/tech-decision-risk-assessment.md
---

# Tech Decision Risk Assessment (cross-link)

**Canonical source**: [software-architecture-essentials/tech-decision-risk-assessment.md](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/tech-decision-risk-assessment.md)

## Why this matters to AI agents

When an AI agent is choosing between two technology paths (e.g., "use the
existing vendor now and migrate later" vs. "adopt the new vendor now with a
facade"), the agent must place each path on the risk hierarchy and prefer the
lower-risk path unless there is a concrete, named reason to accept higher
risk. Vague justifications ("it's cleaner", "it's more modern") are not
sufficient.

The hierarchy is total: a change at level N is riskier than a change at level
N+1, all else equal. When a decision spans multiple levels, the decision's
risk is the **highest** level it touches, not the average.

## AI-agent-specific application

- **Do not** recommend a higher-risk path because its upfront code looks
  similar to the lower-risk path. Place both on the hierarchy first.
- **Do not** use pre-AI time estimates as the cost axis. Pair the hierarchy
  with [AI + Human Timeline Estimates](ai-human-timeline-estimates.md).
- **Do** name the specific product or compliance reason when deviating from
  the lower-risk path.
- **Do** size verification to risk: higher-risk recommendations require more
  verification steps in the plan.

## See also

- [AI + Human Timeline Estimates](ai-human-timeline-estimates.md) — the cost
  axis that pairs with this risk axis
- [Canonical: Tech Decision Risk Assessment](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/tech-decision-risk-assessment.md)
  — the full hierarchy, dependency-update axis, functional-style axis, and
  worked example
