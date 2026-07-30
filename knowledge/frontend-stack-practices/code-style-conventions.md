---
type: Practice
title: Code Style Conventions
description: TypeScript code style — double quotes, 2-space indentation, semicolons, kebab-case filenames, type over interface, import type for type-only imports, ESM preferred.
tags: [typescript, code-style, formatting, conventions, eslint]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20251019001-explicit-file-extensions
    resource: "internal-docs/adr/adr-20251019001-explicit-file-extensions.md"
    title: "job-aide"
  - id: adr-20251019002-path-alias-safety
    resource: "internal-docs/adr/adr-20251019002-path-alias-safety.md"
    title: "job-aide"
  - id: adr-20251019003-plugin-composition-api
    resource: "internal-docs/adr/adr-20251019003-plugin-composition-api.md"
    title: "job-aide"
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
