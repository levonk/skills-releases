---
type: Practice
title: Unsafe Code Practices
description: Unsafe Rust is a last resort — encapsulate it behind safe abstractions (ideally in a separate crate), justify why safe code was impossible, document correctness with SAFETY: comments, never consume a poisoned mutex's contents, and never rely on catch_unwind.
tags: [rust, unsafe, safety-comments, ffi, mutex-poison, soundness]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# Unsafe Code Practices

## Failure Mode

Unsafe blocks scattered through business logic make soundness review
impossible — every maintainer must re-derive the invariants. Unsafe written
before safe alternatives were exhausted adds UB risk for zero gain.
Consuming a poisoned mutex's contents propagates corrupted state left by a
panicking thread. `catch_unwind` used as a control-flow mechanism breaks
under `panic=abort` builds.

## Practice

### Unsafe Is a Last Resort

Do not write unsafe code unless safe code cannot express the functionality.
When unsafe is unavoidable:

- **Encapsulate** it behind a safe abstraction, isolated from business
  logic. Ideally, unsafe code lives in a separate crate with few
  dependencies beyond `std` — minimizing the surface a soundness review
  must cover.
- **Justify** it, per `unsafe` block or per file/build target: why is this
  not written in safe Rust? If the answer is performance, where are the
  benchmarks?
- **Document** correctness with a comment starting with `SAFETY:` that
  explains why the code is correct — which invariants hold and why.

### Mutex Poison

Never reach inside a poisoned mutex to get at its contents — the data may be
in an inconsistent state left by the panicking thread. Treat
`PoisonError` as a failed invariant, not a convenience bypass
(`into_inner()` is the code smell).

### `catch_unwind`

Do not call `std::panic::catch_unwind` — it is not a control-flow or
error-handling mechanism, and it does not exist under `panic=abort`.
The only defensible use is defense-in-depth around critical entry points in
a codebase that already avoids panics, and only where `panic=unwind` is
guaranteed — it must never be *relied* upon for correctness.

### Related Rules

- **No unstable features** — see
  [API Stability Attributes](api-stability-attributes.md)
- **No code before `main()`** — no `ctor`-style pre-main initialization
- **Unsafe invariants documented** — every `unsafe fn`/`unsafe trait` must
  state its contract in doc comments; see
  [Documentation Comments](documentation-comments.md)

## Related Concepts

- [Security and Auditing](security-auditing.md) — safe FFI practices,
  dependency auditing
- [Error Handling](error-handling.md) — panic policy for violated invariants
- [Documentation Comments](documentation-comments.md) — documenting unsafe
  contracts
