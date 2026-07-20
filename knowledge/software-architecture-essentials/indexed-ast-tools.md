---
type: Practice
title: Indexed AST Tool Selection
description: Pick the right indexed AST tool (CodeGraph, Graphify, GitNexus) for the AST Search and AST Insights rows of the 6×2 matrix — by freshness, dispatch tracing, multi-repo support, content breadth, and license; they win orthogonal rounds and can run together.
tags: [architecture, code-intelligence, indexed-ast-tools, mcp, ai-agents, tooling, tool-selection]
timestamp: 2026-07-18T00:00:00Z
---

# Indexed AST Tool Selection

## Practice

CodeGraph, Graphify, and GitNexus are the **indexed entries** in the AST Search
(§4) and AST Insights (§5) rows of the 6×2 search-modality matrix. They build a
persistent graph of code structure (nodes = functions/classes/modules, edges =
calls/imports/extends/implements) and expose it via MCP — more evolved indexed
AST tools, not a separate modality. The bonus capabilities on top (dynamic
dispatch tracing, multi-repo impact, multimodal content) are extensions of AST
insights, not a different kind of question.

Pick the tool by sweet spot, not by general superiority: the three contenders
each win exactly two of six rounds and **do not conflict at runtime**, so
running more than one is a valid architecture.

| Tool | Stack | License | Langs | Sweet spot |
|------|-------|---------|-------|------------|
| **CodeGraph** | Node.js, standalone binary | MIT | 20+ | Zero-maintenance auto-sync + dynamic dispatch tracing (single project) |
| **Graphify** | Python | MIT | 36 | Multimodal — links code to PDFs, images, video, audio, docs |
| **GitNexus** | Node.js | ⚠️ PolyForm Noncommercial | 14 | Multi-repo impact analysis + 17 specialized MCP tools |

### Decision tree (sub-decision within the AST rows)

This is the sub-decision you make once the main 6×2 decision tree routes you to
an indexed AST tool (AST Search §4 or AST Insights §5, "With index" branch):

1. **Project < 20 files?** → Skip. The agent can read everything directly; the
   index adds overhead with no payoff.
2. **Need to link non-code knowledge** (PDFs, docs, video, images) to code? →
   **Graphify** (MIT, multimodal).
3. **Work across multiple repos / services?** → **GitNexus** (procure a
   commercial license for business use — PolyForm Noncommercial).
4. **Need zero-maintenance + dynamic dispatch tracing?** → **CodeGraph**
   (MIT, auto-sync, single tool).
5. **Power-user structural queries on a single repo?** → **GitNexus** (17
   specialized MCP tools).

### The six rounds (winner → why)

| Round | Winner | Why |
|-------|--------|-----|
| Index freshness | **CodeGraph** | Native file watcher (FSEvents/inotify), 2-second debounce, no manual commands |
| Content breadth | **Graphify** | Only tool that indexes PDFs, images, video, audio, YouTube URLs, Google Workspace |
| Dynamic dispatch | **CodeGraph** | Traces callbacks, event emitters, React setState, interface dispatch, C function pointers |
| Query power | **GitNexus** | 17 specialized MCP tools vs CodeGraph's single-tool philosophy |
| Multi-repo support | **GitNexus** | Repository groups, contract registries, cross-repo blast radius |
| Visualization | **Graphify** | 7 export formats: HTML, SVG, Obsidian vaults, Neo4j Cypher, GraphML, markdown wikis, tree views |

### Dynamic dispatch coverage

| Pattern | CodeGraph | GitNexus | Graphify |
|---------|-----------|----------|----------|
| Callbacks (register/invoke later) | ✅ | ❌ | ❌ |
| Event emitters (`.on`/`.emit` by string key) | ✅ | ❌ | ❌ |
| React `setState` → re-render → child | ✅ | ❌ | ❌ |
| Interface / abstract dispatch | ✅ | ✅ (with confidence scoring) | ❌ |
| Framework routing (Express, Django, …) | ✅ | ✅ | ❌ |
| Dependency injection resolution | ❌ | ✅ | ❌ |
| C function pointer dispatch | ✅ | ❌ | ❌ |

### Shared design patterns (all three)

1. **tree-sitter** as the universal parser (fast, local, syntax-error tolerant, 20+ langs via one interface)
2. **Content-addressed caching** — SHA-256 fingerprint per file; unchanged files skipped on reruns
3. **MCP** as the agent protocol (emerging standard for AI agent ↔ tool communication)
4. **Confidence tracking on every edge** — *found directly in source* / *heuristically inferred* / *LLM guessed*
5. **Index once, query many** — expensive parsing at build time; queries are cheap graph lookups
6. **`.gitignore` hygiene** — all respect `.gitignore` and exclude `node_modules`, `dist`, etc.

### Limitations of all three

1. **No runtime behavior** — analyze source as written, not what happens when it runs. Use a debugger/profiler for race conditions or performance.
2. **Small projects don't benefit** — under ~20 files, agents can read everything directly.
3. **Language coverage gaps** — Haskell, OCaml, F#, Clojure unsupported by any of the three.
4. **Correctness isn't guaranteed** — knowing blast radius ≠ knowing the change is correct; tests still required.
5. **Initial build takes time** — first indexing is 1–5 minutes depending on project size.
6. **Static analysis ceiling** — reflection, `eval`, dynamically computed file paths remain invisible.

## Why

AI agents without structural awareness burn 15+ tool calls and 4,000+ tokens per
query reading file after file, and still miss connections (callbacks, event
emitters, framework routing) that are invisible to text search. Published
benchmarks show **~58% fewer tool calls** when agents use an indexed AST tool.
Picking the wrong one — e.g., defaulting to CodeGraph for a multi-repo
microservices project, or to GitNexus for a single-project zero-setup workflow —
loses that benefit and adds setup friction. The three tools are **not
interchangeable**; they serve orthogonal sweet spots.

## When this practice applies

- AI agents (Claude Code, Cursor, Codex CLI, opencode) with MCP support doing
  code exploration, refactoring, or impact analysis — i.e., AST Search (§4) or
  AST Insights (§5) questions in the 6×2 matrix.
- Multi-repo / microservices work where "what breaks in service B if I change
  this in service A?" is a recurring question.
- Projects where architecture docs, research papers, or design video should
  link to code (Graphify's multimodal index).
- Single-project workflows where the index must stay fresh without manual
  commands (CodeGraph's file watcher).

## When this practice does NOT apply

- **Text search tasks** (find text, find files, fuzzy match) — use the
  non-AST rows of the 6×2 matrix in
  [ADR-20260520001](https://github.com/levonk/skills-releases/blob/main/../../../../lrepo52/job-aide/internal-docs/adr/adr-20260520001-codegraph-vs-semble-rs-tool-selection.md)
  (ripgrep, xgrep, fzf, fd). Indexed AST tools are for *structural* questions,
  not text search.
- **Semantic search** (§6) — use `semble_rs` (hybrid BM25 + Model2Vec, single
  Rust binary, ephemeral index) or `qmd`.
- **Build / CI log compression** — use `semble_rs digest`.
- **Projects under ~20 files** — the index adds overhead with no payoff.

## See Also

- [Tool Detection Architecture](tool-detection.md) — how tools are discovered on the system before they can be wired into an AST index workflow.
- [Adding New Tools](adding-tools.md) — procedure for wiring a newly detected indexed AST tool into the CLI surface.
- [Tech Decision Risk Assessment](tech-decision-risk-assessment.md) — the risk hierarchy that justifies running multiple MIT-licensed indexed AST tools (low risk) vs. adopting GitNexus's PolyForm Noncommercial license (higher risk for business use).
- [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md) — devbox/direnv integration for keeping AST indexes fresh on directory entry.

## Sources

- ADR-20260520001 v3.0.0 — `ADR-20260520001 v3.0.0 (job-aide internal-docs)`
  (CodeGraph vs semble_rs + indexed AST tool comparison: CodeGraph vs Graphify vs GitNexus).
- WiseBuilder (2026-07-06) — "Graphify vs GitNexus vs CodeGraph — Which Code Knowledge Graph Should You Use?"
  https://www.youtube.com/watch?v=-Fb1SBC_nmg — basis for the six-round comparison.
- 2ndbrain note — `Graphify vs GitNexus vs CodeGraph — Code Knowledge Graph Comparison` (Obsidian).
