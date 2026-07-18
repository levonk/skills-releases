---
type: Practice
title: Just Over Makefiles
description: Replace Makefiles with just for task running — no .PHONY needed, simple syntax, better error messages, cross-platform consistency, and command-runner focus.
tags: [just, makefile, task-runner, developer-experience, build-tools]
timestamp: 2026-07-17T00:00:00Z
---

# Just Over Makefiles

## Failure Mode

Makefiles have complex syntax, `.PHONY` requirements, confusing variable
assignments (`=` vs `:=` vs `?=`), and file-name collisions — `make test` refuses
to run if a file named `test` exists. These issues create friction and confusion,
especially for developers new to the project.

## Practice

Use **just** as the command runner instead of Makefiles. just is designed for
development tasks, not build systems, and offers a cleaner developer experience.

### Why just Wins

1. **No Phony Targets**: All recipes are treated as commands, no `.PHONY` needed
2. **Simple Syntax**: No confusing `=` vs `:=` assignments or `$$` for variables
3. **Better Error Messages**: Clear feedback when commands fail
4. **Command Runner Focus**: Designed for development tasks, not build systems
5. **Cross-Platform**: Consistent behavior across different systems
6. **Dependencies**: Clean recipe dependencies without complex syntax

### Comparison

```makefile
# Makefile (problematic)
.PHONY: build test lint
build:
	cargo build
test:
	cargo test
# Fails if a file named "test" exists!
```

```just
# justfile (clean)
build:
    cargo build

test:
    cargo test
# Always runs — no file collision
```

### Standard justfile Targets

```just
# Normal targets — Developer interface
build:
    devbox run build

test:
    devbox run test

lint:
    devbox run lint

# Internal targets — Actual implementation
build-internal:
    cargo build

test-internal:
    cargo test

lint-internal:
    cargo clippy -- -D warnings
```

## Why Not Other Solutions

- **Custom shell scripts**: Brittle, inconsistent, hard to maintain
- **Nix flakes**: Steeper learning curve, verbose for simple cases
- **mise**: Limited package ecosystem compared to Nix, no reproducibility
- **Bazel/Pants**: Overkill for most projects, complex setup

## Related Concepts

- [Standard Developer UX Flow](standard-developer-ux-flow.md) — The workflow just enables
- [Internal vs Normal Targets](internal-vs-normal-targets.md) — Target naming convention

## Citations

[1] `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — levonk-base-boilerplate
