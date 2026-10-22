---
type: Practice
title: Implementation Idioms
description: Inside-function Rust idioms — prefer unique ownership over Rc/Arc, borrows over clones, enough explicit types to read the code, pattern matching over check-then-unwrap, for loops over convoluted combinator chains, and format!/write! over ad-hoc concatenation.
tags: [rust, idioms, ownership, borrowing, type-inference, pattern-matching, iterators, assertions]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# Implementation Idioms

## Failure Mode

`Rc`/`Arc` reached for reflexively adds runtime overhead and hides the
ownership story. `.clone()` used to satisfy the borrow checker papers over a
design problem and silently doubles allocation cost. Fully inferred types
make code writeable but unreadable. `is_some()` + `unwrap()` duplicates a
proof the type system could carry. Multi-screen combinator chains obscure
logic a `for` loop states directly.

## Practice

### Ownership and Borrowing

- **Avoid `Rc` and `Arc`** — prefer unique ownership and borrowing. Most
  object graphs do not need shared ownership. Exception: when the
  alternative ownership structure would be unreasonably complex — a
  judgment call for code review.
- **Borrows over deep copies** — `.clone()` when you genuinely need a deep
  copy, never as a borrow-checker workaround; if borrow relationships
  become excessively complex, a clone is the pragmatic choice. Weigh
  performance. (Cloning an `Rc`/`Arc` pointer is a cheap refcount bump, not
  a deep copy — expected usage.)

### Type Inference

Add enough explicit types that a reader familiar with the codebase can tell
what the inferred types are. Prefer type annotations on variable
declarations over turbofish; when the compiler forces a turbofish, a `_`
marker is fine. Always annotate after generic-returning methods
(`.into()`, `.parse()`) and complex iterator chains.

### Pattern Matching Over Check-Then-Unwrap

Let `if let`/`match` carry the proof instead of a runtime check plus
`unwrap` — the match arm proves the invariant to the compiler:

```rust
// Good — the compiler sees `value` cannot be absent
if let Some(value) = option {
    use_value(value);
}

// Bad — unwrap's correctness depends on the is_some() check staying in sync
if option.is_some() {
    use_value(option.unwrap());
}
```

### Iterator Chains vs `for` Loops

Combinators are preferable for short chains and where the combinator itself
carries logic (`any`, `filter_map`, `collect`). Prefer a `for` loop when the
chain mutates external state or grows conditionals. Never build a combinator
chain in a `for` loop header — bind it to a named variable first, and avoid
`Iterator::for_each` without a specific reason.

### Assertions With Context

Use `assert!`'s format-string argument to explain why an invariant should
hold, log the offending value, or flag API misuse (`"Call connect() before
executing queries"`). Do not restate the condition in the message.

### `format!` / `write!` for String Building

Prefer `format!`/`write!` over `+` concatenation (fewer allocations) for
more than two strings, and over `str::replace` for substitution — standard
format strings beat ad-hoc templating.

## Related Concepts

- [Error Handling](error-handling.md) — `expect` vs `unwrap`, panic policy
- [API Design Principles](api-design-principles.md) — iterator vs collection
  choices at the signature level
- [Testing Strategy](testing-strategy.md) — assertions in test code
