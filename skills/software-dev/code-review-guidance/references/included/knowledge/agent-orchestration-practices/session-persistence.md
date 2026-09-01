---
type: Practice
title: Session Persistence
description: Persist a provider session ID across workflow re-runs using a scope-keyed composite identity, so the agent resumes its prior conversation context instead of cold-starting. The scope key ties the session to the conversation or run context, not to an ephemeral execution.
tags: [agent-orchestration, session-persistence, session-resume, scope-key, provider-session, conversation-context]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-session-persistence
    resource: "https://github.com/coleam00/archon"
    title: "Archon — persist_session with scope-keyed composite primary key and provider session resume"
---

# Session Persistence

## The General Rule

When an agent node runs inside a workflow, the provider (Claude, Codex,
etc.) creates a **session** — a conversation context that the agent can
resume on a later invocation. Without persistence, every re-run of the
workflow cold-starts the agent: no memory of prior turns, no accumulated
context, no ability to continue a multi-step conversation.

Session persistence stores the provider's session ID in a durable record
keyed by a **composite identity** that ties the session to the workflow
context, not to an ephemeral execution. On the next run with the same
scope, the engine loads the stored session ID and passes it as the resume
handle to the provider.

### Scope-Keyed Composite Identity

The session record is keyed by a composite of:

- **Workflow name** — which workflow definition the session belongs to.
- **Node ID** — which node within the workflow produced the session.
- **Scope key** — the conversation or run context that owns the session
  (typically the conversation ID or a user+run tuple).
- **Provider** — which agent provider created the session (a workflow may
  use multiple providers across nodes).

This composite key ensures sessions do not collide across workflows,
nodes, scopes, or providers. A session for (workflow-A, node-X,
conversation-42, claude) is distinct from (workflow-A, node-X,
conversation-43, claude) — different conversations, different contexts.

### Opt-In Per Node

Session persistence is opt-in per node. A node declares
`persist_session: true` (or the workflow declares a default
`persist_sessions: true` that individual nodes can override with `false`).
Not every node benefits from session resume — a one-shot bash command has
no session to persist. The opt-in keeps the session table sparse and
avoids storing ephemeral sessions that will never be resumed.

### Capability Requirement

Session persistence requires the provider to support session resume. If
the resolved provider's capability set does not include session resume,
the engine does not persist the session — and warns the user that the
node's `persist_session: true` declaration is not honored. This is a
capability mismatch, not a silent failure.

### Distinction from On-Disk Transcript Persistence

Session persistence (storing the provider's session ID for resume) is
distinct from on-disk transcript persistence (the provider's own
mechanism for saving the conversation transcript to disk). The former is
the engine's responsibility — it records the session ID and passes it
back. The latter is the provider's responsibility — it manages its own
transcript files. The engine may use both, but they are separate concerns
with separate configuration.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `workflow_node_sessions` table stores one row per
`(workflow_name, node_id, scope_key, provider)` tuple. A node opts in via
`persist_session: true`; the workflow-level `persist_sessions: true` sets
a default for all AI nodes. On a subsequent run with the same scope key,
the executor loads the stored `provider_session_id` and passes it as
`resumeSessionId` to the provider's `sendQuery()`. The `last_run_id`
column is nullable with `ON DELETE SET NULL` — deleting the originating
run clears the reference without dropping the resumable session itself.
Requires `sessionResume: true` in the provider's
`ProviderCapabilities`.

### LangGraph

LangGraph's `checkpointer` mechanism persists graph state (including
conversation messages) across invocations. The `thread_id` is the scope
key — each thread has its own state history. On re-invocation with the
same `thread_id`, LangGraph restores the state and resumes from the last
checkpoint. This is the equivalent of session persistence at the graph
level rather than the per-node level.

### AutoGen

AutoGen's `ConversationBuffer` and `GroupChatManager` maintain
conversation history that can be serialized and restored. A conversation
ID ties the buffer to a specific multi-agent exchange. On resume, the
buffer is deserialized and the agents continue with full prior context.
AutoGen does not enforce a composite key — the application is responsible
for scoping the conversation ID.

## Anti-Patterns

- **Session keyed by run ID only** — the session is tied to a specific
  execution and cannot be resumed on a different run of the same workflow
  in the same conversation. Use a scope key that survives across runs.
- **Silent no-persist on unsupported provider** — the node declares
  `persist_session: true`, the provider does not support resume, and the
  engine silently drops the declaration. Warn the user so they know the
  session will not be resumed.
- **Persisting every node's session** — storing sessions for one-shot
  nodes that will never be resumed. This bloats the session table and
  provides no value. Make persistence opt-in.
- **Conflating session ID with transcript** — storing the provider's
  on-disk transcript path as the session handle. The session ID is the
  resume handle; the transcript is the provider's internal state. They
  are separate concerns.

## See Also

- [DAG Workflow Engine](dag-workflow-engine.md) — the engine that
  executes nodes with persistent sessions.
- [Provider Capability Tiers](provider-capability-tiers.md) — how the
  engine determines whether a provider supports session resume.
