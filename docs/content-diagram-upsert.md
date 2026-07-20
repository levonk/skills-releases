<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **content** · Status:  · Version: 1.0.0

Create and embed diagrams in technical documentation (ADR, design docs, README, knowledge bundles). Selects the right tool (Mermaid, PlantUML, Excalidraw) from output type and rendering environment, authors the diagram with syntax that survives markdown pre-processing, validates by rendering before returning, and embeds at the correct location. Use when the user asks to 'draw a flowchart', 'add a sequence diagram', 'create an architecture diagram', 'fix a broken mermaid diagram', 'render a PlantUML diagram', or 'add a diagram to this ADR/doc'. Do NOT trigger on general documentation writing, data visualizations/charts (use Chart.js/D3/Plotly), UI mockups (use Figma), or architecture-as-code (C4/Structurizr).

## Metadata

| Field | Value |
|-------|-------|
| Name | `diagram-upsert` |
| Category | `content` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- [`references/tool-selection.md`](references/tool-selection.md) — pointer to
  the bundle's `diagram-tool-selection.md`.
- [`references/mermaid-syntax.md`](references/mermaid-syntax.md) — pointer to
  the bundle's `mermaidjs.md`.
- [`references/plantuml-syntax.md`](references/plantuml-syntax.md) — pointer
  to the bundle's `plantuml.md`.
- [`references/excalidraw-workflow.md`](references/excalidraw-workflow.md) —
  pointer to the bundle's `excalidraw.md`.
- [`documentation-diagram-practices overview`](references/included/knowledge/documentation-diagram-practices/overview.md)
  — the canonical knowledge bundle, materialized for offline standalone use.
  Read before authoring.
- `scripts/resolve-reference.sh` — three-tier fallback resolver (local → URL →
  materialized) for any runtime lookups of bundle content.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **trigger-guard** (template, over-triggering-guard) — Shared over-triggering guard protocol
- **knowledge-bundle-upsert** (skill, complement) — Knowledge bundles that document diagram practices live in src/current/knowledge/documentation-diagram-practices/ — this skill references that bundle rather than restating it

---

- **Full skill**: [`skills/content/diagram-upsert/SKILL.md`](skills/content/diagram-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
