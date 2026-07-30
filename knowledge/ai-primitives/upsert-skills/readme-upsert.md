---
type: Skill Reference
title: readme-upsert
description: Generates and updates project README.md documentation for human developers.
resource: src/current/skills/ai/readme-upsert/
tags: [upsert-skills, readme, documentation, brownfield]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: readme-upsert-skill-md
    resource: src/current/skills/ai/readme-upsert/SKILL.md.tmpl
    title: "readme-upsert SKILL.md"
---

# readme-upsert

## Summary

Generates or updates a project's README.md for human developers. Use when
onboarding a human to an existing codebase, creating a README from scratch,
or refreshing a stale README.

## Version

1.1.0

## Modes

- **Mode A: Create** — Create a README from scratch
- **Mode C: Update** — Update an existing README (refresh stale content)

## Key Capabilities

- Onboard humans to existing codebases
- Create READMEs from scratch
- Refresh stale READMEs
- Detect and follow existing README conventions

## Tags

`ai/skill`, `software-development`, `documentation`, `readme`, `brownfield`

## File Location

`src/current/skills/ai/readme-upsert/SKILL.md.tmpl`

## Produces

README.md files — human-facing project documentation. Not agent documentation
(use `agent-file-upsert` for AGENTS.md).
