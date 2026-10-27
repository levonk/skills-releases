---
type: Practice
title: Rust Code Review Methodology
description: A repeatable review process — scope first (library vs application, edition/MSRV, frameworks), run the tools before reading, then report findings in priority order (correctness, errors, API, idiom, docs/tests) with file:line, a cited rule, and the smallest fix, ending with what the code already does well.
tags: [rust, code-review, review, clippy, methodology, audit]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Rust Code Review Methodology

## Failure Mode

Unstructured reviews pad the report with style nits while a soundness hole
scrolls past. Findings without a `file:line` or a cited rule read as taste,
not engineering. A rewrite dressed up as a review removes the author's
choice about what to fix. Reviewing a diff as if it were the whole file —
or a library as if it were application code — produces findings against the
wrong bar.

## Practice

### 1. Decide the Scope

- Review exactly what was pointed at: a file, module, crate, or diff. For
  a diff, review the changed lines and what they break — not the whole
  file.
- Determine **library vs application** (`lib.rs`, `pub` items used by other
  crates, published `Cargo.toml`). Libraries are held to the API-design
  rules strictly; applications get the simplicity rules instead. State the
  assumption at the top of the report.
- Read the **edition and MSRV** from `Cargo.toml` so recommendations do not
  require features the project cannot use.
- Check **frameworks**: a `bevy`/`bevy_ecs` dependency means
  [Bevy ECS Conventions](bevy-ecs-conventions.md) applies — several general
  rules are wrong for systems.

### 2. Run the Tools First

```bash
cargo fmt --check
cargo clippy --all-targets --all-features -- -W clippy::pedantic
cargo test
```

Fold results into the report — do not paste raw output. Group repeated
warnings into one finding; skip pedantic lints that do not matter for this
code. If no toolchain is available, say so and review by reading.

### 3. Findings, in Priority Order

**Correctness and soundness** (where real bugs live): `unsafe` without a
`// SAFETY:` comment or a `transmute` dodging lifetimes; reachable panics
on outside input (`unwrap`, indexing, wrapping `as` casts, overflow); trait
contracts broken (hand-written `Ord` with derived `PartialEq`, `Hash`
disagreeing with `Eq` — silently corrupts `BTreeMap`/`sort`/`dedup`); lock
hazards (`MutexGuard` across `.await` or returned, closures under a lock,
poison recovered); destructors that panic, block, or can fail.

**Error handling**: `()`, `String`, `Box<dyn Error>`, or `anyhow::Error` as
a library's public error type; missing `Display`/`Error`/`source()`;
`map_err(|_| ...)` dropping information; panics for expected failures;
`catch_unwind` as control flow.

**API design** (strict for libraries): `&String`/`&Vec<T>`/`&Box<T>`
parameters; `bool` in public signatures; `Rc`/`RefCell`/`Arc` in
signatures; leaked third-party types; missing `Debug`/`Display`/`Default`/
`FromStr`; `get_` prefixes and `Manager`/`Service`/`Util` names; enums or
traits that should be `#[non_exhaustive]`/sealed.

**Idiom and clarity**: borrow-checker clones; check-then-unwrap; `+` string
building; iterator chains that should be loops or vice versa; `HashMap`
order leaking into output or tests; `#![deny(warnings)]` in source;
`#[allow]` without a reason; glob imports of external crates.

**Documentation and tests**: undocumented public items or signature-parrot
docs; missing `# Errors`/`# Panics`/`# Safety`; doc examples using
`unwrap()`; untested logic or tests that restate constants.

### 4. Report Format

```markdown
# Rust review: <what was reviewed>
<paragraph: what it does, library or application, verdict, single most
important fix, whether clippy/tests ran>

## Must fix       — bugs, soundness holes, reachable panics, API mistakes
                    that become breaking changes once published
## Should fix     — works, but violates a rule with a real cost
## Consider       — style, naming, polish
## What's already good — 2–4 specific things to keep (required)
```

Each finding: `file:line` (or `whole file`), the rule with its source (an
API Guidelines code like `C-GETTER`, a Microsoft `M-` code, a clippy lint
name, "Google Rust Style Guide"), the concrete consequence, and the
smallest code change that fixes it — never a function rewrite. Group
repeats ("eight `unwrap()` calls", listing lines) into one finding.
Deliberate-looking quirks go under Consider with the trade-off noted, not
Must fix. Keep it proportionate: five to ten findings for a short file.

### 5. Close With Enforcement

If the project lacks a `[lints]` table, suggest the tested config in
[Rustfmt and Clippy](rustfmt-clippy-config.md) and name two or three
findings it would have caught automatically.

## Related Concepts

- [Rustfmt and Clippy](rustfmt-clippy-config.md) — the `[lints]` table a
  review should end by recommending
- [Porting to Rust](porting-to-rust.md) — the port-specific variant of
  this methodology
- [Unsafe Code Practices](unsafe-code-practices.md) — the soundness rules
  behind the top finding category
- [Error Handling](error-handling.md) — the contract behind the second
