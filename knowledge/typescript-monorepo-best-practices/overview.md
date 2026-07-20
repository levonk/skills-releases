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

## Canonical Tech-Stack Choices

The following table is the single source of truth for tech-stack choices across
this bundle. Individual concept pages deep-dive on the rationale; this table is
kept in sync via the templater at build time.

> **Single source of truth.** When a choice changes, update this table once.
> Every knowledge file that includes it stays in sync automatically at build
> time. Do not restate these choices in individual knowledge files — include
> this table or link to it instead.
>
> This table records the *what* — use this, don't use this, with exceptions
> where they matter. For the *why* (decision process, risk hierarchy,
> alternatives considered, timeline estimates), see the footnotes at the bottom.

| Category | Concern | Use | Don't use | Exceptions |
|----------|---------|-----|-----------|------------|
| build | Build orchestrator | **Nx** | Turborepo, Bazel, Pants | — |
| build | Task runner | **just** (justfile) | Makefiles, npm scripts, custom shell scripts | — |
| build | Development environment (system tools) | **devbox** (Nix-backed) + direnv | brew/apt/system npm/pip for system tools, raw Nix flakes, mise | Language-native package managers (pnpm/cargo/uv/pip) remain canonical for language libraries — never install language deps via devbox |
| node | Package manager | **pnpm** | npm, yarn, bun | — |
| node | Ad-hoc package execution (host / pnpm workspace) | **`pnpm dlx <pkg>`** (for packages not installed) or **`pnpm exec <cmd>`** (for workspace-installed binaries) | `npx`, `bunx`, `yarn dlx`, `bun x` | None — `pnpm dlx`/`pnpm exec` always, even when contributing to upstream projects that use a different package manager |
| node | Test runner (TypeScript) | **Vitest** | Jest, Mocha/Chai, Playwright Test Runner | Playwright is still used for E2E browser automation — just not as the primary test runner |
| node | Linter | **ESLint** (`@antfu/eslint-config` + `@job-aide/tools-lint-eslint-config`) | Biome, XO | — |
| node | Formatter | **ESLint stylistic rules** (via antfu) — no separate formatter | Prettier, Biome | — |
| node | ORM (TypeScript) | **Drizzle ORM** | Prisma, Kysely, raw SQL | — |
| python | Ad-hoc package execution (Python, packages) | **`uvx <pkg>`** | `pip install` at runtime, `python -m pip install` in scripts, `pipx run` | Use `uvx` for one-off package execution; `uv run --script` for PEP 723 inline-metadata scripts. When `uv` is not on PATH, resolve via `cli-tool-discovery.sh --runner python` and follow the `recommendation` (add to devbox.json, or fall back to `pip install` + `python3` when no `devbox.json` exists) |
| python | Ad-hoc script execution (Python, PEP 723) | **`uv run --script <file>`** | `python3 <file>` (when deps are pre-installed), `pip install` + `python3 <file>` | The PEP 723 `# /// script` block is a comment to `python3`, so `python3 script.py` works if deps are already installed. `uv run --script` provisions deps automatically. See `python-services-practices/standalone-scripts.md` |
| python | Python orchestration | **nox** | Bazel, Pants | — |
| rust | Ad-hoc package execution (Rust) | **`cargo binstall -y <pkg>`** (prebuilt binaries) | `cargo install <pkg>` (source build, slow), `rustup component add` | `cargo binstall` fetches prebuilt binaries — much faster than `cargo install`. Use `cargo install` only when binstall has no package for the target. Resolve via `cli-tool-discovery.sh --runner rust` |
| go | Ad-hoc package execution (Go) | **`go install <pkg>@latest`** | `go get` (deprecated for binaries), manual `git clone` + `go build` | `go install <pkg>@version` is the canonical way to install a Go binary. Resolve via `cli-tool-discovery.sh --runner go` |
| shell | Test runner (shell / bash) | **bats-core** (`bats` executable, `bats-core` + `bats-support` + `bats-assert` + `bats-file` libraries) | Plain shell scripts masquerading as tests, `shunit2`, `shellcheck` used as a test runner, hand-rolled `test_*.sh` scripts with `set -e` and assertions | Ad-hoc one-line smoke checks (`script.sh && echo ok`) inside a Justfile are fine for smoke commands but do not count as a test suite; promote them to a `bats` file when they grow past one assertion |
| shell | Linter (shell / bash) | **shellcheck** (`shellcheck -x` for sourced scripts) | `sh -n` (syntax-only, no semantic checks), ignoring shell issues, relying on `set -e` alone | `shellcheck` is a static analyzer — it catches common shell bugs (unquoted variables, word-splitting, SC2086, etc.) but does not execute code. Not a replacement for `bats` behavior tests. Use `-x` to follow sourced scripts |
| shell | Formatter (shell / bash) | **shfmt** (default: `shfmt -i 2 -ci -bn` — 2-space indent, case indent, binary-next-line) | hand-rolling indentation, `bash -n` as a format check, editor-specific formatting | `shfmt` enforces consistent formatting (indentation, line breaks, spacing). Pairs with `shellcheck` — `shfmt` for format, `shellcheck` for semantics. Not a test runner |
| container | Ad-hoc package execution (inside a container) | **`bunx <pkg>`** | `npx`, `pnpm dlx`, `pnpm exec`, `yarn dlx` | Containers use bun as their runtime — never install pnpm in a container. Applies to Dockerfiles, container entrypoint scripts, and any script that runs inside a container image |
| container | Container system packages | **Container's native package manager** (`apk` on Alpine, `apt-get` on Debian slim) or **bare container** (`scratch`/`distroless`) for static binaries | Installing system packages via npm/pip/cargo at runtime; baking dev toolchains into runtime images | Dev toolchains (`build-base`, gcc, make) belong in the builder stage only |
| container | Container runtime tooling | **Docker** — OrbStack on x86_64 Darwin, Docker Desktop on Windows, `dockerd` on Linux; platform-native on aarch64 Darwin | podman, colima | — |
| container | Container orchestration (local dev) | **k3s** | kind, minikube, microk8s, full k8s | — |
| container | Container orchestration (production) | **k8s** (full Kubernetes) | k3s, Docker Swarm, Nomad | — |
| deployment | Service deployment & configuration | **Ansible** (`community.docker` modules) | `docker compose` for deployment | `docker-compose.yml` is valid for sharing a deployable service externally (outside the org) where the recipient doesn't have the Ansible overhead |
| security | Auth provider | **better-auth** (passkey / organization / two-factor plugins) | Supabase Auth, Auth0, Clerk, Lucia | Auth method preference: passkey-first > passkey > Google/Apple OAuth > local password + 2FA > local password only; email always collected for recovery |
| data | Database (SaaS / multi-tenant OLTP) | **Supabase Postgres** with RLS via per-request session variables | PocketBase, SQLite-per-tenant, shared-schema Postgres without RLS, per-tenant Postgres clusters | — |
| data | Analytics / ETL sidecar | **Per-tenant SQLite export + DuckDB** | PocketBase as OLTP, direct analytics on production Postgres, per-tenant Postgres replicas | — |
| tooling | Ad-hoc runner resolution (all ecosystems) | **`cli-tool-discovery.sh --runner <python\|node\|rust\|go>`** | Hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install` in scripts | The runner mode pairs binary resolution with the canonical invocation. Returns JSON with `script`, `package`, `fallback`, and `recommendation` fields. Single source of truth for "how do I invoke an ad-hoc command in ecosystem X?" — `detect-package-manager.sh` delegates to it for the `runner` field |
| tooling | Code intelligence (text search) | **ripgrep** (fresh, no index) + **xgrep** (repeated queries, trigram index) + **fzf** (interactive fuzzy) | grep, find, skim | Per ADR-20260520001 §6×2 matrix rows 1, 4, 5 (filename, exact, fuzzy). ripgrep for one-off fresh searches; xgrep for 2–46× faster repeated queries; fzf for interactive selection |
| tooling | Code intelligence (semantic search) | **semble_rs** (hybrid BM25 + Model2Vec, ephemeral, single Rust binary) | qmd, Sourcegraph Cody | Per ADR-20260520001 §6. Ephemeral index rebuilt every run — zero config. Also provides `digest` for build/CI log compression (-99%) and `tree` for token-efficient codebase trees |
| tooling | Code intelligence (AST: indexed) | **CodeGraph** (single-project, auto-sync) + **Graphify** (multimodal: code + PDFs/docs/video) + **GitNexus** (multi-repo impact analysis) — run together per workload | Standardizing on one indexed AST tool for all workloads (each wins only 2 of 6 rounds — no universal winner; see ADR-20260520001 v3.0.0), building a unified wrapper (hides meaningful capability differences) | Per ADR-20260520001 v3.0.0 §4 AST Search / §5 AST Insights, "With index" row. These are indexed AST tools (persistent node/edge graph + MCP), not a separate modality. CodeGraph (MIT, file watcher 2s, single MCP tool, dynamic dispatch) for fresh single-project work. Graphify (MIT, Python, 36 langs, multimodal) when docs/PDFs/video link to code. GitNexus (⚠️ PolyForm NC — commercial license required for business use, 17 MCP tools, cross-repo) for multi-repo impact. See `software-architecture-essentials/indexed-ast-tools.md` for the sub-decision tree |

### Notable "considered and rejected" choices

- **Turborepo** — superseded by ADR-20260419001. JS-only; cannot cache or orchestrate Docker, Python, or Rust builds.
- **Jest** — replaced by Vitest per ADR-20251106002. Slower in ESM, complex TS/ESM config.
- **Plain shell scripts as tests** — rejected in favor of bats-core. Hand-rolled `test_*.sh` scripts with `set -e` and manual assertions give no fixture isolation, no parallel execution, no TAP output, no `setup`/`teardown` hooks, and silently pass on skipped assertions. bats-core provides all of these, is a single portable bash script with no runtime deps, and emits TAP 13 output that CI runners and `bats-reporter` consume natively. Use `shellcheck`/`shfmt` for lint/format, `bats` for behavior.
- **`sh -n` as a lint/format substitute** — rejected. `sh -n` only checks syntax (parse errors), not semantics — it misses unquoted variables (SC2086), word-splitting, unsafe globs, and the hundreds of other issues `shellcheck` catches. It also does not format. `shellcheck` for semantics + `shfmt` for formatting is the canonical pair; `sh -n` is a smoke check, not a lint pipeline.
- **Prettier** — not used. Formatting is enforced through ESLint (antfu stylistic rules).
- **Biome** — rejected. ESLint composition API and plugin ecosystem (Drizzle, Tailwind, Prisma, antfu framework support) cannot be replaced by Biome's static JSON config.
- **podman** — rejected after real-world use. No working molecule driver in nixpkgs; molecule can't find podman binary in Ansible's restricted PATH; `community.docker` modules target the Docker Engine API.
- **Raw Nix flakes for dev environments** — superseded by ADR-20251226001 (devbox + direnv). Too verbose; learning curve too steep for non-Nix-expert developers.
- **brew/apt/system pip/system npm for system tools** — rejected for host dev environments (host pollution, drift, broken reproducibility). Still used **inside containers** (apk/apt-get) where the container's native package manager is correct.
- **Supabase Auth** — rejected in favor of better-auth. No passkey-first onboarding; passkey API beta as of April 2026; tightly coupled to Postgres via `auth.uid()` in RLS policies (migration = end-user-impact risk); MAU billing above 50k.
- **PocketBase** — rejected as primary OLTP and as a free-tier backend. Collection rules are app-layer filters, not storage-engine RLS (unacceptable for financial data with FTC Safeguards exposure). SQLite remains in the stack as the **analytics export format**, not as a live backend.
- **Standardizing on one indexed AST tool** — rejected per ADR-20260520001 v3.0.0. The three contenders (CodeGraph, Graphify, GitNexus) each win exactly two of six rounds (index freshness, content breadth, dynamic dispatch, query power, multi-repo support, visualization) — there is no universal winner. Defaulting to CodeGraph for a multi-repo microservices project loses GitNexus's cross-repo blast radius; defaulting to GitNexus for a single-project zero-setup workflow loses CodeGraph's auto-sync; defaulting to either for a project with architecture docs/PDFs loses Graphify's multimodal coverage. The three do not conflict at runtime and can be run together. GitNexus's PolyForm Noncommercial license is a separate consideration — procure a commercial license before indexing proprietary code for business use.

> **Decision process & rationale** for these choices — including the full risk
> hierarchy, alternatives considered, and AI + human timeline estimate format
> that drove decisions like better-auth-from-day-one over a "use Supabase Auth
> now, migrate later" path — live in the
> [software-architecture-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/overview.md)
> and
> [api-auth-payment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/overview.md)
> knowledge bundles. For code knowledge graph tool selection specifically, see
> [code-knowledge-graph-tools.md](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/code-knowledge-graph-tools.md).
> This table records the *what*; those bundles record the *why*.


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

- [data-engineering-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/data-engineering-best-practices/overview.md)
  — TypeScript data access patterns (Drizzle ORM, CQRS) used in data products.
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — security rules
  for credential detection, crypto usage, and container hardening that apply
  to TypeScript applications.
- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) —
  Dockerfile and container packaging practices for Node.js/TypeScript services.

## Citations

[1] [job-aide typescript-rules.md](https://github.com/lrepo52/job-aide/blob/main/.devin/rules/typescript-rules.md) — project rule summary
[2] [job-aide ADR-20251019001](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019001-explicit-file-extensions.md) — explicit file extensions decision
[3] [job-aide ADR-20251019002](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019002-path-alias-safety.md) — path alias safety decision
[4] [job-aide ADR-20251019003](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251019003-plugin-composition-api.md) — ESLint plugin composition API decision
