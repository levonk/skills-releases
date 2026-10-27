---
type: Practice
title: Porting Code to Rust
description: Port behavior, not structure — inventory observable behavior before writing, port the tests first so "same behavior" is checkable, design the Rust API from the behavior list rather than transliterating, use the per-language mapping tables, keep the port proportionate, and ship a PORTING.md mapping old API and tests to new.
tags: [rust, porting, migration, translation, ffi, characterization-tests]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Porting Code to Rust

## Failure Mode

A line-by-line transliteration — C written in Rust syntax, Python with
`Box<dyn Any>` — compiles but keeps every problem the original had and adds
the borrow checker on top. Ports that silently "fix" the original's quirks
change behavior nobody approved. Missing test parity means there is no
definition of "same behavior" to check the port against. Reimplementing the
source language's runtime (hand-rolled `splitlines`, `strtol`, `repr()`)
bloats the port for inputs that never occur.

## Practice

### 1. Understand Before Writing

- Read the code, its tests, and its callers if available.
- List the **observable behavior**: every public function, inputs, outputs,
  and every way it can fail — including the quiet parts where ports go
  wrong: result ordering, tie-breaking, empty input, whitespace/case
  handling, integer limits, error-vs-edge-case distinctions.
- Note what is **incidental** — things the original does only because of
  its language (manual memory, out-parameters, `NULL` returns, global
  state, fixed buffers, grouping classes, `isinstance` checks). These do
  not carry over.
- If the original has a bug or ambiguity, keep its behavior, flag it in the
  porting notes, and let the user decide — a port is not the place to
  silently fix things.

### 2. Port the Tests First

Translate the original tests into Rust tests before the implementation —
one Rust test per original test, named to map back. The tests are the
definition of "same behavior". If the original has no tests, write
characterization tests from the behavior list.

### 3. Design the Rust API From the Behavior List

Decide public types and signatures from the behavior list, not from the
original's shape.

**From C and C++:**

| In the original | In Rust |
|---|---|
| `malloc`/`free`, `create`/`destroy` pairs | Owned types (`String`, `Vec`, `Box`); `Drop` for the rest |
| `NULL` meaning absent | `Option<T>` |
| Error codes, `errno` | `Result<T, E>` + error enum, `Display` + `Error` impls |
| Out-parameters | Return values in `Ok` or the error variant |
| Flag bitmasks | Options struct + `Default`, or `bitflags` crate |
| `char *` + length | `&str`/`String`; `eq_ignore_ascii_case` for `strcasecmp` |
| Pointer + count | Slices, iterators |
| Fixed buffers + truncation | Growable types (drop the limit unless it is behavior) |
| `#define` constants/macros | `const`, enums, functions |
| Global mutable state | A struct the caller owns |
| `strtol` family | `str::parse`, failures mapped to the error enum |

**From Python:**

| In the original | In Rust |
|---|---|
| Exception hierarchy | One error enum (or per area), attributes → variant fields |
| `None` as a value | `Option<T>` |
| Strings as a closed set | An enum with `FromStr` + `Display` |
| Dicts/classes as records | Structs with named fields |
| `dict` insertion order | `Vec` or ordered map — `HashMap` silently reorders output |
| `isinstance`, duck typing | Traits or enums |
| Unbounded `int` | Sized integer chosen on purpose + `checked_*` where needed |
| `sorted(key=..)` | `sort_by_key`/`sort_by` (stable, like Python) |
| `try`/`except` around a parse | `?` with mapped error, or `match` |

**From Go / JavaScript / TypeScript:** `(value, error)` returns → `Result`;
`nil`/`null`/`undefined` → `Option`; interfaces → traits; goroutines +
channels → threads with `mpsc` or async tasks; plain objects → structs;
numbers → a sized integer or `f64` chosen on purpose.

### 4. Keep It Proportionate

- **Do not reimplement the source runtime.** Use `str::lines`, `trim`,
  `parse`, and `char` methods. Where behavior differs only on exotic input
  (Unicode digits, non-ASCII whitespace, unbounded integers), list the
  difference in the notes instead of coding around it; write a
  compatibility shim only when the user says those inputs occur.
- **Do not grow the API.** Port the public surface plus the std trait
  impls callers expect (`Debug`, `Clone`, `Display`, `Error`, `FromStr`,
  `Default`, `IntoIterator`). Skip builders and custom iterators unless
  the original's callers needed them.
- **Keep the algorithm** unless it is wrong — swap only to fix a real
  problem (quadratic on realistic input) and say so.
- **Check the size.** A C/C++ port lands near the original's line count;
  a Python/JS port at 2–3×. Much more means one of the three habits above.
- Differential testing helps, but a few dozen realistic + edge inputs
  answer the question — a million-input fuzz finds exotic divergences
  that belong in the notes.

### 5. Verify and Document

`cargo build`, `cargo test`, `cargo clippy --all-targets -- -D warnings` —
every ported test passes; run the original's tests on the same inputs where
possible. Write a short `PORTING.md` a reviewer can check in minutes:

- **API mapping** — original function/type → Rust equivalent
- **Test mapping** — original test → covering Rust test
- **Deliberate differences** — what now behaves differently and why
- **Preserved quirks** — odd behavior kept on purpose, so nobody "fixes" it
- **Verification** — commands run and their result

## Related Concepts

- [Rust Code Review](rust-code-review.md) — review the ported module
  against the same rules
- [Type and Trait Design](type-and-trait-design.md) — the enum/newtype/
  trait machinery the maps above produce
- [Error Handling](error-handling.md) — error-code/exception → error enum
  conversions
- [Unsafe Code Practices](unsafe-code-practices.md) — when the port must
  talk to C through FFI
