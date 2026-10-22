---
type: Practice
title: Rust Naming Conventions
description: Naming rules — as_/to_/into_ conversion prefixes with matching self convention, descriptive lifetimes, short indicative generic parameters, ~Ext extension trait suffix, new()/try_new()/from_foo() initialization, getter/setter conventions, and no obscure abbreviations.
tags: [rust, naming, conventions, methods, lifetimes, generics, getters, setters]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# Rust Naming Conventions

## Failure Mode

Inconsistent conversion names (`to_foo` that consumes, `into_foo` that
borrows) mislead callers about cost and ownership. Single-letter lifetimes
on type declarations hide intent. `new2`, `init_foo`, and ad-hoc constructor
names make APIs unguessable. Abbreviations that are obvious to the author
are opaque to every reader after them.

## Practice

### Method Names

Follow Rust standard library conventions. Use conversion prefixes with the
matching `self` convention (clippy: `wrong_self_convention`):

- `as_...()` — borrowed view, `&self` (cheap)
- `to_...()` — conversion producing a new owned value, `&self`
- `into_...()` — consuming conversion, `self`

### Getters and Setters

- `foo()` — getter returning `T` by value (or `&T`)
- `foo_mut()` — getter returning `&mut T`
- `take_foo()` — clears the value (`None`/default) and returns the old one
- `set_foo(foo: T)` — setter taking `T` by value
- `replace_foo(foo: T) -> T` — setter returning the old value
- `with_foo(|foo| ...)` / `with_mut_foo(|foo| ...)` — closure-based access;
  forwards the closure's return value

Closure accessors are the right choice when the property lives behind
interior mutability (`Mutex`, `RefCell`) — the closure bounds the borrow
scope without leaking `MutexGuard` — or when post-change validation is
needed and `set_foo()` cannot express it (un-cloneable or expensive type).

### Lifetimes

Use descriptive names, especially for type lifetimes. Single-character
lifetimes are acceptable only when they merely relate a method's input to
its output or for local `for<'a>` bounds — up to two; more require
descriptive names. Anonymous `'_` is fine where it compiles. Extremely
generic abstractions (`Cow`) may keep single letters.

### Generic Parameters

Short names related to what they represent; single letters should hint at
the most important trait bound. `T`/`U` are fine in broadly unbound APIs
like `Vec<T>`.

### Initialization Functions

- `new()`, or `new_with_foo()` when there are several constructors
- `try_new()` when the constructor returns `Result`
- `from_foo()` for value-to-value conversions, paired with a `From` impl

### Extension Traits

Name extension traits with the `~Ext` suffix — see
[Type and Trait Design](type-and-trait-design.md).

### Avoid Abbreviations

Do not use abbreviations an outsider would not know; do not delete letters
within words. Exceptions: abbreviations common enough for Wikipedia, and
domain-obvious ones like `IpAddr` (reviewer judgment — preference is still
not to abbreviate).

## Related Concepts

- [Type and Trait Design](type-and-trait-design.md) — extension traits,
  `From` + constructor pairing
- [API Design Principles](api-design-principles.md) — signature-level
  choices these names expose
- [Documentation Comments](documentation-comments.md) — documenting the
  named API
