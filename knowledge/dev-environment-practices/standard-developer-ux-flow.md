---
type: Practice
title: Standard Developer UX Flow
description: Three-flow developer UX pattern — direnv → devbox → just (*-internal) → [build tool]. Separate flows for AI agents, novices, and power users. Technology-agnostic build tool mapping.
tags: [developer-experience, devbox, just, workflow, ai-agents, build-tools]
timestamp: 2026-07-17T00:00:00Z
---

# Standard Developer UX Flow

## Failure Mode

Inconsistent commands across projects create cognitive overhead. AI agents
struggle with environment drift. Developers don't know whether to use `devbox
run`, `just`, or direct language tools. Different projects have different
workflows with no standard pattern.

## Practice

Define three standard flows that cover all developer personas. The core
pattern is: `direnv → devbox → just (*-internal) → [build tool]`.

### Technology-Agnostic Build Tools

Each project type uses its native build tools:

| Technology | Build | Test | Lint | Dev |
|------------|-------|------|------|-----|
| Rust | `cargo build` | `cargo test` | `cargo clippy` | `cargo run` |
| Node.js | `nx build` | `nx test` | `nx lint` | `nx dev` |
| Python | `python -m build` | `pytest` | `ruff check` | `uv run python src/main.py` |
| Go | `go build` | `go test` | `golangci-lint run` | `go run` |
| Java | `mvn compile` | `mvn test` | `checkstyle` | `mvn exec:java` |

### Flow 1: AI Agent / CI (Primary)

```bash
devbox run just build-internal
devbox run just test-internal
devbox run just lint-internal
```

`devbox run` executes directly without interactive shell overhead. Efficient for
automated operations. `devbox shell` is reserved for interactive human sessions.

### Flow 2: Novice Developer

```bash
just build
# Flow: just build → devbox run build → just build-internal → cargo build
```

Normal targets ensure devbox environment automatically. Simpler command
interface for daily development.

### Flow 3: Power User (in devbox shell)

```bash
devbox shell
just build-internal
just test-internal
```

Already in devbox environment via direnv. Can call `*-internal` targets directly
without the devbox run wrapper.

### Bootstrap Flow

```bash
cd project
# direnv auto-activates devbox
# devbox init_hook calls bootstrap-internal
# bootstrap calls prime-internal for code indexing
```

### Devbox Scripts Configuration

```json
{
  "scripts": {
    "bootstrap": "just bootstrap-internal",
    "prime": "just prime-internal",
    "doctor": "just doctor-internal",
    "clean": "just clean-internal",
    "build": "just build-internal",
    "lint": "just lint-internal",
    "test": "just test-internal",
    "dev": "just dev-internal"
  }
}
```

Devbox scripts point to `*-internal` targets because automated systems are
already in the devbox environment — no need for the normal target wrapper.

## Related Concepts

- [Internal vs Normal Targets](internal-vs-normal-targets.md) — Target naming convention
- [Just Over Makefiles](just-over-makefiles.md) — Why just is the task runner
- [Mandatory Testing Workflow](mandatory-testing-workflow.md) — Testing gates for all flows

## Citations

[1] `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — levonk-base-boilerplate
