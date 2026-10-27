---
type: Practice
title: Builders and Constructors
description: Construction API design — provide new() even when Default exists and make them agree, inherent constructors for up to two optional parameters, a builder beyond that with field-named infallible setters and build() -> Result doing all validation, and semantic types when a constructor has four or more loose arguments.
tags: [rust, constructors, builder-pattern, api-design, default, validation]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Builders and Constructors

## Failure Mode

Constructor proliferation (`new`, `new_with_a`, `new_with_a_b`,
`new_with_a_b_c`, …) doubles with each optional parameter. A `build()` that
panics or a setter that can fail pushes validation into call sites. Four or
more loose `&str`/`u64` arguments invite swapped parameters the compiler
cannot catch. A `Default` that disagrees with `new()` surprises callers who
assumed the two were interchangeable.

## Practice

### `new()` and `Default` Agree

Provide `new()` even when `Default` exists — one delegates to the other so
they behave identically. Derive or implement `Default` so callers can write
`..Default::default()`; bag-of-options structs with public fields should
always have it. Only one `Default` per type — use named constructors for
other starting states.

### When to Introduce a Builder

- **Up to two optional parameters**: inherent constructors — `new`,
  `with_a`, `with_b` (and `with_a_b` if needed).
- **Beyond that**, or when construction validates or has side effects: a
  builder. Introduce `TBuilder` for many inputs, compound data, optional
  config, several flavors, or side effects on build. The `derive_builder`
  crate removes the boilerplate.
- **Four or more loose arguments**: group them into semantic types —
  `Deposit::new(account, amount)` rather than four `&str`/`u64` parameters
  that callers can silently swap. Required parameters may arrive through
  `deps: impl Into<FooDeps>`.

### Builder Shape

```rust
let client = Client::builder()
    .timeout(Duration::from_secs(5))
    .retries(3)
    .build()?;              // all validation happens here
```

- `Foo::builder()` returns `FooBuilder`; `FooBuilder::new()` is not public.
- Setters are named after fields (`timeout(d)`, not `set_timeout`) and are
  infallible — they store, they do not validate.
- `build() -> Result<Foo, Error>` does all validation, including
  cross-field checks.
- Prefer non-consuming setters (`&mut self -> &mut Self`) — they allow
  staging a builder and conditional configuration. Use consuming setters
  (`self -> Self`) only when `build` must move a value out; a repeatable
  `build(&self)` must construct a fresh value each call.

### Constructors Beyond `new`

- `with_capacity` / `new_with_foo` for variants; `try_new` for fallible.
- `from_foo` for conversions — pair important ones with a `From` impl (see
  [Type and Trait Design](type-and-trait-design.md)).
- I/O resources use domain verbs: `File::open`, `TcpStream::connect`.
- Conversion constructors may be `unsafe` (`Box::from_raw`) or take extra
  arguments (`u64::from_str_radix`), unlike `From`.

## Related Concepts

- [Rust Naming Conventions](rust-naming-conventions.md) — `new`/`try_new`/
  `from_foo` naming rules
- [Type and Trait Design](type-and-trait-design.md) — `Default`, `From`,
  and the standard trait checklist
- [API Design Principles](api-design-principles.md) — enum over `bool`
  parameters; strongest std types for grouped arguments
