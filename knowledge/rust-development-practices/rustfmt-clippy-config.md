---
type: Practice
title: Rustfmt and Clippy Configuration
description: Standard rustfmt and clippy configuration for consistent formatting and linting — 2-space indent, 100 char width, cognitive complexity threshold, trivial copy size limit.
tags: [rust, rustfmt, clippy, formatting, linting, code-quality]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-27"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
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

### Drop-in `[lints]` Table

For projects with no lint configuration, the BeautifulRust `lints/lints.toml`
provides a tested `[lints]` block that makes clippy enforce the
machine-checkable idioms in this bundle. Paste it into `Cargo.toml` (or use
`[workspace.lints]` at the workspace root plus `[lints] workspace = true`
per member). Everything warns; CI makes it strict with
`cargo clippy --all-targets --all-features -- -D warnings`.

```toml
[lints.rust]
unsafe_op_in_unsafe_fn = "warn"          # each unsafe op needs its own block
missing_debug_implementations = "warn"   # every public type implements Debug
missing_docs = "warn"                    # [lib] document every public item
unreachable_pub = "warn"                 # pub items that aren't exported
rust_2018_idioms = { level = "warn", priority = -1 }

[lints.clippy]
all = { level = "warn", priority = -1 }
pedantic = { level = "warn", priority = -1 }
unwrap_used = "warn"                     # use ?, or expect("why")
expect_used = "allow"                    # expect w/ reason is sanctioned
panic_in_result_fn = "warn"
missing_panics_doc = "warn"              # [lib] document reachable panics
missing_errors_doc = "warn"              # [lib] document failures
allow_attributes = "warn"                # prefer #[expect] (needs 1.81+)
allow_attributes_without_reason = "warn" # every suppression says why
undocumented_unsafe_blocks = "warn"      # // SAFETY: on every unsafe block
multiple_unsafe_ops_per_block = "warn"
fn_params_excessive_bools = "warn"       # enum or two methods instead
struct_excessive_bools = "warn"
clone_on_ref_ptr = "warn"                # write Rc::clone(&x) explicitly
redundant_clone = "warn"
rc_buffer = "warn"                       # Rc<str>/Rc<[T]> not Rc<String>
string_add = "warn"                      # format!/push_str, not +
wildcard_imports = "warn"                # super::* in tests is exempt
dbg_macro = "warn"
todo = "warn"
print_stdout = "warn"                    # [lib] libraries log, not print
print_stderr = "warn"
as_conversions = "warn"                  # From/TryFrom over `as`
cast_possible_truncation = "warn"
cast_sign_loss = "warn"
module_name_repetitions = "allow"
must_use_candidate = "allow"
module_inception = "allow"               # leaf module named for item is fine
enum_glob_use = "allow"                  # use Enum::* in matching fns
```

And alongside it, a `clippy.toml` at the crate root:

```toml
max-fn-params-bools = 0        # flag any bool parameter, not just 4+
allow-unwrap-in-tests = true   # tests panic as the assertion
allow-expect-in-tests = true
allow-print-in-tests = true
```

`allow_attributes` and `allow_attributes_without_reason` need
`rust-version = "1.81"` or later — clippy switches them off for crates that
cannot use `#[expect]`. Lints marked `[lib]` fit libraries; applications
may drop them. Bevy crates need four extra allows — see
[Bevy ECS Conventions](bevy-ecs-conventions.md).

### Suppression Policy

- **Fix the lint rather than silencing it.** When a lint is genuinely wrong
  for one item, use `#[expect(clippy::name, reason = "...")]` on the
  narrowest item — `expect` warns when the lint stops firing, so stale
  suppressions get cleaned up. Reserve `#[allow]` for generated code and
  macro output.
- **Never put `#![deny(warnings)]` in source.** New toolchains add warnings
  and break the build. Enforce warnings-as-errors in CI with
  `cargo clippy -- -D warnings` (or `RUSTFLAGS="-D warnings"`), and deny
  specific lints by name when needed.
- Configure lints once in `Cargo.toml` (`[lints]`/`[workspace.lints]`), not
  with scattered crate attributes.

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
- [Bevy ECS Conventions](bevy-ecs-conventions.md) — four allows Bevy crates
  need on top of the `[lints]` table
- [Rust Code Review](rust-code-review.md) — reviews end by recommending
  this config
