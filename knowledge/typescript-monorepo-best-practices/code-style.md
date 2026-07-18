---
type: Practice
title: Code Style — Double Quotes, Semicolons, Type Over Interface
description: Enforce double quotes, 2-space indentation, semicolons, kebab-case filenames, prefer type over interface, and use import type for type-only imports across all TypeScript projects.
tags: [typescript, monorepo, code-style, formatting, eslint, conventions]
timestamp: 2026-07-17T00:00:00Z
---

# Code Style — Double Quotes, Semicolons, Type Over Interface

## Failure Mode

Allowing each developer or package to choose its own code style. Problems:

1. **Inconsistent diffs**: Formatting changes dominate PRs, hiding real
   changes.
2. **Cognitive overhead**: Reading code requires switching between style
   conventions.
3. **Merge conflicts**: Different formatting in the same file causes
   unnecessary conflicts.
4. **Tooling fragmentation**: Each package configures its own formatter/linter
   differently.

## Practice

All TypeScript projects **must** follow these style rules:

### Formatting

- **Double quotes** (`"`) not single quotes (`'`)
- **2-space indentation**
- **Semicolons** required

### Filenames

- **kebab-case** for all filenames (except `README.md`, `LICENSE`, etc.)
- Enforced via `unicorn/filename-case` ESLint rule

### Type Definitions

- **Prefer `type` over `interface`** for type definitions
- **Use `import type`** for type-only imports

```ts
// ✅ Good
import type { User } from "@/types/user";

export type UserProfile = {
  id: string;
  name: string;
};

// ❌ Bad — interface instead of type
export interface UserProfile {
  id: string;
  name: string;
}

// ❌ Bad — missing import type
import { User } from "@/types/user";
```

### Enforcement

All style rules are enforced via `@job-aide/tools-lint-eslint-config`, which
builds on `@antfu/eslint-config`. The shared config applies these rules
consistently across the entire monorepo.

## Rationale

1. **Consistency**: A single style across the monorepo eliminates formatting
   debates and reduces diff noise.
2. **Double quotes**: Aligns with Prettier defaults and most TypeScript
   ecosystem tooling.
3. **2-space indent**: Common in TypeScript ecosystems; reduces horizontal
   scrolling in nested code.
4. **Semicolons**: Prevents ASI (Automatic Semicolon Insertion) hazards.
5. **kebab-case filenames**: Consistent with Unix conventions and avoids
   case-sensitivity issues across operating systems.
6. **`type` over `interface`**: More flexible (unions, intersections,
   conditional types) and consistent with a functional style.
7. **`import type`**: Enables better tree-shaking and clearly separates
   type-only imports from value imports.

## Related Concepts

- [ESLint Composition API](/eslint-composition-api.md) — the config that
  enforces these style rules.
- [Explicit File Extensions](/explicit-file-extensions.md) — kebab-case
  filenames work alongside explicit extensions (e.g., `user-profile.mts`).
- [ESM over CommonJS](/esm-over-commonjs.md) — `import type` is an ESM
  feature.

## Citations

[1] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — Code Style section
[2] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — ESLint Configuration section
[3] [USAGE-EXAMPLES.md](https://github.com/levonk/job-aide/blob/main/packages/active/tools/lint/eslint-config/typescript/docs/USAGE-EXAMPLES.md)
[4] [@antfu/eslint-config](https://github.com/antfu/eslint-config) — base config
