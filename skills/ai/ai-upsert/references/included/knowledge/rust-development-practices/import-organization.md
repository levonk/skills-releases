---
type: Practice
title: Import and Use Statement Organization
description: Organize use statements for readability and refactorability — no glob imports, one module per use statement, locally-scoped trait imports, module-qualified function calls, unqualified type names.
tags: [rust, imports, use-statements, glob-imports, module-organization, refactoring]
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

# Import and Use Statement Organization

## Failure Mode

Glob imports hide where names come from and defeat codebase-wide tooling.
Merged `use` trees (`use foo::{a, bar::B}`) create noisy diffs when items are
added or removed. Unqualified function names make calls look local when they
are not. Import hygiene directly determines how easy the code is to navigate
without an IDE and to refactor at scale.

## Practice

### No Glob Imports

Avoid `use module::*`. Exceptions where a glob import is acceptable:

- `use super::*` in inline test/helper modules
- `use enum::*` in method bodies of that enum, or functions that primarily
  deal with that enum
- `pub use submodule::*` in non-leaf re-export modules

Avoid defining preludes. A framework's documented prelude is fine —
`use bevy::prelude::*` is Bevy's official import pattern (clippy's
`wildcard_imports` already exempts `prelude` paths) — but reviewer
discretion applies to third-party crates that merely encourage one
(`tracing::prelude`), and never glob-import a crate you do not control
without pinning it: a minor release can add a clashing name (error E0034).

### One Module Per `use` Statement

Each `use` imports items from a single module — no `::` inside the `{..}`
block (the rustfmt setting `imports_granularity = Module` enforces this):

```rust
// Good
use foo::Foo;
use foo::bar::Bar;
use foo::bar::Baz;

// Bad — two modules merged in one statement
use foo::{Foo, bar::Bar};
```

### Prefer Locally-Scoped Trait Imports

Import traits inside the function body unless the trait's methods are used
extensively throughout the file:

```rust
fn foo(x: &str) {
    // Import the trait within a function, not at the module scope.
    use std::str::FromStr;
    let num = u8::from_str(x).expect("x must be a u8");
}
```

### Qualify Top-Level Function Calls With a Module Name

Import the module, not the function, for top-level functions from other
modules or crates:

```rust
// Good — the call site shows where transmute lives
use std::mem;
let x = mem::transmute(y);

// Bad — looks like a local function
use std::mem::transmute;
let x = transmute(y);
```

Exceptions: functions with sufficiently disambiguated names, and cases where
the module name itself collides.

### Import Type Names Unqualified

Types and traits should appear in code without their module path —
`Regex`, not `regex::Regex`. Exceptions:

- Ambiguous common names — reference `io::Error` directly or rename
  (`use std::io::Error as IoError`)
- Large type groups where importing everything produces a huge import block
- Macros and generated code where a `use` is counterproductive

## Related Concepts

- [Project Structure](project-structure.md) — leaf vs non-leaf module rules
- [Rustfmt and Clippy](rustfmt-clippy-config.md) — `imports_granularity`
  enforcement
