---
name: ai-workflow-upsert
description: Create new workflows, modify and improve existing workflows, and convert between workflow and skill formats. Use when users want to create a workflow from scratch, update or audit an existing workflow, convert a skill back into a workflow (preserving git history via git mv), edit or optimize an existing workflow's frontmatter or steps, or scaffold a new workflow file with the Template/Wrapper pattern. Make sure to use this skill whenever the user mentions workflow creation, workflow design, workflow scaffolding, workflow updating, workflow auditing, workflow optimization, skill-to-workflow conversion, or wants to package a multi-step procedure into a reusable workflow file, even if they don't explicitly ask for a "workflow creator." Do NOT trigger on general coding questions, one-off scripts, single-step tasks, bug fixes, feature implementation, or code review — this skill is for workflow lifecycle management, not general development. For skill lifecycle management (create/update/convert/eval/benchmark), use ai-skill-upsert instead.
version: 3.0.0
triggers:
  - user
date:
  created: "2025-12-20"
  updated: "2026-07-05"
  last-used: "2026-07-05"
tags:
  - "ai/workflow/workflow/upsert"
  - "skill"
  - "workflow-creation"
  - "workflow-design"
  - "workflow-update"
  - "workflow-conversion"
see-also:
  - template: "base-workflow-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
  - skill: "ai-skill-upsert"
    relationship: "sibling"
    description: "Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not a workflow, or when converting a workflow into a skill (the reverse of this skill's Mode B)."
---

---

{{{ include "workflows/ai/includes/base-workflow-guidance.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# AI Workflow Upsert

A skill for creating new workflows and iteratively improving them through structured audit and conversion. Handles the full workflow lifecycle: create from scratch, update existing, and convert between workflow and skill formats.

## Overview

### What Workflows Provide

1. **Repeatable processes** - Multi-step procedures with clear phases (Initialize, Plan, Apply, Verify, Deliver)
2. **Template/Wrapper pattern** - Content template + frontmatter wrapper, separable and reusable
3. **Step-based execution** - Sequences of prompts/tools with defined concurrency and safety controls

### Workflow Architecture

1. **Wrapper file** — `config/ai/workflows/<category>/<name>.md.tmpl`: YAML frontmatter (metadata, triggering) + `includeTemplate` call pulling in the content template.
2. **Content template** — `config/ai/templates/<category>/<name>-template.md`: The workflow steps and logic, no frontmatter. Reusable across wrappers.
3. **Bundled resources** — Workflows do NOT support `scripts/`, `references/`, `evals/`, or `assets/` subdirectories. If a workflow needs these, convert it to a skill (see Mode B in `ai-skill-upsert`, or Mode B below for the reverse direction).

## Decision: Create vs Convert vs Update

Before starting, determine which mode applies:

1. **Check whether the target wrapper file already exists** at `config/ai/workflows/<category>/<name>.md.tmpl`.
2. **If no wrapper exists:**
   - If the user has an existing skill they want as a workflow → **Mode B: Convert a Skill to a Workflow** (preserves git history).
   - Otherwise → **Mode A: Create a New Workflow from Scratch**.
3. **If the wrapper already exists** → **Mode C: Update an Existing Workflow (Upsert)**. See `references/workflow-upsert.md` for the full update workflow.

## Mode A: Create a New Workflow from Scratch

### Workflow Design Focus

- Create workflows that execute sequences of prompts/tools
- Define clear phases: Initialize, Plan, Apply, Verify, Deliver
- Specify concurrency and safety controls

{{{ include "workflows/ai/includes/data-format-requirements.md" . }}}

### Inputs

- Process description
- Required steps and tools
- Safety requirements

### Operation

1. **Initialize**: Define workflow purpose and scope. Run `scripts/init_workflow.py <workflow-name> --path <output-directory>` to scaffold the workflow wrapper and content template with TODO placeholders. See `references/anatomy.md` for the directory layout the scaffolder creates.
2. **Plan**: Map steps and dependencies. Identify which phases are deterministic (candidates for script extraction if later converted to a skill) and which require AI judgment.
3. **Apply**: Implement using the Template/Wrapper pattern:
   - Content template in `config/ai/templates/<category>/<name>-template.md` (no frontmatter) — the scaffolder creates this with section headers.
   - Workflow wrapper in `config/ai/workflows/<category>/<name>.md.tmpl` with frontmatter including `date.last-used` set to current date (YYYY-MM-DD) and `includeTemplate` call — the scaffolder creates this with TODO placeholders.
   - Fill in the placeholders.
4. **Verify**: Validate step sequencing and template syntax. Run `chezmoi execute-template` on the wrapper to confirm the include resolves.
5. **Deliver**: Save to `internal-docs/workflows/` and update `date.last-used` in the frontmatter.

## Mode B: Convert an Existing Skill to a Workflow

When the user provides an existing skill directory and wants it turned back into a workflow, use this path to preserve the skill's git history while transforming it into a workflow. **See `references/skill-to-workflow-conversion.md` for the full process**, including when conversion is appropriate (the skill no longer needs scripts/evals/references), the git-mv-based history preservation, and the optimization checklist.

**High-level steps:**

1. **Verify conversion is appropriate** — the skill should not rely on `scripts/`, `references/`, `evals/`, or `assets/` that workflows cannot bundle. If it does, conversion loses functionality; warn the user.
2. **Create the wrapper location** at `config/ai/workflows/<category>/<name>.md.tmpl` — do NOT create the file yet.
3. **`git mv` the skill's `SKILL.md` to the wrapper path** (renaming to `<name>.md.tmpl`). This preserves the skill's git history so `git log --follow` traces back through the original skill.
4. **Commit the rename as a standalone commit** — pure rename, no content changes.
5. **Apply workflow-based optimizations as separate commits** — convert frontmatter from skill schema to workflow schema (strip `name`/`description`/`triggers`, add `workflow`/`slug`/`use`/`role`), move body content to the content template, restructure for the linear step format. See `references/skill-to-workflow-conversion.md` for the full optimization checklist.

**Why separate commits:** The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.

## Mode C: Update an Existing Workflow (Upsert)

When the target workflow wrapper already exists, switch to update mode. The goal is to bring the existing workflow into compliance with the workflow guidelines without blindly overwriting the author's intent. **See `references/workflow-upsert.md` for the full update workflow**, including the audit checklist, prioritized change proposal, and confirmation-before-applying discipline.

**High-level steps:**

1. **Read the existing workflow fully** — wrapper frontmatter, content template, and any `see-also` references.
2. **Audit against the workflow guidelines** — frontmatter, description/use quality, step structure, context declaration, includes, stale text. See `references/workflow-upsert.md` for the full audit checklist.
3. **Propose changes — do not apply yet.** Present a prioritized list (Critical / Important / Nice to have) with before/after for each change.
4. **Ask for confirmation before applying.** Let the author accept all, a subset, or reject.
5. **Apply approved changes as separate commits** — one logical change per commit, each independently reviewable and revertable.
6. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied.

**Never silently overwrite.** The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.

## Cross-Cutting Concerns

### Script Execution Standards

This skill bundles `scripts/init_workflow.py`. All scripts bundled with or created by this skill must include devbox and rtk detection patterns. See `references/anatomy.md` in `ai-skill-upsert` for the script output contract (quiet by default, `--verbose`, `--dry-run`) and the one-handoff principle.

### Cross-Linking

When workflows reference other workflows or skills:

1. **Use see-also in frontmatter**: Document relationships
2. **Specify relationship type**: dependency, alternative, complement, sibling
3. **Explain the relationship**: Why this workflow is related
4. **Avoid circular dependencies**: Workflows shouldn't depend on each other

### When to Convert to a Skill

If a workflow grows to need `scripts/`, `references/`, `evals/`, or `assets/`, it has outgrown the workflow format. Use `ai-skill-upsert` Mode B to convert it to a skill (the reverse of this skill's Mode B). Signs a workflow needs conversion:

- Repeatedly inlining the same script code in prose
- Needing evals to test triggering accuracy
- Reference material growing too large for the content template
- Needing bundled assets (templates, icons, fonts)

---
## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/ai-workflow-upsert/SKILL.md`
- Scaffolder script: `config/ai/skills/ai/ai-workflow-upsert/scripts/init_workflow.py`
- References: `config/ai/skills/ai/ai-workflow-upsert/references/`
- Workflow template: `config/ai/templates/meta/workflow-template.md`
- Output directory: `internal-docs/workflows/`

### External Resources
- Project documentation: https://github.com/levonk/dotfiles

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk

<!-- vim: set ft=markdown -->
