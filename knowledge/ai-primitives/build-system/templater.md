---
type: Concept
title: Templater
description: Go text/template renderer with custom delimiters that renders .tmpl files and inlines includes at build time.
resource: src/current/templater/
tags: [build-system, templater, go, text-template, rendering]
timestamp: 2026-07-11T10:30:00Z
---

# Templater

## Definition

The templater is a custom Go `text/template` renderer that walks a profile
directory, renders every `.tmpl` file, and copies all other files verbatim
to the build output. It uses custom delimiters (`{{{`/`}}}`) instead of
Go's default `{{`/`}}`.

## How It Works

1. **Walks** the profile directory (`src/current/`)
2. **Renders** every `.tmpl` file using Go `text/template` with `{{{`/`}}}` delimiters
3. **Copies** all other files verbatim
4. **Inlines** `{{{ include "..." . }}}` directives at render time
5. **Detects cycles** — includes cannot loop; the templater errors with the full loop path
6. **Outputs** to `build/<profile>/`

## Template Functions

Helm-compatible functions:
- `default`, `lower`, `upper`, `replace`, `split`, `join`, `indent`
- `env`, `now`, `date`
- `list`, `dict`, `hasKey`

## Context Variables

Populated from the environment, git, and `context.yaml` files:
- `user.*` — user information
- `repo.*` — repository information
- `system.*` — system information
- `date.*` — date information

## Include Resolution

Three include path styles are supported:

1. **Profile-root includes** — `{{{ include "includes/foo.md" . }}}`
   Resolves relative to the profile root (`src/current/`). Used for shared
   includes that cross skill/workflow boundaries.

2. **Skill-local includes** — `{{{ include "skills/software-dev/nixify/includes/foo.md" . }}}`
   Resolves relative to the profile root, but the include file lives inside
   a specific skill's `includes/` directory. Used for shared content that is
   only relevant within one skill (e.g. a guard section inlined into multiple
   reference files of the same skill). The templater walks the entire profile
   directory, so any file under `src/current/` is reachable.

3. **Cross-profile includes** — `{{{ include "../../shared/includes/foo.md" . }}}`
   Paths with `../` resolve relative to the current template's directory.
   Paths cannot escape `src/`.

Fallback resolver: if an include path doesn't resolve relative to the
rendering profile root, it tries resolving relative to the current
template's profile root (enables cross-profile nested includes).

## Key Files

| File | Purpose |
|------|---------|
| `render.go` | Core renderer — walks dirs, renders `.tmpl`, copies others |
| `functions.go` | Template functions (include, default, lower, env, etc.) |
| `context.go` | Context variables (user, repo, system, date) |
| `cycle.go` | Cycle detection for includes |

## Build Commands

```bash
just build              # all profiles (src/*/ → build/*/)
just build current      # single profile
just validate           # render to temp dir, check leaked delimiters + frontmatter
just test               # templater tests (go test ./...)
just catalog            # generate README.md catalogs
```

# Citations

[1] [Templater source](src/current/templater/)
[2] [Developer guide](.agents/knowledge/developer.md)
