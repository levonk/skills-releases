---
type: Concept
title: Build-Time vs Runtime Dependencies
description: How skill dependencies work — what gets inlined at build time vs what consumers must install at runtime.
tags: [build-system, dependencies, build-time, runtime, composition]
timestamp: 2026-07-11T10:30:00Z
---

# Build-Time vs Runtime Dependencies

Skills declare their relationships in YAML frontmatter. The distinction
between build-time and runtime dependencies determines what gets inlined
into the built skill versus what the consumer must have installed separately.

## Build-Time Dependencies (inlined at render)

These are resolved by the templater and baked into the `SKILL.md` during
build. The consumer never needs them — they are already part of the output.

### `{{{ include "..." . }}}` directives

Shared includes (`base-ai-guidance`, `base-frontmatter`, `trigger-guard`,
etc.) are inlined into the skill body at render time.

```go
{{{ include "includes/base-ai-guidance.md" . }}}
```

### `see-also` entries with `template:`

Reference shared templates/frameworks that inform the skill's structure.
These are documentation references; the actual content is inlined via
includes.

```yaml
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
```

## Runtime Dependencies (consumer must install)

These are other skills or workflows the skill references at runtime. They
are **not** inlined — the consumer's environment must have them available.

### `see-also` entries with `skill:` or `workflow:`

Point to sibling skills/workflows that complement or are invoked by this
skill.

```yaml
see-also:
  - skill: "readme-upsert"
    relationship: "related"
    description: "Generate or update README documentation"
  - workflow: "ai-knowledge-bundle-create"
    relationship: "creates-the-bundle"
    description: "Create OKF-compliant knowledge bundles"
```

### `dependencies:` array

Explicit list of required skills, tools, or templates needed for the skill
to function.

```yaml
dependencies:
  - "git-repository-management"     # another skill that must be installed
```

## Committee Runtime Dependencies

Committees have a special runtime dependency: their `members:` list
references agent files that must exist at runtime.

```yaml
members:
  - big-five-analyst      # → must exist as an agent file
  - mbti-typologist       # → must exist as an agent file
```

## Installation Model

When you install a skill from a distribution repo, only that skill's built
`SKILL.md` (with build-time includes already inlined) is copied. Runtime
dependencies must be installed separately — the catalog and per-skill docs
list them so consumers know what else to add.

```bash
# Install all public skills from the releases repo
npx skills add levonk/skills-releases
```

## Self-Contained After Build

Skills are self-contained after build — includes are inlined, so built
skills in `skills-releases` have no `{{{ include }}}` directives. The
`cli-tool-discovery.sh` script is also materialized into each skill's
`scripts/` directory at build time, making installed skills fully
self-contained.

# Citations

[1] [skills-src README](https://github.com/levonk/skills-src)
[2] [Developer guide](.agents/knowledge/developer.md)
