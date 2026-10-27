---
type: Practice
title: Documentation Comments
description: Doc comment standards — /// on items, //! for modules, Markdown formatting, always document panic conditions and unsafe invariants, and never write comments that merely restate the signature.
tags: [rust, documentation, doc-comments, rustdoc, comments]
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

# Documentation Comments

## Failure Mode

Public APIs with no documentation force users to read implementation code.
Comments that parrot the signature (`/// Removes an element` on
`remove_element()`) add noise with zero information. Undocumented panic
conditions and unsafe invariants turn API misuse into runtime failures or
UB. Language-explaining comments signal the writer is padding, not
documenting.

## Practice

### Comment Kinds

- `///` documents the item that follows (functions, structs, enums, traits,
  type aliases)
- `//!` documents the enclosing module or crate — placed at the top of the
  file
- `//` is for implementation comments, TODOs, and anything users should not
  see in rustdoc output
- Use Markdown syntax; prefer `///`/`//!` over generating docs from macros

Mixing doc and ordinary comments on one item is encouraged — public
documentation above, implementation note below:

```rust
/// Finds the first `FooItem` with the given `name`, or `None` if absent.
// TODO: `name` should be &str, not String.
pub fn get_named(items: &[FooItem], name: String) -> Option<&FooItem> { ... }
```

Doc comments are part of the AST — they flow to rustdoc, IDEs, and macros,
and misuse is linted.

### What to Document

Add doc comments to public APIs; the `missing_docs` lint can enforce it.

- **First sentence** — a single line of roughly fifteen words; it becomes
  the item's summary in rustdoc listings
- **Named sections, in order** — `# Examples`, `# Errors` (any `Result`,
  including trait methods whose impls may err), `# Panics` (any reachable
  panic), `# Safety` (required on every `unsafe fn`, listing every caller
  invariant)
- **Examples use `?`, never `unwrap()`** — users copy them verbatim. Hide
  the scaffolding behind `# ` lines:

  ```rust
  /// ```
  /// # use std::error::Error;
  /// # fn main() -> Result<(), Box<dyn Error>> {
  /// let value = parse_it("...")?;
  /// # Ok(())
  /// # }
  /// ```
  ```

- **What the signature cannot say** — preconditions, side effects,
  ownership transfer, complexity, and *why*. Describe parameters in prose,
  not a table.
- **Cross-references** — link items in prose with `` [`Type`] ``; hide
  impls users never trigger (`From<PrivateError> for PublicError`) behind
  `#[doc(hidden)]`
- **Module docs** — every public module gets `//!`: what it contains, when
  to use it, examples, observable side effects
- Capitalization and punctuation — write prose, not fragments

### `//` Implementation Comments

Explain *why*, not *what*: `// SAFETY:` on unsafe blocks,
`// TODO(issue-123):`, non-obvious magic values (name the `const` and say
where the value comes from and what changing it affects), workarounds
with a link. No design journals, "why we chose X" essays, or
rule-compliance tables (`Rule | Applied | Where`) in code docs — document
the end state.

### What to Omit

- Comments that restate the signature — `/// Removes an element` on
  `pub fn remove_element()` adds nothing; omit the comment (or `allow` the
  lint)
- Language basics — `/// A mock implementation of the FileSystem trait` on
  `impl FileSystem for MockFileSystem` explains Rust, not the code
- Self-explanatory enum variants — individual variant docs are optional

## Related Concepts

- [Unsafe Code Practices](unsafe-code-practices.md) — the invariants doc
  comments must state
- [Testing Strategy](testing-strategy.md) — doc examples double as doc tests
- [API Stability Attributes](api-stability-attributes.md) — `#[doc(hidden)]`
