# Directory Update Log

## 2026-07-29
* **Update**: Extended [cli-tool-standards.md](cli-tool-standards.md) with
  three new agent-mode requirements from ADR-20260607001 v5.0.0:
  - `--gen-skill` skill emission (print installable Agent Skill prompt to
    stdout, recommend hooks > CLI > MCP, `--check` for CI staleness)
  - Coding-agent hook wiring (Devin, Cursor, Continue, Aider opt-in; per-agent
    `[agent-hooks]` table in `${XDG_CONFIG_HOME:-$HOME/.config}/{app-name}/config.toml`;
    `--install-agent-hooks` / `--uninstall-agent-hooks`)
  - Non-user-identifiable telemetry (no file paths, no identifiers, no command
    args; `MYTOOL_TELEMETRY` env var + `[telemetry]` config; `--telemetry-dry-run`)
* **Source**: ADR-20260607001 bumped to v5.0.0 (date-updated 2026-07-29) in
  levonk-base-boilerplate.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Initialization**: Created the `rust-development-practices` knowledge bundle to consolidate Rust package and CLI development practices from two ADRs in levonk-base-boilerplate.
* **Creation**: Authored 11 concept pages covering the full Rust development lifecycle.
  - [project-structure.md](project-structure.md) — standard directory layout, module organization
  - [cargo-configuration.md](cargo-configuration.md) — Cargo.toml metadata, dependency pinning, workspace config
  - [rustfmt-clippy-config.md](rustfmt-clippy-config.md) — formatting and linting standards
  - [testing-strategy.md](testing-strategy.md) — unit, integration, doc tests, benchmarks, proptest
  - [error-handling.md](error-handling.md) — thiserror, anyhow, no panic in libraries
  - [async-patterns.md](async-patterns.md) — tokio runtime, async tests, stream implementation
  - [serde-serialization.md](serde-serialization.md) — optional serde, multiple formats, skip patterns
  - [cli-tool-standards.md](cli-tool-standards.md) — cross-language CLI standards, AXI agent mode, TOON
  - [container-support.md](container-support.md) — multi-stage Dockerfile, non-root, healthcheck
  - [security-auditing.md](security-auditing.md) — cargo audit, secrecy, zeroize, safe FFI
  - [quality-gates.md](quality-gates.md) — pre-commit hooks, multi-version CI, validation criteria
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20260128001 (Rust package boilerplate requirements, 756 lines) and ADR-20260607001 (CLI tool standards, 401 lines) in levonk-base-boilerplate.
