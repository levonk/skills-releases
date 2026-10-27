---
type: Practice
title: Type and Trait Design
description: Type system usage — newtypes over aliases for semantic types, named fields over tuples, derive over manual impls, std traits over custom methods, generics over dyn Trait, extension traits with ~Ext suffix, and the standard trait impl checklist (Copy, Clone, Default, Eq, Ord, Hash).
tags: [rust, traits, newtype, generics, derive, extension-traits, api-design]
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

# Type and Trait Design

## Failure Mode

Type aliases for semantically distinct values let `Day` and `Month` mix
silently. Tuple fields (`.0`, `.1`) decay into unreadable code. Custom
`from_str` methods duplicate std traits and miss ecosystem integration.
`dyn Trait` parameters add vtable indirection and block inlining. Traits
used to organize code create abstraction debt with no generic payoff.

## Practice

### Newtypes vs Type Aliases

Use a newtype (not a type alias) when the type has semantic differences,
warrants its own API, needs freedom to change the underlying type, or could
be confused with a sibling type (e.g., `Day` vs `Month` inside a `Date`).

### Named Fields Over Tuples

Prefer named fields — tuple indexes confuse quickly. Exceptions: newtype
tuple structs (single field) and very local contexts.

### Standard Trait Checklist

Downstream crates cannot add std traits to your types (orphan rule), so you
must — eagerly, wherever every field supports it:

- **`#[derive()]` first** — avoid manual impls that a derive can express
- **Std traits over custom methods** — if a method matches a std trait's
  purpose, implement the trait (`impl FromStr`, not `fn from_str`). Keeping
  both is acceptable for discoverability (clippy: `should_implement_trait`)
- **`Debug`** — on every public type; hand-write it to redact secrets, plus
  a test asserting the secret never appears in output
- **`Clone`** — for most types; skip unique-access resources and key
  material
- **`Copy`** — only small, bitwise-copyable plain types (the compiler
  copies silently); especially valuable for error types propagated by value
- **`Default`** — when the type has `new()` or a default state (clippy:
  `new_without_default`); options structs must implement it for
  `..Default::default()` syntax
- **`Display`** — for anything meant to be read: error types, string-like
  wrappers
- **`PartialEq` + `Eq`** — prefer `PartialEq` for `==` users; add `Eq` when
  reflexive (not floats)
- **`PartialOrd` + `Ord`** — never ship `PartialOrd` without `Ord` when a
  total order exists
- **`Hash` consistent with `Eq`** — when the type may key a map or be
  cached
- **Expected API sets** — `len()` implies `is_empty()` (clippy:
  `len_without_is_empty`)
- **`#[must_use]`** — on pure functions and on types (errors, lazy values)
  whose discarding is a bug; see
  [API Stability Attributes](api-stability-attributes.md)

**Hand-written ordering/consistency contract.** If you hand-write `Ord`,
hand-write `PartialEq`, `PartialOrd`, and `Hash` to agree with it —
compare the same fields, ignore the same fields. A derived `PartialEq`
next to a custom `Ord` breaks the std contract and misbehaves in
`BTreeMap` and `sort`/`dedup`. Document which fields equality ignores.

### Conversion and Collection Traits

- Implement `From`/`TryFrom`, never `Into`/`TryInto` directly — blanket
  impls supply those. `From` for lossless, `TryFrom` for fallible; prefer
  them over `as`, which silently permits lossy casts.
- Implement `FromStr` rather than an ad-hoc `from_str` method.
- Collections implement `FromIterator` + `Extend` (so `collect`,
  `partition`, `unzip` work) and `IntoIterator` for both owned and borrowed
  forms; `size_hint()` is truthful.
- Implement `Deref`/`DerefMut` only on smart pointers and owning
  collections (`Vec<T>` → `[T]`, `String` → `str`) — never to fake
  inheritance. Write explicit forwarding methods or a trait instead.
- Overload `std::ops` operators only for their mathematical meaning
  (`Mul` should be associative).
- Smart pointers add no inherent methods — associated functions
  (`Box::into_raw(b)`, not `b.into_raw()`), so a call cannot be ambiguous
  with the pointee.

### No Derivable Bounds on Struct Definitions

`#[derive(Clone)] struct Good<T>`, not `struct Bad<T: Clone + Debug>` —
bounds belong on the `impl` blocks that need them. Never bound a data
structure by `Clone`, `PartialEq`, `PartialOrd`, `Debug`, `Display`,
`Default`, `Error`, `Serialize`, or `Deserialize`. Exceptions:
associated-type references, `?Sized`, a `Drop` impl that needs the bound.

### Generics vs `dyn Trait`

In libraries, accept generics (`T: Trait` or `impl Trait`) over `dyn Trait` —
vtable indirection costs performance, blocks inlining, and many traits are
not dyn-compatible. Exception: cases where code size matters.

### Trait vs Inherent Implementation

Define a trait only to enable generic programming (`T: Trait` bounds),
to accept/return `impl Trait` or `dyn Trait`, or to define an extension
trait. For everything else use an inherent `impl` block. Do not use traits
merely to organize code. Put essential functionality in inherent methods
and have trait impls forward to them, so callers need no import.

Keep required trait methods minimal and provide defaults for everything
derivable from them — `Iterator` builds 50+ methods on `next`. Adding a
defaulted method is usually backward compatible.

### Object Safety Decided Early

Decide early whether a trait must be object-safe. Generic methods and
`Self` outside the receiver break it; exclude such methods with
`where Self: Sized` so the rest of the trait stays usable as `dyn`:

```rust
trait MyTrait {
    fn object_safe(&self, i: i32);
    fn not_object_safe<T>(&self, t: T) where Self: Sized;
}
```

### Methods vs Free Functions

If a function has a clear receiver, make it a method — methods need no
import, autoborrow, and express ownership through `self`. A computation
with no receiver is a free function, not `Database::check(params)`.
Associated functions are for construction. For closures take the most
general bound that works (`FnOnce` if called once, `FnMut` if it mutates,
else `Fn`), prefer `Fn*` bounds to bare `fn` pointers, put closure
parameters last, and take at most one. Keep parameter order consistent
across a crate: call-specific first, ubiquitous context (loggers,
allocators) last.

### Extension Traits

An extension trait adds methods to a foreign type and is not intended for
generic bounds or `dyn`. Name it with the `~Ext` suffix (`ForeignTypeExt`).
The team owning the original type should own the extension trait —
same-owner code avoids method name conflicts between base type and
extensions. Extension traits may also blanket-impl over a foreign trait
(`impl<T: ForeignTrait> ForeignTraitExt for T`).

### Pair `From` Impls With Explicit Constructors

If a `From` impl is a primary construction path, also provide
`::new()`, `::new_from_foo()`, or `::from_foo()` — explicit constructors are
discoverable in ways trait impls are not.

### Add Trait Impls When Needed

Low-level libraries anticipate users' needs; application code adds impls as
requirements emerge.

## Related Concepts

- [API Design Principles](api-design-principles.md) — parameter and return
  type choices
- [Rust Naming Conventions](rust-naming-conventions.md) — `~Ext` suffix,
  `as_`/`to_`/`into_` prefixes
- [API Stability Attributes](api-stability-attributes.md) —
  `#[non_exhaustive]`, `#[must_use]`
- [Builders and Constructors](builders-and-constructors.md) — `new()`/
  `Default` agreement, builder shape
- [Visibility and API Evolution](visibility-and-api-evolution.md) — sealed
  traits, object-safety breaking changes
