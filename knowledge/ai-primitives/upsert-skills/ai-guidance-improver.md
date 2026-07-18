---
type: Skill Reference
title: ai-guidance-improver
description: Audits and improves existing AI guidance files of any type — skills, workflows, agents, prompts, AGENTS.md.
resource: src/current/skills/ai/ai-guidance-improver/
tags: [upsert-skills, guidance-improvement, quality-assurance, token-efficiency]
timestamp: 2026-07-11T10:30:00Z
---

# ai-guidance-improver

## Summary

Analyzes and improves existing AI guidance files (skills, workflows, agents,
prompts, AGENTS.md) and interactive prompts by identifying conflicts,
duplications, inadequate frontmatter, poor progressive disclosure, scattered
context, and specific solutions where general would be better.

## Version

1.1.0

## Key Capabilities

- Identify conflicts and duplications across AI guidance files
- Ensure consistency across the AI system
- Apply best practices for token efficiency and progressive disclosure
- Provide real-time suggestions for prompts being actively written
- Detect staleness in guidance files

## Tags

`ai/skill`, `guidance-improvement`, `quality-assurance`, `token-efficiency`, `progressive-disclosure`, `best-practices`, `interactive-prompt-improvement`, `real-time-suggestions`, `staleness-detection`

## File Location

`src/current/skills/ai/ai-guidance-improver/SKILL.md.tmpl`

## Scope

This is the **cross-cutting** quality assurance skill. It doesn't produce
a specific primitive — it audits and improves any AI guidance type. Use it
to audit primitives that don't have a dedicated upsert skill (committees,
hooks, snippets, context files).

# Citations

[1] [ai-guidance-improver SKILL.md](src/current/skills/ai/ai-guidance-improver/SKILL.md.tmpl)
