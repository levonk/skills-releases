---
type: Practice
title: Path Alias Safety — Ban Ambiguous @/* Aliases
description: No bare @/* path aliases; use explicit category-based aliases (@/core/*, @/features/*, @/components/*, @/utils/*, @/lib/*, @/types/*) or project-specific prefixes to avoid conflicts with npm scoped packages.
tags: [typescript, monorepo, path-aliases, imports, eslint, tsconfig]
timestamp: 2026-07-17T00:00:00Z
---

# Path Alias Safety — Ban Ambiguous @/* Aliases

## Failure Mode

Using `"@/*": ["./src/*"]` as a catch-all path alias in `tsconfig.json`. This
creates ambiguity and conflicts:

1. **Conflicts with npm scoped packages**: `@company/package` vs `@/utils` —
   which is an npm package and which is a local file?
2. **Import confusion**: Is `import { api } from "@/lib/api"` a local file or
   an npm package?
3. **Tooling issues**: IDEs and bundlers struggle to differentiate between
   scoped packages and path aliases.
4. **Monorepo problems**: Unclear if importing from a workspace package or a
   local file.
5. **Maintenance**: Hard to refactor when the alias meaning is unclear.

## Practice

**Ban ambiguous path aliases**:

- `@` (bare `@`)
- `@/*` (too generic, conflicts with npm scoped packages)

**Require explicit category-based aliases**:

```json
{
  "compilerOptions": {
    "paths": {
      "@/core/*": ["./src/core/*"],
      "@/features/*": ["./src/features/*"],
      "@/components/*": ["./src/components/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"]
    }
  }
}
```

**Or project-specific prefix**:

```json
{
  "compilerOptions": {
    "paths": {
      "@/job-aide/*": ["./src/*"],
      "@/app/*": ["./src/*"]
    }
  }
}
```

Actual npm scoped packages (`@radix-ui/*`, `@trpc/*`, `@prisma/client`) are
still allowed — the rule only affects path aliases, not real package imports.

## Enforcement

Enforced via `@job-aide/tools-lint-eslint-config` using ESLint's
`no-restricted-imports`:

```ts
"no-restricted-imports": [
  "error",
  {
    patterns: [
      {
        group: ["@", "@/*"],
        message: "Don't use ambiguous '@' or '@/*' path alias. Use explicit category-based aliases like @/core/*, @/features/*, etc."
      }
    ]
  }
]
```

## Monorepo Distinction

In a monorepo, the distinction becomes critical:

- `@job-aide/*` = workspace packages (actual npm scoped packages)
- `@/app/*` = local app files (path aliases)

This makes it immediately obvious whether an import crosses package boundaries.

## Rationale

1. **Clear intent**: `@/components/button` is obviously a component.
2. **No conflicts**: Never confused with `@radix-ui/button`.
3. **Better tooling**: IDEs provide better autocomplete.
4. **Monorepo safe**: Clear distinction between workspace packages and local
   files.
5. **Maintainable**: Easier to refactor and reorganize code by category.

## Migration

1. Update `tsconfig.json` paths — remove `@/*`, add category-based aliases.
2. Update build tool configs (Vite `resolve.alias`, Webpack `resolve.alias`).
3. Migrate imports — find with `rg "from ['\"]@/" --type ts`, update manually
   or via codemod.
4. Enable ESLint rule with `warn` first, then upgrade to `error`.

## Related Concepts

- [Monorepo Structure](/monorepo-structure.md) — how path aliases map to the
  package directory layout.
- [ESLint Composition API](/eslint-composition-api.md) — how to configure the
  `no-restricted-imports` rule via the shared config.

## Citations

[1] [ADR-20251019002: Ban Ambiguous @ Path Alias](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019002-path-alias-safety.md)
[2] [PATH-ALIAS-RULES.md](https://github.com/levonk/job-aide/blob/main/packages/active/tools/lint/eslint-config/typescript/docs/PATH-ALIAS-RULES.md)
[3] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — Path Aliases section
[4] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — TypeScript Path Aliases section
