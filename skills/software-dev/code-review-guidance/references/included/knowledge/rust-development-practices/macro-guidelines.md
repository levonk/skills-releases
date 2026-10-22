---
type: Practice
title: Macro Guidelines
description: Prefer plain Rust over metaprogramming — the escalation order is functions/types/traits, then macro_rules!, then code generation, then proc macros, weighed against real costs to tooling, readability, and refactors.
tags: [rust, macros, metaprogramming, proc-macro, macro-rules, code-generation]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
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
4. **Procedural macros** — last resort

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
