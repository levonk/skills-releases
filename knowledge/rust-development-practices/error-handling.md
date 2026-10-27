---
type: Practice
title: Error Handling
description: Use thiserror for structured error types, anyhow for context, implement From traits, and never panic in library code except for unrecoverable logic errors.
tags: [rust, error-handling, thiserror, anyhow, panic, result]
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

# Error Handling

## Failure Mode

Panics in library code crash applications. Unstructured errors (String, Box<dyn
Error>) prevent callers from matching on error variants. Missing From
implementations force callers to manually convert errors.

## Practice

### Structured Error Types with thiserror

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum PackageError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Parse error: {0}")]
    Parse(String),

    #[error("Validation error: {field} - {message}")]
    Validation { field: String, message: String },

    #[error("Configuration error: {0}")]
    Config(String),
}

pub type Result<T> = std::result::Result<T, PackageError>;
```

### Patterns

- Use `thiserror` for structured error types
- Implement `From` traits for error conversion (via `#[from]`)
- Provide context with `anyhow`'s `context()` method when appropriate
- **Never** use `panic!` in library code except for unrecoverable logic errors

### Choosing the Reporting Mechanism

Pick the mechanism that fits the API contract:

- **`Option` — simple, obvious failure.** The cause is self-evident and the
  caller gains nothing from details: a missing value, a parse mismatch,
  `checked_add` overflow.
- **`Result` — recoverable failure needing context.** Unavoidable errors
  from external factors (I/O, network) that correct code cannot prevent —
  the caller distinguishes failure modes (`NotFound` vs
  `PermissionDenied`) and recovers.
- **`panic!` — bugs and violated invariants.** Avoidable defects where the
  caller failed a precondition (`remove(index)` out of bounds). These are
  fixed in code, not handled at runtime. Exceptions: developer-facing
  binaries may panic for non-fatal errors; tests may panic for assertions.

### Panic Discipline

- **Prefer `expect` over `unwrap`** — when a panic is necessary because an
  invariant cannot be expressed in the type system, `expect("reason")`
  documents why the panic is impossible
- **Every intentional panic carries the relevant values** —
  `assert!(buf.len() >= HEADER, "buffer too small: {} bytes", buf.len())`.
  Do not restate the condition as the message; state why the invariant
  should hold or log the offending value.
- **Panics are not exceptions** — a panic means "stop now". Never use one
  to report bad input a caller could act on, and never catch and continue
  inside a library. Where a panicking convenience is justified, pair it
  with a fallible API (`get`/`get_unchecked`, `new`/`try_new`) and document
  it under `# Panics`.
- **Lock poisoning is fatal** — `.lock().expect("lock poisoned")`; do not
  recover with `into_inner`. See
  [Unsafe Code Practices](unsafe-code-practices.md).
- **Never `catch_unwind` for control flow** — it is not an error-handling
  mechanism and does not exist under `panic=abort`; the FFI boundary is the
  one legitimate use. See
  [Unsafe Code Practices](unsafe-code-practices.md).
- **Prefer pattern matching over check-then-unwrap** — see
  [Implementation Idioms](implementation-idioms.md)

### Library Error Type Requirements

Any `E` in a public `Result<T, E>`:

- Implements `std::error::Error` (which requires `Debug` + `Display`), is
  `Send + Sync + 'static`, and implements `source()` for wrapped causes.
  Never `()`, `String`, or `Box<dyn Error>` as a public error type.
- `Display` messages are lowercase, concise, no trailing punctuation:
  `"invalid header length"`.
- Implements `From<Upstream>` so `?` converts — `map_err` only for foreign
  errors or to add context.
- Two sound shapes: an enum with one variant per cause (`thiserror`
  generates this well), or a situation-specific struct with a private
  `kind`, a captured `Backtrace`, and `is_xxx()`/accessor methods. Do not
  build one crate-wide enum listing every failure mode, and do not expose
  details callers cannot act on.
- If a fallible function consumes an argument, return it inside the error
  so the caller can retry without cloning
  (`FromUtf8Error::into_bytes`).

Application code uses `anyhow`/`eyre` with `.context("...")` — one
app-level error type, not several; `main` may return
`Result<(), anyhow::Error>`. Never expose `anyhow::Error` in a library's
public API — see
[Anyhow + Thiserror Combination](anyhow-thiserror-combination.md).

### Destructors Never Fail

`Drop` impls never fail, panic, or block — a failure during unwinding
aborts. Provide `close(self) -> Result<()>` for fallible teardown and let
`Drop` do best-effort cleanup. Document failure modes: `# Errors` on any
`Result`, `# Panics` on any reachable panic, `# Safety` on every
`unsafe fn`.

## Related Concepts

- [Anyhow + Thiserror Combination](anyhow-thiserror-combination.md) —
  layered error handling across the library/application boundary
- [Project Structure](project-structure.md) — error.rs module placement
- [Cargo Configuration](cargo-configuration.md) — thiserror as workspace dependency
- [Implementation Idioms](implementation-idioms.md) — check-then-unwrap
  avoidance
- [Unsafe Code Practices](unsafe-code-practices.md) — mutex poison and
  `catch_unwind` policy
