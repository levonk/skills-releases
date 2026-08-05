---
type: Practice
title: Explicit File Extensions for TypeScript Modules
description: Enforce .mts/.cts/.tsx over ambiguous .ts/.js. File extension immediately shows module system, prevents tooling confusion, and allows mixing ESM and CommonJS in same package.
tags: [typescript, file-extensions, esm, commonjs, eslint, modules]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-08-04"
sources:
  - id: adr-20251019001-explicit-file-extensions
    resource: "internal-docs/adr/adr-20251019001-explicit-file-extensions.md"
    title: "job-aide"
  - id: turbopack-extension-alias-issue-82945
    resource: https://github.com/vercel/next.js/issues/82945
    title: 'Next.js #82945: Turbopack lacks webpack resolve.extensionAlias parity for .mjs→.mts'
  - id: typescript-mts-bundler-warning
    resource: https://www.typescriptlang.org/docs/handbook/modules/reference.html#module-resolution-with-bundler
    title: 'TypeScript docs: "it is recommended not to use .mts files in bundler projects for now"'
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

## Forced Workaround: Turbopack (Next.js)

**`.ts` is never the right answer** — but Turbopack (Next.js's bundler,
default since Next.js 15 dev / Next.js 16 production) is broken: it does
not properly support `.mts` files. Next.js apps are **forced** to use
`.ts`/`.tsx` until the bug is fixed. This is tech debt, not an endorsed
practice.

### Support Matrix — Turbopack Is the Lone Outlier

| Tool | `.ts` | `.mts` | `.cts` | `.tsx` | `.mjs` | `.cjs` |
|------|:-----:|:------:|:------:|:------:|:------:|:------:|
| TypeScript (`tsc`) | Yes | Yes | Yes | Yes | — | — |
| Node.js | Needs loader | Yes (ESM) | Yes (CJS) | Needs loader | Yes | Yes |
| **Turbopack** | Yes | **Broken** | No | Yes | Yes | Yes |
| webpack | Yes | Yes | Yes | Yes | Yes | Yes |
| Vite | Yes | Yes | Yes | Yes | Yes | Yes |
| Vitest | Yes | Yes | Yes | Yes | Yes | Yes |

Every tool supports `.mts` except Turbopack. Using `.mts` in a Turbopack
app breaks server/client boundary detection, causing Node.js builtins
(`fs`, `net`, `tls`) to leak into client bundles
([#82945](https://github.com/vercel/next.js/issues/82945)). TypeScript
itself warns: *"it is recommended not to use `.mts` files in bundler
projects for now."*

### What Next.js Apps Must Do (Temporary)

Until [#82945](https://github.com/vercel/next.js/issues/82945) is fixed,
use `.ts`/`.tsx` for all files inside Next.js app directories. The
`"type": "module"` field in `package.json` ensures ESM semantics —
Turbopack handles module resolution. **When the issue is fixed**,
Next.js apps should migrate back to `.mts`.

The `.mts` rule still applies to library packages consumed by the app
(built with `tsc`/`tsup`, not Turbopack). See
[typescript-monorepo-best-practices/explicit-file-extensions](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/explicit-file-extensions.md)
for the full workaround details, root cause analysis, and ESLint
configuration.

## Related Concepts

- [Path Alias Safety](path-alias-safety.md) — Import patterns for these files
- [ESLint Composition API](eslint-composition-api.md) — Config that enforces these rules
