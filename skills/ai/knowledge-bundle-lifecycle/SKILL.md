---
name: knowledge-bundle-lifecycle
description: Maintain and grow OKF knowledge bundles through ingest, query, and lint operations. Use when users want to add new sources to an existing bundle, query a bundle for answers, health-check a bundle for contradictions or stale claims, or file query results back as new concepts. This skill wraps the ai-knowledge-bundle-create workflow, adding the living-artifact lifecycle that the create-only workflow does not cover. Use this skill after a bundle has been created, or when maintaining a bundle over time.
version: 1.0.0
date:
  created: "2026-06-28"
  updated: "2026-06-28"
  last-used: ""
tags:
  - "ai/skill"
  - "okf"
  - "knowledge-management"
  - "lifecycle"
  - "ingest"
  - "lint"
  - "compounding"
see-also:
  - workflow: "ai-knowledge-bundle-create"
    relationship: "creates-the-bundle"
    description: "Create OKF-compliant knowledge bundles — the create-only workflow this skill wraps"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Knowledge Bundle Lifecycle

A skill for maintaining and growing OKF knowledge bundles over time. The `ai-knowledge-bundle-create` workflow creates a bundle; this skill keeps it alive.

## Overview

A knowledge bundle is not a one-time deliverable — it is a persistent, compounding artifact. The create workflow produces the initial structure. This skill covers the three operations that keep the bundle useful as it grows: **Ingest**, **Query**, and **Lint**.

### Three-Layer Architecture

OKF bundles operate within a three-layer architecture:

1. **Raw sources** — your curated collection of source documents. Articles, papers, images, data files. These are immutable — you read from them but never modify them. This is your source of truth.

2. **The bundle (wiki)** — a directory of markdown concept files following OKF v0.1. Summaries, entity pages, concept pages, comparisons, an overview, a synthesis. The agent owns this layer entirely. It creates pages, updates them when new sources arrive, maintains cross-references, and keeps everything consistent. You read it; the agent writes it.

3. **The schema** — the workflow/skill files (like this one and `ai-knowledge-bundle-create`) that tell the agent how the bundle is structured, what the conventions are, and what workflows to follow when ingesting sources, answering questions, or maintaining the bundle. You and the agent co-evolve this over time as you figure out what works for your domain.

## Operations

### Ingest

You drop a new source into the raw collection and tell the agent to process it. The agent:

1. Reads the source
2. Discusses key takeaways (optional — depends on supervision level)
3. Writes a summary page in the bundle
4. Updates the index (`index.md`)
5. Updates relevant entity and concept pages across the bundle
6. Appends an entry to the log (`log.md`)

A single source might touch 10-15 bundle pages. Extract concepts, not pages — a single source document may produce many concept files. One concept per file.

**Supervision levels:**

- **One-at-a-time (recommended)**: Ingest sources one at a time, stay involved — read the summaries, check the updates, guide the agent on what to emphasize.
- **Batch**: Ingest many sources at once with less supervision. Faster but less curated.

Document the chosen workflow in the bundle's schema for future sessions.

### Query

You ask questions against the bundle. The agent:

1. Reads the index first to find relevant pages
2. Drills into the relevant concept documents
3. Synthesizes an answer with citations

Answers can take different forms depending on the question — a markdown page, a comparison table, a chart.

**File good answers back.** Good answers and analyses are valuable and should not disappear into chat history. A comparison you asked for, an analysis, a connection you discovered — file it back into the bundle as a new concept document. This way explorations compound in the knowledge base just like ingested sources do.

### Lint

Periodically health-check the bundle. Look for:

- **Contradictions** between pages (newer sources superseding stale claims)
- **Orphan pages** with no inbound links
- **Missing pages** — important concepts mentioned in prose but lacking their own page
- **Missing cross-references** between related concepts
- **Broken links** that should be filled (not-yet-written knowledge that has become relevant)
- **Data gaps** that could be filled with a web search or a new source

The agent is good at suggesting new questions to investigate and new sources to seek. File lint findings as new concept documents or log entries.

## Indexing and Logging

Two reserved filenames help navigate the bundle as it grows:

- **`index.md`** is content-oriented — a catalog of everything in the bundle, each page listed with a link and a one-line description. The agent updates it on every ingest. When answering a query, the agent reads the index first. This works well at moderate scale and avoids the need for embedding-based RAG infrastructure.

- **`log.md`** is chronological — an append-only record of what happened and when (ingests, queries, lint passes). Newest first, ISO 8601 date headings. For grep-friendly parseability, entries MAY use a consistent `**<operation>** | <subject>` prefix within each date group.

## Best Practices

- The bundle is just a git repo of markdown files — you get version history, branching, and collaboration for free.
- The tedious part of maintaining a knowledge base is the bookkeeping (updating cross-references, keeping summaries current, noting contradictions). Agents don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass. The bundle stays maintained because the cost of maintenance is near zero.
- The human's job is to curate sources, direct the analysis, ask good questions, and think about what it all means. The agent's job is everything else.
- Lint regularly — a healthy bundle is more useful than a large one.
- When in doubt about whether to file something, file it. Compounding is the whole point.

## Citations

[1] [LLM Wiki pattern (Andrej Karpathy)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
[2] [OKF v0.1 Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
[3] Related: [Knowledge Bundle Create Workflow](/config/ai/workflows/ai/ai-knowledge-bundle-create.md.tmpl)
[4] Reference: [OKF Spec Reference](/config/ai/templates/ai/knowledge-bundle/references/okf-spec-reference.md)

<!-- vim: set ft=markdown -->
