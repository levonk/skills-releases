---
type: Practice
title: Quality Gates
description: Pre-commit hooks for fmt/clippy/test, CI/CD with multiple Rust versions (stable/beta/nightly), cross-platform testing, documentation builds, and security audits.
tags: [rust, quality-gates, pre-commit, ci-cd, cross-platform, testing]
timestamp: 2026-07-17T00:00:00Z
---

# Quality Gates

## Failure Mode

Without quality gates, unformatted code, linting failures, and untested changes
land in the repository. Single-version testing misses compatibility issues.
Missing security audits let vulnerable dependencies ship.

## Practice

### Pre-commit Hooks

```bash
#!/bin/sh
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

### CI/CD Requirements

- **Multiple Rust versions**: Test against stable, beta, and nightly
- **Cross-platform**: Test on Linux, macOS, and Windows
- **Documentation**: Ensure docs build without warnings
- **Security**: Run `cargo audit` in CI

### Validation Criteria

A Rust package is considered complete when:

1. `cargo check` passes without warnings
2. `cargo test` passes all tests
3. `cargo clippy` passes without warnings
4. `cargo fmt --check` passes
5. `cargo doc` generates docs without warnings
6. `cargo build --release` succeeds
7. Docker image builds and runs successfully
8. `nix build` succeeds in development shell

## Related Concepts

- [Rustfmt and Clippy](rustfmt-clippy-config.md) — Formatting and linting config
- [Testing Strategy](testing-strategy.md) — Test types that gates enforce
- [Security and Auditing](security-auditing.md) — cargo audit in CI

## Citations

[1] `internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md` — levonk-base-boilerplate
