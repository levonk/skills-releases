---
name: readme-upsert
description: Generate or update a project's README.md for human developers. Use when onboarding a human to an existing codebase, creating a README from scratch, or refreshing a stale README. Triggers on requests like "create README", "generate readme", "update README", "write project readme", or "set up readme for this repo".
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-06-26"
  updated: "2026-06-26"
tags: ["ai/skill", "software-development", "documentation", "readme", "brownfield"]
dependencies: []
---

{{{ include "includes/base-ai-guidance.md" . }}}

---

# Readme Upsert

Generate or update a project's `README.md` — the human-facing entry point visible on GitHub and in the repo root.

## Scope

This skill handles **README.md only** — the single human-readable file at the repo root. For AI agent documentation (`AGENTS.md`, `.agents/knowledge/developer.md`, sub-folder `AGENTS.md`), use the `agent-file-upsert` skill instead.

**Key distinction:** README.md is for humans browsing GitHub. AGENTS.md is for AI agents loading context. They serve different audiences with different constraints:
- README: marketing tone, single file, no token budget, human reading speed
- AGENTS.md: contract tone, hierarchical, token-efficient, machine-loaded

## Workflow

### Phase 1: Repository Analysis

1. **Check for existing README**: If one exists, read it — preserve user-facing sections that are still accurate
2. **Review Documentation**: Check AGENTS.md, docs/, internal-docs/ for existing project descriptions
3. **Analyze Structure**: Identify repo type, tech stack, build system, entry points
4. **Identify Audience**: Who reads this README? (open-source contributors, internal team, end users?)
5. **Output**: A structured understanding of what the README needs to cover

### Phase 2: Generate README.md

Create a README using the template at `references/README-project-root-template.md.tmpl` as a starting point. Adapt it to the project — do not blindly copy the template.

**Required sections:**
- **Project name + overview**: What it does, who it's for (1-2 paragraphs)
- **Quick Start**: Copy-paste ready setup commands (clone, bootstrap, run)
- **Build/Test Commands**: The commands a developer needs day-to-day
- **Project Structure**: Directory layout with one-line descriptions
- **AI Agent Documentation**: Link to `AGENTS.md` for AI-specific guidance

**Optional sections** (include if relevant):
- Development Workflow (branching, TDD, PR process)
- Testing (how to run, what's required)
- Package Management (pnpm, etc.)
- Troubleshooting (common environment issues)
- Contributing (guidelines for external contributors)
- License

**What NOT to put in README.md:**
- AI agent workflows or context-loading instructions (those go in AGENTS.md)
- Detailed code patterns or ✅ DO / ❌ DON'T lists (those go in the developer guide)
- Out-of-scope documentation (that goes in `internal-docs/oos/`)
- Architecture Decision Records (those go in `internal-docs/adr/`)

### Phase 3: Upsert (Create or Update)

- **No existing README**: Create from the template, adapted to the project
- **Existing README, stale**: Update sections that are outdated, preserve accurate ones. Do not rewrite from scratch unless the existing README is fundamentally wrong
- **Existing README, accurate**: Only update sections that changed. Report what was left unchanged and why

### Phase 4: Cross-Reference Check

Verify the README links to:
- `AGENTS.md` — for AI agent guidance
- `internal-docs/oos/` — if out-of-scope docs exist
- `internal-docs/adr/` — if ADRs exist

Do NOT duplicate content from AGENTS.md or the developer guide into the README. Link to them instead.

## Instructions

- **Human tone**: Write for a developer browsing GitHub, not an AI loading context. Full sentences are fine; marketing language is acceptable for the overview
- **Copy-paste ready**: Every command block must be runnable as-is
- **Real paths**: Use actual file paths from the project, not template placeholders
- **Concise**: Aim for 100-200 lines. A README is a landing page, not a manual
- **No duplication**: If content exists in AGENTS.md or the developer guide, link to it rather than copying

## Design By Contract

### Preconditions
- Access to a readable codebase
- (Optional) Existing README.md to update

### Postconditions
- `README.md` exists at repo root
- README links to `AGENTS.md` for AI agent guidance
- No content duplicated from AGENTS.md or developer guide

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/readme-upsert/SKILL.md`
- README template: `references/README-project-root-template.md.tmpl`
- Output file: `README.md`

### Related Skills
- `agent-file-upsert`: Generates AGENTS.md hierarchy (AI agent documentation). Run this skill first, then readme-upsert, so the README can link to the generated AGENTS.md files.

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk

<!-- vim: set ft=markdown -->
