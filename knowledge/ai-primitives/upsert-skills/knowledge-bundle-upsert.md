---
type: Skill Reference
title: knowledge-bundle-upsert
description: Creates and maintains OKF knowledge bundles. The producer skill for the knowledge bundle primitive.
resource: src/current/skills/ai/knowledge-bundle-upsert/
tags: [upsert-skills, okf, knowledge-management, knowledge-bundle, lifecycle]
timestamp: 2026-07-11T10:30:00Z
---

# knowledge-bundle-upsert

## Summary

Creates and maintains OKF knowledge bundles through four operations: create
a new bundle from scratch, ingest new sources into an existing bundle, query
a bundle for answers, and lint a bundle for contradictions or stale claims.
The producer skill for the knowledge bundle primitive.

## Version

2.0.0

## Modes

- **Mode A: Create** — Scaffold a new OKF-compliant knowledge bundle from scratch
- **Mode B: Ingest** — Add a new source to an existing bundle
- **Mode C: Query** — Answer a question using the bundle, then file good answers back
- **Mode D: Lint** — Health-check the bundle for contradictions, orphans, broken links

## Key Capabilities

- Create OKF v0.1-compliant knowledge bundles
- Ingest sources and extract concepts (one concept per file)
- Query bundles with progressive disclosure (index → concept → synthesis)
- Lint for contradictions, orphan pages, missing pages, broken links
- File good answers back as new concept documents (compounding)

## Tags

`ai/skill`, `okf`, `knowledge-management`, `knowledge-bundle`, `lifecycle`, `ingest`, `lint`, `compounding`

## File Location

`src/current/skills/ai/knowledge-bundle-upsert/SKILL.md.tmpl`

## Produces

OKF knowledge bundles — compounding, structured knowledge bases following
the Open Knowledge Format v0.1. This very bundle is an example of the
skill's output.

## Three-Layer Architecture

1. **Raw sources** — immutable source documents (read-only)
2. **The bundle (wiki)** — markdown concept files following OKF v0.1 (agent-owned)
3. **The schema** — the skill files that tell the agent how the bundle works (co-evolved)

## References

- `references/bundle-structure.md` — Directory layout and reserved filenames
- `references/okf-spec.md` — OKF v0.1 design principles and conformance criteria
- `references/concept-documents.md` — Frontmatter fields and body structure
- `references/index-files.md` — Progressive disclosure with index files
- `references/log-files.md` — Chronological update history
- `references/best-practices.md` — Type naming, maintenance, lint
- `references/example-concepts.md` — Resource-bound and abstract concept examples
- `references/operations.md` — Ingest, query, and lint workflows

# Citations

[1] [knowledge-bundle-upsert SKILL.md](src/current/skills/ai/knowledge-bundle-upsert/SKILL.md.tmpl)
[2] [OKF v0.1 Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
