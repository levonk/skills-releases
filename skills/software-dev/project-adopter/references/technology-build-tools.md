# Technology-Specific Build Tools

**Technology-Specific Build Tools**:
| Technology | Build | Test | Lint | Dev |
|------------|-------|------|------|-----|
| **Rust** | `cargo build` | `cargo test` | `cargo clippy` | `cargo run` |
| **Node.js** | `nx build` | `nx test` | `nx lint` | `nx dev` |
| **Python** | `python -m build` | `pytest` | `ruff check` | `uv run python src/main.py` |
| **Go** | `go build` | `go test` | `golangci-lint run` | `go run` |
| **Java** | `mvn compile` | `mvn test` | `checkstyle` | `mvn exec:java` |

> **Node.js/TypeScript build-tool selection** (per the `build-tool-selection`
> knowledge concept in `typescript-monorepo-best-practices`): `nx build` is the
> orchestrator entry point, but the actual bundler depends on the project type:
> `tsc --noEmit` for type-checking (always in CI, never for bundling), **tsup**
> for library packages (ESM+CJS+`.d.ts` via esbuild), **Rolldown** for
> applications/CLIs (Rust speed, Rollup plugins, powers Vite 8+). Never use
> `tsc` for bundling; never use a bundler for type-checking. `configure-nodejs.sh`
> wires tsup automatically for `library` app_type.
>
> **Nx 23 + TypeScript 7 executor incompatibilities**: `@nx/js:build` was
> removed in `@nx/js` 23.x, `@nx/js:tsc` crashes on TS 7.0 (`ts.sys` is
> `undefined`), and `@nx/vite:test` fails with "Cannot find native binding"
> under pnpm. All `build`/`test` targets should use `nx:run-commands` with
> direct tool invocations (`tsc -p tsconfig.json`, `tsup`, `pnpm exec vitest
> run`) instead of Nx executor wrappers. `sharedGlobals` must be defined in
> `nx.json` `namedInputs` if referenced by `default`.
