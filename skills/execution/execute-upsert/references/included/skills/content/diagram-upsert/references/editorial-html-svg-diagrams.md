---
type: Reference Pointer
title: Editorial HTML/SVG Diagram Practices
description: Pointer to the canonical editorial HTML/SVG diagram practices in the documentation-diagram-practices knowledge bundle, and to the upstream cathrynlavery/diagram-design skill for per-type details.
tags: [diagrams, editorial, html-svg, reference-pointer, diagram-design]
timestamp: 2026-08-21T00:00:00Z
---

# Editorial HTML/SVG Diagram Practices (Reference Pointer)

The canonical cross-cutting practices for standalone editorial HTML/SVG
diagrams live in the knowledge bundle. **Read the bundle page before
authoring** — this file is a pointer, not a restatement. For per-type layout
grammar, the style guide, brand onboarding, animation, export, and geometry
verification scripts, follow the upstream skill.

## Canonical Source (bundle)

[`knowledge/documentation-diagram-practices/editorial-html-svg-diagrams.md`](../included/knowledge/documentation-diagram-practices/editorial-html-svg-diagrams.md)

The bundle page synthesizes:

- Deletion-first philosophy and the remove test
- Self-contained single-file output contract
- 4px grid (font sizes, node dimensions, coordinates, gaps, padding, radius)
- Complexity budget (max nodes, arrows, accent elements, per-type limits)
- Six mandatory connector rules (orthogonal elbows, label margins, no
  overlaps, fanned attach points, no transit behind non-endpoints, no label
  masks overlapping nodes)
- Universal anti-patterns (the "AI slop" list)
- Skinnable design system with semantic roles (`paper`, `ink`, `muted`,
  `accent`, `link`)
- Brand-onboarding gate (pause on first diagram in a new project)
- Accessible SVG contract (`role="img"`, prefixed `<title>`/`<desc>`)
- Semantic-pattern-then-visual-type selection
- Import flow for `.drawio` and `.mmd` sources (extract, set four dials,
  redraw, report fidelity ledger)
- Pre-output taste-gate checklist

## Canonical Source (upstream skill)

[`cathrynlavery/diagram-design`](https://github.com/cathrynlavery/diagram-design)
(MIT-licensed, v2.6)

The upstream skill ships the full editorial design system. Its
`references/` directory holds the per-type details that the bundle page
intentionally does not restate:

- 39 visual-type references (`type-architecture.md`, `type-flowchart.md`,
  `type-sequence.md`, `type-state.md`, `type-er.md`, `type-timeline.md`,
  `type-swimlane.md`, `type-quadrant.md`, `type-radar.md`, `type-loop.md`,
  `type-tree.md`, `type-org-chart.md`, `type-layers.md`, `type-venn.md`,
  `type-pyramid.md`, `type-bar.md`, `type-line.md`, `type-gantt.md`,
  `type-scatter.md`, `type-sankey.md`, `type-fishbone.md`, `type-wardley.md`,
  `type-kanban.md`, `type-journey.md`, `type-deployment.md`,
  `type-dependency.md`, `type-uml-class.md`, `type-story-map.md`,
  `type-db-schema.md`, and more)
- `style-guide.md` — the skinnable single source of truth for colors,
  typography, and tokens
- `onboarding.md` — URL-based brand-token extraction flows
- `profiles.md` — saved client profiles and the `.diagram-design` marker
- `semantic-patterns.md` — behavioral patterns (fan-in queue, stage
  framework, paired policy-evaluation traces, secure paved road, governance
  catalog, compensating security layers)
- `animation.md` — optional motion (`none` / `reveal` / `step` / `loop`)
- `export.md` — PNG/SVG export procedure
- `import-drawio.md`, `import-mermaid.md` — import flows for existing sources
- `output-spec.md` — the four output dials (format, size, detail, audience)
- `primitive-annotation.md`, `primitive-sketchy.md`, `primitive-icons.md`,
  `primitive-terminal.md` — optional primitives
- `doctor.md` — diagnostic reference

The upstream skill's `scripts/` directory ships:

- `self_check.py` — accessible-SVG contract, single-file safety, motion
  basics
- `verify-geometry.py` — connector rule violations (overlapping strokes,
  label masks overlapping nodes, shared attach points)
- `verify-motion.py` — animation validation
- `drawio_extract.py`, `mermaid_extract.py` — structural digest extractors
  for import

## Summary (for quick orientation only)

Pick the editorial HTML/SVG route when the diagram **is the deliverable** — a
standalone `.html`/`.svg`/`.png` file for a blog post, slide, OG card, or
print figure where editorial layout and visual hierarchy matter more than VCS
diffability. Do not pick it for markdown-embedded diagrams (use
Mermaid/PlantUML/Excalidraw) or for quantitative data visualizations (use a
charting library).

The full practice set, the per-type references, the style guide, and the
verification scripts are in the bundle page and the upstream skill — read them
before authoring.

## Why this is a pointer

The bundle is the single source of truth for the cross-cutting practices. The
upstream skill is the single source of truth for the per-type details,
skinnable style guide, and verification scripts. Restating either here would
cause drift. When the bundle or the upstream skill updates, this pointer stays
valid.
