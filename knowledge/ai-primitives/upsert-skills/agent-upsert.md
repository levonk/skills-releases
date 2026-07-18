---
type: Skill Reference
title: agent-upsert
description: Creates, updates, and audits agent definitions. The producer skill for the agent primitive.
resource: src/current/skills/ai/agent-upsert/
tags: [upsert-skills, agent-creation, agent-audit]
timestamp: 2026-07-11T10:30:00Z
---

# agent-upsert

## Summary

Creates new expert agents, modifies and improves existing agents, and
audits agent definitions for relevance and correctness. The producer skill
for the agent primitive.

## Version

1.0.0

## Modes

- **Mode A: Create** — Create a new agent from scratch (research → scaffold → customize → verify → deliver)
- **Mode C: Update** — Update an existing agent (upsert)

## Key Capabilities

- Scaffold new agents with `init_agent.py` using the standard frontmatter structure
- Fill in personality (name, role, color, icon, voice), categories, capabilities, model-level, tools
- Audit agent definitions for relevance and correctness
- Review whether an agent's capabilities and model level are still appropriate

## Tags

`ai/agent`, `agent-creation`, `agent-design`, `agent-update`, `agent-audit`, `agent-optimization`

## File Location

`src/current/skills/ai/agent-upsert/SKILL.md.tmpl`

## Produces

[Agents](../primitives/agents.md) — autonomous orchestrators that channel domain expertise.

## References

- `references/agent-template.md.tmpl` — Standard agent template
- `references/agent-structure.md` — Full frontmatter field reference
- `references/agent-design.md` — Agent-specific design guidance
- `references/agent-guidelines.md` — Agent-specific guidelines
- `references/agent-search.md` — Agent search workflow

# Citations

[1] [agent-upsert SKILL.md](src/current/skills/ai/agent-upsert/SKILL.md.tmpl)
