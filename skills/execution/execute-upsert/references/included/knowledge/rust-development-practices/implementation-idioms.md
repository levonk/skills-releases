---
type: Practice
title: Implementation Idioms
description: Inside-function Rust idioms — prefer unique ownership over Rc/Arc, borrows over clones, enough explicit types to read the code, pattern matching over check-then-unwrap, for loops over convoluted combinator chains, and format!/write! over ad-hoc concatenation.
tags: [rust, idioms, ownership, borrowing, type-inference, pattern-matching, iterators, assertions]
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
  a deep copy — expected usage.) See
  [Ownership and Borrowing](ownership-and-borrowing.md) for the six-step
  ladder to try before cloning.

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

For early-exit paths prefer `let ... else`, which binds the value and keeps
the failure branch visually separate:

```rust
let Some(value) = option else { return default_result(); };
```

`Option` is itself an iterator of zero or one items — `vec.extend(opt)`,
`iter.chain(opt.iter())` — when that is clearer than `if let`.

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
format strings beat ad-hoc templating. Use inline args
(`format!("{name}: {count}")`); `write!` into an existing buffer in hot
paths.

### `Option`/`Result` Combinators vs `match`

Use combinators (`map`, `and_then`, `ok_or_else`, `unwrap_or_else`,
`as_ref`, `as_deref`) when they read clearer than `match`, and `match`
when they do not. Collect fallible iterator steps into
`Result<Vec<_>, E>` and apply `?` — the first error propagates.

### Drop Guards Bind to a Name

Cleanup that must run on early `?` return or unwind belongs in a `Drop`
guard bound to a named variable — `let _guard = ..`. `let _ = ..` drops
immediately. Destructors run on early returns and unwinding but can be
skipped by abort, an infinite loop, or a panic during unwinding — do not
rely on them for essential work.

### Closures Capturing Mixed Ownership

When a closure needs some captures cloned or borrowed and others moved,
rebind in an inner block, then `move`:

```rust
let job = {
    let cfg = cfg.clone();      // cloned
    let data = data.as_ref();   // borrowed
    move || run(cfg, data)      // everything else moves
};
```

### Magic Numbers Become Named Constants

Replace magic numbers with named `const`s carrying a doc comment: where
the value comes from and what changing it affects (external systems
involved, protocol limits, tuning trade-offs).

## Related Concepts

- [Error Handling](error-handling.md) — `expect` vs `unwrap`, panic policy
- [Ownership and Borrowing](ownership-and-borrowing.md) — the
  borrow-checker clone-avoidance ladder
- [API Design Principles](api-design-principles.md) — iterator vs collection
  choices at the signature level
- [Testing Strategy](testing-strategy.md) — assertions in test code
- [Import Organization](import-organization.md) — the `use`-level idioms
  these build on
