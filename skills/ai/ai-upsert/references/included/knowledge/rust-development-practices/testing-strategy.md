---
type: Practice
title: Testing Strategy
description: Multi-level Rust testing — inline unit tests, integration tests in tests/, doc tests in comments, benchmarks with criterion, and property-based testing with proptest.
tags: [rust, testing, unit-tests, integration-tests, doc-tests, benchmarks, proptest]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-27"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Testing Strategy

## Failure Mode

Rust packages with only unit tests miss integration failures. Missing doc tests
let examples go stale. No benchmarks mean performance regressions go unnoticed.

## Practice

### Test Organization

- **Unit tests**: Inline in source files using `#[cfg(test)] mod tests`
  (`use super::*`) — they see private internals
- **Integration tests**: In `tests/` directory for anything reachable
  through the public API — prefer this location when either would do
- **Documentation tests**: In doc comments using `///` with code examples
- **Benchmarks**: In `benches/` directory for performance testing

### What to Assert

Test observable behavior and properties — monotonicity, round-trips,
idempotence — not restated constants or mirrored implementation branches
(`assert_eq!(CHECKPOINTS, [0, 90, 180, 270])` tests nothing). Write a
failing test before fixing a bug; cover each feature combination and each
platform-specific path. Assertions carry context so failures read well:
`assert_eq!(got, want, "input {input:?}")`.

### Mockable I/O

Anything doing file, network, clock, entropy, or other non-deterministic
I/O must be mockable — provide `new_mocked() -> (Self, MockCtrl)` behind a
single `test-util` feature (mocks, fakes, fake-data generators, sensitive-
data inspection), never a `Default` that performs I/O.

### Specialized Test Types

- **Fuzz** parsers of untrusted input with `cargo fuzz`
- **Benchmarks** with `criterion` or `divan` — wrap inputs in
  `std::hint::black_box` so the optimizer cannot elide the work
- **Miri** over `unsafe` code — see
  [Unsafe Code Practices](unsafe-code-practices.md)
- **`trybuild`** for proc-macro error messages, **`insta`** for expansion
  snapshots — see [Macro Guidelines](macro-guidelines.md)
- **Bevy systems** — headless `App` tests plus a whole-plugin smoke test;
  see [Bevy ECS Conventions](bevy-ecs-conventions.md)

### Required Test Dependencies

```toml
[dev-dependencies]
tokio-test = "0.4"
tempfile = "3.8"
assert_cmd = "2.0"
predicates = "3.0"
serial_test = "2.0"
criterion = { version = "0.5", features = ["html_reports"] }
proptest = "1.4"
```

### Async Test Helper

```rust
#[macro_export]
macro_rules! async_test {
    ($test_name:ident, $test_body:block) => {
        #[tokio::test]
        async fn $test_name() {
            let _ = setup_test_logger();
            $test_body
        }
    };
}
```

### Test Utilities

```rust
// tests/common/mod.rs
pub fn setup_test_logger() {
    let _ = env_logger::builder()
        .filter_level(log::LevelFilter::Debug)
        .is_test(true)
        .try_init();
}
```

## Related Concepts

- [Quality Gates](quality-gates.md) — CI runs all test types
- [Async Patterns](async-patterns.md) — Async test macro pattern
- [Implementation Idioms](implementation-idioms.md) — context strings in
  assertions
- [Bevy ECS Conventions](bevy-ecs-conventions.md) — headless `App` system
  tests
- [Porting to Rust](porting-to-rust.md) — characterization tests pin the
  port's behavior
