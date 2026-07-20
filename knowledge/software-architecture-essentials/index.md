---
okf_version: "0.1"
---

# Software Architecture Essentials

A compounding knowledge base documenting architectural practices for modular,
maintainable software — project structure, data access, configuration,
distribution, theming, terminal state, tool detection, extensibility, and
auth/environment. Each concept captures a specific architectural concern with
the practice that addresses it.

## Concepts

* [Overview](overview.md) - Synthesis of the architecture practice set and how the pieces fit together
* [Root-Cause First](root-cause-first.md) - Diagnose before fixing; workarounds are last resort; when changing a standard, update every document that restates the old one
* [Tech Decision Risk Assessment](tech-decision-risk-assessment.md) - Ordered risk hierarchy for evaluating technology decisions (novel work > end-user impact > ... > new constant); dependency-update and functional-style axes
* [AI + Human Timeline Estimates](ai-human-timeline-estimates.md) - Estimate as human review + AI execution pairs on four axes; pre-AI "human days" are no longer valid units
* [Architecture Philosophy](philosophy.md) - Domain-based modular architecture with clear separation of concerns and thin top-level entry points
* [Project Structure](project-structure.md) - Domain-first hierarchical package structure with vertical slicing for scalable monorepos
* [Data Access Layer](data-access-layer.md) - Centralize data fetching, caching, and mutation; single source of truth; security checkpoint
* [Configuration System](configuration-system.md) - Layered config precedence with schema validation, caching, and documented override rules
* [Distribution and Packaging](distribution.md) - Prefer single-binary or minimal-runtime distributions; track sizes; document install paths
* [Theme System](theme-system.md) - Single source of truth for palettes/variants; runtime switching; consistent semantic colors
* [Terminal State Management](terminal-state.md) - Minimal control sequences; prepare state for tools; centralize theme-aware helpers
* [Tool Detection Architecture](tool-detection.md) - PATH-first detection with version verification, caching, and clear errors
* [Adding New Tools](adding-tools.md) - Consistent procedure for wiring new tools into the CLI surface and service layer
* [Indexed AST Tool Selection](indexed-ast-tools.md) - Pick the right indexed AST tool (CodeGraph, Graphify, GitNexus) for the AST Search and AST Insights rows of the 6×2 matrix — by freshness, dispatch tracing, multi-repo support, content breadth, and license; they win orthogonal rounds and can run together
* [Authentication and Environment Management](auth-env.md) - Detect CI/SSH/Docker/Codespaces; prevent browser auth in headless; centralize helpers
