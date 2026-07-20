---
type: Practice
title: pnpm and Nx for Monorepo Management
description: Standardize on pnpm workspaces with workspace:* dependencies and Nx for polyglot task orchestration; enforce only-allow pnpm to prevent phantom dependencies and enable unified caching across JavaScript, Docker, Python, and Rust.
tags: [typescript, monorepo, pnpm, nx, build-system, workspaces, caching, polyglot]
timestamp: 2026-07-17T00:00:00Z
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
6. **Fragmented build system**: Turborepo handles JavaScript but cannot cache
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
  dependencies. Strictness prevents phantom dependency issues.
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

## Related Concepts

- [Monorepo Structure](/monorepo-structure.md) — the directory layout that pnpm
  workspaces consume.
- [Vitest Testing](/vitest-testing.md) — test runner that integrates with
  Nx's `test` task.
- [Package Naming Convention](/package-naming-convention.md) — how workspace
  packages are named and referenced.

## Citations

[1] [ADR-20260419001: Use Nx for Monorepo Build Orchestration](https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md)
[2] [ADR-20251106001: Use pnpm and Turborepo for Monorepo Management (superseded)](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251106001-pnpm-and-turborepo.md)
[3] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — Package Management section
[4] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — "Must use the pnpm package manager"
[5] [pnpm](https://pnpm.io/)
[6] [Nx](https://nx.dev/)
[7] [Nx vs Turborepo Comparison](https://nx.dev/concepts/turbo-and-nx)
