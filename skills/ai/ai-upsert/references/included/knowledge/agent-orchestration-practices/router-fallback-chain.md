---
type: Practice
title: Router Fallback Chain
description: Resolve a workflow by name using a multi-tier fallback hierarchy (exact, case-insensitive, suffix, substring) with AI-assisted semantic routing and a catch-all default workflow. Ambiguous matches throw with candidates; no match falls back to the default rather than failing.
tags: [agent-orchestration, router, fallback-chain, name-resolution, semantic-routing, catch-all, disambiguation]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-router
    resource: "https://github.com/coleam00/archon"
    title: "Archon — 4-tier name resolution with archon-assist catch-all fallback"
---

# Router Fallback Chain

## The General Rule

When a user invokes a workflow by name (or by a natural-language
description), the router resolves the name to a concrete workflow
definition using a **multi-tier fallback hierarchy**. Each tier is
progressively more lenient; the first tier that produces exactly one match
wins. If a tier produces multiple matches, the router throws an ambiguity
error listing the candidates. If no tier matches, the router falls back to
a **catch-all default** workflow rather than failing.

### The Tier Hierarchy

1. **Exact match** — the requested name equals a workflow name exactly.
2. **Case-insensitive match** — the requested name matches a workflow
   name ignoring case.
3. **Suffix match** — the requested name is a suffix of a workflow name
   (e.g. "assist" matches "archon-assist").
4. **Substring match** — the requested name is a substring of a workflow
   name (e.g. "smart" matches "archon-smart-pr-review").

Each tier is checked in order. The first tier with exactly one match
returns that workflow. A tier with multiple matches throws an ambiguity
error. A tier with zero matches falls through to the next tier.

### Ambiguity Handling

If a tier produces multiple matches, the router does not guess. It throws
an error listing all candidates so the user can disambiguate with an
explicit name. This is fail-fast for ambiguity — a wrong guess silently
runs the wrong workflow, which is worse than an error that asks for
clarification.

### Catch-All Default

If all tiers fail (no match at any level), the router does not throw. It
falls back to a **catch-all default** workflow — a general-purpose
assistant that handles unmatched requests with full agent capabilities.
The default workflow logs that it was used as a fallback so the user knows
their request did not match a specific workflow. This ensures no request
fails silently; every request gets a response, even if it is a generic
one.

### AI-Assisted Semantic Routing

For natural-language requests (not explicit names), the router may use
AI-assisted semantic routing: it reads all workflow descriptions and picks
the best match for the user's intent. This is a layer on top of the
tier hierarchy — the semantic router maps the natural-language request to
a workflow name, then the tier hierarchy resolves it. If the semantic
router's confidence is low, it falls back to the catch-all default.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `resolveWorkflowName()` implements the 4-tier hierarchy: exact,
case-insensitive, suffix (looks for `-<name>` suffix), substring. Each
tier uses `checkTier()` which returns the single match, throws on
ambiguity with candidate names listed, or returns undefined to fall
through. If all tiers fail, the caller routes to `archon-assist` — the
catch-all general assistant workflow. The CLI, Slack, Telegram, GitHub,
Discord, and Web surfaces all use the same resolution function. For
natural-language requests, an AI router reads workflow descriptions and
selects the best match before name resolution.

### LangChain Routers

LangChain's `MultiRouteChain` and `LLMRouterChain` use an LLM to classify
the user's input into one of several named destinations. The router
prompt includes the destination names and descriptions; the LLM outputs a
structured classification. If the LLM's confidence is below a threshold,
the chain falls back to a default destination. This is semantic routing
without the tier hierarchy — the LLM is the only resolver, and the
default is the only fallback.

### Semantic Routing (semantic-router library)

The `semantic-router` library encodes routes as natural-language
utterances (not regex patterns). At routing time, it computes the
similarity between the user's input and each route's utterances using
embedding models. The route with the highest similarity wins. If no
route's similarity exceeds a threshold, the router returns a default
route. This is pure semantic routing — no name-based tier hierarchy, just
embedding similarity with a threshold-based fallback.

## Anti-Patterns

- **Guessing on ambiguity** — a tier produces two matches and the router
  picks the first one. The user asked for "smart" and got
  "archon-smart-pr-review" when they meant "archon-smart-commit". Throw
  with candidates instead.
- **No catch-all** — all tiers fail and the router throws "workflow not
  found". The user's request is lost. Fall back to a general assistant
  that can handle any request.
- **Silent fallback** — the router falls back to the default without
  logging or notifying the user. The user thinks their request matched a
  specific workflow. Log the fallback so the user knows.
- **Per-surface routing logic** — the CLI uses one resolution algorithm
  and the web uses another. The same name resolves to different workflows
  on different surfaces. Encode the resolution once and call it from all
  surfaces.

## See Also

- [DAG Workflow Engine](dag-workflow-engine.md) — the engine that
  executes the resolved workflow.
- [Capability Gating](capability-gating.md) — the gate that runs after
  routing resolves the workflow but before execution begins.
