<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **general** · Status:  · Version: 1.0.0

Generate, reconcile, and audit ignore files (.gitignore, .codeiumignore, .cursorignore, .dockerignore, .npmignore, VS Code exclude settings, ripgrep config) from modular concern sources. Use when users want to create or update ignore files across multiple tools, find patterns that have diverged between .gitignore and .codeiumignore, harvest missing patterns from deployed files into the source-of-truth concerns, add a new ignore pattern to all relevant outputs at once, set up ignore files for a new project, update *.code-workspace files with proper exclude settings across a directory tree, or update ripgrep config to keep search results clean. Also use when the git-repository-management skill needs to update .gitignore as part of a commit workflow. Do NOT trigger on general git questions, single-file edits to one .gitignore (just edit it directly), or questions about what a specific ignore pattern does.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ignorefile-manager` |
| Category | `general` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **trigger-guard** (template, shared-include) — Over-triggering guard protocol
- **python-script-standards** (template, shared-include) — PEP 723 / uv header requirements for bundled scripts
- **git-repository-management** (skill, complement) — Uses ignorefile-manager to update .gitignore as part of commit workflows

---

- **Full skill**: [`skills/general/ignorefile-manager/SKILL.md`](skills/general/ignorefile-manager/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-03T17:56:44Z
