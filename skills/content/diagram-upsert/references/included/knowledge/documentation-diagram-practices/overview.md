---
type: Synthesis
title: Documentation Diagram Practices Overview
description: Synthesis of documentation diagram practices — tool selection across Mermaid, PlantUML, and Excalidraw, plus the syntax conventions that keep diagrams rendering across markdown pre-processors.
tags: [documentation, diagrams, mermaid, plantuml, excalidraw, overview, synthesis]
timestamp: 2026-07-18T00:00:00Z
---

# Documentation Diagram Practices Overview

This bundle documents practices for embedding diagrams in technical
documentation. Each concept captures a specific diagram concern — tool
selection, syntax that survives markdown pre-processing, rendering pipelines —
and the practice that addresses it.

## The Diagram Tool Landscape

```
tool-selection → mermaid (inline, render-portability) → plantuml (precise, server-rendered)
                                ↓
              excalidraw (hand-drawn, whiteboard, .excalidraw JSON)
```

| Concern | Practice | Prevents |
|---------|----------|----------|
| Selection | [Diagram Tool Selection](diagram-tool-selection.md) | Picking a tool that doesn't render in your target environment, version-control friction, unreachable rendering servers |
| Mermaid | [Mermaid Practices](mermaidjs.md) | Parse errors from unquoted labels, `<br/>` stripped by pre-processors, broken decision nodes |
| PlantUML | [PlantUML Practices](plantuml.md) | Missing `@startuml`/`@enduml`, server-only rendering, layout sprawl, unreadable sequence diagrams |
| Excalidraw | [Excalidraw Practices](excalidraw.md) | Binary blob in git, lost sketch history, hand-drawn diagrams where precision is required |

## Scope

This bundle covers **diagram authoring and embedding practices** for technical
documentation — the tool selection, syntax conventions, and rendering
considerations that keep diagrams working across markdown renderers (GitHub,
Obsidian, VS Code, static site generators). It does **not** cover:

- General technical writing — see a dedicated writing bundle.
- Diagram design aesthetics (color theory, visual hierarchy) — out of scope.
- Rendering tool installation — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Build system integration for diagram pipelines — see
  [build-system-essentials](../build-system-essentials/overview.md).

## Compounding

New lessons from future diagram work — new tool integrations, renderer-specific
quirks, accessibility practices — should be filed as new concept pages. Append
to `log.md` when adding.

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment setup for diagram rendering tools (PlantUML jar, Mermaid CLI,
  Excalidraw desktop).
- [build-system-essentials](../build-system-essentials/overview.md) —
  Diagram-to-image pipelines in build systems.
- [software-architecture-essentials](../software-architecture-essentials/overview.md)
  — ADRs that embed decision-tree diagrams (Mermaid flowcharts) rely on the
  Mermaid practices in this bundle to render correctly.

## Sources

- ADR-20260520001 v3.0.0 — `ADR-20260520001 v3.0.0 (job-aide internal-docs)`
  (two Mermaid flowcharts that broke from unquoted decision node labels; fix
  documented in [mermaidjs.md](mermaidjs.md)).
