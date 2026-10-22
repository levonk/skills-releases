---
type: Practice
title: Type and Trait Design
description: Type system usage — newtypes over aliases for semantic types, named fields over tuples, derive over manual impls, std traits over custom methods, generics over dyn Trait, extension traits with ~Ext suffix, and the standard trait impl checklist (Copy, Clone, Default, Eq, Ord, Hash).
tags: [rust, traits, newtype, generics, derive, extension-traits, api-design]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
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

- **`#[derive()]` first** — avoid manual impls that a derive can express
- **Std traits over custom methods** — if a method matches a std trait's
  purpose, implement the trait (`impl FromStr`, not `fn from_str`). Keeping
  both is acceptable for discoverability (clippy: `should_implement_trait`)
- **`Copy`** — implement when the type will reasonably stay `Copy`;
  especially valuable for error types (propagate by value)
- **`Clone`** — implement for most types unless they represent an external
  resource
- **`Default`** — implement when the type has `new()` or a default state
  (clippy: `new_without_default`). Options structs (all-public-field bags)
  must implement `Default` to enable `..Default::default()` syntax
- **`PartialEq` before `Eq`** — prefer `PartialEq` for `==` users; `Eq`
  requires reflexivity
- **`PartialOrd` before `Ord`** — `Ord` requires total ordering
- **Map keys** — implement `Hash` + `Eq` if the type may key a map or be
  cached; add `Ord` too when a clear total ordering exists
- **Expected API sets** — `len()` implies `is_empty()` (clippy:
  `len_without_is_empty`)

### Generics vs `dyn Trait`

In libraries, accept generics (`T: Trait` or `impl Trait`) over `dyn Trait` —
vtable indirection costs performance, blocks inlining, and many traits are
not dyn-compatible. Exception: cases where code size matters.

### Trait vs Inherent Implementation

Define a trait only to enable generic programming (`T: Trait` bounds),
to accept/return `impl Trait` or `dyn Trait`, or to define an extension
trait. For everything else use an inherent `impl` block. Do not use traits
merely to organize code.

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
