---
type: Practice
title: Cargo Configuration
description: Required Cargo.toml metadata, dependency version pinning, feature flags for optional functionality, and workspace configuration for monorepo integration.
tags: [rust, cargo, cargo-toml, dependencies, features, workspace]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-27"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Cargo Configuration

## Failure Mode

Missing Cargo.toml metadata causes poor crate discoverability. Unpinned
dependencies lead to reproducibility issues. Missing feature flags force all
functionality on all consumers.

## Practice

### Required Metadata

```toml
[package]
name = "package-slug"
version = "0.1.0"
edition = "2021"
authors = ["Author <email>"]
description = "Package description"
license = "MIT"
repository = "https://github.com/..."
rust-version = "1.70"
```

### Dependency Management

- **Version ranges**: use compatible ranges (`"1"`, `"1.4"`) — never `"*"`
  or a needless `"="` pin. `"1.2.3"` already means `^1.2.3`; `"~"` allows
  patches only.
- **Cargo.lock**: commit it for binaries (applications); libraries may
  leave it out.
- **Every dependency has a cost**: compile time, binary size, and
  supply-chain exposure — including `build.rs` and proc macros. Audit the
  graph with `cargo tree --duplicates`, `cargo deny`, `cargo udeps`, and
  `cargo audit` (see [Security and Auditing](security-auditing.md)).
- **Minimal dependencies**: prefer the standard library over external
  crates.
- **Stable deps for stable crates**: a 1.0+ crate needs every public
  dependency — any crate whose types appear in its API — to be stable too
  (a `From<other::Error>` impl leaks `other`).
- **MSRV and edition**: set `rust-version` deliberately at creation and
  raise it conservatively in minor releases; new crates use the latest
  stable edition.

### Feature Flags

Features are **additive** — Cargo unifies them across the dependency
graph, so any combination must compile. A feature never removes or changes
a public item, never gates a struct field or trait method. Names are bare:
`std`, `serde`, `alloc`, `test-util` — never `no-std`, `use-serde` (model
`no_std` support as a `std`/`alloc` feature on a `no_std` base). Gate
serde derives behind a feature named exactly `serde`. Put mocks and fakes
behind `test-util` (see [Testing Strategy](testing-strategy.md)). Each
independent feature doubles the configuration space — CI should cover the
combinations that matter.

```toml
[features]
default = []
async = ["tokio"]
serde = ["dep:serde", "serde/derive"]
test-util = []
```

### Workspace Configuration

```toml
[workspace]
members = [
    "packages/active/*/rust/*",
    "apps/active/*/rust/*"
]

[workspace.dependencies]
tokio = { version = "1.35", features = ["full"], default-features = false }
serde = { version = "1.0", features = ["derive"] }
anyhow = "1.0"
thiserror = "1.0"
```

Share lint configuration the same way — `[workspace.lints]` at the root
plus `[lints] workspace = true` in each member — rather than scattered
crate attributes; see
[Rustfmt and Clippy](rustfmt-clippy-config.md) for the lint table.

## Related Concepts

- [Project Structure](project-structure.md) — Directory layout for the package
- [Security and Auditing](security-auditing.md) — cargo audit for dependencies
- [Visibility and API Evolution](visibility-and-api-evolution.md) — semver
  and MSRV commitments behind the manifest
- [Rustfmt and Clippy](rustfmt-clippy-config.md) — the `[lints]` table
  shared through `[workspace.lints]`
