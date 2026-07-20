---
okf_version: "0.1"
---

# TypeScript Monorepo Best Practices

A compounding knowledge base documenting hard-won conventions for TypeScript
monorepos: explicit file extensions, safe path aliases, ESLint composition,
pnpm + Nx orchestration, Vitest testing, package/application naming, and
code style. Each concept captures a specific failure mode — ambiguous `.ts`
extensions, `@/*` alias conflicts, brittle ESLint configs — and the practice
that prevents it.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [Explicit File Extensions](explicit-file-extensions.md) - Use `.mts` for ESM, `.cts` for CJS, `.tsx` for React, `.mjs`/`.cjs` for JS, `.d.ts` for declarations; ban ambiguous `.ts`/`.js`
* [Path Alias Safety](path-alias-safety.md) - No bare `@/*`; use explicit category aliases like `@/core/*`, `@/features/*`, `@/components/*`, `@/lib/*`, `@/utils/*`, `@/types/*`
* [ESLint Composition API](eslint-composition-api.md) - Three usage patterns for `@job-aide/tools-lint-eslint-config`: direct, with options, full composition
* [pnpm and Nx Monorepo](pnpm-nx-monorepo.md) - pnpm workspaces, `workspace:*`, Nx polyglot task orchestration (JS/Docker/Python/Rust), `only-allow pnpm`, **never `npx`/`bunx`/`yarn dlx` — always `pnpm dlx` or `pnpm exec`**
* [Vitest Testing](vitest-testing.md) - `.test.mts` extension, project-based testing (unit/integration), environment configuration
* [Package Naming Convention](package-naming-convention.md) - `packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language}`
* [Application Naming Convention](app-naming-convention.md) - `apps/{status}/{product-suite}/{app-name}/{platform}/{language}`
* [Code Style](code-style.md) - Double quotes, 2-space indent, semicolons, kebab-case, `type` over `interface`, `import type` for type-only imports
* [Monorepo Structure](monorepo-structure.md) - `active` vs `icebox`, `core`/`features`/`services`/`ui`/`tools` categories, platform (node/web/shared)
* [JavaScript and TypeScript Fundamentals](javascript-typescript-fundamentals.md) - ES modules, modern syntax, error handling, performance, security, JSDoc typing, import standards, config hygiene, tooling integration
