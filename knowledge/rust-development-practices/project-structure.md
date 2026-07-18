---
type: Practice
title: Project Structure
description: Standard directory layout for Rust packages — src/lib.rs for libraries, src/main.rs for binaries, tests/ for integration, benches/ for benchmarks, docs/ for architecture.
tags: [rust, project-structure, directory-layout, modules, re-exports]
timestamp: 2026-07-17T00:00:00Z
---

# Project Structure

## Failure Mode

Inconsistent directory layouts across Rust packages make navigation difficult,
cause missing modules, and result in poor public API surfaces.

## Practice

Every Rust package must follow the standard directory layout:

```
package/
├── Cargo.toml
├── src/
│   ├── lib.rs              # Library root
│   ├── main.rs             # Binary entry point
│   ├── module.rs           # Main module
│   └── error.rs            # Error types
├── tests/
│   ├── integration_tests.rs
│   └── common/
│       └── mod.rs          # Test utilities
├── benches/
│   └── performance.rs      # Benchmarks
└── docs/
    ├── architecture.md
    └── examples/
        └── basic_usage.rs
```

### Module Organization

- **Library crates**: `src/lib.rs` as entry point
- **Binary crates**: `src/main.rs` for applications, `src/bin/` for multiple binaries
- **Module structure**: Organize by feature/domain, not by file type
- **Re-exports**: Use `pub use` in `lib.rs` to create a clean public API

## Related Concepts

- [Cargo Configuration](cargo-configuration.md) — Manifest for this structure
- [Testing Strategy](testing-strategy.md) — Tests live in tests/ and benches/

## Citations

[1] `internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md` — levonk-base-boilerplate
