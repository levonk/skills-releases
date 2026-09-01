---
type: Practice
title: Encode Lessons in Structure
description: When you write the same instruction twice, encode it as a lint rule, script, metadata flag, or runtime check instead of more text. Text instructions get skipped; structural enforcement does not. The test of whether a lesson is encoded is whether a new agent can violate it without noticing — if it can, the lesson is text, not structure.
tags: [agent-orchestration, structural-enforcement, lint-rules, lessons, encoding, conventions]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: open-pstack-encode-lessons
    resource: "https://github.com/ericlitman/open-pstack"
    title: "open-pstack poteto-mode — Encode Lessons in Structure principle"
---

# Encode Lessons in Structure

## The General Rule

When the same instruction appears twice in documentation, it is a
signal that the instruction should be **encoded as structure** — a
lint rule, a script, a metadata flag, or a runtime check — instead of
more text. Text instructions get skipped (an agent in a hurry does not
read the style guide); structural enforcement does not (the lint rule
fails the build, the script refuses to run, the runtime check throws).

### The Test

The test of whether a lesson is encoded in structure is whether a new
agent can violate it without noticing. If the agent can violate it and
proceed (the build passes, the script runs, no error is thrown), the
lesson is text, not structure. If the agent cannot violate it without
an immediate failure, the lesson is structure.

### Forms of Structural Encoding

- **Lint rules** — a convention about code style or pattern is
  enforced by a lint rule that fails the build. The agent cannot
  commit violating code without noticing.
- **Scripts** — a procedure that must be followed is encoded as a
  script. The agent runs the script instead of following text
  instructions. The script either succeeds or fails — there is no
  "I think I followed it correctly."
- **Metadata flags** — a property that must be declared is encoded as
  a required metadata field. The build fails if the field is missing
  or invalid. The agent cannot skip the declaration.
- **Runtime checks** — an invariant that must hold at runtime is
  encoded as an assertion or guard. The program throws if the
  invariant is violated. The agent cannot proceed with a broken
  invariant.
- **Type systems** — a constraint on data shape is encoded as a type.
  The compiler rejects code that violates the constraint. The agent
  cannot write code that does not type-check.

### When to Encode vs When to Document

Encode in structure when:

- **The lesson is enforceable** — there is a deterministic check that
  can detect violations.
- **The lesson is repeated** — the instruction has appeared twice or
  more. Repetition is the signal that text is not working.
- **The lesson is violated** — agents have skipped the text
  instruction in practice. The violation is the evidence that text is
  insufficient.

Document in text when:

- **The lesson is judgment-based** — there is no deterministic check;
  the lesson requires human or AI judgment.
- **The lesson is context-dependent** — the right action depends on
  circumstances that cannot be enumerated.
- **The lesson is new** — it has not been repeated or violated yet.
  Encode when the pattern emerges.

## Concrete Instances

### Worktree Isolation as a Script

The lesson "do not work on main" can be a text instruction in
AGENTS.md. Agents skip it. Encoding it as a script that refuses to run
on main (the worktree isolation guard) makes it structure — the agent
cannot work on main without the script failing.

### Frontmatter Validation as a Build Check

The lesson "every SKILL.md must have valid frontmatter" can be a text
instruction. Agents skip it. Encoding it as a build-time validation
check makes it structure — the build fails if the frontmatter is
invalid.

### No Secrets as a Scan Script

The lesson "do not commit secrets" can be a text instruction. Agents
skip it. Encoding it as a scan script that checks staged files makes
it structure — the commit is blocked if a secret pattern is detected.

### Binding Contract as Hooks

The lesson "create a worktree before dispatching subagents" can be a
text instruction. Agents skip it. Encoding it as a PreToolUse hook
that blocks subagent dispatch without a gate-pass file makes it
structure — the dispatch is blocked by the hook.

## Anti-Patterns

- **Text instead of structure** — writing the instruction in a
  document and hoping agents read it. The instruction gets skipped.
  If the lesson is enforceable, encode it.
- **Structure without failure** — a check that warns but does not
  fail. The agent sees the warning and proceeds. The check must fail
  (block the build, block the commit, throw at runtime) to be
  structural.
- **Encoding unenforceable lessons** — trying to encode a
  judgment-based lesson as a lint rule. The lint rule is either too
  strict (blocks valid code) or too loose (misses violations). Keep
  judgment-based lessons in text.
- **Documenting after encoding** — keeping the text instruction after
  encoding the lesson in structure. The text is now redundant and can
  drift from the structure. Remove the text or reduce it to a pointer
  ("see the lint rule").

## See Also

- [Build the Lever](../software-architecture-essentials/build-the-lever.md)
  — the architecture-oriented companion: build the tool that does or
  proves the work. Encode Lessons in Structure is the
  orchestration-oriented version: build the tool that enforces the
  lesson.
- [Multi-Model Adversarial Review](multi-model-adversarial-review.md)
  — review findings that are enforceable should be encoded in
  structure (lint rules, scripts), not added to documentation.
