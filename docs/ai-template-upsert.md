<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 1.0.0

Create new reusable templates, modify and improve existing templates, and audit template contracts for consistency. Use when users want to create a template from scratch, update or audit an existing template's frontmatter or variable schema, scaffold a new template file using the meta-template pattern, refine a template's rendering rules, or validate that a template is still used and consistent with calling workflows. Make sure to use this skill whenever the user mentions template creation, template design, template scaffolding, template updating, template auditing, template optimization, variable schema design, or wants to package a reusable structure into a template file, even if they don't explicitly ask for a "template creator." Do NOT trigger on general coding questions, one-off prompts, single-step formatting tasks, bug fixes, feature implementation, or code review — this skill is for template lifecycle management, not general development. For prompt instance creation, use ai-prompt-create instead; for skill lifecycle management, use ai-skill-upsert instead.

## Metadata

| Field | Value |
|-------|-------|
| Name | `template-upsert` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

### What Templates Provide

1. **Reusable structures** - Standardized formats for consistent output generation across prompts, agents, and workflows
2. **Variable schemas** - Defined inputs with types, defaults, and rendering rules
3. **Composable contracts** - Templates that can be safely used by workflows like `ai-prompt-create` without additional explanation

### Template Architecture

1. **Frontmatter** — `template`, `slug`, `description`, `use`, `engine`, `outputs_to`, `variables.schema`, `date`.
2. **Body** — Section structure, rendering rules, partials/includes documentation.
3. **Meta-template contract** — `templates/meta/template-template.md` defines the canonical structure for new or significantly revised templates.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **ai-skill-upsert** (skill, sibling) — Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not a template.
- **ai-workflow-upsert** (skill, sibling) — Full lifecycle management for workflows (create/update/convert). Use when the target is a workflow, not a template.
- **agent-file-upsert** (skill, sibling) — Full lifecycle management for agent files (create/update/audit). Use when the target is an agent definition.

---

- **Full skill**: [`skills/ai/template-upsert/SKILL.md`](skills/ai/template-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-18T08:27:30Z
