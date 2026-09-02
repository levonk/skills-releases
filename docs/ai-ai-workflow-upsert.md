<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 3.1.0

Create new workflows, modify and improve existing workflows, and convert between workflow and skill formats. Use when users want to create a workflow from scratch, update or audit an existing workflow, convert a skill back into a workflow (preserving git history via git mv), edit or optimize an existing workflow's frontmatter or steps, or scaffold a new workflow file with the Template/Wrapper pattern. Make sure to use this skill whenever the user mentions workflow creation, workflow design, workflow scaffolding, workflow updating, workflow auditing, workflow optimization, skill-to-workflow conversion, or wants to package a multi-step procedure into a reusable workflow file, even if they don't explicitly ask for a "workflow creator." Do NOT trigger on general coding questions, one-off scripts, single-step tasks, bug fixes, feature implementation, or code review — this skill is for workflow lifecycle management, not general development. For skill lifecycle management (create/update/convert/eval/benchmark), use ai-upsert instead.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-workflow-upsert` |
| Category | `ai` |
| Version | `3.1.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-workflow-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **ai-upsert** (skill, sibling) — Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not a workflow, or when converting a workflow into a skill (the reverse of this skill's Mode B).
- **requirements-upsert** (skill, consult) — Consult the requirements ledger when creating workflows to ensure generated workflows do not contradict project constraints

---

- **Full skill**: [`skills/ai/ai-workflow-upsert/SKILL.md`](skills/ai/ai-workflow-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:52:56Z
