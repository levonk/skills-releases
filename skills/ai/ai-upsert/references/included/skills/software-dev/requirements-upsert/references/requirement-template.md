---
project: {proj}
module: {module}
slug: {slug}
status: active
date:
  created: "YYYY-MM-DD"
  last-revised: "YYYY-MM-DD"
  superseded: ""
supersedes: ""
see-also: []
---

<!-- This is the current/ template — a pure description of how the system
     works NOW. No plan, no gap analysis, no implementation notes. Those
     belong in todo/ (ready plans) or proposed/ (draft plans). When a todo
     is implemented, the current/ file is updated to reflect the new
     reality and the todo moves to history/. -->

## Statement

<!-- EARS templates — pick the one that fits. See references/ears-patterns.md
     for the full reference card. "SHALL" is the required modal verb. -->

Use one of the 5 EARS sentence patterns (pick the one that fits the
requirement):

1. **Ubiquitous** — always true, no conditions:
   The {system} shall {response}.

2. **Event-driven** — reacts to an external event:
   When {trigger}, the {system} shall {response}.

3. **State-driven** — active while a condition holds:
   While {state}, the {system} shall {response}.

4. **Unwanted** — handles an error or unwanted situation:
   If {condition}, then the {system} shall {response}.

5. **Optional** — feature-flagged or optional behavior:
   Where {feature is included}, the {system} shall {response}.

Be concrete — specific thresholds, versions, and scope boundaries, not
vague aspirations. Use active voice.

## Rationale

{Why this requirement exists. What problem does it solve? What happens
if it is not satisfied?}

## Constraints

<!-- Each constraint is also an EARS sentence using "SHALL". -->

- The {system} shall {constraint response}.
- When {trigger}, the {system} shall {constraint response}.
- While {state}, the {system} shall {constraint response}.
- If {condition}, then the {system} shall {constraint response}.
- Where {feature is included}, the {system} shall {constraint response}.

## Verification

| Check | Command | Expected |
|-------|---------|----------|
| {What to verify} | {command or grep pattern} | {expected result} |

## Change Log

- YYYY-MM-DD — Created — initial requirement
