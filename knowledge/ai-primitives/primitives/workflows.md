---
type: Primitive Definition
title: Workflows
description: Multi-step repeatable processes using the Template/Wrapper pattern, lighter than skills with no bundled subdirectories.
resource: src/current/workflows/
tags: [ai-primitives, workflows, commands, multi-step, template-wrapper]
timestamp: 2026-07-11T10:30:00Z
---

# Workflows (Commands)

## Definition

Workflows are multi-step repeatable processes that use the Template/Wrapper
pattern: a wrapper file with YAML frontmatter + `includeTemplate` call, and
a content template with the actual steps. Workflows are lighter than skills
— no `scripts/`, `references/`, `evals/`, or `assets/` subdirectories.

Also referred to as **commands** in some contexts.

## Primary Role

**Process** — a workflow defines a repeatable, multi-step procedure with
clear phases (Initialize, Plan, Apply, Verify, Deliver).

## Scope

Multi-step procedures. Broader than a single skill invocation, narrower
than an agent's full domain.

## Frontmatter

```yaml
workflow: <Display Name>
slug: <kebab-case-id>
description: <What the workflow does>
use: <When to invoke this workflow>
role: <Agent role: Orchestrator, Reviewer, etc.>
aliases: [<alternative names>]
triggers: [<system_init, manual, etc.>]
artifacts: [<output file patterns>]
permissions: [<read:workspace, write:workspace, etc.>]
version: <semver>
owner: <owner URL>
status: <ready | draft | deprecated>
visibility: <public | internal>
date:
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
tags: [<categorization tags>]
```

### Key Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `workflow` | Display name |
| `slug` | kebab-case identifier |
| `description` | What the workflow does |
| `use` | When to invoke (the trigger scenario) |
| `role` | Agent role when executing this workflow |
| `triggers` | When it fires (system_init, manual) |
| `artifacts` | Output file patterns |
| `permissions` | Required permissions |

## Body Structure (Template/Wrapper Pattern)

### Wrapper File (`<name>.md.tmpl`)

1. **Frontmatter** — YAML metadata
2. **Includes** — `{{{ include "workflows/ai/includes/base-workflow-guidance.md" . }}}`
3. **`includeTemplate` call** — links to the content template

### Content Template (`templates/<name>-template.md`)

1. **Purpose/Design Focus** — core guidance
2. **Inputs/Args** — control behavior
3. **Operation** — phases: Initialize, Plan, Apply, Verify, Deliver
4. **System Prompt** — the actual prompt content

## Loading Behavior

Loaded when triggered by the user or invoked by an agent. Not always-on.

## Reusability

Reusable across agents — yes. Any agent can invoke any workflow.

## Autonomy Level Changes

No — workflows execute their defined steps. They do not change autonomy.

## Personality/Behavior

No — workflows have no personality. They define a process.

## Planning and Reasoning

No — workflows follow a defined sequence of steps. They do not plan
open-endedly.

## File Location

- Wrapper: `src/current/workflows/<category>/<name>.md.tmpl`
- Content template: `src/current/templates/<category>/<name>-template.md`

## How Workflows Compose Other Primitives

- **Templates** — workflows use the Template/Wrapper pattern, pulling in
  content templates via `includeTemplate`
- **Includes** — workflows pull in shared guidance via `{{{ include }}}`
- **Prompts** — workflow steps are essentially structured prompts

## Key Difference from Skills

| Aspect | Workflows | Skills |
|--------|-----------|--------|
| Subdirectories | None (lightweight) | `scripts/`, `references/`, `evals/`, `assets/` |
| Frontmatter | `workflow`/`slug`/`use`/`role` | `name`/`description`/`version`/`tags` |
| Pattern | Template/Wrapper | Single SKILL.md + subdirs |
| Purpose | Multi-step procedures | Full lifecycle with bundled resources |

If a workflow needs scripts or references, convert it to a skill (see
`ai-workflow-upsert` Mode B or `ai-skill-upsert` Mode B).

## Examples

- `workflows/ai/ai-strategy.md.tmpl` — Core orchestration strategy
- `workflows/ai/ai-prompt-run.md.tmpl` — Run prompts
- `workflows/software-dev/` — Software development workflows

## Producer Skill

[`ai-workflow-upsert`](../upsert-skills/ai-workflow-upsert.md) — creates,
updates, and converts workflows.

# Citations

[1] [Workflows directory](src/current/workflows/)
[2] [Workflows AGENTS.md](src/current/workflows/AGENTS.md)
