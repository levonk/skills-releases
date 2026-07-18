---
type: Primitive Definition
title: Templates
description: Reusable content structures with variable schemas, used by workflows, skills, and agents for output generation.
resource: src/current/templates/
tags: [ai-primitives, templates, reusable, variable-schema, structure]
timestamp: 2026-07-11T10:30:00Z
---

# Templates

## Definition

Templates are reusable content structures with variable schemas. They
provide standardized formats for consistent output generation across
prompts, agents, and workflows. Templates define the structure; the caller
fills in the variables.

## Primary Role

**Structure provider** — a template defines the shape of output, not the
content. It provides a skeleton that workflows, skills, and agents fill in.

## Scope

Narrow, structural. A template defines one output format.

## Frontmatter

```yaml
template: <template-name>
slug: <kebab-case-id>
description: <What this template produces>
use: <When to use this template>
engine: <text/template | other>
outputs_to: <output destination pattern>
variables:
  schema:
    - name: <variable-name>
      type: <string | boolean | list | dict>
      required: <true | false>
      default: <default value>
      description: <what it is>
date:
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
```

### Key Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `template` | Template identifier |
| `slug` | kebab-case id |
| `description` | What this template produces |
| `use` | When to use it |
| `engine` | Template engine (Go text/template) |
| `outputs_to` | Where output goes |
| `variables.schema` | Input variable definitions with types and defaults |

## Body Structure

1. **Section structure** — headings defining the output format
2. **Rendering rules** — how variables map to output
3. **Partials/includes documentation** — what shared content is pulled in

## Meta-Template Contract

`templates/meta/template-template.md` defines the canonical structure for
new or significantly revised templates. Every template should conform to this
meta-template.

## Loading Behavior

Loaded when referenced by a workflow, skill, or agent. Not triggered
independently.

## Reusability

Reusable across agents — yes. Any workflow, skill, or agent can use any
template.

## Autonomy Level Changes

No — templates are pure structure. No autonomy.

## Personality/Behavior

No — templates have no personality.

## Planning and Reasoning

No — templates are static structures. No planning or reasoning.

## File Location

`src/current/templates/<category>/<template-name>.md` (or `.md.tmpl`)

## How Templates Compose

- **Meta-templates** — `templates/meta/` contains templates for creating
  other primitives (agent-template, template-template, workflow-template,
  rule-template, hook-template, snippet-template)
- **Includes** — templates can use `{{{ include }}}` for shared content
- **Variable schemas** — templates define inputs that callers must provide

## Template Categories

| Category | Examples |
|----------|---------|
| `ai/` | Prompt skeletons, knowledge bundle templates, response formats |
| `meta/` | Agent, workflow, rule, hook, snippet, template templates |
| `build-agents/` | Build agent templates |
| `business/` | Business document templates |
| `features/` | Feature-specific templates |
| `general/` | General-purpose templates |
| `patterns/` | Reusable patterns (coding, analysis, research) |
| `shell/` | Shell script templates |
| `software-dev/` | Software development templates |

## Key Files

| File | Purpose |
|------|---------|
| `readme-catalog.md.tmpl` | Template for generated README.md catalogs |
| `skill-doc.md.tmpl` | Template for per-skill synopsis pages |
| `meta/agent-template.md.tmpl` | Template for agent definitions |
| `meta/template-template.md` | Template for creating new templates |
| `meta/knowledge-bundle-template.md` | Template for knowledge bundles |

## Examples

- `templates/ai/prompt-skeleton.md.tmpl` — Prompt structure skeleton
- `templates/meta/agent-template.md.tmpl` — Agent definition template
- `templates/ai/knowledge-bundle/references/concept-template-resource-bound.md` — Resource-bound concept template

## Producer Skill

[`template-upsert`](../upsert-skills/template-upsert.md) — creates, updates,
and audits templates.

# Citations

[1] [Templates directory](src/current/templates/)
[2] [Templates AGENTS.md](src/current/templates/AGENTS.md)
