---
type: Practice
title: CLI Tool Standards
description: Cross-language CLI standards — standard args, config precedence, output discipline, color control, daemon mode, agent mode (AXI/TOON), shell completion, man pages, and structured logging.
tags: [cli, standards, axi, toon, agent-mode, daemon, cross-language]
timestamp: 2026-07-17T00:00:00Z
---

# CLI Tool Standards

## Failure Mode

CLI tools drift across projects and languages, causing inconsistent UX,
configuration handling, and operational posture. Traditional human-centric CLI
design is suboptimal for autonomous agent consumption.

## Practice

Adopt a unified cross-language standard for CLI program behavior with **agent
mode as the default**.

### Standard Arguments

All CLIs must support `--help`/`-h`, `--version`/`-v`, and `--usage`.

### Configuration Precedence

CLI args > env vars > local project config > user config (XDG) > system config >
hardcoded defaults. Prefer TOML for human-edited config.

### Output Discipline

- Results to stdout; logs/progress/errors to stderr
- `--json` output mode
- `--color=auto|always|never` with smart TTY detection
- Honor `NO_COLOR` environment variable

### Daemon Mode

For long-running tasks (>30s), provide `--daemon`/`--no-daemon` flags with
auto-spawning, `--list-jobs`, and `--cancel-job <id>`.

### Agent Mode (AXI)

- **TOON format** on stdout (~40% token savings over JSON)
- **Minimal default schemas**: 3-4 fields in list output, not 10
- **Content truncation**: truncated preview with total size and `--full` escape
- **Pre-computed aggregates**: include total count in list output
- **Definitive empty states**: "0 tasks found" not empty output
- **Structured errors on stdout**: actionable suggestions, no raw stack traces
- **No interactive prompts**: fail with clear error if required value missing
- **Content-first no-args**: show live state, not usage manual
- **Contextual disclosure**: suggest next steps after current output
- **Session integrations**: register hooks for Claude Code, Codex, OpenCode

### Error Format

```
ERROR: <description> - <suggestion>
```

### File References

Use VSCode-compatible format: `file:///absolute/path/to/file:line:column`

## Related Concepts

- [Quality Gates](quality-gates.md) — Testing CLI behavior
- [Container Support](container-support.md) — Health check for containers

## Citations

[1] `internal-docs/adr/adr-20260607001-cli-tool-standards.md` — levonk-base-boilerplate
