---
type: Practice
title: Path Alias Safety
description: Ban ambiguous @/* path alias in favor of explicit category-based aliases like @/core/*, @/features/* to prevent conflicts with npm scoped packages.
tags: [typescript, path-aliases, imports, eslint, npm, monorepo]
timestamp: 2026-07-17T00:00:00Z
---

# Path Alias Safety

## Failure Mode

The common `@/*` catch-all alias conflicts with npm scoped packages
(`@company/package` vs `@/utils`). IDEs and bundlers struggle to differentiate.
In monorepos, it's unclear if `@/lib/api` is a local file or workspace package.

## Practice

**Ban ambiguous aliases**:
- `@` (bare)
- `@/*` (too generic)

**Require explicit category-based aliases**:
- `@/core/*` — Core application code
- `@/features/*` — Feature modules
- `@/components/*` — UI components
- `@/utils/*` — Utility functions
- `@/lib/*` — Library code
- `@/types/*` — Type definitions

**Or project-specific prefix**:
- `@/job-aide/*` — Project-scoped alias
- `@/app/*` — Application-specific alias

### ESLint Enforcement

```ts
"no-restricted-imports": [
  "error",
  {
    patterns: [
      {
        group: ["@", "@/*"],
        message: "Don't use ambiguous '@' or '@/*' path alias..."
      }
    ]
  }
]
```

### Why Explicit Aliases

1. **Clear intent**: `@/components/button` is obviously a component
2. **No conflicts**: Never confused with `@radix-ui/button`
3. **Better tooling**: IDEs provide better autocomplete
4. **Monorepo safe**: Clear distinction between workspace packages and local files
5. **Maintainable**: Easier to refactor and reorganize code

## Related Concepts

- [Explicit File Extensions](explicit-file-extensions.md) — What these aliases point to
- [ESLint Composition API](eslint-composition-api.md) — Config that enforces these rules

## Citations

[1] `internal-docs/adr/adr-20251019002-path-alias-safety.md` — job-aide
