---
type: Practice
title: Error Handling
description: Use thiserror for structured error types, anyhow for context, implement From traits, and never panic in library code except for unrecoverable logic errors.
tags: [rust, error-handling, thiserror, anyhow, panic, result]
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
- **Never `catch_unwind`** — it is not an error-handling mechanism and does
  not exist under `panic=abort`; see
  [Unsafe Code Practices](unsafe-code-practices.md)
- **Prefer pattern matching over check-then-unwrap** — see
  [Implementation Idioms](implementation-idioms.md)

## Related Concepts

- [Anyhow + Thiserror Combination](anyhow-thiserror-combination.md) —
  layered error handling across the library/application boundary
- [Project Structure](project-structure.md) — error.rs module placement
- [Cargo Configuration](cargo-configuration.md) — thiserror as workspace dependency
- [Implementation Idioms](implementation-idioms.md) — check-then-unwrap
  avoidance
- [Unsafe Code Practices](unsafe-code-practices.md) — mutex poison and
  `catch_unwind` policy
