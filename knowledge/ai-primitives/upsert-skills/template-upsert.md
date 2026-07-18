---
type: Skill Reference
title: template-upsert
description: Creates and audits reusable templates. The producer skill for the template primitive.
resource: src/current/skills/ai/template-upsert/
tags: [upsert-skills, template-creation, template-audit, variable-schema]
timestamp: 2026-07-11T10:30:00Z
---

# template-upsert

## Summary

Creates new reusable templates, modifies and improves existing templates,
and audits template contracts for consistency. The producer skill for the
template primitive.

## Version

1.0.0

## Modes

- **Mode A: Create** — Create a new template from scratch using the meta-template pattern
- **Mode C: Update** — Update an existing template (upsert, with audit checklist)

## Key Capabilities

- Scaffold new templates using the meta-template pattern
- Define variable schemas with types, defaults, and rendering rules
- Audit template contracts for consistency with calling workflows
- Validate that templates are still used and consistent

## Tags

`ai/template/upsert`, `template-creation`, `template-design`, `template-update`, `template-audit`

## File Location

`src/current/skills/ai/template-upsert/SKILL.md.tmpl`

## Produces

[Templates](../primitives/templates.md) — reusable content structures with variable schemas.

## Meta-Template Contract

`templates/meta/template-template.md` defines the canonical structure for
new or significantly revised templates. Every template should conform to
this meta-template.

# Citations

[1] [template-upsert SKILL.md](src/current/skills/ai/template-upsert/SKILL.md.tmpl)
