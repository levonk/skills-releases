# Directory Update Log

## 2026-07-18

* **Ingest**: Authored [indexed-ast-tools.md](indexed-ast-tools.md)
  — indexed AST tool selection practice for the three-contender
  landscape (CodeGraph, Graphify, GitNexus) within the AST Search (§4) and
  AST Insights (§5) rows of the 6×2 matrix. Reframed from "code knowledge graph
  tools" (a separate category) to "indexed AST tools" (the indexed entries in
  existing AST rows) — the bonus capabilities (dynamic dispatch, multi-repo,
  multimodal) are extensions of AST insights, not a different modality.
  Captures the six-round head-to-head (each tool wins exactly two rounds),
  dynamic-dispatch coverage matrix, shared design patterns (tree-sitter,
  SHA-256 caching, MCP, confidence-tagged edges, index-once-query-many,
  .gitignore hygiene), limitations of all three, and a sub-decision tree.
  Sourced from ADR-20260520001 v3.0.0 and the WiseBuilder YouTube comparison
  (2026-07-06). Cross-linked to
  [tool-detection.md](tool-detection.md),
  [adding-tools.md](adding-tools.md), and
  [tech-decision-risk-assessment.md](tech-decision-risk-assessment.md)
  (the risk hierarchy that justifies running multiple MIT-licensed indexed AST
  tools vs. adopting GitNexus's PolyForm Noncommercial license for business
  use).
* **Addition**: Authored [tech-decision-risk-assessment.md](tech-decision-risk-assessment.md)
  — ordered risk hierarchy for evaluating technology decisions, from
  highest risk (novel work, end-user impact, public API impact) down to
  lowest risk (new constant). Includes the dependency-update orthogonal
  axis (major > minor; security > capability > drift-avoidance) and the
  functional-programming-style axis (pure functions > immutable > static-wide
  > local-only mutable > wide-scope mutable > read-only). Worked example:
  better-auth vs. Supabase Auth migration decision. Cross-linked to
  [ai-human-timeline-estimates.md](ai-human-timeline-estimates.md) and
  [api-auth-payment-practices/auth-provider-selection.md](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/auth-provider-selection.md).
* **Addition**: Authored [ai-human-timeline-estimates.md](ai-human-timeline-estimates.md)
  — timelines must be estimated as "human review + AI execution" pairs on
  four axes (AI execution, human review, verification, tail risk), never as
  pre-AI "human days" alone. Documents what collapses with AI
  (well-trodden patterns, boilerplate, iteration, test generation) and what
  does not (security verification, migration risk on live systems, novel
  work, compliance/audit). Worked example: the better-auth middleware
  estimate correction. Cross-linked to
  [tech-decision-risk-assessment.md](tech-decision-risk-assessment.md) and
  [api-auth-payment-practices/auth-provider-selection.md](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/auth-provider-selection.md).
* **Addition**: Authored [root-cause-first.md](root-cause-first.md) —
  root-cause-first discipline: diagnose before fixing, workarounds are last
  resort, and when changing a standard update every document that restates the
  old one (never leave the other side in a broken state). Sourced from the
  dotfiles `.devin/rules/testing.md` Root-Cause First Policy, the infrahub
  Ansible AGENTS.md "Root Cause First - No Workarounds" section, and the
  dotfiles AGENTS.md "CRITICAL: Root Cause Analysis Required" section.
* **Initialization**: Created the `software-architecture-essentials` knowledge bundle to consolidate architectural practices from the `src/current/rules/software-dev/general/architecture/` rule files.
* **Creation**: Authored 10 concept pages covering philosophy, project structure, data access, configuration, distribution, theming, terminal state, tool detection, extensibility, and auth/environment.
  - [philosophy.md](philosophy.md) — domain-based modular architecture
  - [project-structure.md](project-structure.md) — domain-first hierarchical package structure
  - [data-access-layer.md](data-access-layer.md) — centralized data access with security checkpoint
  - [configuration-system.md](configuration-system.md) — layered config precedence with validation
  - [distribution.md](distribution.md) — single-binary/minimal-runtime distributions
  - [theme-system.md](theme-system.md) — single source of truth for palettes/variants
  - [terminal-state.md](terminal-state.md) — minimal terminal control sequences
  - [tool-detection.md](tool-detection.md) — PATH-first detection with caching
  - [adding-tools.md](adding-tools.md) — consistent procedure for wiring new tools
  - [auth-env.md](auth-env.md) — CI/SSH/Docker/Codespaces detection and headless auth
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts migrated from `src/current/rules/software-dev/general/architecture/*.md` (10 files).
