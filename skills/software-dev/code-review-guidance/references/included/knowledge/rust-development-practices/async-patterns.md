---
type: Practice
title: Async Patterns
description: Use tokio as the async runtime, #[tokio::test] for async tests, async fn for async functions, and implement Stream for async iterators when appropriate.
tags: [rust, async, tokio, futures, async-trait, stream]
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

# Async Patterns

## Failure Mode

Using different async runtimes across packages prevents interoperability.
Missing async test attributes cause test panics. Blocking operations in async
contexts freeze the runtime.

## Practice

### Async Configuration

```toml
[dependencies]
tokio = { version = "1.35", features = ["full"] }
tokio-util = "0.7"
futures = "0.3"
async-trait = "0.1"
```

### Patterns

- Use `async fn` for async functions (over `fn -> impl Future`, except in
  traits or on hot paths where setup must run outside the async block)
- Prefer **tokio** as the async runtime (standardize across all packages)
- Use `#[tokio::test]` for async tests
- Implement `Stream` for async iterators when appropriate
- Never block in async contexts — use `spawn_blocking` for CPU-bound work,
  or `yield_now()` roughly every 10–100 µs inside long CPU-bound tasks
- Library code does not assume a runtime — accept an executor, a spawn
  function, or `impl AsyncRead` from the caller. See
  [Concurrency and Async Design](concurrency-and-async-design.md) for
  `Send`/`Sync` assertions and lock discipline.

### Feature Flag

```toml
[features]
default = []
async = ["tokio"]
```

## Related Concepts

- [Testing Strategy](testing-strategy.md) — Async test macro pattern
- [Cargo Configuration](cargo-configuration.md) — tokio as workspace dependency
- [Concurrency and Async Design](concurrency-and-async-design.md) —
  `Send`/`Sync` assertions, lock discipline, runtime-agnostic libraries
