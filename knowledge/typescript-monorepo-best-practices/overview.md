---
type: Synthesis
title: TypeScript Monorepo Best Practices Overview
description: Synthesis of TypeScript monorepo conventions — explicit file extensions, safe path aliases, ESLint composition, pnpm + Nx, Vitest testing, package/app naming, code style, and monorepo structure.
tags: [typescript, monorepo, pnpm, nx, eslint, vitest, best-practices, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# TypeScript Monorepo Best Practices Overview

This bundle documents conventions for building and maintaining TypeScript
monorepos that are consistent, toolable, and safe for AI agents to edit. Each
concept was extracted from a real failure mode — ambiguous file extensions that
confuse ESM/CommonJS resolution, `@/*` aliases that conflict with npm scopes,
brittle ESLint configs that can't compose — and the practice that prevents it.

## The TypeScript Monorepo Lifecycle

```
file-extension → path-alias → eslint-config → package-manager → testing → naming → structure
       ↓              ↓             ↓               ↓             ↓         ↓        ↓
  explicit      category       composition    pnpm +       vitest    package  active/icebox
  .mts/.cts     @/core/*       @job-aide/     nx            .test.mts naming   categories
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| File extensions | [Explicit File Extensions](explicit-file-extensions.md) | ESM/CJS ambiguity, tooling resolution errors, mixed module system confusion |
| Path aliases | [Path Alias Safety](path-alias-safety.md) | `@/*` conflicts with npm scoped packages, unclear import intent |
| Linting | [ESLint Composition API](eslint-composition-api.md) | Copy-paste ESLint configs, untested plugin additions, inconsistent rule sets |
| Package management | [pnpm and Nx Monorepo](pnpm-nx-monorepo.md) | npm/yarn drift, non-deterministic installs, fragmented build system for polyglot projects |
| Testing | [Vitest Testing](vitest-testing.md) | `.test.ts` extension mismatch, unit/integration test conflation |
| Naming | [Package Naming Convention](package-naming-convention.md), [Application Naming Convention](app-naming-convention.md) | Inconsistent directory structure, unclear package status (active vs icebox) |
| Structure | [Monorepo Structure](monorepo-structure.md) | Packages scattered by app, no clear shared/core boundary |
| Style | [Code Style](code-style.md) | Quote/indent/style drift, `interface`/`type` inconsistency |
| Fundamentals | [JavaScript and TypeScript Fundamentals](javascript-typescript-fundamentals.md) | Missing JSDoc typing, unsafe error handling, config drift, import boundary violations |

## Scope

This bundle covers **TypeScript monorepo conventions** — file extensions, path
aliases, ESLint composition, pnpm + Nx, Vitest testing, naming
conventions, and monorepo structure. It does **not** cover:

- Framework-specific patterns (Next.js, NestJS, Express server setup) — those
  can be ingested as separate concepts.
- React component patterns beyond file extension conventions — see
  framework-specific bundles.
- CSS/Tailwind conventions — the `tools-css-config` and `tools-tailwind-config`
  packages cover these internally.
- Build tooling like esbuild/rollup/webpack — these are implementation choices
  subordinate to the monorepo conventions here.

## Relationship to Existing Project Assets

The job-aide monorepo is the primary source for this bundle:

- **`.devin/rules/typescript-rules.md`** — high-level rule file summarizing these
  conventions. This bundle provides the generalizable knowledge and rationale
  behind each rule.
- **`internal-docs/adr/`** — Architecture Decision Records documenting why
  explicit extensions (ADR-20251019001), safe aliases (ADR-20251019002), and
  ESLint composition (ADR-20251019003) were adopted.
- **`packages/active/tools/lint/eslint-config/typescript/`** — the ESLint config
  package implementing the composition API documented in
  [ESLint Composition API](eslint-composition-api.md).
- **`internal-docs/ARCHITECTURE.md`** — canonical monorepo structure and naming
  conventions.

## Sources

1. **job-aide** — `.devin/rules/typescript-rules.md`, `internal-docs/ARCHITECTURE.md`,
   and ADRs 20251019001, 20251019002, 20251019003, 20251106001, 20251106002,
   20260419001.
2. **job-aide** — `packages/active/tools/lint/eslint-config/typescript/docs/`
   (FILE-EXTENSION-RULES, PATH-ALIAS-RULES, API-REFERENCE, USAGE-EXAMPLES).
3. **job-aide** — Root `package.json`, `nx.json`, `pnpm-workspace.yaml`,
   `tsconfig.base.json`, and example app configurations.

See each concept's `# Citations` section for specific file paths.

## Compounding

New lessons from future TypeScript monorepo work — framework migrations, new
lint rules, package manager changes, testing patterns — should be filed as new
concept pages. The trigger for adding a concept is: a build resolution error, an
ESLint config conflict, a package manager edge case, or a tooling decision that
revealed a practice the bundle doesn't yet cover. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `typescript-strictness.md` — `strict` mode, `noImplicitAny`,
  `exactOptionalPropertyTypes`, incremental enablement
- `monorepo-dependency-boundaries.md` — preventing circular dependencies between
  `core`/`features`/`services` packages
- `changesets-releases.md` — versioning and publishing workspace packages
- `type-only-imports.md` — `import type` enforcement, barrel file performance

## Related Knowledge Bundles

- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
  — TypeScript data access patterns (Drizzle ORM, CQRS) used in data products.
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — security rules
  for credential detection, crypto usage, and container hardening that apply
  to TypeScript applications.
- [container-best-practices](../container-best-practices/overview.md) —
  Dockerfile and container packaging practices for Node.js/TypeScript services.

## Citations

[1] [job-aide typescript-rules.md](https://github.com/lrepo52/job-aide/blob/main/.devin/rules/typescript-rules.md) — project rule summary
[2] [job-aide ADR-20251019001](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019001-explicit-file-extensions.md) — explicit file extensions decision
[3] [job-aide ADR-20251019002](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019002-path-alias-safety.md) — path alias safety decision
[4] [job-aide ADR-20251019003](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019003-plugin-composition-api.md) — ESLint plugin composition API decision
