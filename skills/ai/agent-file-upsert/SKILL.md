---
name: agent-file-upsert
description: Generate hierarchical AGENTS.md documentation for AI agents working in codebases. Use when onboarding an AI agent to an existing codebase (Brownfield) to establish context and conventions. Triggers on requests like "create AGENTS.md", "generate agent documentation", "help AI understand this codebase", or "set up agent guidance for this repo".
version: 2.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-12-07"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "documentation", "agents", "brownfield", "hierarchical-docs"]
dependencies: []
see-also:
  - skill: "readme-upsert"
    relationship: "related"
    description: "Generate or update README documentation with similar hierarchical principles"
  - skill: "ai-skill-upsert"
    relationship: "complement"
    description: "For creating new AI skills — pairs with agent-file-upsert for full AI guidance setup"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
---

{{{ include "includes/base-ai-guidance.md" . }}}

---

# Agent File Upsert

Generate a hierarchical AGENTS.md system to help AI agents work efficiently with minimal token usage (JIT context).

## Quick Start

When invoked, this skill analyzes the codebase and creates:
- `AGENTS.md` (Root)
- `apps/**/AGENTS.md` (Sub-projects)
- `packages/**/AGENTS.md` (Sub-packages)
- `internal-docs/oos/` (Out-of-scope documentation)

## Core Principles

- **Lightweight Root**: Keep root AGENTS.md minimal (~100-200 lines)
- **Nearest-wins Hierarchy**: Agents read the closest AGENTS.md first
- **JIT Indexing**: Point to sub-AGENTS.md files rather than duplicating content
- **Token Efficiency**: Prioritize small, actionable guidance over encyclopedic text

## Workflow

### Phase 1: Repository Analysis

1. **Review Documentation**: Check README.md, docs/, internal-docs/
2. **Analyze Structure**: Identify repo type (monorepo/polyrepo), tech stack, build system
3. **Map Components**: Identify major directories (`apps/`, `services/`, `packages/`)
4. **Identify Patterns**: Code organization, naming conventions, critical files
5. **Output**: A structured map of the repository

### Phase 2: Generate Root AGENTS.md and Developer Guide

Split content across two files by audience. The root `AGENTS.md` serves **users** (people deploying/using the project); a separate `.agents/knowledge/developer.md` serves **developers** (people working on the code). This is progressive disclosure — developer content is only loaded when an agent is editing code, not when a user is setting up or running the project.

**Root `AGENTS.md`** (user-facing):
- **Project Snapshot**: Repo type, stack
- **Project Overview**: 2-3 sentences on what it does and who it's for
- **Root Setup**: Install, build, test commands (users run these too)
- **Tech Stack**: What's included
- **JIT Index**: Directory map pointing to sub-AGENTS.md files **and the developer guide**
- **Out of Scope Reference**: Link to `internal-docs/oos/`
- **Universal Contracts**: Only rules that bind users (tooling, environment activation)
- **Developer Guide Reference**: Link to `.agents/knowledge/developer.md`

**`.agents/knowledge/developer.md`** (developer-facing):
- **JIT Index**: Pointer to `internal-docs/oos/` (check before adding features)
- **Commands**: Environment-specific commands (devbox, etc.)
- **Workflow**: Branching, TDD, PR process
- **Key Directories**: Repo structure
- **Key Files**: Config files, documentation files
- **Patterns**: Code conventions (✅ DO / ❌ DON'T)
- **Boundaries**: Always / ask-first / never rules
- **Known Gotchas**: Warnings specific to working on the code
- **Definition of Done**: PR checklist

**Audience Separation Rules:**
- Do NOT mix user and developer content in the same file — split them
- The root AGENTS.md links to the developer guide in its JIT Index and a Developer Guide section
- Setup commands appear in the user file (both audiences need them); workflow/process appears in the developer file
- Universal Contracts in the root file contain only rules that bind users; developer-specific rules go in the developer file's `<boundaries>` section

#### Root AGENTS.md Template

See: `references/AGENT-project-root-template.md.tmpl`

The root template provides the user-facing structure: Project Snapshot, Setup, JIT Index (pointing to sub-AGENTS.md files and the developer guide), Out of Scope reference, Universal Contracts, and a Developer Guide link.

#### Developer Guide Template

See: `references/AGENT-project-developer-template.md.tmpl`

Lives at `.agents/knowledge/developer.md`. Contains workflow, key-directories, key-files, patterns, boundaries, known-gotchas, and Definition of Done.

### Phase 3: Generate Sub-Folder AGENTS.md

For each major package/directory, create a detailed file with:

- **Identity**: What it does, tech used
- **Setup & Run**: Package-specific commands
- **Patterns & Conventions**: Most important. File org, naming, "✅ DO / ❌ DON'T" examples
- **Touch Points**: Key files (Auth, API, Config)
- **JIT Index Hints**: Specific search commands (`rg`, `find`) for this package
- **Gotchas**: Specific warnings

#### Sub-Folder AGENTS.md Template

See: `references/AGENT-project-subfolder-template.md.tmpl`

Lives at `{package}/AGENTS.md`. Developer-focused (agents working in code). Contains the DOX-influenced contract sections: Purpose, Ownership, Local Contracts, Patterns, Key Files, Search Hints, Verification, and JIT Index.

### Phase 4: Special Considerations

- **Design System**: Document component usage and tokens
- **Database**: Document ORM, migrations, seeding
- **API**: Document routes, middleware, validation
- **Testing**: Document patterns, mocks, coverage

### Phase 5: Out of Scope Documentation

Maintain an `{REPO_ROOT}/internal-docs/oos/` directory documenting what the repository explicitly does NOT do. This prevents scope creep and helps agents check boundaries before suggesting features.

**Naming Convention:**
- Files: `oos-YYYYMMDDHHmm-{slug}.md` (date-embedded, chronologically sortable)
- Directory: `internal-docs/oos/YYYY/MM/` structure

**Integration:**
- Root AGENTS.md: brief `## Out of Scope` section pointing to `internal-docs/oos/`
- Developer guide: JIT Index entry pointing to `internal-docs/oos/` with a note to check before adding features

### Phase 6: Usage Protocol

AGENTS.md files are binding work contracts for their subtrees. Everything in a subtree must stay understandable from the nearest AGENTS.md plus every parent above it. Agents using the generated hierarchy must follow this traversal before editing:

1. Read the root AGENTS.md
2. Identify every file or folder expected to be touched
3. Walk from the repository root to each target path
4. Read every AGENTS.md found along each route
5. If a parent AGENTS.md lists a child AGENTS.md whose scope contains the path, read that child and continue from there
6. Use the nearest AGENTS.md as the local contract and parent docs for repo-wide rules
7. If docs conflict, the closer doc controls local work details, but no child doc may weaken the hierarchy

Do not rely on memory. Re-read the applicable AGENTS.md chain in the current session before editing.

### Phase 7: Maintenance Protocol

Every meaningful change requires a documentation pass before the task is done. Update the closest owning AGENTS.md when a change affects:

- Purpose, scope, ownership, or responsibilities
- Durable structure, contracts, workflows, or operating rules
- Required inputs, outputs, permissions, constraints, side effects, or artifacts
- User preferences about behavior, communication, process, organization, or quality
- AGENTS.md creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Small edits that do not change behavior or contracts may leave docs unchanged, but the documentation pass still must happen.

**Closeout checklist:**

1. Re-check changed paths against the AGENTS.md chain
2. Update nearest owning docs and any affected parents or children
3. Refresh every affected JIT Index
4. Remove stale or contradictory text
5. Run existing verification when relevant
6. Report any docs intentionally left unchanged and why

## Instructions

- **Token Efficiency**: Prioritize small, actionable guidance over encyclopedic text
- **Examples**: Always provide real file paths as examples
- **Commands**: Ensure commands are copy-paste ready
- **Hierarchy**: Agents should read the closest `AGENTS.md` first
- **Structured Data**: Use markdown tables for any tabular data in AGENTS.md files (categories, compliance scores, file inventories, etc.). Markdown tables are readable by both humans and AI agents without learning a custom format. Avoid JSON blocks, TOON, or other custom notations in documentation — markdown tables are the standard.

Example:
```markdown
| Category | Rating | Status | Source Files |
|----------|--------|--------|--------------|
| Auth     | 100%   | ✅ Full | src/auth/    |
| API      | 75%    | ⚠️ Partial | src/api/  |
```

## Design By Contract

### Preconditions
- Access to a readable codebase

### Postconditions
- `AGENTS.md` exists at root (user-facing)
- `.agents/knowledge/developer.md` exists (developer-facing)
- `AGENTS.md` files exist in major sub-directories
- `internal-docs/oos/` directory exists with decision documentation

## Example Session

```
User: Create AGENTS.md for this codebase

Claude:
1. Analyzing repository structure...
   [Identifies monorepo structure, tech stack, major directories]

2. Generating root AGENTS.md...
   [Creates lightweight root with JIT index]

3. Generating sub-folder AGENTS.md files...
   [Creates detailed guides for apps/web/, packages/core/, etc.]

4. Setting up out-of-scope documentation...
   [Creates internal-docs/oos/ directory structure]

Done! Created:
- AGENTS.md (root)
- apps/web/AGENTS.md
- packages/core/AGENTS.md
- internal-docs/oos/YYYY/MM/oos-YYYYMMDDHHmm-initial.md
```

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/agent-file-upsert/SKILL.md`
- Root template: `references/AGENT-project-root-template.md.tmpl`
- Developer template: `references/AGENT-project-developer-template.md.tmpl`
- Sub-folder template: `references/AGENT-project-subfolder-template.md.tmpl`
- Output files: `AGENTS.md`, `.agents/knowledge/developer.md`, `**/AGENTS.md`
- Out of scope directory: `{REPO_ROOT}/internal-docs/oos/`

### Related Skills
- readme-upsert (related) — Generate or update README documentation
- ai-skill-upsert (complement) — For creating new AI skills
- base-ai-guidance (base-framework) — Shared framework for all AI guidance types

### External Resources
- Project documentation: https://github.com/levonk/dotfiles
- DOX framework (inspiration for usage/maintenance protocols): https://github.com/agent0ai/dox

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk

<!-- vim: set ft=markdown -->
