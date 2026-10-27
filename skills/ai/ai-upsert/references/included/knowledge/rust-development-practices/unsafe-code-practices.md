---
type: Practice
title: Unsafe Code Practices
description: Unsafe Rust is a last resort — encapsulate it behind safe abstractions (ideally in a separate crate), justify why safe code was impossible, document correctness with SAFETY: comments, never consume a poisoned mutex's contents, and never rely on catch_unwind.
tags: [rust, unsafe, safety-comments, ffi, mutex-poison, soundness]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-27"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
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

Write `unsafe` only for one of three reasons: a novel abstraction safe code
cannot express, a benchmarked performance need, or FFI/platform calls.
Reach for std and well-reviewed crates first — they already contain the
audited `unsafe` (`Rc`, `Mutex`, `Pin`, `cxx`). When unsafe is unavoidable:

- **Encapsulate** it behind a safe abstraction, isolated from business
  logic, in the smallest module that can uphold the invariant — the module
  boundary is the soundness boundary. Ideally, unsafe code lives in a
  separate crate with few dependencies beyond `std` — minimizing the
  surface a soundness review must cover.
- **Justify** it, per `unsafe` block or per file/build target: why is this
  not written in safe Rust? If the answer is performance, where are the
  benchmarks?
- **Document** correctness with a comment starting with `SAFETY:` that
  explains why the code is correct — which invariants hold and why. Enable
  `unsafe_op_in_unsafe_fn` so each unsafe op needs its own block.
- **Test adversarially** — run unsafe code under Miri and against hostile
  inputs. A safe function that can cause UB through any sequence of safe
  calls is unsound, and unsound code is never acceptable; if the invariant
  cannot be encapsulated, expose an `unsafe fn` and document the contract.

### Marking `unsafe`

Mark a function or trait `unsafe` only when misuse can cause undefined
behavior — not because the operation is merely dangerous
(`delete_database()` is a safe function). Banned patterns: `transmute` to
cast enums or bypass lifetimes, and `unsafe impl Send`/`Sync` to silence
the compiler.

### Mutex Poison

Never reach inside a poisoned mutex to get at its contents — the data may be
in an inconsistent state left by the panicking thread. Treat
`PoisonError` as a failed invariant, not a convenience bypass
(`into_inner()` is the code smell).

### `catch_unwind`

Do not call `std::panic::catch_unwind` as a control-flow or error-handling
mechanism — it does not exist under `panic=abort` and can leave state
inconsistent. Libraries never catch a panic and continue; servers may
catch per request only to promote a controlled restart. The two
defensible uses are the FFI boundary (below — required, since unwinding
into C is UB) and defense-in-depth around critical entry points where
`panic=unwind` is guaranteed — never *relied* upon for correctness.

### FFI Boundaries

When `unsafe` exists for FFI:

- `#[repr(C)]` on shared structs; sized integer types; `CString`/`CStr`
  for strings; allocate and free on the same side.
- Wrap C-owned pointers in an RAII type whose `Drop` frees them; check
  for null and return `Result`.
- Stop panics at the boundary with `catch_unwind` — unwinding across the
  FFI boundary is UB. This is the one place it is required, and the FFI
  crate still returns `Result` inward.
- Generate bindings with `bindgen` (with `--allowlist-*`) in a `foo-sys`
  crate — `include!` the output and fail CI if a regenerated file differs.
  Keep business logic in a safe core crate; the `-sys`/`-ffi` layer only
  translates types and signatures. For C++, prefer `cxx`. (`-sys` crates
  import C libraries; `-ffi` crates export Rust as a C-style library.)
- Across DLL/shared-library boundaries share only portable data:
  `#[repr(C)]` types with no statics, thread-locals, `TypeId`, or pointers
  to non-portable data.
- Exported functions need `extern "C"`, `#[no_mangle]`, a unique prefix;
  `Box::into_raw`/`from_raw` for ownership transfer; never return stack
  pointers.

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
- [Porting to Rust](porting-to-rust.md) — when FFI is the bridge a port
  must cross
- [Rustfmt and Clippy](rustfmt-clippy-config.md) —
  `undocumented_unsafe_blocks`, `unsafe_op_in_unsafe_fn`,
  `multiple_unsafe_ops_per_block` enforcement
