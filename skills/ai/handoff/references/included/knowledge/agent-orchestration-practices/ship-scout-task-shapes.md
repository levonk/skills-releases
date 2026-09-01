---
type: Practice
title: Ship and Scout Task Shapes
description: Not every task produces code. Ship tasks deliver authorized changes through a PR or local merge, then tear down the worktree. Scout tasks leave a standalone investigation report at a known path, feed a decision inventory, then tear down. Scout worktrees are declared scratch — discardable only after the report exists and the completion gate passes. The distinction determines the execution pipeline: ship tasks run the full dev-review-commit-ship cycle; scout tasks skip it.
tags: [agent-orchestration, task-shapes, ship, scout, investigation-report, worktree-lifecycle, decision-inventory]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: firstmate-task-shapes
    resource: "https://github.com/kunchenguid/firstmate"
    title: "firstmate — ship/scout task distinction with different execution pipelines and worktree lifecycles"
---

# Ship and Scout Task Shapes

## The General Rule

An execution pipeline that treats every task as "produce code, commit,
push, PR" forces investigation work into the wrong shape. An
investigation that produces a report gets committed as a markdown file
and pushed as a PR — but the PR has no code to review, the report is
the deliverable, and the review cycle is theater. The fix is to
distinguish two task shapes at triage time and route them through
different pipelines.

### Ship Tasks

A ship task **delivers authorized changes**. The output is code (or
config, or documentation that changes behavior). The pipeline:

1. Work in a worktree on a feature branch.
2. Implement the change.
3. Review (single-model or multi-model adversarial review).
4. Commit.
5. Ship — push and create a PR, or merge locally per the project mode.
6. Tear down the worktree.

The worktree is not scratch — it holds the branch that will become
the PR. It is discardable only after the PR is merged (or the local
merge is complete).

### Scout Tasks

A scout task **leaves a standalone investigation report**. The output
is a report, not code. The pipeline:

1. Work in a worktree declared **scratch**.
2. Investigate — read code, run experiments, build prototypes, gather
   evidence.
3. Write `report.md` at a known path (e.g.
   `internal-docs/feature/todo/{slug}/report.md`).
4. Feed the report into a **decision inventory** — a tracked list of
   open investigations and their findings.
5. Completion gate — verify the report exists and meets a minimum
   structure (problem statement, findings, recommendation, evidence).
6. Tear down the worktree.

Scout tasks **skip the dev-review-commit-ship cycle**. There is no PR
to review because there are no code changes to merge. The report is
the deliverable; the decision inventory is the tracking mechanism.

### Scratch Worktree Discipline

A scout worktree is declared scratch at creation time. This signals:

- The branch is not a PR candidate. Do not push it.
- The worktree is discardable after the report exists and the
  completion gate passes.
- Any code or prototypes in the worktree are evidence for the report,
  not production code. Do not extract them into the main branch.

The declaration prevents confusion: without it, an agent may treat a
scout worktree as a ship worktree, push the branch, and create a PR
for prototype code that was never meant to ship.

### Decision Inventory

Scout reports feed a **decision inventory** — a tracked list of open
investigations. Each entry links to the report and records the
decision status: pending (report filed, no decision yet), accepted
(recommendation adopted), rejected (recommendation declined with
reason), or superseded (a later investigation replaced this one). The
inventory prevents investigations from disappearing — a report filed
and forgotten is a wasted investigation.

## Concrete Instances

### Feature Investigation

A user asks: "Should we adopt library X or library Y for feature Z?"
This is a scout task. The agent investigates both libraries, builds a
small prototype with each, writes a report comparing them with a
recommendation, and files it in the decision inventory. No code is
merged. The worktree is torn down after the report is filed.

### Bug Reproduction

A user reports a bug that is not reproducible. This is a scout task.
The agent investigates, attempts reproduction, and writes a report
documenting the conditions under which the bug appears (or does not).
If the agent finds a fix during investigation, the scout task can be
converted to a ship task — but the conversion is explicit, not
implicit.

### Architecture Spike

A user asks: "Can we migrate from system A to system B?" This is a
scout task. The agent investigates the migration path, identifies
risks, estimates effort, and writes a report. The report feeds the
decision inventory. If the decision is to proceed, the migration
becomes a series of ship tasks.

## Anti-Patterns

- **Forcing scout work into ship shape** — committing an investigation
  report as a PR. The PR has no code to review; the review cycle is
  theater. File the report and update the decision inventory instead.
- **No scratch declaration** — a scout worktree is not declared
  scratch. An agent pushes the branch and creates a PR for prototype
  code. Declare scratch at creation time.
- **Tearing down before the report exists** — the worktree is
  discarded before the report is written. The investigation's evidence
  is lost. The completion gate prevents this.
- **Reports without a decision inventory** — reports are filed but not
  tracked. They disappear. Feed every report into the decision
  inventory.
- **Implicit scout-to-ship conversion** — an agent starts
  investigating, finds a fix, and merges it without converting the
  task shape. The conversion must be explicit: change the task from
  scout to ship, create a new worktree on a feature branch, and run
  the ship pipeline.

## See Also

- [Event-Driven Zero-Token Supervision](event-driven-supervision.md)
  — scout tasks have different liveness expectations than ship tasks
  (investigations may be quiet for long periods while reading).
- [Restart-Proof State](restart-proof-state.md) — the task shape
  (ship or scout) is part of the task's on-disk state, so a killed
  session can resume with the correct pipeline.
