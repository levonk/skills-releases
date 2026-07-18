---
okf_version: "0.1"
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
