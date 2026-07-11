<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# If installed via skills (includes/ is bundled alongside the skill):

> Category: **execution** · Status:  · Version: 1.0.0

>-

## Metadata

| Field | Value |
|-------|-------|
| Name | `execute-upsert` |
| Category | `execution` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

This skill is a generalized version of the Infrahub project controller
(`do-proj-infrahub.md`). Where the Infrahub controller assumes tasks already
exist and simply chains subagents through them, this skill has the
intelligence to:

1. **Assess** whether a request is large enough to warrant the full pipeline
2. **Create a PRD** if one doesn't exist (for large requests)
3. **Break the PRD into tasks** if task files don't exist
4. **Execute tasks** via subagents, chaining through the project
5. **Update the PRD** when scope changes, and regenerate affected tasks
6. **Update documentation** (project docs + PRD/task files) as the final phase

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **trigger-guard** (template, over-triggering-guard) — Prevents triggering on requests that don't need the full pipeline
- **** (, prd-creation) — Workflow for generating a PRD from a brief feature prompt — used when no PRD exists
- **** (, task-breakdown) — Workflow for breaking a PRD into parallelizable task stories — used when no task files exist
- **** (, task-execution) — Workflow for processing task stories — delegates to subagents for each story

---

- **Full skill**: [`skills/execution/execute-upsert/SKILL.md`](skills/execution/execute-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-11T11:03:17Z
