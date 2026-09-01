---
type: Practice
title: Provider Capability Tiers
description: Model each agent provider's capabilities as structured flags with enforced/best-effort/false tiers, so the engine can negotiate features (structured output, native tools, session resume, hooks, skills) without assuming uniform support. Capability mismatches warn loudly; the source of truth is the provider's capability declaration, not the node's request.
tags: [agent-orchestration, provider-capabilities, capability-tiers, enforced, best-effort, false, capability-negotiation, provider-abstraction]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-provider-capabilities
    resource: "https://github.com/coleam00/archon"
    title: "Archon — ProviderCapabilities interface with enforced/best-effort/false tiers per capability"
---

# Provider Capability Tiers

## The General Rule

An agentic runtime that supports multiple providers (Claude, Codex,
Copilot, community providers) cannot assume uniform capability support.
Each provider has a different feature set: some support structured output
with backend grammar, some only with prompt augmentation; some support
session resume, some do not; some support in-process native tools, some
do not.

The engine models each provider's capabilities as a **structured
capability declaration** — a set of typed flags that the engine queries
before dispatching a node. The declaration is the **source of truth**: the
engine reads capabilities from the provider, not from the node's request.
A node that requests a feature the provider does not support produces a
loud warning (or a hard block for critical features), not a silent
downgrade.

### The Three-Tier Model

For capabilities that have gradations of support (not just present or
absent), the engine uses a three-tier model:

- **Enforced** — the provider guarantees the feature at the backend level.
  The engine trusts the guarantee but still validates as a net for edge
  cases.
- **Best-effort** — the provider approximates the feature (e.g.
  prompt-augmented structured output). The engine adds its own
  validation and repair loop.
- **False** — the provider does not support the feature at all. The engine
  rejects the node at dispatch time or warns and drops the feature,
  depending on whether the feature is critical or optional.

For binary capabilities (session resume, hooks, skills, MCP, native
tools), the flag is a boolean: `true` (supported) or `false` (not
supported).

### Capability Mismatch Handling

When a node requests a feature the provider does not support, the engine's
response depends on the feature's criticality:

- **Critical features** (structured output, container execution) — the
  engine hard-blocks the node. A node that requires structured output on
  a provider with `structuredOutput: false` is rejected at dispatch. A
  container run on a provider with `containerExec: false` is rejected
  before the container is created.
- **Optional features** (settingSources, thinking control, effort
  control) — the engine warns loudly that the feature is ignored and
  proceeds without it. The warning is visible in the run log and surfaced
  to the user.

The engine never silently drops a critical feature. The engine never
silently downgrades an enforced tier to best-effort.

### Static Declaration at Registration

Capabilities are declared **statically at provider registration time**, not
probed at runtime. The provider's registration entry includes a
`capabilities` object that the engine reads once and caches. This avoids
per-node capability probes (which would be slow and would couple the
engine to the provider's runtime state). The capability declaration is a
contract: if a provider's capabilities change, the registration is
updated and the engine picks up the new declaration on the next
registration cycle.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `ProviderCapabilities` interface declares 16 capability flags:
`sessionResume`, `mcp`, `hooks`, `skills`, `agents`, `toolRestrictions`,
`structuredOutput` (with `'enforced' | 'best-effort' | false` tiers),
`envInjection`, `costControl`, `effortControl`, `thinkingControl`,
`fallbackModel`, `sandbox`, `settingSources`, `nativeTools`, and
`containerExec`. Each provider registers its capabilities statically via
`ProviderRegistration.capabilities`. The dag-executor queries these flags
before dispatch: `structuredOutput: false` hard-blocks output_format
nodes; `settingSources: false` warns and ignores the per-node override;
`containerExec: false` hard-blocks container runs. The capability
declaration is the single source of truth — the engine never probes the
provider at runtime.

### OpenAI Tiers

OpenAI's API exposes capability tiers across models: Structured Outputs
(enforced tier via `response_format` with `json_schema`), function calling
(native tools, enforced), and vision (boolean capability). The
`gpt-4o` model supports all three; `gpt-4o-mini` supports structured
outputs and function calling but with lower quality; older models like
`gpt-3.5-turbo` lack structured outputs entirely (false tier). A
multi-model application must query the model's capabilities before
dispatching — the same pattern as provider capability tiers, applied at
the model level.

### Anthropic Tiers

Anthropic's Claude API exposes capability tiers across models: tool use
(native tools, enforced via the `tools` parameter), extended thinking
(thinking control, boolean per model), and prompt caching (boolean per
model). Claude Opus and Sonnet support tool use and extended thinking;
Haiku supports tool use but has limited thinking control. The Claude
Code SDK adds `settingSources` (which filesystem sources to load:
CLAUDE.md, skills, commands, agents) — a provider-specific capability
that other providers do not have. This illustrates why capabilities are
per-provider, not universal.

## Anti-Patterns

- **Assuming uniform capability support** — the engine treats all
  providers as if they support the same feature set. A node that uses
  structured output silently fails on a provider that does not support
  it. Query the capability declaration before dispatch.
- **Silent downgrade** — a node requests enforced structured output, the
  provider is best-effort, and the engine silently drops the enforcement
  guarantee. Warn loudly so the user knows the guarantee is absent.
- **Runtime capability probing** — the engine probes the provider's
  capabilities on every node dispatch (e.g. by sending a test request).
  This is slow and couples the engine to the provider's runtime state.
  Declare capabilities statically at registration time.
- **Node as source of truth** — the engine trusts the node's feature
  request over the provider's capability declaration. A node that
  requests `settingSources` on a provider that does not support it
  silently no-ops. The provider's declaration is the source of truth.

## See Also

- [Output Schema Validation](output-schema-validation.md) — how the
  `structuredOutput` capability tier determines the validation and re-ask
  strategy.
- [Session Persistence](session-persistence.md) — how the `sessionResume`
  capability flag gates session persistence.
- [MCP Hooks Skills Integration](mcp-hooks-skills-integration.md) — how
  the `mcp`, `hooks`, `skills`, and `agents` capability flags gate
  integration features.
- [Capability Gating](capability-gating.md) — workflow-level capability
  gating (external integrations) vs. provider-level capability tiers
  (agent features).
