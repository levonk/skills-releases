---
type: Practice
title: Internal vs Normal Targets
description: Naming convention for just targets — *-internal suffix for actual implementation, normal targets wrap devbox run for environment guarantee. Prevents double-wrapping and clarifies responsibilities.
tags: [just, devbox, targets, naming-convention, workflow]
timestamp: 2026-07-17T00:00:00Z
---

# Internal vs Normal Targets

## Failure Mode

Without a clear naming convention, it's unclear which targets ensure the devbox
environment and which targets contain the actual implementation. AI agents
double-wrap `devbox run` calls, or developers call implementation targets
without the environment being active, leading to missing tools and cryptic
errors.

## Practice

Use a **two-tier target naming convention**:

### Normal Targets (Developer Interface)

Normal targets ensure the devbox environment is active by wrapping `devbox run`:

```just
build:
    devbox run build

test:
    devbox run test

lint:
    devbox run lint
```

Flow: `just build → devbox run build → just build-internal → cargo build`

### Internal Targets (*-internal suffix)

Internal targets contain the **actual implementation** — the language-specific
commands that run inside the devbox environment:

```just
build-internal:
    cargo build

test-internal:
    cargo test

lint-internal:
    cargo clippy -- -D warnings
```

### Why Devbox Scripts Point to *-internal

Devbox scripts in `devbox.json` call `*-internal` targets directly because
automated systems (CI/CD, init_hooks) are already in the devbox environment.
Calling normal targets would add an unnecessary `devbox run` wrapper.

```json
{
  "scripts": {
    "build": "just build-internal",
    "test": "just test-internal"
  }
}
```

### Required Targets

All boilerplate projects MUST include:

- `build`, `test`, `lint`, `dev`, `typecheck` (normal)
- `build-internal`, `test-internal`, `lint-internal`, `dev-internal` (internal)
- `bootstrap`, `bootstrap-internal` (initialization)
- `prime`, `prime-internal` (code indexing)
- `doctor`, `clean` (health and cleanup)

## Related Concepts

- [Standard Developer UX Flow](standard-developer-ux-flow.md) — The three-flow pattern
- [Just Over Makefiles](just-over-makefiles.md) — Why just is the task runner

## Citations

[1] `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — levonk-base-boilerplate
