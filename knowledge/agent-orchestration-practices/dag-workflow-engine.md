---
type: Practice
title: DAG Workflow Engine
description: Execute multi-step agent workflows as a directed acyclic graph with typed node kinds, depends_on ordering, trigger rules for concurrent layers, and load-time cycle validation. The graph is the governance surface — ordering, gates, joins, and retries are declarative; computation lives inside node bodies.
tags: [agent-orchestration, workflow-engine, dag, node-types, depends-on, trigger-rules, concurrent-layers, graph-validation]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-workflow-engine
    resource: "https://github.com/coleam00/archon"
    title: "Archon — DAG workflow engine with 10 node types, trigger rules, load-time validation"
---

# DAG Workflow Engine

## The General Rule

A workflow engine for agent orchestration executes a **directed acyclic
graph (DAG)** of typed nodes. The graph is the governance surface: it
expresses what the engine must see to govern a run — ordering, gates,
joins, retries, sessions, and artifacts. Computation stays inside node
bodies (script source, prompt text, bash commands), not in the graph
metadata.

### Typed Node Kinds

Each node has exactly one **kind** that determines how the engine executes
it. The kind set covers the full spectrum of agent orchestration:

- **Deterministic execution** — bash, script, command nodes that run
  without an LLM call.
- **AI agent invocation** — prompt nodes that send a query to a provider
  and stream a response.
- **Control flow** — loop nodes for iteration, approval nodes for human
  gates, cancel nodes for early termination.
- **Composition** — include nodes that flatten another workflow's nodes
  at load time, workflow nodes that spawn a separate sub-run with its own
  governance object.

The kind is the dispatch key. The engine switches on kind to select the
executor; validation enforces kind-specific field requirements (e.g. a
prompt node requires non-empty prompt text; an approval node requires an
on_approve/on_reject structure).

### Dependency Ordering (depends_on)

Nodes declare their predecessors via `depends_on`. The engine resolves
execution order by topological sort. Nodes with no unmet dependencies form
a **concurrent layer** — they may execute in parallel. The engine does not
require explicit layer declarations; layers emerge from the dependency
graph.

### Trigger Rules

A node's `trigger_rule` controls when it fires relative to its
dependencies:

- **all_success** — fire only when all dependencies succeeded (default).
- **one_success** — fire when at least one dependency succeeded.
- **none_failed_min_one_success** — fire when no dependency failed and at
  least one succeeded.
- **all_done** — fire when all dependencies completed regardless of
  outcome (fan-in for cleanup or reporting).

Trigger rules let a single graph express conditional fan-out and fan-in
without a separate conditional node kind.

### Load-Time Validation

The graph is validated **at load time**, not at execution time. Cycle
detection, dependency reference validation, and `$nodeId.output.field`
variable substitution checks all run before any node executes. A graph
that fails validation never starts — no worktree, no clone, no AI cost.

### The YAML Surface Boundary

The workflow definition expresses only what the engine must see to govern.
Computation — conditionals, data transformation, decision logic — lives
inside a node's body (the script source or prompt text), not in graph
metadata. A `when:` field is declarative data (a simple string condition),
not an expression engine. If a condition requires computation, the answer
is a script node that computes the decision and a downstream `when:` that
reads its structured output.

This boundary keeps load-time validation, visual building, resume, and
audit trails possible. A graph that computes at parse time cannot be
statically validated or resumed.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's workflow engine defines 10 node types across four categories:
command (invoke a bundled command), prompt (AI agent call), bash (shell
execution), script (inline TypeScript), loop (iteration with gate
control), approval (human gate with on_approve/on_reject), cancel (early
termination with reason), include (flatten another workflow at load
time), workflow (spawn a separate sub-run), and the shared base fields.
Trigger rules are `all_success`, `one_success`, `none_failed_min_one_success`,
and `all_done`. The loader uses `dagNodeSchema.safeParse()` for node
validation; graph-level checks (cycles, deps, `$nodeId.output` refs) run
as imperative code in `validateDagStructure()`. The flat static DAG is the
executor's input — no runtime-resolved structure.

### GitHub Actions

GitHub Actions models workflows as a DAG of jobs with `needs` dependencies.
Jobs contain steps (the node body). The `if` condition on a job or step is
a declarative expression (not arbitrary code) — consistent with the
YAML-surface boundary. Jobs with no unmet `needs` run concurrently (the
concurrent layer emerges from the graph). Matrix strategy provides
data-driven fan-out without a separate node kind.

### Temporal

Temporal models workflows as code (not YAML), but the same principles
apply: the workflow function expresses ordering and gates (Signals,
Queries, child workflow spawns), while Activities hold the computation.
The workflow code is replayed deterministically from the event log — the
"load-time validation" equivalent is that non-deterministic workflow code
causes a non-determinism error on replay. Temporal's child workflows are
the equivalent of sub-run nodes (separate governance object, separate
audit trail).

## Anti-Patterns

- **Runtime-resolved graph structure** — a node that dynamically adds
  other nodes to the graph at execution time. This breaks load-time
  validation, resume, and audit. Use a sub-run (separate governance
  object) instead.
- **Computation in graph metadata** — a `when:` field that grows into an
  expression engine with functions and arithmetic. This makes the graph
  non-statically-validatable. Push computation into a script node.
- **Missing cycle detection** — a graph with a cycle that passes load-time
  validation and deadlocks at execution time. Cycle detection must run
  before any node executes.
- **Untyped nodes** — a single node kind with a "type" field that the
  engine switches on at runtime. This pushes validation to execution time
  and loses the kind-specific field enforcement.

## See Also

- [Output Schema Validation](output-schema-validation.md) — how the engine
  validates structured output from AI nodes.
- [Session Persistence](session-persistence.md) — how the engine resumes
  provider sessions across re-runs.
- [Capability Gating](capability-gating.md) — how the engine blocks
  invocation before any cost when a capability is missing.
