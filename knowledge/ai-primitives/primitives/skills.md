---
type: Primitive Definition
title: Skills
description: Capabilities loaded on demand for focused tasks, with bundled scripts, references, and evals.
resource: src/current/skills/
tags: [ai-primitives, skills, capability, on-demand, focused]
timestamp: 2026-07-11T10:30:00Z
---

# Skills

## Definition

Skills are capabilities loaded on demand for focused tasks. A skill is a
self-contained directory with a `SKILL.md` entry point (YAML frontmatter +
body) and optional `scripts/`, `references/`, `assets/`, and `evals/`
subdirectories.

## Primary Role

**Capability** — a skill provides a specific, narrow capability that an
agent or user can invoke.

## Scope

Narrow, focused tasks. A skill does one thing well.

## Frontmatter

```yaml
name: <skill-name>
description: <Detailed trigger description with "Do NOT trigger on..." clause>
version: <semver>
user-invocable: <true | false>
disable-model-invocation: <true | false>
date:
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
  last-used: "YYYY-MM-DD"
tags:
  - "ai/skill"
  - <domain-specific tags>
see-also:
  - template: <template-name>
    relationship: <base-framework | structure-standard | shared-include>
    description: <what it provides>
  - skill: <sibling-skill-name>
    relationship: <sibling | complement | alternative>
    description: <what it does>
```

### Key Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `name` | Skill identifier |
| `description` | Primary trigger mechanism — states what it does and when to use it |
| `version` | Semantic version |
| `user-invocable` | Whether the user can invoke it directly |
| `disable-model-invocation` | If true, only user can trigger (not auto-invoked by model) |
| `date.created` | Creation date |
| `date.updated` | Last content change date |
| `date.last-used` | Last invocation date (self-updated) |
| `tags` | Categorization tags (always include `ai/skill`) |
| `see-also` | Cross-links to related skills, templates, workflows |

## Body Structure

1. **Includes** (top): `base-ai-guidance`, `trigger-guard`, `research-phase`,
   `cross-linking`, `date-management`, `clarifying-questions`
2. **Title and overview** — what the skill does
3. **Decision: Which Mode** — determines which operation applies
4. **Mode sections** — Create, Update, Audit, Convert, etc.
5. **Citations** — external sources
6. **Context Declaration** — file paths, external resources, project info

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `scripts/` | Python/bash scripts (one per AI→script handoff). Must have PEP 723 headers. |
| `references/` | Detailed guidance loaded on demand (topic-named files) |
| `assets/` | Static assets (images, data files) |
| `evals/` | Evaluation files for testing skill quality |

## Loading Behavior

Loaded only when relevant or called by the user. The `description`
frontmatter field is the primary trigger mechanism — it must clearly state
when to use the skill and when NOT to.

## Reusability

Reusable across agents — yes. Any agent can invoke any skill.

## Autonomy Level Changes

No — skills do not change the autonomy level. They execute their focused
task and return.

## Personality/Behavior

No — skills have no personality. They are pure capability.

## Planning and Reasoning

No — skills follow a defined procedure. They do not plan or reason
open-endedly; they execute their modes.

## File Location

`src/current/skills/<category>/<skill-name>/SKILL.md.tmpl`

## How Skills Compose Other Primitives

- **Templates** — skills reference templates via `see-also` (build-time) and
  includes (build-time inlining)
- **Includes** — skills pull in shared guidance via `{{{ include }}}` at
  build time
- **Scripts** — skills bundle Python/bash scripts in `scripts/`
- **References** — skills bundle detailed guidance in `references/`

## Build-Time vs Runtime Dependencies

- **Build-time** (inlined at render): `{{{ include }}}` directives, `see-also`
  with `template:`
- **Runtime** (consumer must install): `see-also` with `skill:` or `workflow:`,
  `dependencies:` array

See [Build-Time vs Runtime Dependencies](../build-system/dependencies.md).

## Examples

- `skills/ai/ai-skill-upsert/` — Creates and manages skills
- `skills/ai/knowledge-bundle-upsert/` — Creates OKF knowledge bundles
- `skills/software-dev/git-repository-management/` — Git operations
- `skills/commerce/acquisition/` — Acquisition analysis

## Producer Skill

[`ai-skill-upsert`](../upsert-skills/ai-skill-upsert.md) — creates, updates,
converts, and benchmarks skills.

# Citations

[1] [Skills directory](src/current/skills/)
[2] [Skills AGENTS.md](src/current/skills/AGENTS.md)
[3] [Developer guide](.agents/knowledge/developer.md)
