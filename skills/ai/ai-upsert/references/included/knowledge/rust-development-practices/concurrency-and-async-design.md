---
type: Practice
title: Concurrency and Async Design
description: Concurrency design discipline — Send/Sync compile-time assertions on public types and futures, message passing over shared state, lock scope rules (never return MutexGuard, never call closures under a lock), async fn over impl Future, yield points for CPU-bound async work, and runtime-agnostic library code.
tags: [rust, concurrency, async, send-sync, mutex, tokio, message-passing, locks]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Concurrency and Async Design

## Failure Mode

A public future that is `!Send` silently breaks callers who spawn it — and
a refactor that holds an `Rc` across an `.await` can regress this without
anyone noticing. `MutexGuard` returned to a caller extends the lock's scope
invisibly. A user closure invoked under a lock is a deadlock invitation.
CPU-bound work inside async tasks starves every other task on the executor.
Library code that spawns threads or assumes tokio forces a runtime on
consumers who may not have one.

## Practice

### Pin `Send`/`Sync` on Public Types

Public types, and the futures they return, should be `Send` (and usually
`Sync`). Lock it in with a compile-time check so a refactor cannot silently
regress it:

```rust
const _: () = {
    const fn assert_send<T: Send>() {}
    assert_send::<MyClient>();
};
```

Holding an `Rc`, or a `RefCell` borrow, across an `.await` makes the
future `!Send`. `Send`/`Sync` are automatic — the assertion exists to catch
the day they stop being.

### Message Passing Over Shared State

Prefer channels to shared state. When sharing is necessary:

- Keep data with linked invariants under one lock.
- Keep lock scopes to a few lines.
- Never call user closures while holding a lock.
- Never return a `MutexGuard` (or `RwLock` guard) from a public method —
  return the data or a scoped closure (`with_foo(|v| ..)`).
- Treat lock poisoning as fatal — see
  [Unsafe Code Practices](unsafe-code-practices.md).
- A documented lock hierarchy is a last resort; add deadlock detection to
  CI for complex sharing.

### Async API Shape

- Write `async fn` rather than `fn -> impl Future` — except in traits
  (`async fn` is not object-safe; use `async-trait` or boxed futures) or
  when setup must run outside the async block on a hot path.
- Long CPU-bound work inside async must yield
  (`tokio::task::yield_now().await` roughly every 10–100 µs) or move to
  `spawn_blocking`.
- Track hot-future stack size with `size_of_val` in a test; shrink state
  held across `.await` and move setup outside the async block.

### Runtime-Agnostic Libraries

Library code does not spawn raw threads or assume a runtime — take an
executor, a spawn function, or `impl AsyncRead`/`impl Read` from the
caller. Applications choose the runtime; see
[Async Patterns](async-patterns.md) for the standard tokio setup.

## Related Concepts

- [Async Patterns](async-patterns.md) — tokio runtime, `#[tokio::test]`,
  `Stream` implementations
- [Unsafe Code Practices](unsafe-code-practices.md) — mutex poison policy;
  `unsafe impl Send` is banned
- [Ownership and Borrowing](ownership-and-borrowing.md) — `Rc` vs `Arc`,
  `RefCell` vs `Mutex` ownership choices
- [Performance Practices](performance-practices.md) — batching over
  per-item locking
