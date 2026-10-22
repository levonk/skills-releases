---
type: Practice
title: Project Structure
description: Standard directory layout for Rust packages — src/lib.rs for libraries, src/main.rs for binaries, tests/ for integration, benches/ for benchmarks, docs/ for architecture.
tags: [rust, project-structure, directory-layout, modules, re-exports]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-21"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
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
- **Leaf vs non-leaf modules**: Non-leaf modules contain only `mod`
  declarations and `pub use` re-exports — never API implementations (small
  "ties things together" code is acceptable; `mod test` and
  `#[cxx::bridge]` binding modules do not count against leaf-ness)
- **Name files and leaf modules after the primary item**: when a leaf module
  exists mainly to define `Foo`, name it `foo.rs` / `mod foo` — content and
  purpose are identifiable at a glance
- **Prefer small crates**: split code into small crates focusing on one
  abstraction where feasible; the root module may re-export leaf-submodule
  APIs so submodules stay an implementation detail. Larger crates are
  justified by trait-impl coherence or foundational-library scope. Needing
  subdirectories inside one crate is a smell indicating the crate has grown
  too large.

## Related Concepts

- [Cargo Configuration](cargo-configuration.md) — Manifest for this structure
- [Import Organization](import-organization.md) — `use` statement and
  re-export rules
- [Testing Strategy](testing-strategy.md) — Tests live in tests/ and benches/
