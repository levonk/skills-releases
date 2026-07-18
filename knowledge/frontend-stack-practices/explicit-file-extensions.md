---
type: Practice
title: Explicit File Extensions for TypeScript Modules
description: Enforce .mts/.cts/.tsx over ambiguous .ts/.js. File extension immediately shows module system, prevents tooling confusion, and allows mixing ESM and CommonJS in same package.
tags: [typescript, file-extensions, esm, commonjs, eslint, modules]
timestamp: 2026-07-17T00:00:00Z
---

# Explicit File Extensions for TypeScript Modules

## Failure Mode

`.ts` and `.js` files are ambiguous — their module system (ESM vs CommonJS)
depends on `package.json` `type` field. This causes unclear module system,
tooling confusion, import errors (require in ESM, import in CJS), and monorepo
complexity when different packages have different `type` settings.

## Practice

**Use explicit extensions that indicate module system**:

- `.mts` — TypeScript ESM modules
- `.cts` — TypeScript CommonJS modules
- `.tsx` — React components (always ESM)
- `.mjs` — JavaScript ESM modules
- `.cjs` — JavaScript CommonJS modules
- `.d.ts` — Type declarations (standard)

**Ban ambiguous extensions**:

- `.ts` files (except `.d.ts`, `.config.ts`, `.test.ts`)
- `.js` files (except `.config.js`)

### ESLint Enforcement

Rules in `@job-aide/tools-lint-eslint-config`:
- `job-aide/ban-ambiguous-ts` — Flags `.ts` files
- `job-aide/ban-ambiguous-js` — Flags `.js` files
- `job-aide/mts-must-be-esm` — Enforces ESM syntax in `.mts`
- `job-aide/cts-must-be-commonjs` — Enforces CommonJS syntax in `.cts`
- `react/jsx-filename-extension` — Requires `.tsx` for JSX

### Why Not Rely on package.json type

- Global setting affects all files
- Can't mix ESM and CommonJS
- Some tools ignore it
- Requires checking external file to understand module system

## Related Concepts

- [Path Alias Safety](path-alias-safety.md) — Import patterns for these files
- [ESLint Composition API](eslint-composition-api.md) — Config that enforces these rules

## Citations

[1] `internal-docs/adr/adr-20251019001-explicit-file-extensions.md` — job-aide
