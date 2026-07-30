---
type: Skill Reference
title: ai-workflow-upsert
description: Creates, updates, and converts workflows. The producer skill for the workflow primitive.
resource: src/current/skills/ai/ai-workflow-upsert/
tags: [upsert-skills, workflow-creation, workflow-conversion]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: ai-workflow-upsert-skill-md
    resource: src/current/skills/ai/ai-workflow-upsert/SKILL.md.tmpl
    title: "ai-workflow-upsert SKILL.md"
---

# ai-workflow-upsert

## Summary

Creates new workflows, modifies and improves existing workflows, and
converts between workflow and skill formats. The producer skill for the
workflow primitive.

## Version

3.1.0

## Modes

- **Mode A: Create** — Create a new workflow from scratch using the Template/Wrapper pattern
- **Mode B: Convert** — Convert a skill back into a workflow (preserving git history via `git mv`)
- **Mode C: Update** — Update an existing workflow (upsert)

## Key Capabilities

- Scaffold new workflows with the Template/Wrapper pattern (wrapper + content template)
- Convert skills to workflows (reverse of `ai-upsert` Mode B)
- Edit or optimize workflow frontmatter or steps
- Audit existing workflows

## Tags

`ai/workflow/workflow/upsert`, `skill`, `workflow-creation`, `workflow-design`, `workflow-update`, `workflow-conversion`

## File Location

`src/current/skills/ai/ai-workflow-upsert/SKILL.md.tmpl`

## Produces

[Workflows](../primitives/workflows.md) — multi-step repeatable processes.
