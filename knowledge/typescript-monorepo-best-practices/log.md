# Directory Update Log

## 2026-07-18

* **Rule**: Added a hard "NEVER `npx`/`bunx`/`yarn dlx` — always `pnpm dlx` or
  `pnpm exec`" section to [pnpm-nx-monorepo.md](pnpm-nx-monorepo.md) with a
  decision table and before/after examples. The rule is absolute on the host
  and inside pnpm workspaces — no exceptions, including when contributing to
  upstream projects that use bun or yarn. **Container exception**: inside a
  Docker container, use `bunx <pkg>` and never install pnpm in a container.
  Replaced every prescriptive `npx`/`bunx` reference in this bundle with
  `pnpm dlx` (ad-hoc packages) or `pnpm exec` (workspace binaries). Added
  matching rows to the canonical tech-stack table include
  (`src/current/includes/tech-stack-table.md.tmpl`) — one for host/pnpm-workspace
  use, one for container use — so every overview that includes it inherits
  both rules. Updated [index.md](index.md) to surface the rule in the concept
  blurb.

## 2026-07-18

* **DRY**: Converted [overview.md](overview.md.tmpl) to `overview.md.tmpl` and
  added `{{{ include "includes/tech-stack-table.md" . }}}` so the canonical
  tech-stack choices table (Nx, pnpm, Vitest, ESLint+antfu, no Prettier/Turbo/
  Jest/Biome) is inlined from a single source of truth at
  `src/current/includes/tech-stack-table.md.tmpl`. When a choice changes, update
  that one include file and every overview that includes it stays in sync at
  build time. The build output remains `overview.md` (`.tmpl` stripped).

## 2026-07-17

* **Ingest**: Ingested ADR-20260419001 (Use Nx for Monorepo Build Orchestration),
  which supersedes ADR-20251106001 (pnpm + Turborepo). Renamed
  [pnpm-turborepo-monorepo.md](pnpm-nx-monorepo.md) →
  [pnpm-nx-monorepo.md](pnpm-nx-monorepo.md) and rewrote it to document Nx as
  the unified polyglot build orchestrator (JavaScript, Docker, Python, Rust),
  keeping pnpm as the package manager. Updated [overview.md](overview.md),
  [index.md](index.md), and cross-references in
  [vitest-testing.md](vitest-testing.md),
  [app-naming-convention.md](app-naming-convention.md), and
  [package-naming-convention.md](package-naming-convention.md) to reflect the
  turbo→nx migration.

## 2026-07-17

* **Update**: Added [monorepo-structure.md](monorepo-structure.md) to complete the concept pages referenced in [index.md](index.md).

## 2026-07-17

* **Initialization**: Created the `typescript-monorepo-best-practices` knowledge bundle as an OKF v0.1 knowledge base, sourced from real findings in the job-aide monorepo.
* **Creation**: Established [index.md](index.md) directory listing and [overview.md](overview.md) synthesis covering the full TypeScript monorepo practice set.
* **Creation**: Added 8 concept pages sourced from job-aide `.devin/rules`, `internal-docs/adr`, and ESLint config documentation.
  - [explicit-file-extensions.md](explicit-file-extensions.md) — `.mts`/`.cts`/`.tsx`/`.mjs`/`.cjs`/`.d.ts` usage; banned ambiguous `.ts` and `.js`
  - [path-alias-safety.md](path-alias-safety.md) — explicit category-based aliases instead of bare `@/*`
  - [eslint-composition-api.md](eslint-composition-api.md) — three patterns for `@job-aide/tools-lint-eslint-config`
  - [pnpm-nx-monorepo.md](pnpm-nx-monorepo.md) — pnpm workspaces, `workspace:*`, Nx polyglot task orchestration (originally Turborepo, migrated per ADR-20260419001)
  - [vitest-testing.md](vitest-testing.md) — `.test.mts` extension, project-based unit/integration testing
  - [package-naming-convention.md](package-naming-convention.md) — `packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language}`
  - [app-naming-convention.md](app-naming-convention.md) — `apps/{status}/{product-suite}/{app-name}/{platform}/{language}`
  - [code-style.md](code-style.md) — double quotes, 2-space indent, semicolons, kebab-case, `type` over `interface`
  - [monorepo-structure.md](monorepo-structure.md) — active vs icebox, core/features/services/ui/tools categories, node/web/shared platforms
