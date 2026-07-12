<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 1.0.0

Create new AI prompts, modify and improve existing prompts, and scaffold reusable prompt files with companion READMEs. Transforms user input into precision-crafted, structured prompts using the Levonk methodology (DECONSTRUCT, DIAGNOSE, DEVELOP, DELIVER). Use when users want to create a prompt from scratch, update or audit an existing prompt, refine a prompt's instructions or structure, add thinking triggers or validation hooks, align a prompt with reusable templates, or scaffold a multi-prompt task set with parallel/sequential numbering. Make sure to use this skill whenever the user mentions prompt creation, prompt design, prompt writing, prompt optimization, prompt auditing, prompt refinement, crafting a prompt, or wants to turn a vague request into a structured reusable prompt, even if they don't explicitly ask for a "prompt upsert." Do NOT trigger on general coding questions, bug fixes, feature implementation, code review, or executing a prompt — this skill is for prompt lifecycle management (designing prompts), not for running prompts or general development.

## Metadata

| Field | Value |
|-------|-------|
| Name | `prompt-upsert` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **template-upsert** (skill, sibling) — Full lifecycle management for templates. Use when the target is a reusable template, not a prompt.
- **agent-upsert** (skill, sibling) — Full lifecycle management for agent files. Use when the target is an agent definition, not a prompt.
- **ai-skill-upsert** (skill, sibling) — Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not a prompt.
- **ai-workflow-upsert** (skill, sibling) — Full lifecycle management for workflows. Use when the target is a workflow, not a prompt.

---

- **Full skill**: [`skills/ai/prompt-upsert/SKILL.md`](skills/ai/prompt-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T19:44:04Z
