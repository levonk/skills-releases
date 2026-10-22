---
type: Practice
title: Rustfmt and Clippy Configuration
description: Standard rustfmt and clippy configuration for consistent formatting and linting — 2-space indent, 100 char width, cognitive complexity threshold, trivial copy size limit.
tags: [rust, rustfmt, clippy, formatting, linting, code-quality]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-21"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
---

# Rustfmt and Clippy Configuration

## Failure Mode

Without standardized formatting and linting, code style drifts across packages,
complexity creeps in unnoticed, and reviews waste time on style debates.

## Practice

### Rustfmt

```toml
# .rustfmt.toml
edition = "2021"
hard_tabs = false
tab_spaces = 2
max_width = 100
use_small_heuristics = "Default"
reorder_imports = true
reorder_modules = true
remove_nested_parens = true
use_field_init_shorthand = true
force_explicit_abi = true
empty_item_single_line = true
struct_lit_single_line = true
```

### Clippy

```toml
# clippy.toml
cognitive-complexity-threshold = 30
too-many-arguments-threshold = 7
type-complexity-threshold = 250
single-char-lifetime-names-threshold = 4
trivial-copy-size-limit = 64
```

### Optional Style Rules (Google)

The Google Rust Style Guide recommends these additional rustfmt options —
they may be skipped when unavailable on the project's stable toolchain:

```toml
hex_literal_case = "Lower"        # 0xab123cdef, not 0xAB123CDEF
format_macro_matchers = true      # format macro matcher arms
imports_granularity = "Module"    # one module per use statement
```

It also requires escaping invisible characters in literals (e.g., write
`\u{200D}` rather than embedding a zero-width joiner).

### Opting Out of Formatting

`#[rustfmt::skip]` is allowed only for:

- **Manual alignment** — a situation-specific reason to keep lines aligned
  (similar statements that must line up, matrix-constructing code)
- **Generated code** — ideally produced by a genrule instead

Never skip formatting for personal style preferences.

### Pre-commit Enforcement

```bash
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
```

## Related Concepts

- [Quality Gates](quality-gates.md) — CI enforcement of formatting and linting
- [Project Structure](project-structure.md) — Config files live at package root
- [Import Organization](import-organization.md) — the import rules
  `imports_granularity` enforces
