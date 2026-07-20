<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 2.0.0

Create and maintain OKF knowledge bundles through four operations: create a new bundle from scratch, ingest new sources into an existing bundle, query a bundle for answers, and lint a bundle for contradictions or stale claims. Use when users want to create an OKF-compliant knowledge bundle, add new sources to an existing bundle, query a bundle for answers, health-check a bundle, or file query results back as new concepts. This skill consolidates the former ai-knowledge-bundle-create workflow and the knowledge-bundle-lifecycle skill into a single upsert skill covering the full bundle lifecycle. Make sure to use this skill whenever the user mentions knowledge bundles, OKF, Open Knowledge Format, concept documents, bundle ingest, bundle query, bundle lint, or wants to organize structured knowledge into a compounding markdown wiki, even if they don't explicitly ask for a "knowledge bundle creator." Do NOT trigger on general documentation questions, one-off markdown files, README creation (use readme-upsert), or general coding tasks — this skill is for OKF knowledge bundle lifecycle management, not general writing.

## Metadata

| Field | Value |
|-------|-------|
| Name | `knowledge-bundle-upsert` |
| Category | `ai` |
| Version | `2.0.0` |
| Status | `` |
| Owner |  |

## Overview

### Three-Layer Architecture

OKF bundles operate within a three-layer architecture:

1. **Raw sources** — your curated collection of source documents. Articles,
   papers, images, data files. These are immutable — you read from them but
   never modify them. This is your source of truth.

2. **The bundle (wiki)** — a directory of markdown concept files following OKF
   v0.1. Summaries, entity pages, concept pages, comparisons, an overview, a
   synthesis. The agent owns this layer entirely. It creates pages, updates
   them when new sources arrive, maintains cross-references, and keeps
   everything consistent. You read it; the agent writes it.

3. **The schema** — the skill files (this one) that tell the agent how the
   bundle is structured, what the conventions are, and what workflows to follow
   when ingesting sources, answering questions, or maintaining the bundle. You
   and the agent co-evolve this over time as you figure out what works for your
   domain.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — check for existing concepts before creating new bundle pages
- **ai-skill-upsert** (skill, sibling) — Same upsert family — handles AI skill creation and updates
- **ai-workflow-upsert** (skill, sibling) — Same upsert family — handles AI workflow creation and updates
- **agent-file-upsert** (skill, sibling) — Same upsert family — handles agent file creation and updates
- **prompt-upsert** (skill, sibling) — Same upsert family — handles prompt creation and updates
- **readme-upsert** (skill, sibling) — Same upsert family — handles README.md creation and updates
- **template-upsert** (skill, sibling) — Same upsert family — handles template creation and updates
- **project-adopter** (skill, consumer) — Installs built knowledge bundles into consumer projects via scripts/install-knowledge-bundles.py — use to populate .agents/knowledge/bundles/ with universal and stack-matched bundles during project adoption
- **** (, example) — Canonical OKF bundle for container authoring and runtime practices
- **** (, example) — Canonical OKF bundle for Java/JVM practices
- **** (, example) — Canonical OKF bundle for data engineering practices
- **** (, example) — Canonical OKF bundle for TypeScript monorepo conventions
- **** (, example) — Canonical OKF bundle for DevSecOps codeguard rules
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram

---

- **Full skill**: [`skills/ai/knowledge-bundle-upsert/SKILL.md`](skills/ai/knowledge-bundle-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
