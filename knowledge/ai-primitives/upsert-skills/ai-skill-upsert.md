---
type: Skill Reference
title: ai-skill-upsert
description: Creates, updates, converts, and benchmarks skills. The producer skill for the skill primitive.
resource: src/current/skills/ai/ai-skill-upsert/
tags: [upsert-skills, skill-creation, skill-evaluation, skill-conversion]
timestamp: 2026-07-11T10:30:00Z
---

# ai-skill-upsert

## Summary

Creates new skills, modifies and improves existing skills, and measures
skill performance. The producer skill for the skill primitive.

## Version

2.3.0

## Modes

- **Mode A: Create** — Create a new skill from scratch (research → scaffold → customize → verify → deliver)
- **Mode B: Convert** — Convert a workflow into a skill (preserving git history via `git mv`)
- **Mode C: Update** — Update an existing skill (upsert)
- **Mode D: Eval** — Run evals to test a skill, benchmark performance with variance analysis

## Key Capabilities

- Research existing skills locally, on skills.sh, and on GitHub
- Scaffold new skills with `init_skill.py`
- Convert workflows to skills (and vice versa via `ai-workflow-upsert`)
- Run evals and benchmark skill performance
- Optimize skill descriptions for better triggering accuracy

## Tags

`ai/skill`, `skill-creation`, `skill-development`, `skill-testing`, `skill-evaluation`, `skill-optimization`, `skill-discovery`

## File Location

`src/current/skills/ai/ai-skill-upsert/SKILL.md.tmpl`

## Produces

[Skills](../primitives/skills.md) — capabilities loaded on demand for focused tasks.

# Citations

[1] [ai-skill-upsert SKILL.md](src/current/skills/ai/ai-skill-upsert/SKILL.md.tmpl)
