# Directory Update Log

## 2026-07-18

* **Initialization**: Created the `documentation-diagram-practices` knowledge bundle to consolidate diagram embedding practices for technical documentation.
* **Creation**: Authored 4 concept pages covering the diagram tool landscape and per-tool conventions.
  - [diagram-tool-selection.md](diagram-tool-selection.md) — when to use Mermaid vs PlantUML vs Excalidraw
  - [mermaidjs.md](mermaidjs.md) — Mermaid syntax conventions, quoting decision nodes, `<br/>` preservation
  - [plantuml.md](plantuml.md) — PlantUML text-based diagrams, rendering pipelines, layout hints
  - [excalidraw.md](excalidraw.md) — Excalidraw hand-drawn diagrams, JSON storage, whiteboard use cases
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Source**: ADR-20260520001 v3.0.0 in `ADR-20260520001 v3.0.0 source (job-aide internal-docs)` — two Mermaid flowcharts broke because unquoted decision node labels with `<br/>` and `(` were stripped by the markdown pre-processor, causing parse errors. The fix (quote all decision labels with special chars) is documented in [mermaidjs.md](mermaidjs.md).
