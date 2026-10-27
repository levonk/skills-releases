---
type: Practice
title: Macro Guidelines
description: Prefer plain Rust over metaprogramming — the escalation order is functions/types/traits, then macro_rules!, then code generation, then proc macros, weighed against real costs to tooling, readability, and refactors.
tags: [rust, macros, metaprogramming, proc-macro, macro-rules, code-generation]
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

# Macro Guidelines

## Failure Mode

Macros reached for early create private dialects of Rust that resist IDE
navigation, code search, and automated refactoring. A proc macro where a
function would do adds a compile-time dependency, slower builds, and worse
error messages. Metaprogrammed APIs are harder to write correctly and
harder for readers to reason about — a reader cannot apply normal Rust
assumptions to macro-generated code.

## Practice

### Escalation Order

When deciding how to express an API, prefer in order:

1. **Regular Rust** — functions, types, traits, objects, modules (avoid
   macros, codegen, and metaprogramming where possible)
2. **`macro_rules!` macros** — operate on the AST, less fragile than
   textual codegen; the right tool for simple code generation
3. **Other code generation** — e.g., build-script or genrule approaches
4. **Procedural macros** — last resort. Prefer a derive macro to a proc
   macro that emits a new type, and check `strum`, `enumn`, `num_enum`
   before writing one at all.

### `macro_rules!` Etiquette

- **Input resembles output** — a macro's input should look like the code it
  generates (`struct S: u32 { .. }`); const-like items end in `;`.
- **Accept attributes on each emitted item** so `#[cfg(..)]` and
  `#[derive(..)]` pass through.
- **Work at any scope** — item macros must work at module and function
  scope; emitting `super::U` breaks inside a function. A `$t:ty` fragment
  must accept primitives, relative and absolute paths, `super::`, and
  generics — do not emit a nested `pub mod` that cannot see local types.
- **Emitted items are private** unless the input says `pub`.
- **Keep control flow visible** — macros can insert `return`, `?`, or
  mutations at the call site; bind expression arguments with `let` to
  avoid re-evaluation.
- **Never let a macro change a type's kind**, alter a function signature,
  or add/remove `async`. Macros do not generate hidden or extra public
  items.

### Procedural Macro Crate Layout

- Structure as three crates: `foo` (public API, re-exports), `foo_proc`
  (thin facade), `foo_proc_impl` (the logic and its tests). Snapshot-test
  the expansion with `insta`; test error messages with `trybuild`.
- Pin companion macro crates with `=x.y.z` and publish them together.
- Generated code reaches third-party items through a hidden
  `#[doc(hidden)] pub mod _private { pub use ::bar::Bar; }` — do not
  support renamed imports.

### Costs to Weigh

Before choosing a macro or codegen, weigh against:

- **Tooling degradation** — IDEs, code search, and cross-reference tools
  work less well on macro code
- **Language dialects** — macros create local variants of Rust that raise
  the cost of working across the codebase
- **Refactor friction** — large-scale changes are harder and more expensive
  to apply over macro-heavy code

## Related Concepts

- [Type and Trait Design](type-and-trait-design.md) — `#[derive()]` over
  manual impls is the sanctioned metaprogramming path
- [Testing Strategy](testing-strategy.md) — `macro_rules!` used for test
  helpers (e.g., the `async_test!` macro)
- [Import Organization](import-organization.md) — macros and generated code
  are exempt from unqualified-type rules
