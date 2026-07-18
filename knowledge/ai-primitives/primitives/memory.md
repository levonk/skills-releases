---
type: Primitive Definition
title: Memory and Context
description: Always-on context files defining the agent's identity, soul, tools, user preferences, and operational rules.
resource: src/current/context/
tags: [ai-primitives, memory, context, identity, always-on, state]
timestamp: 2026-07-11T10:30:00Z
---

# Memory and Context

## Definition

Memory in the skills-src system is achieved through **context files** —
always-on context loaded into the system prompt that defines the agent's
understanding of its environment, operator, and operational rules. These
are minimal stub files with embedded purpose documentation.

## Primary Role

**State** — context files provide persistent state that the agent always
has access to: who it is, what tools it has, who its operator is, and how
it should behave.

## Scope

Always-on, permanent context. Not task-specific.

## Context Files

| File | Purpose | Update Frequency |
|------|---------|-----------------|
| `IDENTITY.md` | Agent role, title, org chart, responsibilities | As org evolves |
| `SOUL.md` | Agent beliefs, values, voice, principles, personality | Rarely (core) |
| `MEMORY.md` | Curated long-term knowledge, lessons, mandates, retention policy | Major updates + continuously |
| `AGENTS.md` | Operating rules, security policy, workflow conventions | When procedures change |
| `TOOLS.md` | Environment-specific notes, credentials, setup, available tools | When tools change |
| `USER.md` | Who the human is, preferences, goals, background | As user evolves |
| `about-tool-preferences.md` | Tool preferences and configuration | When preferences change |
| `about-self-interests.md` | Agent's interests and focus areas | Periodically |
| `about-writing-style-guide.md` | Writing style preferences | Rarely |
| `about-file-paths.md` | File path conventions | Rarely |

## File Structure

Each context file is a stub with embedded documentation in a template
comment block:

```markdown
Your proactive go-getter assistance to your operator. Your core truths are:
{{{/*
---
    IDENTITY.md
    Purpose: Agent role, title, org chart, responsibilities, what I do
    Changes: As the org evolves, it's the foundational definition of who you are
---
*/}}
```

The `{{{/* ... */}}}` syntax is a template comment — the content between
`{{{/*` and `*/}}}` is not rendered in the output but documents the file's
purpose and update guidance.

## Loading Behavior

Always-on. Loaded into the system prompt permanently.

## Reusability

Not reusable — context files are specific to one agent/operator pair.

## Autonomy Level Changes

No — context files are state, not behavior.

## Personality/Behavior

Yes — `SOUL.md` defines the agent's personality, values, and voice. This
is the personality layer.

## Planning and Reasoning

No — context files are state, not process.

## File Location

`src/current/context/`

## How Memory Differs from OKF Knowledge Bundles

| Aspect | Context/Memory | OKF Knowledge Bundles |
|--------|----------------|----------------------|
| Purpose | Agent understanding, session state | Structured knowledge base |
| Format | Minimal stubs + persistent markdown | Concept documents, index files, logs |
| Consumption | Always-on context | Query-based retrieval |
| Operations | Manual updates | Create, ingest, query, lint |
| Structure | Fixed files (IDENTITY, SOUL, etc.) | Flexible bundle structure |
| Compounding | No — manual updates only | Yes — file answers back as new concepts |

## Session Continuity

The `handoff` skill provides session-to-session continuity by capturing and
restoring conversation context. This is a separate mechanism from the
always-on context files.

## Producer Skill

No dedicated `context-upsert` skill. Context files are authored by hand.
Use `ai-guidance-improver` to audit them. The `handoff` skill handles
session continuity.

# Citations

[1] [Context directory](src/current/context/)
[2] [Context AGENTS.md](src/current/context/AGENTS.md)
[3] [SOUL.md](src/current/context/SOUL.md)
