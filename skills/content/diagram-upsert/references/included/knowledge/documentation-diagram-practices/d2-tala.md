---
type: Practice
title: D2 and TALA Practices
description: D2 text-based diagramming with the TALA autolayout engine (open-source MPL-2.0) — orthogonal layout for architecture diagrams, custom and partial positioning for agentic use cases, layout engine selection (TALA vs Dagre vs ELK), and the tradeoffs of randomness and nonlinear scaling.
tags: [documentation, diagrams, d2, tala, autolayout, agentic, text-based, architecture]
date:
  created: "2026-09-08"
  knowledge-basis: "2026-09-08"
  last-used: "2026-09-08"
---

# D2 and TALA Practices

## Practice

D2 is a text-based diagramming language (`.d2` files) that compiles to SVG,
PNG, or PDF. Its distinguishing feature is **TALA** (Terrastruct's AutoLayout
Algorithm), an orthogonal layout engine designed for software architecture
diagrams. TALA was open-sourced under MPL-2.0 in September 2026 and is bundled
into D2 v0.9.0+.

### 1. Choose the layout engine by diagram shape

D2 ships with three layout engines. Pick by the diagram's structure, not by
default:

| Engine | Layout style | Best for | Tradeoff |
|--------|-------------|----------|----------|
| **TALA** | Orthogonal (whiteboard-like) | Architecture diagrams, system diagrams, mixed-flow | Randomness — small input changes can produce very different layouts |
| **Dagre** | DAG (directed acyclic graph) | Long flowing graphs, pipelines, dependency trees | Grows in one direction; less compact for non-DAG structures |
| **ELK** | Layered (Sugiyama-style) | Layered hierarchies, org charts | Can sprawl; less aesthetic for dense interconnections |

```bash
# Specify the layout engine
d2 --layout=tala diagram.d2 diagram.svg
d2 --layout=dagre diagram.d2 diagram.svg
d2 --layout=elk diagram.d2 diagram.svg
```

TALA is the default for architecture diagrams because orthogonal layouts match
what you see on whiteboards. Use Dagre or ELK when the diagram is a long
flowing graph or a strict hierarchy.

### 2. Use custom positioning for agentic diagram generation

TALA supports `top` and `left` properties on nodes, letting you pin exact
coordinates. This is the key capability for **agentic use cases**: AI models
can place nodes in 2D space (which they do well) while TALA handles connector
routing (which models still struggle with).

```d2
# Pin a node to a specific position
Server: {
  top: 100
  left: 200
}

# TALA routes all connectors to/from Server automatically
Client -> Server: request
Server -> Database: query
```

### 3. Use partial positioning for hybrid layouts

TALA supports pinning some nodes and leaving others to the auto-layout engine.
This lets you lock the shape of a sub-group (e.g., four CMYK print stations in a
fixed row) while TALA places the surrounding nodes:

```d2
# Pinned: four stations share a fixed top, equally spaced left
Cyan: { top: 200; left: 100 }
Magenta: { top: 200; left: 300 }
Yellow: { top: 200; left: 500 }
Black: { top: 200; left: 700 }

# Automatic: TALA places these around the pinned stations
Feeder -> Cyan
Camera -> Magenta
Registration -> Yellow
Dryer -> Black
```

### 4. Prefer SVG output for documentation

SVG scales without pixelation and is diffable in git (text-based XML). PNG is
for embedding in environments that don't render SVG; PDF is for print.

```bash
d2 --layout=tala diagram.d2              # defaults to SVG
d2 --layout=tala diagram.d2 out.png      # PNG
d2 --layout=tala diagram.d2 out.pdf       # PDF
```

### 5. Use the playground for quick iteration

[play.d2lang.com](https://play.d2lang.com) runs 100% client-side — no server
sees your diagram content. Use it for prototyping before committing the `.d2`
source to git. For air-gapped or proprietary content, use the local CLI.

### 6. Keep large diagrams under ~100 nodes for TALA

TALA scales nonlinearly — runtime grows faster than node count. For diagrams
with 100+ nodes, benchmark with `--layout=dagre` or `--layout=elk` as
alternatives. See [d2-benchmarks](https://github.com/d2lang/d2-benchmarks) for
runtime comparisons.

### 7. Accept TALA's randomness — or pin coordinates for stability

TALA uses multiple seeds (default: 3) and picks the best-scoring layout. Given
the same seeds and input, output is deterministic. But adding one node can
change the entire layout. If layout stability across small edits matters (e.g.,
in version-controlled docs where diffs should be minimal), pin key node
coordinates with `top`/`left` and let TALA route around them.

## Why

D2 with TALA fills a gap the other text-based tools leave open:

- **Mermaid** renders inline in GitHub/Obsidian but has limited layout control
  and no autolayout engine designed for architecture diagrams.
- **PlantUML** uses Graphviz (dot) for layout — good for DAGs and hierarchies,
  less aesthetic for dense architecture diagrams with bidirectional flows.
- **Excalidraw** is hand-drawn (no autolayout) and stores JSON/binary, not
  text-optimized for VCS diffing.
- **Editorial HTML/SVG** is for standalone deliverables, not inline embedding.

TALA's orthogonal layout produces whiteboard-like diagrams that match how
architectures are drawn on whiteboards. Its custom and partial positioning
makes it the only text-based tool designed for agentic diagram generation —
models set coordinates, TALA routes connectors.

The open-sourcing (MPL-2.0) removes the previous barrier: TALA was proprietary
and required a paid D2 Hosted license. Now the full layout stack is
open-source and self-hostable.

## When this practice applies

- Architecture diagrams, system diagrams, and infrastructure diagrams where
  orthogonal (whiteboard-like) layout is preferred over DAG or layered layout.
- Agentic diagram generation — AI models produce `.d2` source with pinned
  coordinates, TALA handles routing.
- Diagrams that need a text-based, VCS-diffable source format with
  high-quality autolayout (better than Mermaid's built-in layout, more
  architecture-focused than PlantUML's Graphviz output).
- Hybrid layouts where some nodes must be in fixed positions (e.g., a row of
  service nodes) and others can be auto-placed.

## When this practice does NOT apply

- **Inline markdown rendering on GitHub/Obsidian** — D2 does not render
  natively in markdown. Use Mermaid for inline embedding; use D2 for
  standalone SVG/PNG output linked from markdown.
- **Long flowing DAGs (pipelines, dependency trees)** — Dagre or ELK handle
  these better than TALA. Use `--layout=dagre` or `--layout=elk`.
- **Whiteboard sketches** — use Excalidraw (see
  [Excalidraw Practices](excalidraw.md)). D2 produces precise diagrams, not
  hand-drawn aesthetics.
- **Standalone editorial deliverables** — use
  [Editorial HTML/SVG Diagram Practices](editorial-html-svg-diagrams.md). D2
  is for architecture diagrams, not editorial layout-as-message design.
- **Diagrams requiring layout stability across small edits** — TALA's
  randomness means adding one node can reflow the entire diagram. If diff
  stability is critical, pin coordinates or use Dagre/ELK.

## See Also

- [Diagram Tool Selection](diagram-tool-selection.md) — when to pick D2 over
  Mermaid, PlantUML, Excalidraw, or editorial HTML/SVG.
- [Mermaid Practices](mermaidjs.md) — the inline-rendering alternative for
  markdown-embedded diagrams.
- [PlantUML Practices](plantuml.md) — the precise-UML alternative (Graphviz
  layout).
- [Editorial HTML/SVG Diagram Practices](editorial-html-svg-diagrams.md) —
  the standalone-deliverable route.
- [dev-environment-practices](../dev-environment-practices/overview.md) —
  installing the D2 CLI.

## Sources

- [TALA is open-source](https://d2lang.com/blog/tala-is-open-source/) —
  Alexander Wang, September 7, 2026. Announces TALA's open-sourcing under
  MPL-2.0, bundled into D2 v0.9.0. Documents the three layout engines (TALA,
  Dagre, ELK), custom and partial positioning for agentic use cases, and
  TALA's tradeoffs (randomness, DAG performance, nonlinear scaling).
- [D2 documentation](https://d2lang.com) — D2 language reference, tour, and
  examples.
- [d2-benchmarks](https://github.com/d2lang/d2-benchmarks) — TALA runtime
  performance compared to other layout engines.
- [play.d2lang.com](https://play.d2lang.com) — client-side D2 playground (no
  server dependency).
