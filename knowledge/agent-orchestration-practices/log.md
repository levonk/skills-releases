# Directory Update Log

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
