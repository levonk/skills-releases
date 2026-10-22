---
type: Practice
title: API Stability Attributes
description: Attributes that protect public API evolution — #[non_exhaustive] on cross-team enums and public-field structs, #[must_use] on functions and types, const fn as a stability commitment, #[doc(hidden)] treated as private, no unstable features, and no code before main().
tags: [rust, api-stability, non_exhaustive, must_use, semver, attributes, const]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# API Stability Attributes

## Failure Mode

Adding a variant to a public enum breaks every downstream `match` — a
semver-major change disguised as a feature addition. Pure functions whose
return values are dropped silently do nothing. A `const fn` reverted to a
plain fn is a breaking change nobody tracked. `#[doc(hidden)]` items treated
as public API create invisible coupling to internals that were never
committed to.

## Practice

### `#[non_exhaustive]` on Public Enums

Mark `#[non_exhaustive]` on enums in a public API used by other teams —
forces a wildcard arm so adding variants does not break compilation.
Exceptions:

- Enums describing a fixed ontology (`enum Color { Red, Green, Blue }`) or
  two-state enums equivalent to booleans
- You are committed to fixing all downstream breakage when the enum changes

Related: when matching a `#[non_exhaustive]` enum, list the variants you
handle explicitly and fold the rest into the wildcard arm
(`Shape::Triangle | _ => {}`) rather than a bare `_ => {}` — the
`non_exhaustive_omitted_patterns` lint (opt-in) enforces this. If only
specific variants matter, use `if let` or `let ... else`.

### `#[non_exhaustive]` on Public Structs With Public Fields

Mark `#[non_exhaustive]` on all-public-field structs in a cross-team API —
struct literals can then only be built inside the defining crate, so new
(private) fields are non-breaking. Exceptions: fixed-ontology structs,
committed breakage repair, or when you deliberately want users to have
functional record update (`Foo { a: 1, ..Default::default() }`).

### `#[must_use]`

- **Functions**: annotate when the caller cannot use the function correctly
  while ignoring the result — pure functions (`HashMap::get`) and any
  function returning error or critical status information. Skip when the
  return type is already `#[must_use]` (e.g., `Result`).
- **Types**: annotate types designed to be returned by `#[must_use]`-worthy
  functions — error types and lazily-evaluated computations.

### `const fn` Is a Commitment

Mark a public function `const` only if it is expected to remain `const` (or
you commit to migrating clients) — removing `const` is a breaking change.

### `#[doc(hidden)]` Is Private

Treat items marked `#[doc(hidden)]` as private. Never access them unless you
own the code — they are not part of the API contract.

### No Unstable Features

Do not use unstable compiler features; exceptions require explicit review
and a plausible path to stabilization.

### No Code Before `main()`

Do not run code before `main()` — no `ctor`-crate style pre-main
initialization.

## Related Concepts

- [Type and Trait Design](type-and-trait-design.md) — trait impl checklist
- [Unsafe Code Practices](unsafe-code-practices.md) — soundness boundaries
- [Cargo Configuration](cargo-configuration.md) — feature flag discipline
