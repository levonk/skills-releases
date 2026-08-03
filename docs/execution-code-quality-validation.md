<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status: ready · Version: 1.0.0

Comprehensive code quality validation supporting multiple languages with linting, formatting, testing, and security scanning. Use when needing to validate code quality before commits, in CI pipelines, during development workflow, or running lint/test/security checks. Triggers on 'validate code', 'quality check', 'run linter', 'run tests', 'security scan', or 'code quality'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `code-quality-validation` |
| Category | `execution` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `code-quality`
- `linting`
- `testing`
- `security`
- `formatting`

## Quick Start

```bash
# Run complete quality validation
./scripts/quality-validator.sh complete

# Run specific validation phases
./scripts/quality-validator.sh lint        # Linting only
./scripts/quality-validator.sh format      # Formatting check
./scripts/quality-validator.sh test        # Testing only
./scripts/quality-validator.sh security    # Security scanning
./scripts/quality-validator.sh fix         # Auto-fix issues
```

## References

- **Language Support**: See `references/supported-languages.md`
- **Configuration Guide**: See `references/configuration.md`
- **Output Formats**: See `references/output-formats.md`
- **Error Handling & Security**: See `references/error-handling-security.md`
- **Security Patterns**: See `references/security-scanning.md`
- **CI Integration**: See `references/ci-integration.md`

## Related Skills
- **project-detection** (skill, dependency) — Required for automatic project type detection and language identification
- **ai-development-loop** (skill, dependent) — Uses code-quality-validation for iterative quality checks during development
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/execution/code-quality-validation/SKILL.md`](skills/execution/code-quality-validation/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-03T01:25:43Z
