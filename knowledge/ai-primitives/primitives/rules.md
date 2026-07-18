---
type: Primitive Definition
title: Rules
description: Always-on binding constraints loaded into the system prompt, providing contracts for AI agents working in any project.
resource: src/current/rules/
tags: [ai-primitives, rules, always-on, constraints, contracts, binding]
timestamp: 2026-07-11T10:30:00Z
---

# Rules

## Definition

Rules are always-on context files that provide binding constraints for AI
agents. They are consumed as always-on context (loaded into the system
prompt), not triggered like skills. Rules state contracts, not suggestions:
"Always use X" not "Consider X."

## Primary Role

**Constraint** — rules define what the agent must always do, never do, or
ask before doing. They are binding contracts, not optional guidance.

## Scope

Always-on, permanent constraints. Apply to all tasks.

## Frontmatter

Rules typically have **no frontmatter** (unlike skills/workflows). They are
plain markdown files with direct rule statements. The root `rules.md.tmpl`
includes category-specific rules via `{{{ include }}}`.

## Body Structure

A rule file is plain markdown with a heading and contract statement:

    ## Rule Name (Severity, Scope)

    Rule statement as a contract.

    {{{ include "rules/general-ai/some-rule.md" . }}}

Rules are stated as contracts:
- "Always use X" / "Never do Y" / "Ask before Z"
- Severity: CRITICAL, IMPORTANT, etc.
- Scope: ALL repos, specific categories, etc.

## Loading Behavior

Always-on. Loaded into the system prompt permanently. Every rule adds
permanent token cost, so conciseness is critical.

## Reusability

Rules apply across all projects by default. Category-specific rules apply
to their domain.

## Autonomy Level Changes

No — rules constrain behavior, they don't change autonomy level.

## Personality/Behavior

No — rules are contracts, not personality.

## Planning and Reasoning

No — rules are constraints, not process.

## File Location

`src/current/rules/`

## Rule Categories

| Category | Purpose |
|----------|---------|
| `general-ai/` | General AI rules (ai-chat-prompt, ai-quirks, tone-guidelines, skill-tracking) |
| `business/` | Business-domain rules |
| `features/` | Feature-specific rules |
| `software-dev/` | Software development rules (architecture, platforms, coding standards) |

## How Rules Compose

- **Root `rules.md.tmpl`** — includes all category rules via `{{{ include }}}`
- **Category files** — each category directory has its own rule files
- **No frontmatter** — rules are plain markdown, composed via includes

## Key Difference from Skills

| Aspect | Rules | Skills |
|--------|-------|--------|
| Trigger | Always-on (no trigger) | Triggered by description |
| Frontmatter | None | Full YAML frontmatter |
| Token cost | Permanent (be concise) | Loaded on-demand |
| Purpose | Binding constraints | Task execution |
| Loading | System prompt | On-demand |

## Examples

- `rules/rules.md.tmpl` — Root rules file (includes all categories)
- `rules/general-ai/ai-chat-prompt.md` — Chat prompt rules
- `rules/general-ai/ai-quirks.md` — AI behavior quirks
- `rules/general-ai/tone-guidelines.md` — Tone and voice rules
- `rules/software-dev/` — Software development rules

## Producer Skill

[`rule-upsert`](../upsert-skills/rule-upsert.md) — creates, updates, and
audits rules. Previously rules were authored by hand; `rule-upsert` now
provides lifecycle management.

# Citations

[1] [Rules directory](src/current/rules/)
[2] [Rules AGENTS.md](src/current/rules/AGENTS.md)
