---
type: Practice
title: API Design Principles
description: Function signature design — accept flexible reference types, prefer iterators for reusable code, impl Into only when call-site ergonomics matter, and enum over bool for unclear parameters. API design rules are binding for libraries, strong recommendations for application code.
tags: [rust, api-design, function-signatures, iterators, generics, library-design]
date:
  created: "2026-10-21"
  knowledge-basis: "2026-10-21"
  last-used: "2026-10-21"

sources:
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# API Design Principles

## Failure Mode

Signatures that demand concrete containers (`&Vec<T>`, `&String`, `&Box<T>`)
force callers to copy data into a specific shape first. Eagerly returned
`Vec<T>` values allocate when the caller would have streamed. `bool`
parameters make call sites unreadable (`frobnicate(x, true)`). Over-applied
`impl Into<T>` bloats binaries and obscures signatures. The compounding cost
is APIs that are harder to call, slower than they need to be, and painful to
refactor.

## Practice

### Apply API Rules in Context

Distinguish **library code** (general problem, used by other projects) from
**application code** (specific problem, single app). API design rules are
binding for library code; for application code they are a strong
recommendation — favor simplicity and directness over premature
generalization.

### Accept Flexible References for Immutable Data

Pass references to the data itself, not to smart pointers, containers, or
wrappers:

| Use         | Instead of   | Why                                           |
|-------------|--------------|-----------------------------------------------|
| `&T`        | `&Box<T>`    | Borrow the data inside the box                |
| `&[T]`      | `&Vec<T>`    | Accept any slice, not one container           |
| `&str`      | `&String`    | Accept a string slice, not an owned string    |
| `Option<&T>`| `&Option<T>` | Borrow the data inside the Option             |

Exception: non-linear character data (Rope/Cord). See clippy lints
`borrowed_box` and `ptr_arg`.

### Iterators vs Owned Collections in Returns

Library code should return iterators (concrete types or `impl Iterator`)
over `Vec<T>` — callers choose whether to collect, loop, or chain.
Exceptions: most callers need an owned vector, the implementation naturally
builds a vector, the result needs random indexing, or the function's purpose
is producing a collection. Application code may return `Vec<T>` when it is
simpler.

### Iterators vs Slices in Parameters

Reusable library code that only needs to iterate should accept iterators or
`impl IntoIterator` — flexibility (any collection), efficiency (no copy into
contiguous memory), composability. Application code may accept `&[T]` when
simpler.

### Accepting `Into`

Library APIs may accept `impl Into<T>` when **call-site ergonomics are
paramount** — e.g., `impl Into<String>` accepts both `String` and `&str`.
Balance against generic code bloat and harder-to-read signatures.
Application code should almost never use `impl Into<T>` parameters.

### Prefer `enum` Over `bool` in APIs

Use an enum parameter where the purpose of a `bool` is not obvious at the
call site. If a `bool` is used anyway, add an inline comment at the call
site naming what it controls.

## Related Concepts

- [Type and Trait Design](type-and-trait-design.md) — generics vs `dyn`,
  trait vs inherent impl, extension traits
- [Rust Naming Conventions](rust-naming-conventions.md) — getter/setter and
  conversion method naming
- [Error Handling](error-handling.md) — `Option` vs `Result` vs `panic!`
  return-type selection
