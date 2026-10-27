---
type: Practice
title: Visibility and API Evolution
description: How public APIs stay evolvable — private by default with the pub(crate) ladder, sealed traits, exactly one path per public item, foreign re-export rules, the semver breaking-change list, and deprecate-in-minor before removing in major.
tags: [rust, visibility, api-evolution, semver, sealed-traits, re-exports, msrv]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Visibility and API Evolution

## Failure Mode

Every `pub` item is a promise. Fields made public for convenience lock in
the representation and block invariants forever. Two paths to the same type
(`pub mod db { pub struct Connection; }` plus `pub use db::Connection;`)
confuse docs and let refactors silently multiply. An enum variant or struct
field added in a "minor" release breaks every downstream `match` — a
semver-major change disguised as a feature. Traits left unsealed can never
grow a method.

## Practice

### Private by Default

Widen visibility only as needed: `pub(crate)`, `pub(super)`, or
`pub(in path)` before `pub`. Making an item more public later is
non-breaking; narrowing is breaking. Fields stay private unless the struct
is passive C-style data — a public field fixes the representation. `pub` on
an enum or trait exposes all variants and methods at once.

### Seal Traits You Own

Seal traits you do not want implemented downstream, and say so in the docs
— it lets you add methods without breaking users:

```rust
pub trait TheTrait: private::Sealed { /* ... */ }
mod private {
    pub trait Sealed {}
    impl Sealed for usize {}
}
```

### One Path Per Public Item

Expose each public item at exactly one path — do not combine
`pub mod db { pub struct Connection; }` with `pub use db::Connection;` (a
`pub(crate) mod` feeding a single `pub use` is fine). Hide implementation
iterator types behind `impl Iterator<Item = T>` (internal APIs) or a
newtype (public APIs that must stay stable). See
[API Stability Attributes](api-stability-attributes.md) for
`#[non_exhaustive]` — the other half of evolution-proofing.

### Foreign Re-exports

Do not `pub use` another crate's items — users should depend on it
directly. Exceptions: umbrella crates, technical splits, and hidden
`#[doc(hidden)] pub mod _private` paths for macro-generated code. If a
dependency's type must appear in your public API, re-export the crate
(`pub use rand;`) so callers can name the matching version — a caller on a
semver-incompatible copy otherwise gets a confusing "trait bound not
satisfied". Prefer std types at API boundaries; feature-gate third-party
types (`serde` impls behind a `serde` feature).

### Semver Breaking Changes

Any of these requires a major bump:

- Removing or renaming a public item
- Adding a variant to an enum that is not `#[non_exhaustive]`, or a field
  to a publicly constructible struct
- Adding a trait bound, or making a trait non-object-safe
- Adding a blanket impl
- Changing the license or the default feature set

Deprecate in a minor release before removing in a major one. Use the
latest stable edition for new crates and set an MSRV (`rust-version`)
deliberately — raise it conservatively in minor releases.

## Related Concepts

- [API Stability Attributes](api-stability-attributes.md) —
  `#[non_exhaustive]`, `#[must_use]`, `const fn` commitments
- [Project Structure](project-structure.md) — leaf/non-leaf modules and
  re-export placement
- [Cargo Configuration](cargo-configuration.md) — additive features,
  `rust-version`, dependency visibility
- [Type and Trait Design](type-and-trait-design.md) — object safety
  decisions that affect evolution
