---
type: Practice
title: Guard the Context Window
description: When the context fills up — large outputs, long files, repeated reads, fan-out planning — route the bulk to subagents and keep only summaries in the main thread. The main context window is for orchestration decisions; subagent context windows are for the work. A main thread that reads everything has no room left to think.
tags: [agent-orchestration, context-window, subagents, summarization, token-efficiency, fan-out]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: open-pstack-guard-context-window
    resource: "https://github.com/ericlitman/open-pstack"
    title: "open-pstack poteto-mode — Guard the Context Window principle"
---

# Guard the Context Window

## The General Rule

The main orchestrator's context window is a finite resource. Every
large output read, long file loaded, repeated read, or fan-out plan
written consumes it. When the context fills up, the orchestrator loses
the ability to reason about the early parts of the conversation — it
forgets the original goal, the constraints, and the decisions made
along the way. The rule: **route the bulk to subagents, keep only
summaries in the main thread.**

### What Belongs in the Main Thread

- **Orchestration decisions** — what to do next, which subagent to
  dispatch, how to route results.
- **Summaries** — one-paragraph summaries of subagent outputs, not the
  full outputs.
- **Constraints and goals** — the original task, the constraints, the
  decisions made. These must stay in context for the orchestrator to
  reason.
- **Structured results** — the Agreement Map from a multi-model
  review, the pass/fail from a build, the verdict from a code review.
  Structured results are compact; raw outputs are not.

### What Belongs in Subagent Context

- **Large outputs** — full file contents, full test output, full build
  logs. The subagent reads them and returns a summary.
- **Long files** — files that would consume a significant fraction of
  the main context. The subagent reads the file and returns the
  relevant excerpt.
- **Repeated reads** — reading the same file multiple times to answer
  different questions. The subagent reads once and answers all
  questions.
- **Fan-out planning** — planning a multi-step task in detail. The
  subagent produces the plan; the main thread receives the plan
  summary.

### The Summary Contract

When a subagent returns a summary, the summary must be sufficient for
the orchestrator to make decisions without reading the full output.
The summary contract:

- **Verdict** — what was the result (pass/fail, clean/needs-fixes,
  found/not-found)?
- **Key findings** — the 3-5 most important findings, not all
  findings.
- **Action items** — what should the orchestrator do next?
- **Evidence pointer** — where is the full output if the orchestrator
  needs to drill down?

The summary is not a compressed version of the output; it is a
decision-oriented distillation. The orchestrator should be able to act
on the summary alone.

### Fan-Out and Merge

When a task produces a large fan-out (N subagents each producing
output), the merge step is where context window pressure is highest.
Do not merge all N outputs into the main thread. Instead:

1. Each subagent produces a summary.
2. A merge subagent reads all N summaries and produces a merged
   summary.
3. The main thread receives the merged summary.

This keeps the main thread at one summary regardless of N. The merge
subagent's context holds the N summaries, but that is a subagent
context — it is disposable.

## Concrete Instances

### Code Review

A code review of a large diff: dispatch a subagent to read the full
diff and return a verdict (clean/needs-fixes) with key findings. The
main thread receives the verdict and findings, not the full diff. If
the main thread needs to see a specific finding's context, it reads
just that excerpt.

### Build Failure

A build produces 500 lines of output: dispatch a subagent to read the
output and return the error (what failed, where, why). The main thread
receives the error summary, not the 500 lines.

### Multi-Model Review

N reviewers each produce a full review: the merge subagent reads all N
reviews and produces the Agreement Map (a compact table). The main
thread receives the Agreement Map, not the N reviews.

### File Exploration

Exploring a large codebase: dispatch a subagent to read the relevant
files and return a summary of the architecture. The main thread
receives the summary, not the file contents.

## Anti-Patterns

- **Reading everything into the main thread** — the orchestrator reads
  every file, every output, every log. The context fills up and the
  orchestrator forgets the original goal.
- **No summary contract** — the subagent returns a "summary" that is
  just a compressed version of the output. The orchestrator cannot act
  on it without reading the full output. The summary must be
  decision-oriented.
- **Merging N outputs into the main thread** — the orchestrator reads
  all N subagent outputs directly. The context fills up. Use a merge
  subagent.
- **Keeping raw outputs "just in case"** — the orchestrator keeps the
  full output in context in case it needs to drill down. The evidence
  pointer is sufficient — the full output is available if needed, but
  not in the main context.

## See Also

- [Subagent Delegation](../../includes/subagent-delegation.md.tmpl) —
  the patterns for dispatching subagents and collecting summaries.
- [Multi-Model Adversarial Review](multi-model-adversarial-review.md)
  — the Agreement Map is a compact structured result designed for the
  main thread; the full reviews stay in subagent context.
- [Event-Driven Zero-Token Supervision](event-driven-supervision.md)
  — the bash watcher classifies wakes in bash (zero tokens) before
  escalating to the orchestrator (token cost). This is
  context-window guarding at the supervision layer.
