# Directory Update Log

## 2026-08-30

* **Ingest**: Added 5 new concept pages sourced from
  [ericlitman/open-pstack](https://github.com/ericlitman/open-pstack)
  (multi-model adversarial review, design exploration) and
  [kunchenguid/firstmate](https://github.com/kunchenguid/firstmate)
  (event-driven supervision, ship/scout task shapes, restart-proof state).
  Patterns were synthesized into our own prose — no content was copied
  verbatim from the source repos.
  - [multi-model-adversarial-review.md](multi-model-adversarial-review.md)
    — adversarial signal from model diversity not assigned personas;
    consensus tiers (2+ models = high confidence, lone = lower);
    Agreement Map; lead judgment categorizes Act on / Consider / Noted /
    Dismissed; cross-judge in parallel with parent's own reading
  - [design-exploration-parallel-candidates.md](design-exploration-parallel-candidates.md)
    — "design it twice" rule (2+ structurally distinct candidates before
    synthesis); each candidate in its own path; cross-judge scores rubric;
    grafting folds best parts of losers; convergence = ship, divergence =
    reframe; scrap trigger on repeated friction of same shape
  - [event-driven-supervision.md](event-driven-supervision.md) — bash
    watcher sleeps on fleet, classifies wakes in bash, wakes orchestrator
    only when actionable; write-activity liveness (file newer than quiet
    window = deferred not escalated); turn-end guard (no turn ends blind)
  - [ship-scout-task-shapes.md](ship-scout-task-shapes.md) — ship tasks
    deliver code via PR/merge then tear down; scout tasks leave
    investigation reports at known path then tear down; scout worktrees
    declared scratch; decision inventory tracks scout reports
  - [restart-proof-state.md](restart-proof-state.md) — all state on disk
    and in session backend; every state is a file with defined format and
    producer; append-only event logs with fold-based current-state
    derivation; handoff is just another state file
* **Update**: [overview.md](overview.md) — extended the orchestration
  landscape diagram with the review/design/supervision axis; added Review,
  Design, Supervision, Task Shape, and Crash Recovery rows to the concern
  table; added "The Review, Design, and Supervision Axis" narrative
  section synthesizing the 5 new concepts; added open-pstack and firstmate
  to Sources. Updated knowledge-basis and last-used to 2026-08-30.
* **Update**: [index.md](index.md) — registered all 5 new concept pages.
* **Ingest**: Added 2 orchestration-oriented concept pages from
  [ericlitman/open-pstack](https://github.com/ericlitman/open-pstack)
  execution principles:
  - [encode-lessons-in-structure.md](encode-lessons-in-structure.md) —
    when a lesson recurs, encode it in structure (lint rule, script,
    metadata flag, runtime check) rather than prose; structure enforces,
    prose suggests
  - [guard-the-context-window.md](guard-the-context-window.md) — route
    bulk to subagents, keep only summaries in the main thread; the main
    context is for orchestration decisions, subagent context is for the
    work
* **Ingest**: Added 1 concept page from
  [kunchenguid/firstmate](https://github.com/kunchenguid/firstmate)
  two-tier skill layout:
  - [two-tier-skill-layout.md](two-tier-skill-layout.md) — distinguish
    internal skills (private profile, not publicly distributed) from
    public skills (standalone, discoverable, installable by anyone);
    profile-based two-tier layout with decision on metadata.internal
    flag
* **Update**: [index.md](index.md) — registered all 3 new concept pages.

## 2026-08-10

* **Initialization**: Created the `agent-orchestration-practices` knowledge
  bundle to cover the agentic-runtime/workflow-engine domain — a coherent
  subject area not covered by any existing bundle. The bundle captures
  stack-neutral orchestration patterns for systems that coordinate
  multi-step agent execution with deterministic steps, human approval
  gates, and full audit trails.
* **Creation**: Authored 7 concept pages distilled from the
  [coleam00/archon](https://github.com/coleam00/archon) repository as one
  concrete instance, with cross-stack instances from GitHub Actions,
  Temporal, LangGraph, AutoGen, OpenAI, Anthropic, LangChain, and MCP.
  - [dag-workflow-engine.md](dag-workflow-engine.md) — DAG execution with
    typed node kinds, depends_on ordering, trigger rules, concurrent layers
  - [output-schema-validation.md](output-schema-validation.md) — declare a
    schema, validate post-parse, re-ask on failure with bounded retries
  - [session-persistence.md](session-persistence.md) — persist provider
    sessions across re-runs with scope-keyed composite identity
  - [capability-gating.md](capability-gating.md) — hard-block invocation
    before any cost when a required capability is missing
  - [router-fallback-chain.md](router-fallback-chain.md) — multi-tier name
    resolution with AI routing and a catch-all default
  - [provider-capability-tiers.md](provider-capability-tiers.md) —
    structured capability flags with enforced/best-effort/false tiers
  - [mcp-hooks-skills-integration.md](mcp-hooks-skills-integration.md) —
    load external configs, register lifecycle callbacks, preload
    skills/agents declaratively
* **Creation**: Established [overview.md](overview.md) synthesis defining
  why this bundle exists separately (the agentic-runtime domain is a
  coherent new subject area) and [index.md](index.md) directory listing.
