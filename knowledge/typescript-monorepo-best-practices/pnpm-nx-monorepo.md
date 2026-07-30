---
type: Practice
title: pnpm and Nx for Monorepo Management
description: Standardize on pnpm workspaces with workspace:* dependencies, catalog: for external dependency versions, and Nx for polyglot task orchestration; enforce only-allow pnpm to prevent phantom dependencies and enable unified caching across JavaScript, Docker, Python, and Rust.
tags: [typescript, monorepo, pnpm, nx, build-system, workspaces, catalogs, caching, polyglot]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-23"
  last-used: "2026-07-23"
sources:
  - id: adr-20260419001-use-nx-for-monorepo-build-orchestration
    resource: https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md
    title: 'ADR-20260419001: Use Nx for Monorepo Build Orchestration'
  - id: adr-20251106001-use-pnpm-and-turborepo-for-monorepo-management-superseded
    resource: https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251106001-pnpm-and-turborepo.md
    title: 'ADR-20251106001: Use pnpm and Turborepo for Monorepo Management (superseded)'
  - id: architecture-md
    resource: https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md
    title: 'ARCHITECTURE.md — Package Management section'
  - id: typescript-rules-md
    resource: https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md
    title: 'typescript-rules.md — "Must use the pnpm package manager"'
  - id: pnpm
    resource: https://pnpm.io/
    title: 'pnpm'
  - id: pnpm-catalogs
    resource: https://pnpm.io/catalogs/
    title: 'pnpm Catalogs'
  - id: nx
    resource: https://nx.dev/
    title: 'Nx'
  - id: nx-vs-turborepo-comparison
    resource: https://nx.dev/concepts/turbo-and-nx
    title: 'Nx vs Turborepo Comparison'
---

# pnpm and Nx for Monorepo Management

## Failure Mode

Using `npm`, `yarn`, or `bun` in a monorepo without strict dependency
management, and using a JavaScript-only build orchestrator (Turborepo) when the
monorepo has grown to include Docker, Python, and Rust projects. Problems:

1. **Phantom dependencies**: Packages access modules they don't declare in
   `package.json` because of flat `node_modules` hoisting.
2. **Inconsistent tooling**: Some packages use `bun`, others `npm`, creating
   confusion and duplicated effort.
3. **Slow CI**: No build caching — every CI run rebuilds everything from
   scratch.
4. **Disk space bloat**: Flat `node_modules` duplicates dependencies across
   packages.
5. **Dependency conflicts**: Different packages accidentally resolve to
   different versions of the same dependency.
6. **Version drift across packages**: The same external dependency (e.g.
   `react`) is pinned to different versions in different `package.json` files.
   Upgrading requires editing every file (merge conflicts on every bump), and
   no mechanism prevents two packages from drifting apart over time. The
   misconception that `"*"` "inherits from root" makes this worse — `"*"`
   resolves to the latest registry release, ignoring the root entirely.
7. **Fragmented build system**: Turborepo handles JavaScript but cannot cache
   or orchestrate Docker, Python, or Rust builds — requiring separate tools
   (Nexus for Docker, Verdaccio for npm) and fragmented workflows.

## Practice

Use **pnpm** exclusively as the package manager and **Nx** as the unified
build/task orchestration system across the entire monorepo — JavaScript,
Docker, Python, and Rust.

### NEVER `npx`, `bunx`, or `yarn dlx` — Always `pnpm dlx` or `pnpm exec`

**Hard rule**: never invoke `npx`, `bunx`, `bun x`, or `yarn dlx` on the host
or inside a pnpm workspace — not in scripts, CI workflows, documentation,
examples, or shell commands. Not inside this monorepo, and not when
contributing to upstream projects that use a different package manager. These
runners pull from their respective registries by default, bypass pnpm's
lockfile, and silently install packages outside the workspace's
content-addressable store, which re-introduces the phantom-dependency and
non-deterministic-install failure modes that pnpm was chosen to prevent.
`yarn dlx` additionally lacks the runtime execution semantics needed for
ad-hoc package invocation and is not a substitute.

| Need | Use | Don't use |
|------|-----|-----------|
| Run a package that is **not** a workspace dependency (ad-hoc / one-off) | `pnpm dlx <pkg> [args...]` | `npx <pkg>`, `bunx <pkg>`, `bun x <pkg>`, `yarn dlx <pkg>` |
| Run a binary that **is** installed in the workspace (dev dep or root dep) | `pnpm exec <cmd> [args...]` | `npx <cmd>`, `bunx <cmd>`, `bun x <cmd>`, `yarn dlx <cmd>` |
| Run a binary via a pnpm script | `pnpm run <script>` (or `pnpm <script>` for built-ins) | `npx <cmd>`, `bunx <cmd>`, `bun x <cmd>`, `yarn dlx <cmd>` |

```bash
# ✅ Correct — ad-hoc package
pnpm dlx only-allow pnpm
pnpm dlx skills add levonk/skills-releases

# ✅ Correct — workspace-installed binary (nx is a dev dep)
pnpm exec nx affected -t build test --parallel=3
# (equivalently, via a pnpm script that calls nx)

# ❌ Wrong — never use any of these on the host or in a pnpm workspace
npx only-allow pnpm
bunx only-allow pnpm
bun x only-allow pnpm
yarn dlx only-allow pnpm
npx nx affected -t build test
bunx nx affected -t build test
npx skills add levonk/skills-releases
```

This rule applies to **every** consumer of this knowledge base — skills,
workflows, agents, prompts, rules, templates, and generated documentation. When
a third-party tool's docs suggest `npx <tool>`, `bunx <tool>`, or
`yarn dlx <tool>`, translate it to `pnpm dlx <tool>` (or `pnpm exec <tool>` if
the tool is a workspace dep) before writing it into any artifact produced by
this repo. This holds even when the upstream project you're contributing to
uses bun or yarn as its package manager — `pnpm dlx` runs the package
identically regardless of the target project's package manager.

### Container Exception — `bunx` inside containers

**Inside a Docker container**, the rule inverts: use **`bunx <pkg>`** and
**never** install or invoke pnpm (`pnpm dlx`, `pnpm exec`) inside a container.
Containers use bun as their runtime — pnpm's content-addressable store and
symlinked `node_modules` are host-developer-workflow optimizations that add
weight and complexity inside an image without benefit.

This exception applies to:

- **`Dockerfile`s** — `RUN bunx <pkg> ...` is correct; `RUN pnpm dlx <pkg> ...`
  is wrong.
- **Container entrypoint scripts** — scripts that run inside the container
  image (e.g. `entrypoint.sh`, `docker-entrypoint.sh`).
- **Any script whose execution environment is the container** — even if the
  script file lives in the source repo, if it's only ever executed inside the
  container, it uses `bunx`.

```dockerfile
# ✅ Correct — inside a Dockerfile
FROM oven/bun:1
RUN bunx <pkg> <args>

# ❌ Wrong — never install pnpm in a container
FROM oven/bun:1
RUN npm install -g pnpm && pnpm dlx <pkg> <args>
```

When in doubt about whether a script is "container-targeted", check whether it
is executed by a `RUN`/`CMD`/`ENTRYPOINT` directive in a Dockerfile, or by a
docker-compose service command. If yes → `bunx`. If it runs on the developer's
host or in CI outside a container → `pnpm dlx`/`pnpm exec`.

### pnpm Workspaces

```yaml
# pnpm-workspace.yaml
packages:
  - "apps/active/*/*/*/typescript"
  - "packages/active/*/*/*/*/typescript"
  - "packages/icebox/*/*/*/*/typescript"
```

Workspace dependencies use the `workspace:*` protocol:

```json
{
  "dependencies": {
    "@job-aide/core": "workspace:*",
    "@job-aide/utils": "workspace:*"
  }
}
```

#### Workspace Mechanics

| Setting | Default | When to change it |
|---------|---------|-------------------|
| `sharedWorkspaceLockfile` | `true` (single `pnpm-lock.yaml` at root) | Almost never — the shared lockfile is the correct default for monorepos. Set `false` only if a workspace package needs a fully independent lockfile (rare). |
| `saveWorkspaceProtocol` | `true` in pnpm 10+ (writes `workspace:*`/`workspace:^` to `package.json`) | Leave at default. `workspace:*` rewrites to the exact local version on publish; `workspace:^` rewrites to a caret range. Use `workspace:*` for non-published apps, `workspace:^` for published libraries that depend on each other. |
| `injectWorkspacePackages` | `false` (symlink workspace deps) | Set `true` (or use `dependenciesMeta[].injected` per-package) when a workspace dep needs its own resolved `node_modules` — e.g. Next.js transpiling a workspace package, or when the consumer needs the dep's built artifact rather than its source. Symlinking is faster and reflects source edits immediately; injecting produces a hard-linked copy that resolves the dep's own dependency tree independently. |

```jsonc
// Per-package inject via dependenciesMeta (prefer this over the global flag)
{
  "name": "@myorg/app",
  "dependencies": {
    "@myorg/ui": "workspace:*"
  },
  "dependenciesMeta": {
    "@myorg/ui": {
      "injected": true
    }
  }
}
```

For supply-chain security features (`overrides`, `patchedDependencies`,
`onlyBuiltDependencies`, `.pnpmfile.mjs`, `packageExtensions`), see
[pnpm Supply-Chain Hardening](/pnpm-supply-chain.md) — that is a separate
concept page because the security surface is deep enough to warrant its own
treatment.

### Catalogs: Centralize External Dependency Versions

**Hard rule**: external (registry) dependency versions live in **one place** —
the `catalog:` block of the root `pnpm-workspace.yaml`. Sub-package
`package.json` files reference them via the `catalog:` protocol and **never**
duplicate a version range. This is the standard for all pnpm monorepos.

```yaml
# pnpm-workspace.yaml — single source of truth for external dep versions
packages:
  - "apps/*"
  - "packages/*"

catalog:
  react: ^18.3.1
  react-dom: ^18.3.1
  next: ^15.1.0
  drizzle-orm: ^0.36.0
  vitest: ^2.1.0
```

```jsonc
// apps/saas/package.json — references the catalog, no version duplicated
{
  "dependencies": {
    "react": "catalog:",
    "react-dom": "catalog:",
    "next": "catalog:"
  },
  "devDependencies": {
    "vitest": "catalog:"
  }
}
```

```jsonc
// packages/ui/package.json — same versions, zero drift
{
  "dependencies": {
    "react": "catalog:",
    "react-dom": "catalog:"
  }
}
```

`catalog:` (bare) is shorthand for `catalog:default`. Named catalogs support
piecemeal migrations (e.g. `catalog:react18` while some packages still pin
`react@17`). On `pnpm publish`/`pnpm pack`, `catalog:` is rewritten to the
concrete semver range — published packages remain consumable by any package
manager, identical to how `workspace:` is rewritten.

#### Anti-Pattern: `"*"` Does NOT Inherit From Root

A common misconception is that `"*"` in a sub-package's `package.json` makes
it inherit the version from the root `package.json`. **It does not.** `"*"`
is the most permissive semver range — it resolves to the **latest release on
the npm registry**, ignoring whatever the root declares. This is true for
npm, yarn, and pnpm alike; `"*"` is a semver range, not an inheritance
mechanism.

```jsonc
// ❌ WRONG — pulls latest from npm, ignores root, non-deterministic
{
  "dependencies": {
    "react": "*"
  }
}

// ✅ CORRECT — version pinned once in pnpm-workspace.yaml catalog
{
  "dependencies": {
    "react": "catalog:"
  }
}
```

#### Strict Enforcement

Set `catalogMode: strict` in `pnpm-workspace.yaml` so `pnpm add` refuses to
introduce a dependency version outside the catalog. This makes drift
impossible at install time — the only way to add or bump a dependency is to
edit the catalog first.

```yaml
# pnpm-workspace.yaml
catalogMode: strict
catalog:
  react: ^18.3.1
  # ...
```

With `strict`, `pnpm add react@^18.2.0` (when the catalog says `^18.3.1`)
errors out. Use `pnpm add react` (no version) to add from the catalog, or
update the catalog entry first. `prefer` is a softer migration path (falls
back to direct deps if no compatible catalog version); `manual` (default)
relies on convention and review alone. New projects use `strict`.

#### catalog: vs workspace: — When to Use Which

| Protocol | Use for | Rewrites on publish to |
|----------|---------|------------------------|
| `workspace:*` / `workspace:^` / `workspace:~` | **Internal** workspace packages (e.g. `@myorg/ui`) | The local package's concrete version |
| `catalog:` / `catalog:default` / `catalog:<name>` | **External** registry dependencies (e.g. `react`, `next`) | The semver range from the catalog entry |

They are complementary: `workspace:` links local packages, `catalog:` pins
external versions. A typical sub-package uses both:

```jsonc
{
  "dependencies": {
    "@myorg/ui": "workspace:*",      // internal
    "react": "catalog:",             // external
    "next": "catalog:"               // external
  }
}
```

#### Migration

To adopt catalogs in an existing workspace, run the official codemod (it
extracts duplicated version ranges into a catalog and rewrites `package.json`
references):

```bash
pnpm dlx codemod pnpm/catalog
```

Or migrate manually: add a `catalog:` block to `pnpm-workspace.yaml` with one
entry per shared external dep, then replace each sub-package's version range
with `catalog:`. Set `catalogMode: strict` once all packages are migrated.

### Nx Task Orchestration

Nx replaces Turborepo as the build orchestrator. Configuration lives in
`nx.json` at the root, with per-project `project.json` files:

```json
// nx.json — root configuration
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "cli": {
    "packageManager": "pnpm"
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "production": [
      "default",
      "!{projectRoot}/**/?(*.)+(spec|test).[jt]s?(x)?(.snap)"
    ]
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "cache": true
    },
    "test": {
      "dependsOn": ["^build"],
      "cache": true
    },
    "lint": {
      "cache": true
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "cache": true
    }
  },
  "plugins": [
    "@nx/js",
    "@nx/next",
    "@nx/docker"
  ]
}
```

Per-project `project.json`:

```json
{
  "name": "localnet",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "apps/active/devops/localnet",
  "projectType": "application",
  "targets": {
    "build": {
      "executor": "@nx/docker:build",
      "options": {
        "dockerfile": "./Dockerfile",
        "context": "."
      }
    }
  }
}
```

### Developer Workflow

| Task | Old (Turborepo) | New (Nx) |
|------|-----------------|----------|
| Build all | `pnpm build` | `nx run-many -t build` |
| Build specific | `turbo run build --filter=app` | `nx build app` |
| Test affected | `turbo run test --affected` | `nx affected -t test` |
| Docker build | `docker build .` | `nx build localnet` |
| Dev server | `pnpm dev` | `nx dev app` |
| Graph visualization | `turbo run build --graph` | `nx graph` |

### Enforce pnpm Only

Use `only-allow` to prevent other package managers:

```json
{
  "scripts": {
    "preinstall": "pnpm dlx only-allow pnpm"
  }
}
```

### CI/CD

```yaml
# Before (Turborepo)
- run: pnpm dlx turbo run build test --affected

# After (Nx)
- run: pnpm exec nx affected -t build test --parallel=3
```

## Rationale

- **pnpm**: Non-flat `node_modules` structure and content-addressable store
  are highly efficient for monorepos. Saves disk space by symlinking
  dependencies. Strictness prevents phantom dependency issues. The
  `catalog:` protocol (pnpm 9.5+) centralizes external dependency versions
  in `pnpm-workspace.yaml`, eliminating version drift and `package.json`
  merge conflicts on upgrades.
- **Nx**: Polyglot by design — plugin architecture supports JavaScript,
  Docker, Python, and Rust as first-class citizens. Unified computation cache
  for all builds. Same `nx build`, `nx test`, `nx lint` commands work across
  all project types. Cross-technology dependencies are properly modeled (a
  Docker service can depend on a TypeScript package build).
- **Combined**: pnpm workspaces integrate seamlessly with Nx. Nx uses pnpm as
  the package manager and respects the existing workspace structure. This
  combination enables true polyglot monorepos with a single build system.

### Why Nx Over Turborepo

| Capability | Turborepo | Nx |
|------------|-----------|-----|
| JavaScript caching | ✅ | ✅ |
| Docker builds | ❌ | ✅ |
| Python builds | ❌ | ✅ |
| Rust builds | ❌ | ✅ |
| Computation caching | ✅ | ✅ (more granular) |
| Remote caching | Vercel | Nx Cloud / self-hosted |
| Plugin ecosystem | Limited | Extensive |
| Graph visualization | Basic | Advanced |
| Code generation | ❌ | ✅ (generators) |

## Consequences

### Positive

- Faster, more reliable dependency installation and builds.
- Reduced disk space usage via content-addressable store.
- Zero version drift — external dependency versions declared once in the
  catalog, referenced everywhere via `catalog:`.
- One-line upgrades — bump a version in `pnpm-workspace.yaml` and every
  package picks it up; no `package.json` edits, no merge conflicts.
- A single, unified workflow for all developers across all technologies.
- True polyglot monorepo — one build system for JavaScript, Docker, Python,
  Rust, and future technologies.
- Simplified infrastructure — eliminates need for separate Nexus (Docker
  cache) and Verdaccio (npm cache).
- Cross-technology pipelines — Docker image build can depend on TypeScript
  compilation.
- Advanced tooling — graph visualization, affected commands, code generators,
  and distributed task execution.

### Negative

- Developers unfamiliar with pnpm or Nx have a learning curve. Nx is more
  complex than Turborepo — `project.json` configuration requires
  understanding.
- More configuration overhead per project compared to Turborepo's minimal
  `turbo.json` setup.
- All existing projects need Nx configuration added — not a drop-in
  replacement.
- For purely JavaScript projects, Turborepo was simpler. Nx adds capabilities
  that may not be immediately needed.

## Migration

1. Audit for `bun.lock` or `package-lock.json` files.
2. Delete those lockfiles and use `pnpm import` to generate `pnpm-lock.yaml`.
3. Install Nx dependencies at root: `pnpm add -D nx @nx/js @nx/next @nx/workspace`.
4. Create `nx.json` with base configuration and plugin list.
5. Add `@nx/js` or `@nx/next` configuration to each JS/TS project — generate
   `project.json` or add `nx` key to existing `package.json`.
6. Update package scripts to call `nx` commands instead of `turbo`.
7. Update CI workflows to use `pnpm` and `pnpm exec nx ...` (or `pnpm dlx nx`
   if nx is not yet installed). Never `npx`.
8. Add `preinstall` script with `only-allow pnpm`.
9. Remove `turbo.json` (keep as reference for historical ADR).
10. For Docker projects: install `@nx/docker` plugin and configure
    `project.json` targets.
11. Adopt catalogs for external dependencies: run `pnpm dlx codemod pnpm/catalog`
    to extract duplicated version ranges into a `catalog:` block in
    `pnpm-workspace.yaml`, then set `catalogMode: strict`. Replace any `"*"`
    version ranges with `catalog:` references — `"*"` does not inherit from
    root, it resolves to the latest registry release.

## Related Concepts

- [Monorepo Structure](/monorepo-structure.md) — the directory layout that pnpm
  workspaces consume.
- [Vitest Testing](/vitest-testing.md) — test runner that integrates with
  Nx's `test` task.
- [Package Naming Convention](/package-naming-convention.md) — how workspace
  packages are named and referenced.
- [pnpm Supply-Chain Hardening](/pnpm-supply-chain.md) — `overrides`,
  `patchedDependencies`, `onlyBuiltDependencies`, `.pnpmfile.mjs`, and
  `packageExtensions`: the security layer on top of workspaces and catalogs.
- [Nx Monorepo Docker Patterns](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/nx-monorepo-docker-patterns.md)
  — how to Dockerize Nx monorepo frontends: two-layer base image
  (`node-base` + `deps-base`), `nx affected -t docker-build` for affected-only
  image builds, dual cache (Nx computation cache + Docker BuildKit cache), and
  the pnpm-vs-bun-in-containers tradeoff with the pnpm-sidecar shared store
  pattern. Applies the `npx`/`bunx`/`pnpm exec` rule from this page to Docker
  builds.


