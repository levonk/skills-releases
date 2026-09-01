---
type: Practice
title: Design Exploration with Parallel Candidates
description: Before committing to a non-trivial architecture decision, build two or more structurally distinct design candidates in parallel. Each candidate writes to its own path. A cross-judge scores rubric criteria and recommends a base. Grafting folds the best parts of losing candidates into the base by hand. Convergence across candidates is a ship signal; wild divergence is a reframe signal. Repeated friction of the same shape is a scrap trigger.
tags: [agent-orchestration, design-exploration, parallel-candidates, arena, architect, grafting, convergence, scrap-trigger]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: open-pstack-arena
    resource: "https://github.com/ericlitman/open-pstack"
    title: "open-pstack arena skill — parallel design candidates with cross-judge scoring and grafting"
  - id: open-pstack-architect
    resource: "https://github.com/ericlitman/open-pstack"
    title: "open-pstack architect skill — design sketch with type signatures and module boundaries before implementation"
---

# Design Exploration with Parallel Candidates

## The General Rule

For any non-trivial architecture decision — a new module boundary, a
state machine, a data flow with no precedent in the codebase — building
one design and committing to it is a gamble. The first design that
looks reasonable is not necessarily the best design; it is just the
first one that cleared the "plausible" bar. The "design it twice" rule
forces a comparison: build two or more **structurally distinct**
candidates before synthesizing.

"Structurally distinct" does not mean "cosmetically different." Two
candidates that differ only in naming or file layout are the same
design. Structural distinction means different decomposition
strategies — different module boundaries, different data ownership,
different control flow. If the candidates converge on the same
structure, that is a strong signal the structure is right. If they
diverge wildly, that is a signal the problem is not yet understood —
reframe, do not average.

### Each Candidate Writes to Its Own Path

Each candidate produces its artifact in an isolated location — a
worktree, a temp directory, or a named branch. The candidates do not
see each other's output while being built. This prevents anchoring: if
candidate B can see candidate A, B tends to produce a minor variant of
A rather than an independent design.

### Cross-Judge Scores Rubric Criteria

After all candidates are built, a cross-judge (a reviewer that did not
build any candidate) scores each against a shared rubric. The rubric
criteria are defined before the candidates are built — this prevents
the rubric from being retrofitted to justify a preferred candidate.
The cross-judge recommends a base — the candidate with the best
overall rubric score — but the recommendation is not automatic. The
lead can override it with reasoning.

### Grafting Folds Best Parts of Losers

The base candidate is the starting point, not the final answer. The
best parts of the losing candidates are **grafted** into the base by
hand — the lead reads each losing candidate, identifies the specific
ideas worth preserving, and writes them into the base. Grafting is not
copy-paste; it is synthesis. The grafted ideas are adapted to the
base's structure, not pasted on top of it.

### Convergence and Divergence Signals

- **Convergence** — two or more candidates independently arrive at the
  same structural shape. This is a ship signal: the structure is likely
  right. Proceed with the base (or any candidate — they are
  structurally equivalent).
- **Wild divergence** — candidates produce fundamentally incompatible
  structures. This is a reframe signal: the problem statement is
  ambiguous or the constraints are unclear. Do not average the
  candidates (averaging incompatible designs produces a worse design
  than either). Reframe the problem, clarify the constraints, and run
  the candidates again.

### Scrap Trigger

A scrap trigger is not a single instance of friction. It is a
**repeated pattern** of friction of the same shape: the same workaround
appearing in multiple places, multiple unrelated edge cases needing
special-case branches, types needing escape hatches. When the
implementation keeps producing friction the design sketch cannot
absorb, throw out the sketch and redesign. The signal is repetition,
not severity — one bad edge case is normal; the same category of edge
case appearing three times is a scrap trigger.

## Concrete Instances

### Arena Pattern

The arena pattern spawns N candidates in parallel, each in its own
worktree or temp directory, each built by an independent agent (or the
same agent with different seed constraints). A cross-judge reviews all
candidates against the rubric and recommends a base. The lead grafts
the best ideas from losers into the base. Used for architecture
decisions with high reversibility cost — getting the structure wrong
means a rewrite.

### Architect Sketch

For smaller decisions (a single module's interface, a function's type
signature), the full arena is overkill. The architect sketch is a
lighter version: sketch the types, function signatures, and module
boundaries with `not implemented` bodies before writing the
implementation. Screen the sketch against design red flags (shallow
modules, information leakage, temporal decomposition, pass-through
methods). If the sketch has red flags, redesign before implementing.
This is the "design it twice" rule at the module level.

## Anti-Patterns

- **Cosmetic variation** — two candidates that differ only in naming or
  file layout. This is one design, not two. Force structural
  distinction: different module boundaries, different data ownership.
- **Sequential candidates** — building candidate B after seeing
  candidate A. B anchors on A. Build in parallel, in isolated
  locations.
- **Retrofitted rubric** — defining the rubric after seeing the
  candidates, to justify a preferred one. Define the rubric first.
- **Copy-paste grafting** — pasting a losing candidate's code into the
  base. Grafting is synthesis — adapt the idea to the base's
  structure, do not paste the implementation.
- **Averaging incompatible designs** — when candidates diverge wildly,
  averaging them produces a worse design than either. Reframe instead.
- **Single-instance scrap** — throwing out a design after one bad edge
  case. The scrap trigger is repeated friction of the same shape, not
  a single instance.

## See Also

- [Multi-Model Adversarial Review](multi-model-adversarial-review.md)
  — the cross-judge step uses the same consensus-tier pattern: the
  cross-judge is one reviewer, the candidates' builders are others.
- [Encode Lessons in Structure](encode-lessons-in-structure.md) —
  design red flags should be encoded as lint rules, not text
  instructions that get skipped.
