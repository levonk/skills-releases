---
type: Primitive Definition
title: Committees
description: Groups of agents that deliberate and synthesize multiple perspectives into integrated conclusions.
resource: src/current/committees/
tags: [ai-primitives, committees, agents, deliberation, multi-agent]
timestamp: 2026-07-11T10:30:00Z
---

# Committees

## Definition

Committees are groups of agents that deliberate on complex topics, each
contributing their domain expertise, then synthesize their perspectives into
an integrated conclusion. A committee is the highest-level primitive — it
composes multiple agents.

## Primary Role

**Orchestrator of orchestrators** — a committee coordinates multiple agents
to produce a synthesis that no single agent could produce alone.

## Scope

Broad, multi-perspective deliberation. Committees tackle questions where
multiple viewpoints must be weighed, cross-validated, or reconciled.

## Frontmatter

```yaml
committee: <Display Name>
slug: <kebab-case-id>
description: <What the committee does>
members:
  - <agent-slug-1>
  - <agent-slug-2>
  - <agent-slug-3>
deliberation_protocol: <cross-validation | situational-analysis | wisdom-synthesis | consensus-building>
conflict_resolution: <consensus-integration | context-matching | principle-weighting | majority-voting>
```

### Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `committee` | Display name of the committee |
| `slug` | kebab-case identifier |
| `description` | What the committee does |
| `members` | List of agent slugs that are members |
| `deliberation_protocol` | How agents interact during deliberation |
| `conflict_resolution` | How disagreements between members are resolved |

## Body Structure

1. **Include** (optional): `{{{ include "includes/subagent-delegation.md" . }}}`
2. **Purpose** — what the committee does and why
3. **Deliberation Process** — step-by-step workflow:
   - Fork independent assessment by each agent
   - Cross-framework validation
   - Conflict resolution
   - Integrated synthesis
4. **Output Format** — markdown template showing expected output structure

## Deliberation Protocols

| Protocol | Description |
|----------|-------------|
| `cross-validation` | Each agent validates others' findings |
| `situational-analysis` | Agents assess which approach fits the context |
| `wisdom-synthesis` | Agents contribute complementary perspectives |
| `consensus-building` | Agents work toward agreement |

## Conflict Resolution Strategies

| Strategy | Description |
|----------|-------------|
| `consensus-integration` | Merge all valid points into unified output |
| `context-matching` | Pick the approach that fits the situation |
| `principle-weighting` | Weight by historical impact or principles |
| `majority-voting` | Majority decides |

## How Committees Compose Agents

- **Members list** references agent files by slug (e.g., `big-five-analyst`)
- Each member agent runs independently (fork), then results are synthesized
- The committee defines the synthesis protocol, not the agent behavior
- Agents retain their own personality, model-level, and tools

## Loading Behavior

Loaded when triggered by the user or invoked by another agent. Not always-on.

## Reusability

Committees are reusable across contexts — the same committee can deliberate
on different questions in its domain.

## Autonomy Level Changes

Yes — committees can change the autonomy level of the deliberation, deciding
how much weight to give each agent's input.

## Personality/Behavior

Yes — committees inherit the personalities of their member agents and add
a deliberation style on top.

## Planning and Reasoning

Yes — the deliberation process involves planning (decomposition) and
reasoning (synthesis, conflict resolution).

## File Location

`src/current/committees/<category>/<committee-name>.md.tmpl`

## Examples

- `committees/legendary-ceos-council.md.tmpl` — Musk, Bezos, Buffett, etc.
- `committees/humanities/personality-council.md.tmpl` — Big Five, MBTI, Enneagram
- `committees/business/leadership-council.md` — Transformational, Transactional, Servant

## Producer Skill

No dedicated `committee-upsert` skill exists yet. Committees are authored by
hand, following the pattern of existing committee files. Use
`ai-guidance-improver` to audit them.

# Citations

[1] [Committees directory](src/current/committees/)
[2] [Legendary CEOs Council](src/current/committees/legendary-ceos-council.md.tmpl)
