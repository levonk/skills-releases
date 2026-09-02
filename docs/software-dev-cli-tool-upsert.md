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

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **cicd-upsert** (skill, complement) — Builds CI/CD pipelines — cli-tool-upsert builds the CLI tools that pipelines run
- **nixify** (skill, complement) — Packages CLI tools for Nix distribution — cli-tool-upsert creates the tool, nixify packages it
- **project-detection** (skill, dependency) — Detects project type and existing tooling — cli-tool-upsert uses detection to pick language and framework
- **surgical-config** (skill, complement) — Modifies config files non-destructively — cli-tool-upsert creates CLI tools that may read/write config

---

- **Full skill**: [`skills/software-dev/cli-tool-upsert/SKILL.md`](skills/software-dev/cli-tool-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:14:22Z
