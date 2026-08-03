---
type: Practice
title: Build Tool Selection — Rolldown vs tsup vs tsc
description: Choose the right TypeScript build tool by layer — tsc --noEmit for type-checking in CI, tsup for library bundling (ESM+CJS+.d.ts with esbuild speed), Rolldown for full application/CLI bundling (Rust speed, Rollup plugin compatibility, powers Vite 8+). Never use tsc for bundling; never use a bundler for type-checking.
tags: [typescript, build-tool, bundler, rolldown, tsup, tsc, esbuild, vite, library-publishing, ci, type-checking]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"
sources:
  - id: rolldown-rs
    resource: https://rolldown.rs/
    title: 'Rolldown — Blazing Fast Rust-based bundler for JavaScript'
  - id: rolldown-github
    resource: https://github.com/rolldown/rolldown
    title: 'rolldown/rolldown — Fast Rust bundler for JavaScript/TypeScript with Rollup-compatible API'
  - id: rolldown-1-announcement
    resource: https://peerlist.io/saxenashikhil/articles/announcing-rolldown-10
    title: 'Announcing Rolldown 1.0 — stable production release, powers Vite 8+'
  - id: tsup
    resource: https://tsup.egoist.dev/
    title: 'tsup — Bundle your TypeScript library with no config'
  - id: typescript-compiler
    resource: https://www.typescriptlang.org/docs/handbook/compiler-options.html
    title: 'TypeScript Compiler Options — tsc reference'
  - id: boilerplate-adr-tsup-library-builds
    resource: https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260802001-tsup-for-library-package-builds.md
    title: 'ADR-20260802001: Use tsup for TypeScript Library Package Builds'
---

# Build Tool Selection — Rolldown vs tsup vs tsc

## Failure Mode

Using a single tool for all TypeScript build concerns — bundling,
type-checking, and declaration generation — or choosing the wrong layer for
the job. Problems:

1. **`tsc` for bundling**: `tsc` emits one file per source file with no
   tree-shaking, no minification, no code-splitting, and no multi-format
   output (ESM/CJS/IIFE). Libraries built with `tsc` ship larger artifacts
   and require consumers to re-bundle. Applications built with `tsc` have no
   bundling at all — just transpiled files.
2. **A bundler for type-checking**: esbuild, Rolldown, and tsup all
   **strip types without checking them**. Using a bundler's output as proof of
   type safety lets type errors reach production silently. CI must run
   `tsc --noEmit` separately.
3. **esbuild directly for libraries**: esbuild does not generate `.d.ts`
   declaration files. Libraries need a separate tsc pass for declarations,
   which means two build steps and two config files. tsup wraps esbuild and
   adds `.d.ts` generation in one step.
4. **Rollup for new projects**: Rollup is correct and mature but 10-30x
   slower than Rolldown on large projects. For greenfield bundling, Rolldown
   provides the same plugin API at Rust speed. For existing Rollup projects,
   migration is designed to be a config rename + package swap.

## Practice

Use **three tools at three layers**. Each does one thing well.

### Layer 1: Type-checking — `tsc --noEmit`

**Always run `tsc --noEmit` in CI**, regardless of which bundler you use.
This is the canonical source of truth for type correctness. No bundler
performs type-checking — they strip types syntactically.

```bash
# CI type-check gate
tsc --noEmit
```

Configure `tsconfig.json` with `"noEmit": true` for the type-check project,
or pass `--noEmit` on the command line. The `typecheck` Nx target in
boilerplate templates runs this.

### Layer 2: Library bundling — `tsup`

For **publishable npm libraries** that need ESM + CJS + `.d.ts` output,
use **tsup**. It wraps esbuild for speed and adds declaration generation
via tsc under the hood — one tool, one config file, multi-format output.

```typescript
// tsup.config.ts
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,           // generate .d.ts via tsc
  clean: true,
  sourcemap: true,
  treeshake: true,
})
```

```bash
tsup                  # builds dist/index.mjs + dist/index.cjs + dist/index.d.ts
```

**When tsup is the right choice:**
- Publishing a library to npm (needs `exports` map with ESM + CJS + types)
- Workspace packages consumed by other packages that need bundled output
- Small-to-medium libraries where esbuild speed is sufficient

**When tsup is NOT the right choice:**
- Full applications with code-splitting, dynamic imports, HTML/CSS assets
  → use Rolldown (or Vite, which is Rolldown-backed from Vite 8+)
- CLI tools that need platform-specific bundling with Node API shimming
  → use `@nx/esbuild` or Rolldown directly

### Layer 3: Application/CLI bundling — `Rolldown`

For **full applications, CLIs, and anything needing a real bundler**
(code-splitting, asset handling, plugin ecosystem), use **Rolldown**.

Rolldown is a Rust-based bundler with:
- **Rollup-compatible API and plugin interface** — most Rollup plugins work
  unchanged
- **esbuild-level speed** — 10-30x faster than Rollup, on par with esbuild
- **Built-in TypeScript and JSX** via Oxc — no separate transpilation plugin
- **Native CJS/ESM interop** — no `@rollup/plugin-commonjs` dance
- **Powers Vite 8+** — the default bundler for every Vite project since
  Vite 8 stable (March 2026)

```javascript
// rolldown.config.mjs
import { defineConfig } from 'rolldown'

export default defineConfig({
  input: 'src/index.ts',
  output: {
    dir: 'dist',
    format: 'esm',
  },
  plugins: [
    // most Rollup plugins work here unchanged
  ],
})
```

**When Rolldown is the right choice:**
- New application bundling (web app, CLI, server)
- Vite-powered projects (already using Rolldown under the hood from Vite 8+)
- Migrating from Rollup (config rename + package swap in most cases)
- Projects needing Rollup's plugin ecosystem at esbuild speed

**When Rolldown is NOT the right choice:**
- Simple library publishing where tsup's zero-config `.d.ts` is sufficient
- Pure type-checking (use `tsc --noEmit`)

### Decision Matrix

| Need | Use | Why |
|------|-----|-----|
| Type-checking in CI | **`tsc --noEmit`** | Only `tsc` performs full type-checking. Bundlers strip types without checking. |
| Publish an npm library (ESM+CJS+`.d.ts`) | **tsup** | Wraps esbuild for speed + tsc for `.d.ts` in one step. Minimal config. |
| Bundle an application or CLI | **Rolldown** | Full bundler, Rust speed, Rollup plugin compatibility. |
| Vite-powered web app | **Vite 8+** (Rolldown is the bundled backend) | Already using Rolldown — no separate config needed. |
| Migrate from Rollup | **Rolldown** | Drop-in replacement — Rollup-compatible API, rename config + swap package. |
| Migrate from esbuild (library) | **tsup** | Same esbuild speed + adds `.d.ts` generation. |
| Migrate from esbuild (app) | **Rolldown** | Comparable speed + plugin ecosystem + code-splitting. |
| Generate `.d.ts` only | **`tsc --declaration --emitDeclarationOnly`** | No bundler generates correct `.d.ts` without tsc. tsup calls this under the hood. |

### Combined Workflow (Recommended)

For a TypeScript monorepo with both libraries and applications:

```
CI pipeline:
  1. tsc --noEmit          # type-check everything (Nx: typecheck target)
  2. tsup (libraries)      # bundle library packages → dist/*.mjs + *.d.ts
  3. rolldown (apps/CLIs)  # bundle applications → dist/
  4. vitest run            # run tests
  5. eslint .              # lint
```

In an Nx monorepo, each project's `project.json` defines its own `build`
target pointing to the right tool. The `typecheck` target always runs
`tsc --noEmit` regardless of the build tool.

### What About `tsgo`?

`tsgo` is Microsoft's native port of the TypeScript compiler (Go-based,
preview). It is a **faster `tsc`** — same type-checking correctness, 5-10x
faster. When stable, it replaces `tsc` in the type-checking layer above.
It does not change the layer model: `tsgo --noEmit` for type-checking,
tsup/Rolldown for bundling. Until tsgo is stable, continue using `tsc`.

## Rationale

These tools operate at **different layers** and are complementary, not
competing:

- **tsc** is a **type-checker and transpiler**. It verifies type correctness
  and can emit JS + `.d.ts`. It does not bundle — it produces one output file
  per input file. Optimized for correctness, not speed.
- **tsup** is a **library bundler** built on esbuild. It adds multi-format
  output (ESM/CJS), minification, tree-shaking, and `.d.ts` generation
  (via tsc under the hood). It does not type-check during bundling.
- **Rolldown** is a **full bundler** written in Rust. It combines Rollup's
  plugin API with esbuild-level speed. It handles code-splitting, asset
  loading, CJS/ESM interop, and watch mode. It does not type-check.

Using the wrong layer wastes time and produces worse artifacts:
- `tsc` for bundling → no tree-shaking, no minification, one-file-per-source
- A bundler for type-checking → type errors silently pass
- esbuild for libraries → no `.d.ts` without a separate tsc pass
- Rollup for new projects → 10-30x slower than Rolldown for the same API

## Consequences

- **CI always runs `tsc --noEmit`** — this is non-negotiable, regardless of
  bundler choice. The `typecheck` Nx target enforces this.
- **Library packages use tsup** for their `build` target — produces
  `dist/index.mjs` + `dist/index.cjs` + `dist/index.d.mts` with one command.
- **Application packages use Rolldown** (or Vite for web apps) for their
  `build` target — full bundling with code-splitting and asset handling.
- **`@nx/js:build` (tsc-based) is replaced** by tsup for library packages
  that need bundled output. Packages that only need type-checking keep the
  `typecheck` target and may skip `build` entirely.
- **esbuild direct usage in templates** (e.g., `@nx/esbuild:esbuild` for
  CLIs) remains valid — Rolldown is the upgrade path when plugin
  compatibility or code-splitting is needed.

## Migration

### From `tsc` to `tsup` (library packages)

1. Add `tsup` to devDependencies
2. Create `tsup.config.ts` with `entry`, `format: ['esm', 'cjs']`, `dts: true`
3. Change `package.json` `build` script from `tsc -p tsconfig.json` to `tsup`
4. Update `exports` map to point to `dist/index.mjs` (ESM) and
   `dist/index.cjs` (CJS) instead of `dist/index.js`
5. Update Nx `project.json` `build` target to use `nx:run-commands` with
   `tsup` instead of `@nx/js:build`
6. Keep the `typecheck` target as `tsc --noEmit` — it stays unchanged
7. Run `tsc --noEmit && tsup` to verify both type-checking and bundling pass

### From Rollup to Rolldown

1. `pnpm remove rollup && pnpm add -D rolldown`
2. Rename `rollup.config.mjs` → `rolldown.config.mjs`
3. Change `import { defineConfig } from 'rollup'` to
   `import { defineConfig } from 'rolldown'`
4. Most plugins work unchanged — test each one
5. Run the build and compare output

## Related Concepts

- [pnpm and Nx Monorepo](pnpm-nx-monorepo.md) — Nx orchestrates the
  `build`, `typecheck`, `test`, and `lint` targets defined per project.
  The build tool choice (tsup vs Rolldown vs tsc) is made per-project in
  `project.json`; Nx caches and parallelizes across projects regardless.
- [Explicit File Extensions](explicit-file-extensions.md) — tsup output
  uses `.mjs` (ESM) and `.cjs` (CJS); declaration files use `.d.mts` and
  `.d.cts`. The extension conventions apply to build output as well as
  source.
- [Vitest Testing](vitest-testing.md) — Vitest runs independently of the
  build tool. Tests import source files directly; the build tool only
  affects published artifacts.
- [JavaScript and TypeScript Fundamentals](javascript-typescript-fundamentals.md)
  — Covers `tsc` configuration, JSDoc typing, and the relationship between
  TypeScript syntax and the compiler.

## Citations

- Rolldown official site: <https://rolldown.rs/>
- Rolldown GitHub: <https://github.com/rolldown/rolldown>
- Rolldown 1.0 announcement (stable, powers Vite 8+):
  <https://peerlist.io/saxenashikhil/articles/announcing-rolldown-10>
- tsup documentation: <https://tsup.egoist.dev/>
- TypeScript compiler options: <https://www.typescriptlang.org/docs/handbook/compiler-options.html>
- ADR-20260802001 (tsup for library package builds):
  `levonk-base-boilerplate/internal-docs/adr/adr-20260802001-tsup-for-library-package-builds.md`
