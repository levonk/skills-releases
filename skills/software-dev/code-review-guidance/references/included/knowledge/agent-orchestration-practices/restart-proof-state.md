---
type: Practice
title: Restart-Proof State
description: All orchestration state lives on disk and in the session backend — kill the session anytime, the next one reconciles. Every state is a file with a defined format and a producer script. State files are append-only event logs, not current-state truth — the current state is derived by folding the log. The handoff file is just another state file, not a special artifact.
tags: [agent-orchestration, restart-proof, state-management, event-log, append-only, reconciliation, crash-recovery]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: firstmate-restart-proof
    resource: "https://github.com/kunchenguid/firstmate"
    title: "firstmate — restart-proof state via on-disk event logs with fold-based current-state derivation"
---

# Restart-Proof State

## The General Rule

An orchestrator that keeps state in memory dies when the session is
killed — context limit, user pause, crash, network drop. The next
session starts from zero and must re-derive everything. The fix is to
put **all state on disk** (and in the session backend) so a killed
session loses nothing. The next session reads the state files and
reconciles.

### Every State Is a File with a Defined Format and a Producer

Each piece of state has:

- A **file** at a defined path with a defined format (JSON, TOML,
  markdown, line-delimited events).
- A **producer script** that writes to the file. The producer is the
  only thing that writes to the file — no ad-hoc writes from the
  orchestrator's conversation.

This means any session can reproduce the state by running the
producer. It also means the state is auditable — the file's contents
are the record of what happened.

### State Files Are Append-Only Event Logs

A state file is an **append-only event log**, not a current-state
record. Events are appended as they happen; the current state is
**derived by folding the log**. This is the event-sourcing pattern
applied to agent orchestration.

Why append-only:

- **Crash safety** — an append is atomic (on most filesystems). A
  crash mid-append loses at most the last event. A crash mid-update of
  a current-state file may corrupt the entire state.
- **Auditability** — the log records what happened, in order. A
  current-state record records only the result, not the path.
- **Reproducibility** — the fold is deterministic. Running the fold on
  the same log produces the same current state. This means a new
  session can reproduce the exact state the old session had.

The fold function is the only thing that reads the log to produce
current state. The orchestrator reads current state from the fold's
output, not from the log directly.

### The Handoff File Is Just Another State File

The handoff document (the file that captures conversation context for
the next session) is not a special artifact. It is a state file with
a defined format and a producer. It is produced by folding the
session's event log into a structured summary. It is consumed by the
next session as one input among many — not the sole input.

This demotes the handoff from "the thing that saves the session" to
"one view of the session's state." Other views (the task index, the
decision inventory, the worktree registry) are equally important. A
session that reads only the handoff and ignores the other state files
has an incomplete picture.

### Reconciliation

When a new session starts, it reconciles:

1. Read all state files (event logs).
2. Fold each log to derive current state.
3. Compare the derived state with the expected state (e.g. "task X
   should be in progress — is it?").
4. Act on discrepancies — a task marked in-progress but with no
   worktree activity is stale; a worktree that exists but is not in
   the task index is orphaned.

Reconciliation is **idempotent** — running it twice produces the same
result. This is a consequence of the fold being deterministic and the
state files being append-only.

## Concrete Instances

### Task Index as Event Log

The task index is not a markdown file that gets edited. It is an
append-only log of task events: `CREATED task-001 ship "add foo"`,
`STARTED task-001`, `COMPLETED task-001`. The current task list (which
tasks are pending, in-progress, done) is derived by folding the log.
A new session folds the log and sees the current state without
reading any conversation history.

### Worktree Registry

The worktree registry is an append-only log of worktree events:
`ACQUIRED worktree-1 for task-001`, `RELEASED worktree-1`. The
current set of active worktrees is derived by folding the log. A new
session can verify that every active worktree still exists on disk
and that every on-disk worktree is in the registry.

### Session Backend

The session backend (e.g. tmux session state, Claude conversation
state) is another state store. The orchestrator does not rely on it
as the primary state — the on-disk files are primary. The session
backend is a cache that can be rebuilt from the on-disk state. If the
session backend is lost (tmux killed, conversation truncated), the
on-disk state is still complete.

## Anti-Patterns

- **Current-state files instead of event logs** — a file that stores
  the current state and gets overwritten on every change. A crash
  mid-overwrite corrupts the state. Use append-only event logs with a
  fold.
- **In-memory state** — the orchestrator keeps state in its
  conversation context and writes it to disk only at the end. A
  crash loses everything. Write to disk as events happen.
- **Ad-hoc writes** — the orchestrator writes to state files directly
  from its conversation, bypassing the producer script. The format
  drifts; the file becomes unparseable. Only the producer writes.
- **Handoff as the sole state** — the next session reads only the
  handoff and ignores the task index, worktree registry, and decision
  inventory. The picture is incomplete. The handoff is one view, not
  the state.
- **Non-idempotent reconciliation** — running reconciliation twice
  produces different results (e.g. it re-creates worktrees that
  already exist). The fold must be deterministic and reconciliation
  must be idempotent.

## See Also

- [Ship and Scout Task Shapes](ship-scout-task-shapes.md) — the task
  shape (ship or scout) is part of the task's on-disk event log.
- [Event-Driven Zero-Token Supervision](event-driven-supervision.md)
  — the watcher's state (which panes are being watched) lives on disk
  so a killed watcher can resume.
