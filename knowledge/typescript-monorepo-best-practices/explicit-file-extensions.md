---
type: Practice
title: Explicit File Extensions for TypeScript Modules
description: Use .mts for ESM, .cts for CJS, .tsx for React, .mjs/.cjs for JS, .d.ts for types; ban ambiguous .ts/.js extensions that hide the module system behind package.json type.
tags: [typescript, monorepo, file-extensions, esm, commonjs, eslint, module-system]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-08-04"
sources:
  - id: adr-20251019001-explicit-file-extensions-for-typescript-modules
    resource: https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019001-explicit-file-extensions.md
    title: 'ADR-20251019001: Explicit File Extensions for TypeScript Modules'
  - id: file-extension-rules-md
    resource: https://github.com/levonk/job-aide/blob/main/packages/active/tools/lint/eslint-config/typescript/docs/FILE-EXTENSION-RULES.md
    title: 'FILE-EXTENSION-RULES.md'
  - id: typescript-rules-md
    resource: https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md
    title: 'typescript-rules.md — File Extensions section'
  - id: architecture-md
    resource: https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md
    title: 'ARCHITECTURE.md — TypeScript File Extensions section'
  - id: turbopack-extension-alias-issue-82945
    resource: https://github.com/vercel/next.js/issues/82945
    title: 'Next.js #82945: Turbopack lacks webpack resolve.extensionAlias parity for .mjs→.mts'
  - id: turbopack-extension-alias-pr-92685
    resource: https://github.com/vercel/next.js/pull/92685
    title: 'Next.js PR #92685: Turbopack resolveExtensionAlias config option'
  - id: typescript-mts-bundler-warning
    resource: https://www.typescriptlang.org/docs/handbook/modules/reference.html#module-resolution-with-bundler
    title: 'TypeScript docs: "it is recommended not to use .mts files in bundler projects for now"'
---

# Explicit File Extensions for TypeScript Modules

## Failure Mode

Defaulting to `.ts` and `.js` file extensions because "that's what TypeScript
uses". These extensions are **ambiguous** — their module system (ESM vs
CommonJS) depends on the nearest `package.json` `type` field. In a monorepo
with mixed module systems, this causes:

- **Unclear module system**: Is `utils.ts` ESM or CommonJS? You must open
  `package.json` to find out.
- **Tooling confusion**: Some tools don't respect `package.json` `type`.
- **Mixed module systems**: Can't safely mix ESM and CommonJS in the same
  package.
- **Import errors**: Accidentally using `require()` in ESM or `import` in
  CommonJS.
- **Monorepo complexity**: Different packages may have different `type`
  settings, so the same extension means different things in different packages.

## Practice

Use **explicit file extensions that indicate module system**:

| Extension | Use For | Module System |
|-----------|---------|---------------|
| `.mts` | TypeScript ESM modules | ESM |
| `.cts` | TypeScript CommonJS modules | CommonJS |
| `.tsx` | React components with JSX | ESM |
| `.mjs` | JavaScript ESM modules | ESM |
| `.cjs` | JavaScript CommonJS modules | CommonJS |
| `.d.ts` | Type declarations | N/A |

**Ban ambiguous extensions**:

- `.ts` files (except `.d.ts`, `.config.ts`)
- `.js` files (except `.config.js`)

Config files (`.config.ts`, `.config.js`) are exempted for tool compatibility.
Test files use `.test.mts` (not `.test.ts`) — see
[Vitest Testing](/vitest-testing.md).

## Enforcement

Enforced via `@job-aide/tools-lint-eslint-config` with these ESLint rules:

- `job-aide/ban-ambiguous-ts` — Flags `.ts` files
- `job-aide/ban-ambiguous-js` — Flags `.js` files
- `job-aide/mts-must-be-esm` — Enforces ESM syntax in `.mts` (no `require()`, no `module.exports`)
- `job-aide/cts-must-be-commonjs` — Enforces CommonJS syntax in `.cts` (no `import`, no `export`)
- `job-aide/react-must-use-tsx` — Requires `.tsx` for JSX
- `job-aide/test-files-explicit-extension` — Requires `.test.mts` for tests
- `job-aide/type-declarations-standard-extension` — Requires `.d.ts` (not `.d.mts`)

## Rationale

1. **Self-documenting**: File extension immediately shows module system.
2. **Tool-agnostic**: Works regardless of `package.json` `type` field.
3. **Mix module systems**: Can have both ESM and CommonJS in the same package.
4. **Prevent errors**: ESLint catches module system mismatches at lint time.
5. **Future-proof**: Aligns with Node.js ESM best practices.

TypeScript natively supports `.mts`/`.cts` since v4.7. Node.js has supported
`.mjs`/`.cjs` since v12. This is a linting/convention decision, not a runtime
requirement.

## Migration

```bash
# Rename .ts to .mts (excluding exceptions)
find src -name "*.ts" ! -name "*.d.ts" ! -name "*.config.ts" ! -name "*.test.ts" \
  -exec sh -c 'mv "$1" "${1%.ts}.mts"' _ {} \;

# Rename .test.ts to .test.mts
find src -name "*.test.ts" \
  -exec sh -c 'mv "$1" "${1%.test.ts}.test.mts"' _ {} \;
```

Roll out in phases: enable rules with `warn` first, migrate files, then
upgrade to `error`.

## Forced Workaround: Turbopack (Next.js)

**`.ts` is never the right answer.** The practice above is correct —
`.ts` is ambiguous and should be banned in favor of `.mts`. However,
**Turbopack** (Next.js's bundler, default since Next.js 15 for dev and
Next.js 16 for production builds) is broken: it does not properly
support `.mts` files. Next.js applications are **forced** to use `.ts`
until the Turbopack bug is fixed. This is tech debt, not an endorsed
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

Every tool supports `.mts` except Turbopack. There is no principled
reason to use `.ts` in a Next.js app — only a broken tool forcing it.

### Root Cause

Turbopack's module resolution does not have parity with webpack's
`resolve.extensionAlias` for `.mjs`→`.mts` mapping
([#82945](https://github.com/vercel/next.js/issues/82945)). A
`resolveExtensionAlias` config option was added in PR
[#92685](https://github.com/vercel/next.js/pull/92685) but is not
enabled by default and does not fully resolve the issue.

When `.mts` files are used in a Next.js/Turbopack app:

1. **Server/client boundary detection breaks**: Turbopack fails to
   correctly identify `"use server"` / `"use client"` boundaries in
   `.mts` files, causing Node.js-only modules (`fs`, `net`, `tls`,
   `perf_hooks`) to leak into client bundles.
2. **Module resolution failures**: Turbopack does not try `.mts` for
   extensionless imports (unlike `.ts`), requiring every import to
   include the explicit `.mts` extension — which then breaks Turbopack's
   server/client boundary tracking.
3. **TypeScript itself warns against this**: The TypeScript docs
   explicitly state: *"it is recommended not to use `.mts` files in
   bundler projects for now"* (see
   [Module Resolution with Bundler](https://www.typescriptlang.org/docs/handbook/modules/reference.html#module-resolution-with-bundler)).

### What Next.js Apps Must Do (Temporary)

Until [#82945](https://github.com/vercel/next.js/issues/82945) is fixed,
Next.js apps use `.ts`/`.tsx` instead of `.mts`:

| File Type | Extension | Why |
|-----------|-----------|-----|
| Server components / routes | `.ts` | Turbopack resolves and tree-shakes correctly |
| Client components | `.tsx` | No `.mtsx` exists — `.tsx` is the only JSX TypeScript extension |
| Server actions | `.ts` | Turbopack tracks `"use server"` boundary |
| Test files | `.test.ts` / `.test.tsx` | Vitest resolves `.ts` natively |
| Config files | `.config.ts` / `.config.mjs` | Tool compatibility |

The `package.json` `"type": "module"` field ensures `.ts` files are
treated as ESM — Turbopack and Next.js handle this correctly. The
ambiguity that `.mts` solves in library/CLI packages does not apply
here because the bundler controls module resolution.

**When [#82945](https://github.com/vercel/next.js/issues/82945) is
fixed**, Next.js apps should migrate back to `.mts` to align with this
practice. Track the issue and plan the migration.

### Where the Workaround Does NOT Apply

The `.mts` rule still applies to:
- **Library packages** consumed by the Next.js app (e.g.,
  `packages/active/ui/`, `packages/active/integrations/`) — these are
  built with `tsc` or `tsup`, not Turbopack, and benefit from explicit
  extensions.
- **Node.js CLI tools and scripts** — no bundler involved, `.mts`
  ensures correct module system.
- **Non-Next.js web frameworks** that use webpack or Vite — these have
  `resolve.extensionAlias` support or native `.mts` resolution.

### Enforcement

The `job-aide/ban-ambiguous-ts` ESLint rule must be configured with a
glob exception for Next.js app directories:

```js
// eslint.config.mjs
{
  files: ["apps/**/app/**", "apps/**/lib/**", "apps/**/components/**"],
  rules: {
    "job-aide/ban-ambiguous-ts": "off",
  },
}
```

Or scope the rule to library packages only:

```js
{
  files: ["packages/**"],
  rules: {
    "job-aide/ban-ambiguous-ts": "error",
  },
}
```

## Related Concepts

- [ESM over CommonJS](/esm-over-commonjs.md) — the module system preference that
  makes `.mts` the default extension.
- [Code Style](/code-style.md) — kebab-case filenames enforced alongside
  extension rules.
- [ESLint Composition API](/eslint-composition-api.md) — how to enable the
  file-extension rules via the shared config.


