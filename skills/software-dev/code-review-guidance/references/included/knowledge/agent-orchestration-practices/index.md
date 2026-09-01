---
okf_version: "0.2"
---

# Agent Orchestration Practices

A compounding knowledge base documenting practices for agentic runtimes and
workflow engines — the systems that coordinate multi-step agent execution
with deterministic steps, human approval gates, capability gating, session
persistence, structured output validation, provider capability tiers, router
fallback chains, and MCP/hooks/skills integration. Each concept captures a
specific orchestration concern with the practice that addresses it.

## Concepts

* [Overview](overview.md) - Synthesis of the agent orchestration practice set and why it is a separate bundle
* [DAG Workflow Engine](dag-workflow-engine.md) - Directed acyclic graph execution with typed node kinds, depends_on ordering, trigger rules, and concurrent layers
* [Output Schema Validation](output-schema-validation.md) - Declare a schema, validate post-parse, re-ask on failure with bounded retries
* [Session Persistence](session-persistence.md) - Persist provider sessions across re-runs with scope-keyed composite identity
* [Capability Gating](capability-gating.md) - Hard-block invocation before any cost when a required capability is missing
* [Router Fallback Chain](router-fallback-chain.md) - Multi-tier name resolution with AI routing and a catch-all default
* [Provider Capability Tiers](provider-capability-tiers.md) - Structured capability flags with enforced/best-effort/false tiers per provider
* [MCP Hooks Skills Integration](mcp-hooks-skills-integration.md) - Load external configs, register lifecycle callbacks, and preload skills/agents declaratively
* [Multi-Model Adversarial Review](multi-model-adversarial-review.md) - Adversarial signal from model diversity not assigned personas; consensus tiers (2+ models = high confidence, lone = lower); Agreement Map; lead judgment categorizes Act on / Consider / Noted / Dismissed
* [Design Exploration with Parallel Candidates](design-exploration-parallel-candidates.md) - "Design it twice" rule (2+ structurally distinct candidates before synthesis); each candidate in its own path; cross-judge scores rubric; grafting folds best parts of losers; convergence = ship, divergence = reframe; scrap trigger on repeated friction
* [Event-Driven Zero-Token Supervision](event-driven-supervision.md) - Bash watcher sleeps on fleet, classifies wakes in bash, wakes orchestrator only when actionable; write-activity liveness defers escalation; turn-end guard prevents blind turn ends
* [Ship and Scout Task Shapes](ship-scout-task-shapes.md) - Ship tasks deliver code via PR/merge then tear down; scout tasks leave investigation reports at known path then tear down; scout worktrees are declared scratch; decision inventory tracks scout reports
* [Restart-Proof State](restart-proof-state.md) - All state on disk and in session backend; every state is a file with defined format and producer; append-only event logs with fold-based current-state derivation; handoff is just another state file
* [Encode Lessons in Structure](encode-lessons-in-structure.md) - When a lesson recurs, encode it in structure (lint rule, script, metadata flag, runtime check) rather than prose; structure enforces, prose suggests
* [Guard the Context Window](guard-the-context-window.md) - Route bulk to subagents, keep only summaries in the main thread; the main context is for orchestration decisions, subagent context is for the work
* [Two-Tier Skill Layout](two-tier-skill-layout.md) - Distinguish internal skills (private profile, not publicly distributed) from public skills (standalone, discoverable, installable by anyone); profile-based two-tier layout with decision on metadata.internal flag
