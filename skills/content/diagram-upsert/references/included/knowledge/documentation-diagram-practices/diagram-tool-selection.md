---
type: Practice
title: Diagram Tool Selection
description: Pick the right diagram tool (Mermaid, PlantUML, Excalidraw, or editorial HTML/SVG) by output type, version-control needs, and rendering environment — text-based tools for markdown-embedded diffability, Excalidraw for whiteboard sketching, PlantUML for precise UML, editorial HTML/SVG for standalone deliverables.
tags: [documentation, diagrams, tool-selection, mermaid, plantuml, excalidraw, editorial, html-svg]
date:
  created: "2026-07-19"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
---

# Diagram Tool Selection

## Practice

Pick the diagram tool by **output type** and **rendering environment**, not by
general familiarity. The four routes serve orthogonal sweet spots and can be
mixed within one project — pick per diagram, not per document.

| Tool | Source format | Renders in | Best for | VCS diffable |
|------|--------------|-----------|----------|--------------|
| **Mermaid** | Text (fenced code block) | GitHub, Obsidian, VS Code, most static site generators | Flowcharts, decision trees, sequence diagrams embedded in markdown | ✅ Yes |
| **PlantUML** | Text (`@startuml`/`@enduml`) | Server (plantuml.com), local jar, Obsidian plugin | Precise UML (class, state, component, deployment), complex sequence diagrams | ✅ Yes |
| **Excalidraw** | `.excalidraw` JSON or binary | Excalidraw app, Obsidian plugin, npm package | Hand-drawn whiteboard sketches, architecture whiteboard sessions, low-fidelity mockups | ⚠️ JSON (diffable but noisy) |
| **Editorial HTML/SVG** | Self-contained `.html` with inline SVG/CSS | Any modern browser, slide decks, OG cards, print | Standalone editorial diagrams where the diagram is the deliverable, not an inline embed | ⚠️ HTML (diffable but verbose) |

### Decision tree

1. **Embedding in markdown that must render on GitHub/Obsidian without a
   plugin?** → **Mermaid**. Native fenced code block support, no server
   dependency.
2. **Need precise UML notation (class diagrams, state machines, component
   diagrams) with layout control?** → **PlantUML**. Richer UML vocabulary
   than Mermaid; server or local jar rendering.
3. **Whiteboard-style sketch where hand-drawn aesthetics communicate
   "tentative / work in progress"?** → **Excalidraw**. The sketch aesthetic
   signals impermanence — readers don't mistake it for a finalized architecture.
4. **The diagram is the deliverable — a standalone HTML/SVG/PNG file for a
   blog post, slide, OG card, or long-form essay where editorial layout and
   visual hierarchy matter more than VCS diffability?** → **Editorial
   HTML/SVG**. Follow
   [Editorial HTML/SVG Diagram Practices](editorial-html-svg-diagrams.md) and
   the upstream [`cathrynlavery/diagram-design`](https://github.com/cathrynlavery/diagram-design)
   skill (39 visual types, skinnable design system, brand onboarding).
5. **Offline / air-gapped environment?** → **Mermaid** (renders client-side) or
   **PlantUML with local jar** (avoid the public plantuml.com server).
6. **Diagram must be editable by non-developers?** → **Excalidraw** (GUI
   editor) — text-based tools require syntax knowledge.

### When to mix tools in one document

A single ADR or design doc can use all three markdown-embedded tools:

- **Mermaid** for the decision tree (renders inline, no server)
- **PlantUML** for the detailed sequence diagram (precise UML, auto-layout)
- **Excalidraw** for the whiteboard sketch of the proposed architecture
  (signals "this is a draft, not a finalized design")

A standalone editorial HTML/SVG diagram is a separate deliverable, not an
inline embed — produce it as its own file and link to it from the markdown.

## Why

Picking the wrong tool creates friction at the worst time: a Mermaid diagram
that uses syntax the renderer doesn't support, a PlantUML diagram that can't
render because the server is unreachable, or an Excalidraw diagram that's a
binary blob in git history. Matching the tool to the output type and rendering
environment up front avoids rework.

## When this practice applies

- Writing ADRs, design docs, or README files that embed diagrams.
- Documentation that will be read in multiple environments (GitHub, Obsidian,
  VS Code preview, static site).
- Whiteboard sessions that need to be captured and version-controlled.

## When this practice does NOT apply

- **Architecture diagrams as code (C4 model, Structurizr)** — those are
  application architecture tools, not documentation embedding tools.
- **UI mockups** — use Figma, Sketch, or a dedicated UI tool.
- **Data visualizations** — use a charting library (Chart.js, D3, Plotly).
  Editorial HTML/SVG schematics are for layout-as-message, not quantitative
  plots.

## See Also

- [Mermaid Practices](mermaidjs.md) — syntax conventions once Mermaid is selected.
- [PlantUML Practices](plantuml.md) — rendering pipelines once PlantUML is selected.
- [Excalidraw Practices](excalidraw.md) — storage and workflow once Excalidraw is selected.
- [Editorial HTML/SVG Diagram Practices](editorial-html-svg-diagrams.md) —
  the standalone-deliverable route (deletion-first, 4px grid, connector rules,
  skinnable design system).
- [software-architecture-essentials](../software-architecture-essentials/overview.md) —
  ADRs that embed decision trees use Mermaid; the selection criteria here
  explain why.
