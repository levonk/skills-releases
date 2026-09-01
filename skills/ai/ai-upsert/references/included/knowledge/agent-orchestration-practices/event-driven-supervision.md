---
type: Practice
title: Event-Driven Zero-Token Supervision
description: A bash watcher sleeps on the agent fleet and classifies wakes in bash, waking the orchestrator only when a wake is actionable. Actionable wakes are status signals, no-verb signals without liveness evidence, authenticated check output, stale panes not provably working, and heartbeat backstops. Worktree write-activity liveness defers escalation when a file is newer than the quiet window start. A turn-end guard ensures no turn ends blind while work is in flight.
tags: [agent-orchestration, event-driven, supervision, zero-token, liveness, worktree-write-activity, turn-end-guard, heartbeat]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: firstmate-architecture
    resource: "https://github.com/kunchenguid/firstmate"
    title: "firstmate — event-driven zero-token supervision with bash watcher, write-activity liveness, and turn-end guard"
---

# Event-Driven Zero-Token Supervision

## The General Rule

An orchestrator that polls its agent fleet on a timer burns tokens on
every poll — even when nothing has changed. An orchestrator that
blocks waiting for user input never notices a stalled subagent. The
fix is an **event-driven watcher** that sleeps on the fleet and wakes
the orchestrator only when a wake is actionable. The watcher runs in
bash (zero tokens), classifies wakes in bash (zero tokens), and only
escalates to the orchestrator (token cost) when the wake requires a
judgment.

### The Bash Watcher

The watcher is a bash loop that sleeps on the fleet — waiting for
output on any agent pane, a timer expiry, or a heartbeat tick. When a
wake occurs, the watcher classifies it **in bash** before deciding
whether to escalate:

- **Status signal** — an agent emitted a status line (e.g. "BUILD
  PASSED", "tests failed"). Escalate: the orchestrator needs to route
  the result.
- **No-verb signal without liveness evidence** — an agent emitted text
  that is not a status signal, and there is no evidence the agent is
  still working. Escalate: the agent may have stalled.
- **Authenticated check output** — a deterministic check (test, lint,
  build) produced output. Escalate: the orchestrator needs to read the
  pass/fail.
- **Stale pane not provably working** — a pane has been quiet longer
  than its quiet window, and there is no evidence it is working. See
  write-activity liveness below. Escalate.
- **Heartbeat backstop** — a periodic heartbeat tick fired. Escalate
  only if a pane is stale per the liveness check; otherwise re-sleep.

### Worktree Write-Activity Liveness

The naive liveness check is a flat time window: "if the pane has been
quiet for 10 minutes, it is stale." This produces false positives — a
long-running build is quiet for 15 minutes but is not stalled. The
fix is **write-activity detection**: a pane holding a file newer than
the start of its own quiet window, anywhere in the worktree recorded
for that task, is **deferred** (alive) instead of **escalated**
(stale).

The check is bounded by:

- **Depth** (`FM_WORKTREE_WRITE_MAXDEPTH`) — how deep to search the
  worktree for recent files. Bounds the cost of the check.
- **Wall-clock** (`FM_WORKTREE_WRITE_TIMEOUT`) — the maximum quiet
  window before the write-activity check is bypassed. Even if files
  are being written, a pane quiet for an hour is probably stuck.
- **Prune limits** — directories known to be noisy (build output, node
  modules) are pruned from the check.

The check is only taken in the branch about to escalate — if the
pane is clearly active (recent output), the check is skipped.

### Turn-End Guard

When parallel subagents are running and the orchestrator's turn is
about to end, the turn-end guard blocks or follows up. **No turn ends
blind** while work is in flight. The guard checks:

1. Are any subagents still running?
2. Are any subagents stale (per the liveness check)?
3. Are any subagents waiting for the orchestrator's input?

If any of these are true, the turn does not end — the orchestrator
handles the pending work first. This prevents silent stalls where a
subagent is waiting and the orchestrator has moved on.

## Concrete Instances

### Firstmate Fleet Watcher

Firstmate's watcher is a bash loop that sleeps on tmux panes (one per
agent). On wake, it classifies the output in bash and escalates only
actionable wakes to the orchestrator. The write-activity liveness
check searches the worktree for files newer than the quiet window
start, bounded by depth and wall-clock. The turn-end guard runs
before every orchestrator turn exit.

### Heartbeat Backstop

Even with write-activity liveness, a watcher can miss a wake (e.g.
a pane that exits without output). The heartbeat backstop fires on a
fixed interval (e.g. every 60 seconds) and re-runs the liveness check
on all panes. This catches stalls the event-driven path missed. The
heartbeat is not the primary liveness mechanism — it is the backstop.

## Anti-Patterns

- **Timer-based polling** — the orchestrator wakes every N seconds to
  check the fleet. Burns tokens on every wake, even when nothing
  changed. Use event-driven wakes with bash classification.
- **Flat time-window liveness** — "quiet for 10 minutes = stale."
  Produces false positives on long-running builds. Use write-activity
  detection.
- **Escalating every wake** — the watcher wakes the orchestrator on
  every output line. The orchestrator burns tokens reading noise.
  Classify in bash first; escalate only actionable wakes.
- **No turn-end guard** — the orchestrator ends its turn while
  subagents are running. The subagents stall silently. No turn ends
  blind.
- **Heartbeat as primary liveness** — relying on the heartbeat instead
  of event-driven wakes. The heartbeat is a backstop, not the primary
  mechanism. It catches missed wakes but does not replace them.

## See Also

- [Restart-Proof State](restart-proof-state.md) — the watcher's state
  (which panes are being watched, their quiet windows) lives on disk
  so a killed watcher can resume.
- [Ship and Scout Task Shapes](ship-scout-task-shapes.md) — scout
  tasks (investigations) have different liveness expectations than
  ship tasks (code changes).
