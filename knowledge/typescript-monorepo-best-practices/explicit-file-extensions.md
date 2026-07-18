---
type: Practice
title: Explicit File Extensions for TypeScript Modules
description: Use .mts for ESM, .cts for CJS, .tsx for React, .mjs/.cjs for JS, .d.ts for types; ban ambiguous .ts/.js extensions that hide the module system behind package.json type.
tags: [typescript, monorepo, file-extensions, esm, commonjs, eslint, module-system]
timestamp: 2026-07-17T00:00:00Z
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

- `.ts` files (except `.d.ts`, `.config.ts`, `.test.ts`)
- `.js` files (except `.config.js`)

Config files (`.config.ts`, `.config.js`) are exempted for tool compatibility.

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

## Related Concepts

- [ESM over CommonJS](/esm-over-commonjs.md) — the module system preference that
  makes `.mts` the default extension.
- [Code Style](/code-style.md) — kebab-case filenames enforced alongside
  extension rules.
- [ESLint Composition API](/eslint-composition-api.md) — how to enable the
  file-extension rules via the shared config.

## Citations

[1] [ADR-20251019001: Explicit File Extensions for TypeScript Modules](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019001-explicit-file-extensions.md)
[2] [FILE-EXTENSION-RULES.md](https://github.com/levonk/job-aide/blob/main/packages/active/tools/lint/eslint-config/typescript/docs/FILE-EXTENSION-RULES.md)
[3] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — File Extensions section
[4] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — TypeScript File Extensions section
