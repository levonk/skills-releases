<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# If installed via skills (includes/ is bundled alongside the skill):

> Category: **ai** · Status:  · Version: 1.0.0

Maintain and grow OKF knowledge bundles through ingest, query, and lint operations. Use when users want to add new sources to an existing bundle, query a bundle for answers, health-check a bundle for contradictions or stale claims, or file query results back as new concepts. This skill wraps the ai-knowledge-bundle-create workflow, adding the living-artifact lifecycle that the create-only workflow does not cover. Use this skill after a bundle has been created, or when maintaining a bundle over time.

## Metadata

| Field | Value |
|-------|-------|
| Name | `knowledge-bundle-lifecycle` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

A knowledge bundle is not a one-time deliverable — it is a persistent, compounding artifact. The create workflow produces the initial structure. This skill covers the three operations that keep the bundle useful as it grows: **Ingest**, **Query**, and **Lint**.

### Three-Layer Architecture

OKF bundles operate within a three-layer architecture:

1. **Raw sources** — your curated collection of source documents. Articles, papers, images, data files. These are immutable — you read from them but never modify them. This is your source of truth.

2. **The bundle (wiki)** — a directory of markdown concept files following OKF v0.1. Summaries, entity pages, concept pages, comparisons, an overview, a synthesis. The agent owns this layer entirely. It creates pages, updates them when new sources arrive, maintains cross-references, and keeps everything consistent. You read it; the agent writes it.

3. **The schema** — the workflow/skill files (like this one and `ai-knowledge-bundle-create`) that tell the agent how the bundle is structured, what the conventions are, and what workflows to follow when ingesting sources, answering questions, or maintaining the bundle. You and the agent co-evolve this over time as you figure out what works for your domain.

## Related Skills
- **** (, creates-the-bundle) — Create OKF-compliant knowledge bundles — the create-only workflow this skill wraps
- **research-phase** (template, shared-include) — Shared research phase — check for existing concepts before creating new bundle pages
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files

---

- **Full skill**: [`skills/ai/knowledge-bundle-lifecycle/SKILL.md`](skills/ai/knowledge-bundle-lifecycle/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-11T11:03:17Z
