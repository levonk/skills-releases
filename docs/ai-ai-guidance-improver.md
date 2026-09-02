<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 1.1.0

Analyze and improve existing AI guidance files (skills, workflows, agents, prompts, AGENTS.md) and interactive prompts by identifying conflicts, duplications, inadequate frontmatter, poor progressive disclosure, scattered context, and specific solutions where general would be better. Use when users want to improve the quality and maintainability of their AI guidance files, ensure consistency across their AI system, apply best practices for token efficiency and progressive disclosure, or get real-time suggestions for prompts they're actively writing.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-guidance-improver` |
| Category | `ai` |
| Version | `1.1.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **ai-upsert** (skill, complement) — For creating new AI guidance files; shares the research-phase and comparison-methodology includes
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram
- **requirements-upsert** (skill, consult) — Check existing guidance against the requirements ledger for consistency — flag contradictions as improvement candidates

---

- **Full skill**: [`skills/ai/ai-guidance-improver/SKILL.md`](skills/ai/ai-guidance-improver/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:55:48Z
