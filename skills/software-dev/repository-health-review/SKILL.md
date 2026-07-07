---
name: "repository-health-review"
description: "Comprehensive repository health analysis for outdated information, conflicting rules, undocumented standards, lessons from failures, missing tool documentation, and security/access patterns. Use when conducting repository audits, preparing for migrations, post-migration validation, security reviews, or maintaining code quality standards. Triggers on 'repository health', 'code audit', 'security review', 'documentation audit', 'quality check', or 'repository analysis'."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-05"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "repository-management", "quality-assurance", "security-auditing"]
dependencies:
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
  - type: nix
    name: ripgrep
    url: https://github.com/BurntSushi/ripgrep
  - type: nix
    name: fd
    url: https://github.com/sharkdp/fd
  - type: python
    name: json
    url: https://docs.python.org/3/library/json.html
  - type: python
    name: yaml
    url: https://pyyaml.org/
  - type: url
    name: GitHub REST API
    url: https://docs.github.com/en/rest
see-also:
  - name: project-detection
    type: related
  - name: monorepo-extractor
    type: related
  - name: base-ai-guidance
    type: base-framework
---

{{{ include "includes/base-ai-guidance.md" . }}}

## Repository Health Review Skill

### Quick Start

**Basic Repository Health Check:**

```bash
# Run comprehensive health review
./scripts/repository-health-review.sh /path/to/repository

# Run with verbose output
./scripts/repository-health-review.sh --verbose /path/to/repository

# Generate detailed report
./scripts/repository-health-review.sh --report /path/to/repository health-report.json

# Focus on specific issues
./scripts/repository-health-review.sh --security --outdated /path/to/repository
```

**Integration with Other Skills:**

```bash
# Use in monorepo extraction workflows
../monorepo-extractor/scripts/extract-project-strict.sh --analyze-ai-ide /path/to/monorepo project /path/to/new-repo

# Use as standalone audit
./scripts/repository-health-review.sh --pre-extraction /path/to/monorepo project-name
```

## Instructions

### When to Use

- **Repository Audits**: Regular health checks and quality assessments
- **Pre-Migration Analysis**: Before extracting projects from monorepos
- **Post-Migration Validation**: After repository restructuring
- **Security Reviews**: Identifying security vulnerabilities and access issues
- **Documentation Updates**: Finding outdated or missing documentation
- **Code Quality Initiatives**: Establishing and maintaining standards
- **Team Onboarding**: Ensuring repository is well-documented for new team members

**Keywords that trigger this skill**: "repository health", "code audit", "security review", "documentation audit", "quality check", "repository analysis"

### Health Analysis Categories

The review covers six key categories:

1. **Outdated Information Detection** - Date references, deprecated tools, broken links, old APIs
2. **Conflicting Rules Analysis** - ESLint conflicts, gitignore contradictions, config inconsistencies
3. **Undocumented Standards Detection** - Missing docs for scripts, env vars, custom formats, tools
4. **Lessons from Failures Analysis** - TODO/FIXME patterns, temporary workarounds, known issues
5. **Missing Tool Documentation** - Tools without setup instructions, undocumented config files
6. **Security and Access Patterns** - Hardcoded secrets, insecure configs, permission issues

> **See also**: [Health Categories Details](references/health-categories.md) for detailed descriptions of what each category checks, impact assessments, and common patterns.

### Core Workflow

1. **Repository Discovery**: Scan repository structure and identify key files
2. **Pattern Analysis**: Apply specialized analysis functions to each category
3. **Issue Classification**: Categorize findings by severity and impact
4. **Recommendation Generation**: Provide actionable improvement suggestions
5. **Report Generation**: Create comprehensive health review report
6. **Trend Analysis**: Track health metrics over time

> **See also**: [Analysis Functions](references/analysis-functions.md) for bash code implementations of each analysis function, and [Reporting and Metrics](references/reporting-metrics.md) for health score calculation, report structure, and CI/CD integration.

### Integration with Other Skills

#### Monorepo Extractor Integration

```bash
# The monorepo-extractor skill can call this skill for health analysis
../repository-health-review/scripts/repository-health-review.sh \
  --pre-extraction \
  --report health-analysis.json \
  /path/to/monorepo project-name
```

#### CI/CD Integration

```bash
# Weekly health check in CI pipeline
./scripts/repository-health-review.sh \
  --report weekly-health.json \
  --categories security,outdated \
  .
```

#### Development Workflow Integration

```bash
# Pre-commit health check
./scripts/repository-health-review.sh \
  --quick \
  --categories security,conflicts \
  .
```

### Best Practices

#### Before Running Health Review

1. **Clean Repository State**: Ensure working directory is clean
2. **Update Dependencies**: Run package updates to get latest security patches
3. **Backup Repository**: Create backup before major changes
4. **Notify Team**: Let team know about upcoming audit

#### During Health Review

1. **Use Verbose Mode**: Get detailed output for thorough analysis
2. **Generate Reports**: Create JSON reports for tracking trends
3. **Review Critical Issues**: Address security and critical issues first
4. **Document Findings**: Keep record of issues and resolutions

#### After Health Review

1. **Address Critical Issues**: Fix security vulnerabilities immediately
2. **Plan Improvements**: Create roadmap for addressing warnings
3. **Update Documentation**: Fix documentation gaps identified
4. **Schedule Follow-up**: Plan regular health checks

### Examples

#### Example 1: Basic Repository Health Check

```bash
# Quick health assessment
./scripts/repository-health-review.sh /opt/my-project

# Output:
# Repository Health Score: 82/100
# Critical Issues: 1
# Warnings: 4
# Info: 8
#
# 🔴 Critical: Hardcoded API key in config.js
# 🟡 Warning: Deprecated webpack version in package.json
# 🟡 Warning: Conflicting ESLint rules
# 🟡 Warning: TODO comments older than 6 months
# 🟡 Warning: Missing security headers documentation
```

#### Example 2: Security-Focused Review

```bash
# Security-specific analysis
./scripts/repository-health-review.sh --security --verbose /opt/my-project

# Output:
# Security Analysis Results:
# 🔴 Critical: Hardcoded database password
# 🔴 Critical: SSL verification disabled
# 🟡 Warning: Debug mode enabled in production config
# 🟡 Warning: Overly permissive file permissions
# 🔵 Info: Authentication patterns documented
```

#### Example 3: Pre-Migration Analysis

```bash
# Before extracting from monorepo
./scripts/repository-health-review.sh --pre-extraction /opt/company-monorepo webapp

# Output:
# Pre-Extraction Health Review for 'webapp':
# Migration Readiness: 78/100
#
# Issues to address before extraction:
# 🔴 Critical: Shared secrets in project config
# 🟡 Warning: Monorepo-specific paths in documentation
# 🟡 Warning: Undocumented build dependencies
#
# Recommendations:
# 1. Extract and secure shared secrets
# 2. Update documentation for standalone project
# 3. Document all build dependencies
```

### Troubleshooting

#### Common Issues

**Analysis Takes Too Long**:

- Use `--quick` flag for faster analysis
- Limit analysis with `--categories` flag
- Exclude large directories with `--exclude`

**False Positives**:

- Review analysis patterns and adjust regex
- Use `--ignore-patterns` to exclude known false positives
- Customize analysis functions for your repository

**Missing Issues**:

- Ensure analysis patterns cover your use cases
- Add custom analysis functions for domain-specific issues
- Update pattern lists regularly

### Resources

#### Related Skills

- `monorepo-extractor` - Uses this skill for pre/post-extraction health analysis
- `project-configuration` - Can use health review for setup validation

#### Documentation

- Repository health guidelines
- Security best practices
- Documentation standards
- Code quality metrics

#### External Resources

- OWASP security guidelines
- Industry documentation standards
- Security vulnerability databases
- Code quality frameworks

## References

- [Health Categories](references/health-categories.md) - Detailed descriptions of the 6 health analysis categories with impact assessments
- [Analysis Functions](references/analysis-functions.md) - Bash code implementations for outdated info, conflicting rules, security patterns, and custom analysis
- [Reporting and Metrics](references/reporting-metrics.md) - Health score calculation, report structure, CI/CD integration, and performance optimization

## Context Declaration

### File Paths

- Main skill: `config/ai/skills/software-dev/repository-health-review/SKILL.md`
- Scripts: `scripts/repository-health-review.sh`
- References: `references/health-categories.md`, `references/analysis-functions.md`, `references/reporting-metrics.md`

### Related Skills

- `project-detection` (related)
- `monorepo-extractor` (related)
- `base-ai-guidance` (base-framework)

### Project Information

- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

---

**Remember**: Repository health is an ongoing process, not a one-time fix. Regular health reviews help maintain code quality, security, and documentation standards over time.
