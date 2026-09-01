---
type: Practice
title: Capability Gating
description: Hard-block a workflow invocation before any cost is incurred when a required external capability is missing. The gate runs before worktree creation, cloning, or AI calls — a missing capability produces an actionable error, not a partial run or a silent degradation.
tags: [agent-orchestration, capability-gating, pre-flight-check, hard-block, requires-gate, fail-fast]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-requires-gate
    resource: "https://github.com/coleam00/archon"
    title: "Archon — requires:[github] gate hard-blocking invocation before worktree/clone/AI cost"
---

# Capability Gating

## The General Rule

A workflow may declare external capabilities it requires — integrations
that must be connected and available before the workflow can execute
meaningfully. The engine **hard-blocks** the invocation at the earliest
possible point — before any worktree is created, any repository is cloned,
any AI cost is incurred, or any side effect is produced.

The gate is a **pre-flight check**, not a runtime guard. It runs once at
invocation time and either passes (the workflow proceeds) or throws
(the invocation aborts with an actionable error message). There is no
"maybe" state, no partial run, no silent degradation.

### Declare, Check, Block

1. **Declare** — the workflow lists its required capabilities (e.g.
   `requires: [github]`). An empty or absent list means no requirements.
2. **Check** — the engine resolves the runtime connection status of each
   required capability for the originating user (a database check, not a
   live API call).
3. **Block** — if any required capability is not connected, the engine
   throws an error that names the missing capability and the connect step
   to resolve it. No worktree, no run row, no AI cost.

### Actionable Error Messages

The error message is user-facing and actionable. It names:

- The missing capability (e.g. "GitHub identity").
- The connect step (e.g. "Connect GitHub via Slack `/connect github`, CLI
  `auth github`, or the Web UI Settings page").
- The consequence ("No worktree was created and no AI cost was incurred").

The user reads the error, connects the capability, and re-invokes. They
do not need to read documentation or debug logs.

### Pure Policy Module

The gate logic is a pure function — it takes the workflow's declared
requirements and the resolved connection status, and either returns or
throws. The I/O (resolving connection status from the database, surfacing
the error to the platform) is owned by the caller (orchestrator, CLI, web
entrypoint). This separation ensures all three entrypoints behave
identically — the policy is encoded once, not duplicated per surface.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `assertWorkflowRequirementsMet()` is a pure function that takes a
`RequirementBearingWorkflow` and a `RequirementContext` (with
`githubConnected: boolean`). If the workflow declares `requires: [github]`
and `githubConnected` is false, it throws `WorkflowRequirementError` with
a message naming the connect step. The orchestrator, CLI, and web
entrypoints all call this function before creating a worktree or run row.
The `requires` field is validated at load time — a workflow with an
unknown requirement string is rejected before it enters the registry.

### MCP Capabilities

The Model Context Protocol defines a capabilities negotiation handshake
between clients and servers. A client declares its capabilities
(roots, sampling, elicitation); a server declares its capabilities
(tools, resources, prompts, logging, completions). A tool call that
requires a capability the client does not have is rejected before
execution — the protocol enforces the gate at the transport layer. This
is capability gating at the tool level rather than the workflow level.

### Claude Tool Permissions

Claude's `allowed_tools` and `denied_tools` per-node configuration is a
permission gate — the engine checks whether a tool is permitted before
dispatching it to the agent. A tool not in the allowed list (or in the
denied list) is blocked before the agent sees it. This is capability
gating at the tool level: the "capability" is the permission to use a
specific tool, and the gate runs before the tool is invoked.

## Anti-Patterns

- **Soft warning instead of hard block** — the engine warns that a
  capability is missing but proceeds with the run. The workflow fails
  partway through after incurring cost. The gate exists to prevent this.
- **Check after side effects** — the gate runs after a worktree is created
  or a clone is performed. The user is left with a partial run and
  orphaned resources. The gate must run before any side effect.
- **Non-actionable error** — "Capability missing" with no connect step.
  The user must read documentation to resolve it. Name the capability and
  the connect step in the error message.
- **Per-surface duplication** — the CLI, web, and orchestrator each
  implement their own gate logic with subtly different behavior. Encode
  the policy once as a pure function and call it from all surfaces.

## See Also

- [DAG Workflow Engine](dag-workflow-engine.md) — the engine that runs
  the gate before execution.
- [Provider Capability Tiers](provider-capability-tiers.md) —
  capability negotiation at the provider level (structured output, tools,
  sessions) vs. the workflow-level gate (external integrations).
