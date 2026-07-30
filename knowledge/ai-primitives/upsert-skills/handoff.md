---
type: Skill Reference
title: handoff
description: Captures and restores AI conversation context for seamless work continuation across sessions.
resource: src/current/skills/ai/handoff/
tags: [upsert-skills, handoff, context-continuity, session-management]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: handoff-skill-md
    resource: src/current/skills/ai/handoff/SKILL.md.tmpl
    title: "handoff SKILL.md"
---

# handoff

## Summary

Captures and restores AI conversation context for seamless work continuation
across sessions. Use when needing to preserve conversation state, decisions
made, and work progress to start a fresh AI session with full context without
requiring re-explanation.

## Version

2.0.0

## Key Capabilities

- Capture conversation state (decisions, progress, open questions)
- Restore context in a new session
- Preserve work continuity across session boundaries

## Tags

`ai/skill`, `handoff`, `context-continuity`, `session-management`

## Aliases

`conversation-continuity`

## File Location

`src/current/skills/ai/handoff/SKILL.md.tmpl`

## Scope

This is a **utility** skill, not a producer of primitives. It handles
session-to-session continuity, complementing the always-on context files
(IDENTITY.md, SOUL.md, MEMORY.md) which provide permanent state.
