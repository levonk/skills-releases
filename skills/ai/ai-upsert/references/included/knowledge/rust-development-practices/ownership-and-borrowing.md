---
type: Practice
title: Ownership and Borrowing Tactics
description: Working with the borrow checker instead of around it — unique ownership first, a six-step ladder before reaching for clone, mem::take/replace to move out of &mut, disjoint field borrows, owned data in structs, freeze-after-setup, and keeping smart pointers out of public signatures.
tags: [rust, ownership, borrowing, borrow-checker, clone, lifetimes, smart-pointers]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Ownership and Borrowing Tactics

## Failure Mode

A `.clone()` added only to end a borrow produces a silent copy whose later
changes are lost — the borrow error is gone but the design problem remains.
`Rc`/`RefCell` reached for reflexively moves borrow checking from compile
time to runtime, where failures panic. Structs holding `&'a T` force a
lifetime parameter onto every container that stores them. `Rc`/`Arc` in
public signatures leak the ownership strategy to callers who should choose
for themselves.

## Practice

### Unique Ownership First

Reach for `Rc`/`Arc` only when shared ownership is part of the design, and
`RefCell`/`Mutex` only when interior mutability is. They are not failures,
but they move checking from compile time to run time — use them on purpose.
Choose the mutation granularity you need: `Rc<Vec<RefCell<T>>>` (shared
collection, per-item mutation) vs `Rc<RefCell<Vec<T>>>` (shared, swapped
wholesale). Use `try_borrow` where a panic is unacceptable.

### Before Cloning for the Borrow Checker

A clone that exists only to make a borrow error go away is a smell. Try
these first, in roughly this order:

1. Extend a temporary with a named `let`, or shorten a borrow with a block.
2. Split a long expression into typed intermediates so the failing step is
   visible.
3. Move a field out of `&mut self` with `std::mem::take` (needs `Default`),
   `std::mem::replace`, or `Option::take` instead of cloning it.
4. Split a large struct into smaller ones so disjoint fields can be
   borrowed separately. The compiler tracks disjoint field borrows inside
   one function, but not across method calls — composing smaller structs
   usually improves the design anyway.
5. Clone small, immutable data deliberately, and say so in a comment if it
   is not obvious.
6. Use indices into an owning `Vec`, or `Rc<RefCell<_>>` with `Weak`
   back-pointers, as a last resort. Avoid self-referential structs
   (`ouroboros` if truly unavoidable).

```rust
// Move out of a &mut enum without cloning.
fn a_to_b(e: &mut MyEnum) {
    if let MyEnum::A { name, x: 0 } = e {
        *e = MyEnum::B { name: std::mem::take(name) };
    }
}
```

### Owned Data in Structs

A struct holding `&'a T` forces a lifetime onto every container. Owning a
`String` or `Vec<u8>` is usually simpler and rarely the bottleneck — prefer
owning and measure before adding a lifetime. `'static` is for globals or
deliberately leaked data (`Box::leak`), not a way to silence the checker.

### Freeze After Setup

Build with `let mut`, then rebind `let data = data;` so later code cannot
mutate by accident.

### Smart Pointers Out of Public Signatures

Keep `Rc`, `Arc`, `Box`, and `RefCell` out of public APIs — take `&T`,
`&mut T`, or `T` and let callers decide how to own things. A service that
must be shared implements a cheap `Clone` by wrapping its state in
`Arc<Inner>` internally; clones then share state.

### On-Stack Dynamic Dispatch

Get `dyn Trait` over differently typed values without `Box` by binding a
reference in an `if` expression (temporary lifetime extension, Rust 1.79+):

```rust
let readable: &mut dyn io::Read = if arg == "-" {
    &mut io::stdin()
} else {
    &mut fs::File::open(arg)?
};
```

## Related Concepts

- [Implementation Idioms](implementation-idioms.md) — avoid `Rc`/`Arc` and
  borrow-checker clones at the statement level
- [API Design Principles](api-design-principles.md) — `&T` vs `T` at the
  signature level; no `&mut` out-parameters
- [Type and Trait Design](type-and-trait-design.md) — `Deref` only for
  smart pointers, never to fake inheritance
- [Concurrency and Async Design](concurrency-and-async-design.md) —
  `Mutex`/`Arc` discipline across threads
