# Directory Update Log

## 2026-10-27

* **Ingest**: Ingested [BeautifulRust](https://github.com/morganlinton/BeautifulRust)
  — three Agent Skills (write/review/port) plus a tested `[lints]` config,
  synthesizing the Google Rust Style Guide, Rust API Guidelines, Effective
  Rust, Rust Design Patterns, and Microsoft's Pragmatic Rust Guidelines.
  Practice content extracted from `skills/*/SKILL.md`, `lints/lints.toml`,
  `lints/clippy.toml`, and `references/*.md` (six source digests including
  `bevy.md`). Excluded: `evals/` and `benchmarks/` (agent-harness eval
  content, not practice knowledge), install instructions, and
  `examples/review-inventory.md` (sample output). Eight new concept pages:
  - [ownership-and-borrowing.md](ownership-and-borrowing.md) — unique
    ownership first, six-step clone-avoidance ladder, `mem::take`/`replace`,
    disjoint field borrows, owned data in structs, freeze-after-setup,
    smart pointers out of public signatures, on-stack `dyn` dispatch
  - [builders-and-constructors.md](builders-and-constructors.md) —
    `new()`/`Default` agreement, ≤2 optional params inherent, builder shape
    (infallible field-named setters, `build() -> Result`), ≥4 loose args
    grouped into semantic types
  - [visibility-and-api-evolution.md](visibility-and-api-evolution.md) —
    private by default + `pub(crate)` ladder, sealed traits, one path per
    public item, foreign re-export rules, semver breaking-change list,
    deprecate-in-minor
  - [concurrency-and-async-design.md](concurrency-and-async-design.md) —
    `Send`/`Sync` const assertions, `Rc` across `.await`, message passing
    over shared state, lock discipline, `async fn` shape, yield points,
    runtime-agnostic libraries
  - [performance-practices.md](performance-practices.md) — measure-first
    order, `with_capacity`/`collect`, caller-owned buffers,
    `Box<[T]>`/`Box<str>`/`Arc<str>`, `shrink_to_fit`, `foldhash`/`FxHash`
    for trusted keys, batching, `mimalloc` for apps
  - [rust-code-review.md](rust-code-review.md) — review methodology: scope
    (library vs application, edition/MSRV, frameworks), tools first,
    priority-ordered findings, must/should/consider + what's-good report
    format with cited rules
  - [porting-to-rust.md](porting-to-rust.md) — port behavior not structure,
    tests first, per-language mapping tables (C/C++, Python, Go/JS/TS),
    proportionality rules, `PORTING.md` deliverable
  - [bevy-ecs-conventions.md](bevy-ecs-conventions.md) — Bevy 0.20
    exceptions (by-value system params, prelude, public component fields)
    and compile-clean ECS bugs (query conflicts B0001/B0002, deferred
    `Commands`, unordered systems, unwrapped `single()`), headless `App`
    testing
* **Update**: [rustfmt-clippy-config.md](rustfmt-clippy-config.md) —
  BeautifulRust drop-in `[lints]` table + `clippy.toml` (tested against
  clippy; `rust-version` 1.81 for suppression lints), `#[expect]` vs
  `#[allow]` policy, no `#![deny(warnings)]` in source.
* **Update**: [error-handling.md](error-handling.md) — library error type
  requirements (`Error + Send + Sync + 'static`, Display format,
  `From<Upstream>`, two sound shapes, return-consumed-arg), panic message
  content, destructors never fail.
* **Update**: [type-and-trait-design.md](type-and-trait-design.md) — eager
  derive checklist (+ `Debug`/`Display` secret redaction), conversion and
  collection traits (`From`/`TryFrom` not `Into`, `FromStr`,
  `FromIterator`/`Extend`, `IntoIterator`), `Deref` limits, no derivable
  bounds on struct defs, `Ord`/`PartialEq`/`Hash` consistency contract,
  object safety, methods vs free functions.
* **Update**: [api-design-principles.md](api-design-principles.md) —
  strongest std types (`PathBuf`/`Duration`, `bitflags`), `impl AsRef`/
  `RangeBounds`/`Read`/`Write` parameters, take-by-value ownership, no
  `&mut` out-params, sans-IO design, `bool` parameters banned in public
  signatures.
* **Update**: [rust-naming-conventions.md](rust-naming-conventions.md) —
  acronym-as-one-word, weasel-word ban (`Service`/`Manager`/`Factory`/
  `Helper`/`Util`), no module-name-in-type, iterator/error type naming,
  `_unchecked` siblings, bare feature names.
* **Update**: [documentation-comments.md](documentation-comments.md) —
  15-word first sentence, `# Examples`/`# Errors`/`# Panics`/`# Safety`
  order, `?`-in-examples with hidden scaffolding, intra-doc links,
  `//` comments explain why, no design journals.
* **Update**: [implementation-idioms.md](implementation-idioms.md) —
  `let ... else`, `Option` as iterator, drop guards bound to a name,
  closure capture rebind-then-`move`, magic numbers → named `const`s,
  combinator-vs-`match` judgment.
* **Update**: [unsafe-code-practices.md](unsafe-code-practices.md) — three
  allowed reasons for `unsafe`, mark `unsafe` only when misuse = UB,
  banned `transmute`/`unsafe impl Send`, Miri testing, FFI section
  (`#[repr(C)]`, `CString`/`CStr`, RAII wrappers, `bindgen` in `-sys`
  crates, `catch_unwind` required at the FFI boundary — the one exception
  to the no-`catch_unwind` rule).
* **Update**: [macro-guidelines.md](macro-guidelines.md) — `macro_rules!`
  etiquette (input resembles output, attributes pass through, any scope,
  private by default, visible control flow), proc-macro three-crate layout
  (`foo`/`foo_proc`/`foo_proc_impl`), `insta`/`trybuild` testing.
* **Update**: [testing-strategy.md](testing-strategy.md) — prefer `tests/`
  when either works, test properties not constants (tautological tests),
  `new_mocked()`/`test-util` for I/O, `cargo fuzz`, `black_box` benchmarks,
  Miri, fail-first.
* **Update**: [cargo-configuration.md](cargo-configuration.md) — version
  ranges over `*`/`=` pins, `Cargo.lock` for binaries, dependency cost
  audit tooling, additive bare-named features, `[workspace.lints]`,
  `default-features = false`, MSRV/edition policy.
* **Update**: [project-structure.md](project-structure.md) — flat
  `crates/` workspace, essential items at root, group by use case not
  kind, no prelude, one path per public item.
* **Update**: [async-patterns.md](async-patterns.md),
  [structured-logging-tracing.md](structured-logging-tracing.md),
  [import-organization.md](import-organization.md) — cross-links to new
  pages; async design additions, message-template logging, framework
  prelude exception.
* **Update**: [index.md](index.md), [overview.md](overview.md) — eight new
  entries/table rows and source entry.

## 2026-10-21

* **Ingest**: Ingested the [Google Rust Style Guide](https://google.github.io/styleguide/rustguide.html)
  — Google's style, API-design, and implementation rules for Rust across
  google3, Android, ChromeOS, Fuchsia, and Chrome. General (untagged) rules
  were extracted; codebase-tagged `[chrome]`/`[Fuchsia]` rules (Chromium
  crate layout, `chromium::import!`, async/thread bans, `fuchsia_sync::Mutex`,
  per-codebase test frameworks) were excluded as out of scope. Nine new
  concept pages:
  - [import-organization.md](import-organization.md) — no glob imports (with
    exceptions), one module per `use`, locally-scoped trait imports,
    module-qualified function calls, unqualified type names
  - [api-design-principles.md](api-design-principles.md) — flexible
    reference parameters (`&T`/`&[T]`/`&str`/`Option<&T>`), iterators vs
    owned collections, `impl Into<T>` trade-offs, enum over bool, library
    vs application rule strength
  - [type-and-trait-design.md](type-and-trait-design.md) — newtypes vs
    aliases, named fields, derive-first, std-traits-over-methods, generics
    vs `dyn Trait`, extension traits (`~Ext`), trait impl checklist,
    `From` + explicit constructors, options structs `Default`
  - [rust-naming-conventions.md](rust-naming-conventions.md) — `as_`/`to_`/
    `into_` prefixes, getter/setter conventions (`foo`/`foo_mut`/`take_`/
    `set_`/`with_`/`replace_`), descriptive lifetimes, `new()`/`try_new()`/
    `from_foo()`, avoid abbreviations
  - [documentation-comments.md](documentation-comments.md) — `///` vs `//!`
    vs `//`, panic and unsafe invariant documentation, omit
    signature-restating comments, `missing_docs` lint
  - [api-stability-attributes.md](api-stability-attributes.md) —
    `#[non_exhaustive]` enums/structs (+ `non_exhaustive_omitted_patterns`
    match style), `#[must_use]` on functions/types, `const fn` commitment,
    `#[doc(hidden)]` is private, no unstable features, no pre-`main()` code
  - [implementation-idioms.md](implementation-idioms.md) — avoid `Rc`/`Arc`,
    borrows over clones, bounded type inference, pattern matching over
    check-then-unwrap, `for` vs combinator chains, assertion context
    strings, `format!`/`write!` over `+`
  - [unsafe-code-practices.md](unsafe-code-practices.md) — last-resort
    unsafe, encapsulate + `SAFETY:` + justification, no poisoned-mutex
    contents, no `catch_unwind`
  - [macro-guidelines.md](macro-guidelines.md) — escalation order (plain
    Rust → `macro_rules!` → codegen → proc macros) and the tooling/dialect/
    refactor costs
* **Update**: [project-structure.md](project-structure.md) — leaf vs
  non-leaf module rules (declarations + re-exports only), name files after
  the primary item, prefer small crates.
* **Update**: [rustfmt-clippy-config.md](rustfmt-clippy-config.md) —
  optional Google rustfmt options (`hex_literal_case`,
  `format_macro_matchers`, `imports_granularity`), invisible-character
  escapes, `#[rustfmt::skip]` policy.
* **Update**: [error-handling.md](error-handling.md) — `Option`/`Result`/
  `panic!` selection, `expect` over `unwrap`, no `catch_unwind`.
* **Update**: [index.md](index.md), [overview.md](overview.md),
  [testing-strategy.md](testing-strategy.md) — new entries, table rows,
  source entry, and cross-links.

## 2026-08-20

* **Update**: Updated [security-auditing.md](security-auditing.md) with
  cargo-outdated drift detection, shared devbox package provisioning
  (`cargo-audit` + `cargo-outdated` via `_shared/partials/devbox-partials/
  devbox-packages-rust.jinja`), and the 6-step validation pipeline
  (fmt → clippy → test → doc → audit → outdated).
* **Update**: Updated [quality-gates.md](quality-gates.md) with the full
  `just validate` pipeline, shared CI workflow (5 jobs: test, lint, build,
  security, outdated-check), and weekly dependency update workflow
  (cargo update + audit + build + test → PR via peter-evans/create-pull-request).
* **Source**: Added cargo-audit-wiring feature PRD
  (`internal-docs/feature/todo/cargo-audit-wiring/feat-202608201814-cargo-audit-wiring.md`)
  as a source on security-auditing and quality-gates.

## 2026-08-05

* **Ingest**: Authored 7 new concept pages sourced from the project-lint
  audit (Rust CLI linter tooling gaps). All pages grounded against
  project-lint/Cargo.toml versions on 2026-08-05.
  - [tree-sitter-ast-queries.md](tree-sitter-ast-queries.md) — query syntax
    for linting, multi-language query organization, performance, snapshot
    testing (tree-sitter 0.23)
  - [clap-cli-patterns.md](clap-cli-patterns.md) — derive vs builder,
    subcommand organization, argument validators, shell completion (clap 4.4)
  - [toml-config-validation.md](toml-config-validation.md) — serde + toml
    schema validation, profile merging, config migration, hot-reload
    (toml 0.8, serde 1.0)
  - [structured-logging-tracing.md](structured-logging-tracing.md) — tracing
    vs log, structured field conventions, subscriber config, RUST_LOG
    (tracing 0.1, tracing-subscriber 0.3)
  - [file-watcher-patterns.md](file-watcher-patterns.md) — notify event
    filtering, cross-platform watch limits, FS race conditions, async
    integration (notify 6.1)
  - [cross-platform-path-handling.md](cross-platform-path-handling.md) —
    std::path vs camino, normalization, symlinks, Windows UNC paths
  - [anyhow-thiserror-combination.md](anyhow-thiserror-combination.md) —
    layered error handling: thiserror in libs, anyhow at application layer
    (anyhow 1.0, thiserror 1.0)
* **Update**: Updated [index.md](index.md) with 7 new concept entries.

## 2026-07-29
* **Update**: Extended [cli-tool-standards.md](cli-tool-standards.md) with
  three new agent-mode requirements from ADR-20260607001 v5.0.0:
  - `--gen-skill` skill emission (print installable Agent Skill prompt to
    stdout, recommend hooks > CLI > MCP, `--check` for CI staleness)
  - Coding-agent hook wiring (Devin, Cursor, Continue, Aider opt-in; per-agent
    `[agent-hooks]` table in `${XDG_CONFIG_HOME:-$HOME/.config}/{app-name}/config.toml`;
    `--install-agent-hooks` / `--uninstall-agent-hooks`)
  - Non-user-identifiable telemetry (no file paths, no identifiers, no command
    args; `MYTOOL_TELEMETRY` env var + `[telemetry]` config; `--telemetry-dry-run`)
* **Source**: ADR-20260607001 bumped to v5.0.0 (date-updated 2026-07-29) in
  levonk-base-boilerplate.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Initialization**: Created the `rust-development-practices` knowledge bundle to consolidate Rust package and CLI development practices from two ADRs in levonk-base-boilerplate.
* **Creation**: Authored 11 concept pages covering the full Rust development lifecycle.
  - [project-structure.md](project-structure.md) — standard directory layout, module organization
  - [cargo-configuration.md](cargo-configuration.md) — Cargo.toml metadata, dependency pinning, workspace config
  - [rustfmt-clippy-config.md](rustfmt-clippy-config.md) — formatting and linting standards
  - [testing-strategy.md](testing-strategy.md) — unit, integration, doc tests, benchmarks, proptest
  - [error-handling.md](error-handling.md) — thiserror, anyhow, no panic in libraries
  - [async-patterns.md](async-patterns.md) — tokio runtime, async tests, stream implementation
  - [serde-serialization.md](serde-serialization.md) — optional serde, multiple formats, skip patterns
  - [cli-tool-standards.md](cli-tool-standards.md) — cross-language CLI standards, AXI agent mode, TOON
  - [container-support.md](container-support.md) — multi-stage Dockerfile, non-root, healthcheck
  - [security-auditing.md](security-auditing.md) — cargo audit, secrecy, zeroize, safe FFI
  - [quality-gates.md](quality-gates.md) — pre-commit hooks, multi-version CI, validation criteria
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20260128001 (Rust package boilerplate requirements, 756 lines) and ADR-20260607001 (CLI tool standards, 401 lines) in levonk-base-boilerplate.
