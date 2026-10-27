---
type: Practice
title: Performance Practices
description: Measure first, then optimize in a fixed order — capacity hints and collect() over push loops, caller-owned buffer reuse, Box<[T]>/Box<str>/Arc<str> for long-lived sequences, shrink_to_fit, fast hashers for trusted keys only, batching over per-item locking, and mimalloc as the application-level allocator.
tags: [rust, performance, optimization, allocation, benchmarking, memory]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Performance Practices

## Failure Mode

Optimizing before measuring wastes effort on cold paths while hot paths
allocate per item. `Vec`/`String` held for the process lifetime carry
growable capacity nobody reclaims. The default `SipHash` hasher burns
cycles on trusted internal keys. Per-item locking serializes work that a
batch would amortize. Libraries tuned for one deployment target carry
`target-cpu` flags that hurt everyone else.

## Practice

### Order of Operations

Design for usability first; optimize after measuring. Decide early whether
the crate is performance-relevant — if so, find and benchmark hot paths
with `criterion` or `divan` (use `std::hint::black_box`), profile
regularly, and document hot spots. Optimize for items per CPU cycle, not
per-call elegance.

### Allocation Discipline

- `Vec::with_capacity` when the size is known; `collect()` over push loops.
- `Box<[T]>`, `Box<str>`, `Arc<str>` for frequently created, long-lived,
  immutable sequences instead of `Vec`/`String`.
- `shrink_to_fit()` on long-lived growable collections built without a
  reservation.
- Let callers own and reuse buffers in hot APIs:
  `fn read_into(&mut self, buf: &mut Vec<u8>)` alongside a convenience
  `get(id)` — provide `clear()` too. Arenas suit deep call stacks.
- A faster hasher (`foldhash`, `FxHash`) only for trusted keys; the default
  hasher defends untrusted input against hash flooding.
- Use `try_reserve` where memory is limited (`no_std` contexts).

### CPU and Indirection

- Batch work instead of per-item locking or per-item channel sends.
- Do not stack `Arc` layers on hot types; lift hot, cacheable fields
  (`enabled: bool`) into the owning struct.
- Derive `Copy` for small, bitwise-copyable plain types — never for large
  or non-trivial ones (the compiler copies silently).
- No telemetry in hot inner loops and no per-event `format!` — see
  [Structured Logging](structured-logging-tracing.md).

### Application-Only Knobs

- Set `#[global_allocator]` to `mimalloc` for applications (reported gains
  up to ~25%); libraries never choose the allocator.
- Server applications may compile for the highest `target-cpu` the
  deployment guarantees (`x86-64-v3` via `.cargo/config.toml`); libraries
  ignore this.
- Track the stack size of hot futures with `size_of_val` in a test — see
  [Concurrency and Async Design](concurrency-and-async-design.md).

## Related Concepts

- [Ownership and Borrowing](ownership-and-borrowing.md) — clone discipline;
  clones are a design decision, not a reflex
- [Concurrency and Async Design](concurrency-and-async-design.md) — lock
  scope, `spawn_blocking`, yield points
- [Cargo Configuration](cargo-configuration.md) — release-profile and
  feature-level cost control
- [Quality Gates](quality-gates.md) — benchmarks and regression checks
  in CI
