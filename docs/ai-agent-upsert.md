<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# If installed via skills (includes/ is bundled alongside the skill):

> Category: **ai** · Status: ready · Version: 1.0.0

Create new expert agents, modify and improve existing agents, and audit agent definitions for relevance and correctness. Agents channel specific expertise (tax strategy, software architecture, spiritual guidance) and work autonomously using workflows, prompts, and templates. Use when users want to create an agent from scratch, update or audit an existing agent definition, scaffold a new agent file with the standard frontmatter structure, or review whether an agent's capabilities and model level are still appropriate. Make sure to use this skill whenever the user mentions agent creation, agent design, agent scaffolding, agent updating, agent auditing, agent optimization, or wants to package domain expertise into an autonomous agent, even if they don't explicitly ask for an "agent creator." Do NOT trigger on general coding questions, bug fixes, feature implementation, code review, AGENTS.md documentation generation (use agent-file-upsert), skill creation (use ai-skill-upsert), or workflow creation (use ai-workflow-upsert) — this skill is for agent definition lifecycle management, not general development or other AI guidance types.

## Metadata

| Field | Value |
|-------|-------|
| Name | `agent-upsert` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **agent-template** (template, structure-standard) — Standard agent definition template with frontmatter, i/o schema, workflow, guardrails, and contracts
- **ai-skill-upsert** (skill, sibling) — Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not an agent.
- **ai-workflow-upsert** (skill, sibling) — Full lifecycle management for workflows. Use when the target is a workflow, not an agent.
- **agent-file-upsert** (skill, complement) — Generates AGENTS.md hierarchy for AI agents working in codebases — use for agent documentation, not agent definitions

---

- **Full skill**: [`skills/ai/agent-upsert/SKILL.md`](skills/ai/agent-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-11T15:49:28Z
