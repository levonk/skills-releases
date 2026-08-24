# Directory Update Log

## 2026-08-21

* **Ingest**: Added [editorial-html-svg-diagrams.md](editorial-html-svg-diagrams.md)
  — new concept page synthesizing the editorial HTML/SVG diagram practices from
  the upstream MIT-licensed [`cathrynlavery/diagram-design`](https://github.com/cathrynlavery/diagram-design)
  skill. Covers the deletion-first philosophy, 4px grid, complexity budgets,
  six mandatory connector rules, the "AI slop" anti-pattern list, skinnable
  design-system semantic roles, brand-onboarding gate, accessible SVG contract,
  semantic-pattern-then-visual-type selection, draw.io/Mermaid import flow, and
  the pre-output taste-gate checklist. Distinct from the markdown-embedded
  tools (Mermaid/PlantUML/Excalidraw) — applies when the diagram is the
  deliverable (standalone HTML/SVG/PNG for blog posts, slides, OG cards,
  print), not an inline markdown embed.
* **Update**: Updated [diagram-tool-selection.md](diagram-tool-selection.md)
  — added a 4th route (Editorial HTML/SVG) to the tool table and decision
  tree, with a cross-link to the new concept page and the upstream repo.
  Broadened the "mix tools" guidance to note that editorial HTML/SVG is a
  separate deliverable, not an inline embed.
* **Update**: Updated [index.md](index.md) with the new concept entry and
  broadened the bundle description to cover standalone editorial deliverables
  alongside markdown-embedded diagrams.
* **Update**: Updated [overview.md](overview.md) synthesis — added the
  editorial route to the tool-landscape diagram, the synthesis table, the
  scope statement (editorial design system is now in scope for standalone
  deliverables), and the sources list (diagram-design attribution).

## 2026-08-05

* **Ingest**: Authored 2 new Rust documentation concept pages sourced from
  the project-lint audit. All pages grounded against current Rust tool
  versions on 2026-08-05.
  - [rust-doc-comment-patterns.md](rust-doc-comment-patterns.md) — `///` vs
    `//!` conventions, Examples/Errors/Panics sections, intra-doc links, doc
    test patterns
  - [cargo-doc-generation.md](cargo-doc-generation.md) — cargo doc commands,
    public API documentation, hosted docs, cross-crate links, CI doc checks
* **Update**: Updated [index.md](index.md) with 2 new concept entries.

## 2026-08-02

* **Ingest**: Added [color-contrast.md](color-contrast.md) — new concept page
  documenting the hard rule against hosting light text on pastel/light fills.
  Covers Mermaid `classDef`/`style` `color` pairing, PlantUML `skinparam`
  `FontColor`/`BackgroundColor` pairing, Excalidraw per-element `strokeColor`/
  `backgroundColor`, WCAG AA 4.5:1 target, and grayscale/print checks.
  Motivated by a real failure: ELI5 Git Merge Mermaid diagrams used pastel
  fills with white text (~1.3:1 contrast, unreadable). Updated
  [index.md](index.md) listing, [overview.md](overview.md) synthesis table,
  and the scope statement (color contrast for readability is in scope as
  accessibility; palette aesthetics remain out of scope).

## 2026-07-26
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-18

* **Initialization**: Created the `documentation-diagram-practices` knowledge bundle to consolidate diagram embedding practices for technical documentation.
* **Creation**: Authored 4 concept pages covering the diagram tool landscape and per-tool conventions.
  - [diagram-tool-selection.md](diagram-tool-selection.md) — when to use Mermaid vs PlantUML vs Excalidraw
  - [mermaidjs.md](mermaidjs.md) — Mermaid syntax conventions, quoting decision nodes, `<br/>` preservation
  - [plantuml.md](plantuml.md) — PlantUML text-based diagrams, rendering pipelines, layout hints
  - [excalidraw.md](excalidraw.md) — Excalidraw hand-drawn diagrams, JSON storage, whiteboard use cases
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Source**: ADR-20260520001 v3.0.0 in `ADR-20260520001 v3.0.0 source (job-aide internal-docs)` — two Mermaid flowcharts broke because unquoted decision node labels with `<br/>` and `(` were stripped by the markdown pre-processor, causing parse errors. The fix (quote all decision labels with special chars) is documented in [mermaidjs.md](mermaidjs.md).
