---
type: Primitive Definition
title: Prompts
description: Precision-crafted, structured instruction sets created via the Levonk methodology (DECONSTRUCT, DIAGNOSE, DEVELOP, DELIVER).
resource: internal-docs/prompts/
tags: [ai-primitives, prompts, instructions, methodology, levonk]
timestamp: 2026-07-11T10:30:00Z
---

# Prompts

## Definition

Prompts are precision-crafted, structured instruction sets that transform
vague user requests into clear, reusable prompt files. They are created
using the Levonk methodology: DECONSTRUCT, DIAGNOSE, DEVELOP, DELIVER.

## Primary Role

**Instruction** — a prompt provides structured instructions to an AI model
for a specific task.

## Scope

Narrow, task-specific. A prompt defines instructions for one task.

## Frontmatter

Prompts use standard markdown frontmatter with prompt-specific fields:

```yaml
prompt: <prompt-name>
description: <What this prompt does>
use: <When to use this prompt>
version: <semver>
date:
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
tags: [<categorization tags>]
```

## Body Structure

Created via the Levonk methodology:

1. **DECONSTRUCT** — Break down the vague request into components
2. **DIAGNOSE** — Identify what makes the request unclear or incomplete
3. **DEVELOP** — Build the structured prompt with thinking triggers and
   validation hooks
4. **DELIVER** — Produce the final prompt file with companion README

### Prompt Body Sections

- **Role/Context** — Who the AI should be and what it should know
- **Instructions** — Step-by-step instructions
- **Thinking Triggers** — Cues that prompt the AI to reason before acting
- **Validation Hooks** — Checks that verify the output meets criteria
- **Output Format** — Expected output structure

## Loading Behavior

Loaded when invoked by the user or referenced by a workflow/agent. Not
always-on.

## Reusability

Reusable across agents — yes. Any agent or workflow can use any prompt.

## Autonomy Level Changes

No — prompts are instructions. They do not change autonomy.

## Personality/Behavior

No — prompts are pure instructions. No personality.

## Planning and Reasoning

No — prompts define what to do, not how to plan. (Though thinking triggers
can encourage reasoning within the prompt execution.)

## File Location

`internal-docs/prompts/todo/` (or user-specified output directory)

## How Prompts Compose Other Primitives

- **Templates** — prompts can be instantiated from templates (via
  `ai-prompt-create` workflow)
- **Workflows** — prompts are used as step instructions within workflows
- **Multi-prompt task sets** — prompts can be numbered for parallel/sequential
  execution

## Key Difference from Skills/Workflows

| Aspect | Prompts | Skills | Workflows |
|--------|--------|--------|-----------|
| Purpose | Structured instructions | Full capability with scripts | Multi-step process |
| Subdirectories | None | scripts/, references/ | None |
| Methodology | DECONSTRUCT→DELIVER | Research→Deliver | Initialize→Deliver |
| Scope | Single task | Focused capability | Multi-step procedure |

## Examples

- Prompt files in `internal-docs/prompts/` (created on demand)

## Producer Skill

[`prompt-upsert`](../upsert-skills/prompt-upsert.md) — creates, updates, and
audits prompts.

# Citations

[1] [Prompt upsert skill](src/current/skills/ai/prompt-upsert/SKILL.md.tmpl)
