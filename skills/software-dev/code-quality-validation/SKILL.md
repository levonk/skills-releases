---
name: code-quality-validation
description: "Comprehensive code quality validation supporting multiple languages with linting, formatting, testing, and security scanning. Use when needing to validate code quality before commits, in CI pipelines, during development workflow, or running lint/test/security checks. Triggers on 'validate code', 'quality check', 'run linter', 'run tests', 'security scan', or 'code quality'."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "code-quality", "linting", "testing", "security", "formatting"]
see-also:
  - skill: project-detection
    relationship: "dependency"
    description: "Required for automatic project type detection and language identification"
  - skill: ai-development-loop
    relationship: "dependent"
    description: "Uses code-quality-validation for iterative quality checks during development"
  - template: base-ai-guidance
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: project-detection
  - type: url
    name: ESLint Documentation
    url: https://eslint.org/docs/
  - type: url
    name: Prettier Documentation
    url: https://prettier.io/docs/
  - type: url
    name: Rust Documentation
    url: https://doc.rust-lang.org/
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Code Quality Validation

Comprehensive code quality validation system that automatically detects project types and runs appropriate linting, formatting, testing, and security scanning tools.

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

## Supported Languages & Frameworks

The skill supports JavaScript/TypeScript, Rust, Python, Go, and general-purpose tools with language-specific linting, formatting, testing, and security scanning.

For detailed lists of supported languages, frameworks, and tools, see [references/supported-languages.md](references/supported-languages.md).

## Core Features

### Automatic Project Detection
The skill automatically detects project types and configures appropriate validation:

```bash
# Detection examples
package.json          # JavaScript/TypeScript project
Cargo.toml           # Rust project
requirements.txt     # Python project
go.mod              # Go project
pyproject.toml      # Python with modern tooling
```

### Environment Integration
Works seamlessly with multiple environment managers:
- **Devbox**: Preferred for optimal experience
- **Mise**: Alternative environment manager
- **Nix**: Flake-based development
- **Native**: Direct system execution

### Phased Validation
Execute validation in phases or all at once:

#### Phase 1: Linting
- **Static analysis**: Code quality and style checks
- **Error detection**: Syntax and logic issues
- **Best practices**: Language-specific guidelines
- **Configurable rules**: Project-specific customization

#### Phase 2: Formatting
- **Style consistency**: Uniform code formatting
- **Readability**: Enhanced code clarity
- **Team standards**: Consistent across contributors
- **Auto-fix**: Automatic formatting when possible

#### Phase 3: Testing
- **Unit tests**: Component-level validation
- **Integration tests**: System-level testing
- **Coverage**: Code coverage reporting
- **Performance**: Benchmark execution

#### Phase 4: Security
- **Dependency scanning**: Vulnerability detection
- **Code analysis**: Security pattern detection
- **Secret detection**: Credential scanning
- **License compliance**: Legal requirement checks

## Usage Patterns

### Development Workflow
```bash
# Before committing changes
./scripts/quality-validator.sh complete

# Quick check during development
./scripts/quality-validator.sh lint

# Fix auto-fixable issues
./scripts/quality-validator.sh fix
```

### CI/CD Integration
```bash
# In CI pipeline
./scripts/quality-validator.sh complete --ci

# Generate reports
./scripts/quality-validator.sh complete --report
```

### Pre-commit Hooks
```bash
# Install pre-commit hook
./scripts/quality-validator.sh install-hook

# Run pre-commit validation
./scripts/quality-validator.sh pre-commit
```

## Configuration

The skill supports project-level configuration via `.quality-validator.json` with language-specific settings for JavaScript/TypeScript and Rust.

For detailed configuration examples and language-specific settings, see [references/configuration.md](references/configuration.md).

## Output Formats

The skill supports colored standard output, JSON reports, and JUnit XML for CI integration.

For detailed output format examples, see [references/output-formats.md](references/output-formats.md).

## Error Handling and Security

The skill features graceful degradation, recovery strategies, secret detection, dependency security scanning, and code security analysis.

For detailed error handling and security feature documentation, see [references/error-handling-security.md](references/error-handling-security.md).

## Performance Optimization

### Parallel Execution
- **Multi-language**: Run validators in parallel
- **Phase parallelism**: Execute independent phases concurrently
- **File distribution**: Distribute work across CPU cores
- **Caching**: Cache results for incremental runs

### Incremental Validation
- **Git diff**: Only validate changed files
- **Time stamps**: Skip unchanged files
- **Dependency tracking**: Re-run only when dependencies change
- **Smart caching**: Cache expensive operations

## Integration Examples

### Git Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

./scripts/quality-validator.sh pre-commit || exit 1
```

### GitHub Actions
```yaml
name: Quality Validation
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Quality Validation
        run: ./scripts/quality-validator.sh complete --ci
```

### Devbox Integration
```json
{
  "packages": [
    "nodejs",
    "rustc",
    "python3"
  ],
  "scripts": {
    "quality": "./scripts/quality-validator.sh complete"
  }
}
```

## Troubleshooting

### Common Issues

**Tool not found**:
- Install missing tools via package manager
- Use environment manager to install dependencies
- Check PATH configuration

**Configuration errors**:
- Validate JSON syntax
- Check file permissions
- Verify tool compatibility

**Performance issues**:
- Use incremental validation
- Enable parallel execution
- Cache results appropriately

### Debug Mode
Enable detailed logging:
```bash
./scripts/quality-validator.sh complete --debug
```

### Health Check
Verify tool installation:
```bash
./scripts/quality-validator.sh health-check
```

## References

- **Language Support**: See `references/supported-languages.md`
- **Configuration Guide**: See `references/configuration.md`
- **Output Formats**: See `references/output-formats.md`
- **Error Handling & Security**: See `references/error-handling-security.md`
- **Security Patterns**: See `references/security-scanning.md`
- **CI Integration**: See `references/ci-integration.md`

## Scripts

### quality-validator.sh
Main orchestrator script handling all validation phases with automatic language detection and environment integration.

### language-detectors/
Language-specific detection and configuration scripts for each supported language and framework.

### security-scanners/
Security-focused validation scripts for secret detection, dependency auditing, and vulnerability scanning.

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/code-quality-validation/SKILL.md`
- Scripts: `scripts/quality-validator.sh`, `scripts/language-detectors/`, `scripts/security-scanners/`
- References: `references/supported-languages.md`, `references/configuration.md`, `references/output-formats.md`, `references/error-handling-security.md`

### Related Skills
- project-detection (dependency)
- ai-development-loop (dependent)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
