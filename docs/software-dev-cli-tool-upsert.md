<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Create, update, and optimize CLI programs and scripts for AI agent consumption. Two tiers: embedded scripts (lightweight, bundled inside skills or projects) and full CLI tools (scaffolded from boilerplate). Applies AXI (Agent eXperience Interface) principles — token-efficient output, structured errors, definitive empty states, content-first no-args, contextual disclosure — plus CLI best practices like XDG cache/data separation, idempotent operations, and no interactive prompts. Use when creating a new CLI script or tool, making an existing script agent-friendly, scaffolding a CLI project from boilerplate, auditing a CLI for AXI compliance, or optimizing CLI output for token efficiency. Defaults: bash for tiny embedded scripts, Python (uv/PEP 723) for substantive embedded scripts, Rust for full CLI tools — but language is caller's choice. Do NOT trigger on general coding questions, bug fixes in existing CLIs, CI/CD pipeline creation (use cicd-upsert), Dockerfile writing (use container-image-build), or Nix packaging (use nixify) — this skill is for the CLI program itself, not the infrastructure around it.

## Metadata

| Field | Value |
|-------|-------|
| Name | `cli-tool-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

### What This Skill Does

1. **Creates embedded scripts** — small CLI scripts (bash or Python via uv/PEP
   723) bundled inside skills or projects. Agent-friendly by default: quiet
   output, `--verbose`/`--dry-run` flags, structured errors, XDG cache/data
   separation.
2. **Scaffolds full CLI tools** — standalone CLI programs from
   `levonk-base-boilerplate` templates (Python, Rust, Go, TypeScript, etc.).
   Full ADR-20260607001 compliance: `--help`/`--version`/`--usage`, config
   precedence, install/uninstall, shell completion, AXI agent mode.
3. **Audits and improves existing CLIs** — applies AXI principles to existing
   scripts and tools: token-efficient output, minimal schemas, content
   truncation, pre-computed aggregates, definitive empty states, structured
   errors, content-first no-args, contextual disclosure.

### Core Principles

- **Agent-first by default** — every CLI this skill creates is optimized for
  agent consumption via shell execution. Human-friendly features are layered on
  top via explicit flags (`--human`, `--interactive`), not the other way around.
- **AXI compliance** — follow the [Agent eXperience Interface](https://github.com/kunchenguid/axi)
  specification. See `references/axi-principles.md` for the full principle list
  with embedded-script vs full-tool applicability.
- **XDG compliance** — transient data in `${XDG_CACHE_HOME:-$HOME/.cache}`,
  persistent data in `${XDG_DATA_HOME:-$HOME/.local/share}`, config in
  `${XDG_CONFIG_HOME:-$HOME/.config}`. See `references/cli-best-practices.md`.
- **No interactive prompts** — every operation completable with flags alone.
  Missing required values fail immediately with a clear error, not a prompt.
- **Output discipline** — results to stdout, logs/progress/errors to stderr.
  Agents read stdout; stderr is for diagnostics they don't parse.
- **Idempotent mutations** — don't error when the desired state already exists.
  Exit 0 for no-ops. Reserve non-zero for genuine failures.
- **Language defaults, not dogma** — bash for tiny embedded scripts, Python
  (uv/PEP 723) for substantive embedded scripts, Rust for full CLI tools. But
  the caller chooses; the skill adapts.
- **DRY via boilerplate** — full CLI tools are scaffolded from
  `levonk-base-boilerplate` templates, not hand-rolled. The boilerplate encodes
  ADR-20260607001 standards so every tool starts compliant.

### Tier Selection

| Attribute | Embedded Script | Full CLI Tool |
|-----------|----------------|---------------|
| Size | <200 lines, single file | Multi-file project |
| Distribution | Bundled in skill/project | Standalone repo/package |
| Config | Env vars + XDG dirs | Config files + env vars + XDG |
| Dependencies | stdlib or PEP 723 inline | package manager (cargo, pip, npm) |
| Framework | argparse/stdlib | clap, click, cobra, commander |
| AXI level | Subset (output, errors, exit codes) | Full (TOON, schemas, session hooks) |
| Boilerplate | None — inline template | `levonk-base-boilerplate/apps/cli/*` |

When unsure, start embedded. A script that grows beyond ~200 lines or needs
config files, shell completion, or man pages is a candidate for full CLI tool
promotion.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **cicd-upsert** (skill, complement) — Builds CI/CD pipelines — cli-tool-upsert builds the CLI tools that pipelines run
- **nixify** (skill, complement) — Packages CLI tools for Nix distribution — cli-tool-upsert creates the tool, nixify packages it
- **project-detection** (skill, dependency) — Detects project type and existing tooling — cli-tool-upsert uses detection to pick language and framework
- **surgical-config** (skill, complement) — Modifies config files non-destructively — cli-tool-upsert creates CLI tools that may read/write config

---

- **Full skill**: [`skills/software-dev/cli-tool-upsert/SKILL.md`](skills/software-dev/cli-tool-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
