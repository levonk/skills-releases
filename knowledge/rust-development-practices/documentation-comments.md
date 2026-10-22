---
type: Practice
title: Documentation Comments
description: Doc comment standards — /// on items, //! for modules, Markdown formatting, always document panic conditions and unsafe invariants, and never write comments that merely restate the signature.
tags: [rust, documentation, doc-comments, rustdoc, comments]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
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

- **Panic conditions** — always document for functions that may panic on
  malformed input
- **Unsafe invariants** — clearly document for `unsafe fn` and `unsafe
  trait` what callers must uphold
- **Examples** — not every function, but enough coverage somewhere to show
  how the crate works
- Capitalization and punctuation — write prose, not fragments

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
