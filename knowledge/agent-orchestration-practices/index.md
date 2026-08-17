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
