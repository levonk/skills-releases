---
okf_version: "0.2"
---

# Rust Development Practices

A compounding knowledge base documenting practices for Rust package and CLI
development — project structure, tooling, testing, error handling, async
patterns, serialization, container support, and CLI standards. Each concept
captures specific requirements and patterns sourced from real boilerplate ADRs.

## Concepts

* [Overview](overview.md) - Synthesis of the full Rust development practice set
* [Project Structure](project-structure.md) - Standard directory layout, module organization, re-exports
* [Cargo Configuration](cargo-configuration.md) - Required metadata, dependency pinning, feature flags, workspace config
* [Rustfmt and Clippy](rustfmt-clippy-config.md) - Formatting and linting configuration standards
* [Testing Strategy](testing-strategy.md) - Unit, integration, doc tests, benchmarks, property-based testing
* [Error Handling](error-handling.md) - thiserror for structured errors, anyhow for context, no panic in libraries
* [Async Patterns](async-patterns.md) - tokio runtime, async test macro, stream implementation
* [Serde Serialization](serde-serialization.md) - Optional serde integration, multiple format support, skip patterns
* [CLI Tool Standards](cli-tool-standards.md) - Cross-language CLI standards: args, config, output, daemon, agent mode (AXI)
* [Container Support](container-support.md) - Multi-stage Dockerfile, non-root user, healthcheck, docker-compose
* [Security and Auditing](security-auditing.md) - cargo audit, secrecy crate, zeroize, input validation
* [Quality Gates](quality-gates.md) - Pre-commit hooks, CI/CD multi-version testing, cross-platform validation
* [Tree-Sitter AST Queries](tree-sitter-ast-queries.md) - Query syntax for linting, multi-language query organization, performance for large codebases
* [Clap CLI Patterns](clap-cli-patterns.md) - Derive vs builder, subcommand organization, argument validators, shell completion
* [TOML Config Validation](toml-config-validation.md) - serde + toml schema validation, profile merging, config migration, hot-reload
* [Structured Logging with tracing](structured-logging-tracing.md) - tracing vs log, structured field conventions, subscriber config, RUST_LOG
* [File Watcher Patterns](file-watcher-patterns.md) - notify crate event filtering, cross-platform watch limits, FS race conditions, async integration
* [Cross-Platform Path Handling](cross-platform-path-handling.md) - std::path vs camino, normalization, symlinks, Windows UNC paths
* [Anyhow + Thiserror Combination](anyhow-thiserror-combination.md) - Layered error handling: thiserror in libs, anyhow at application layer
* [Import Organization](import-organization.md) - No glob imports, one module per use, locally-scoped trait imports, module-qualified function calls
* [API Design Principles](api-design-principles.md) - Flexible reference parameters, iterators vs owned collections, impl Into, enum over bool
* [Type and Trait Design](type-and-trait-design.md) - Newtypes vs aliases, derive over manual impls, generics vs dyn, extension traits, trait impl checklist
* [Rust Naming Conventions](rust-naming-conventions.md) - as_/to_/into_ prefixes, getter/setter conventions, descriptive lifetimes, new()/try_new(), no obscure abbreviations
* [Documentation Comments](documentation-comments.md) - /// and //! usage, panic and unsafe invariant documentation, omit signature-restating comments
* [API Stability Attributes](api-stability-attributes.md) - #[non_exhaustive] enums/structs, #[must_use], const fn commitment, #[doc(hidden)], no unstable features
* [Implementation Idioms](implementation-idioms.md) - Ownership over Rc/Arc, explicit types over inference, pattern matching over unwrap, for loops vs combinator chains
* [Unsafe Code Practices](unsafe-code-practices.md) - Encapsulate unsafe, SAFETY: comments, no poisoned-mutex contents, no catch_unwind
* [Macro Guidelines](macro-guidelines.md) - Escalation order: plain Rust, macro_rules!, codegen, proc macros; tooling and refactor costs
* [Ownership and Borrowing](ownership-and-borrowing.md) - Clone-avoidance ladder, mem::take/replace, disjoint field borrows, freeze-after-setup, smart pointers out of signatures
* [Builders and Constructors](builders-and-constructors.md) - new()/Default agreement, builder shape with infallible setters and build() -> Result, semantic parameter grouping
* [Visibility and API Evolution](visibility-and-api-evolution.md) - Private by default, sealed traits, one path per public item, semver breaking-change list, MSRV
* [Concurrency and Async Design](concurrency-and-async-design.md) - Send/Sync assertions, message passing over shared state, lock discipline, async fn shape, runtime-agnostic libraries
* [Performance Practices](performance-practices.md) - Measure-first optimization, capacity hints, buffer reuse, fast hashers for trusted keys, mimalloc for apps
* [Rust Code Review](rust-code-review.md) - Review methodology: scope, tools first, priority-ordered findings, must/should/consider report format
* [Porting to Rust](porting-to-rust.md) - Port behavior not structure, tests first, per-language mapping tables, PORTING.md deliverable
* [Bevy ECS Conventions](bevy-ecs-conventions.md) - Bevy-specific exceptions and compile-clean ECS bugs (query conflicts, deferred Commands, system ordering)
