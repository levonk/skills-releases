---
type: Practice
title: Code Style Conventions
description: TypeScript code style — double quotes, 2-space indentation, semicolons, kebab-case filenames, type over interface, import type for type-only imports, ESM preferred.
tags: [typescript, code-style, formatting, conventions, eslint]
timestamp: 2026-07-17T00:00:00Z
---

# Code Style Conventions

## Failure Mode

Inconsistent formatting across projects leads to style debates in code reviews,
mixed conventions within packages, and difficulty navigating unfamiliar code.

## Practice

### Formatting Rules

- **Double quotes** (`"`) not single quotes (`'`)
- **2-space indentation**
- **Semicolons** required
- **kebab-case** for filenames (except `README.md`, `LICENSE`, etc.)

### TypeScript Preferences

- **`type` over `interface`** for type definitions
- **`import type`** for type-only imports
- **ESM over CommonJS** — prefer ESM
- **No `require()`** in `.mts` files
- **No `import`** in `.cts` files
- **No direct `process.env`** access (use config abstraction)

### Testing Conventions

- **`.test.mts`** extension for test files (not `.test.ts`)
- **Vitest** for testing (configured in ESLint config)
- Tests required for all new features

### Documentation

Every package must have:
- `README.md` — Usage and examples
- `docs/` directory — Detailed documentation
- `internal-docs/` — ADRs, architecture decisions
- Inline JSDoc comments for public APIs

## Related Concepts

- [Explicit File Extensions](explicit-file-extensions.md) — Extensions that
  enforce module system
- [ESLint Composition API](eslint-composition-api.md) — Config that enforces
  these style rules
- [Vitest Testing Framework](vitest-testing-framework.md) — Test file naming
  convention

## Citations

[1] `internal-docs/adr/adr-20251019001-explicit-file-extensions.md` — job-aide
[2] `internal-docs/adr/adr-20251019002-path-alias-safety.md` — job-aide
[3] `internal-docs/adr/adr-20251019003-plugin-composition-api.md` — job-aide
