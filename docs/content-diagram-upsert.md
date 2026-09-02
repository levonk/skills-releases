<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **content** · Status:  · Version: 1.1.0

Create and embed diagrams in technical documentation (ADR, design docs, README, knowledge bundles) or produce standalone editorial HTML/SVG/PNG diagrams for blog posts, slides, OG cards, and print. Selects the right route (Mermaid, PlantUML, Excalidraw, or editorial HTML/SVG) from output type and rendering environment, authors the diagram with syntax that survives markdown pre-processing (or, for editorial output, follows the 4px-grid design system), validates by rendering before returning, and embeds at the correct location. Use when the user asks to 'draw a flowchart', 'add a sequence diagram', 'create an architecture diagram', 'fix a broken mermaid diagram', 'render a PlantUML diagram', 'add a diagram to this ADR/doc', 'create a standalone diagram', 'make a branded diagram', 'redraw this draw.io/mermaid source as a polished schematic', or 'design a diagram for a slide/OG card/blog post'. Do NOT trigger on general documentation writing, data visualizations/charts (use Chart.js/D3/Plotly), UI mockups (use Figma), or architecture-as-code (C4/Structurizr).

## Metadata

| Field | Value |
|-------|-------|
| Name | `diagram-upsert` |
| Category | `content` |
| Version | `1.1.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **trigger-guard** (template, over-triggering-guard) — Shared over-triggering guard protocol
- **ai-upsert** (skill, complement) — Knowledge bundles that document diagram practices live in src/current/knowledge/documentation-diagram-practices/ — this skill references that bundle rather than restating it
- **** (, complement) — The canonical knowledge bundle this skill references — now includes editorial-html-svg-diagrams.md synthesizing the upstream cathrynlavery/diagram-design skill for standalone editorial deliverables

---

- **Full skill**: [`skills/content/diagram-upsert/SKILL.md`](skills/content/diagram-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:17:25Z
