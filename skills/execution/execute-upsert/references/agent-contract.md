# AgentContract — Reference

> **What:** AgentContract is a structured YAML format for agent runtime
> contracts. It formalizes the non-negotiable rules an agent must follow during
> execution into machine-readable clauses with explicit severities and
> enforcement mechanisms.

## Why AgentContract

Before formalization, the execute-upsert binding contract was a static ~30-line
prose block injected into context by `inject-binding-contract.sh`. That worked,
but it had three problems:

1. **No structure** — the rules were prose, not queryable. Tools could not
   reason about individual clauses.
2. **No severity policy** — every rule read as equally non-negotiable, even
   though some are hard blocks and others are warnings.
3. **No enforcement mapping** — the prose said "MACHINE-ENFORCED" but did not
   name the specific script or hook that enforces each rule.

AgentContract fixes this by making the `.contract.yaml` the single source of
truth. The injection script becomes a **renderer** — it reads the YAML and
formats it into the `additionalContext` string. The YAML is the contract; the
script is the printer.

## Clause Types

Every contract has three top-level sections:

| Section | Meaning |
|---------|---------|
| `must` | Hard requirements. Violating a `must` clause is a contract breach. |
| `must not` | Hard prohibitions. Violating a `must not` clause is a contract breach. |
| `may` | Permissions and limits. These describe what is allowed, often with a bound (e.g. "up to 5"). |

Each clause is a list item with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Stable identifier (kebab-case). Used for referencing in logs and reviews. |
| `clause` | string | The human-readable rule text. This is what the LLM sees in context. |
| `severity` | enum | `warn` / `block` / `rollback` / `halt_and_alert` (see below). |
| `enforcement` | enum | `machine` or `llm-judged` (see below). |
| `check` | string | Names the script, hook, or review process that enforces this clause. |
| `fallback` | string (optional) | Documented exception or escape hatch. |

## Severity Levels

| Severity | Behavior on violation |
|----------|----------------------|
| `warn` | Log a warning; continue execution. The orchestrator or reviewer notes the deviation. |
| `block` | Hard stop. The enforcing script returns non-zero and the operation is refused. |
| `rollback` | Undo the in-progress work to the last known-good state (checkpoint), then stop. |
| `halt_and_alert` | Stop all execution and surface a human-visible alert. Reserved for safety-critical breaches. |

Severity is a policy declaration, not just a label. The enforcing script is
expected to act on it: a `block` clause's check exits non-zero; a `rollback`
clause's check triggers `git reset --hard` to the checkpoint; a `warn` clause's
check prints and continues.

## Enforcement Types

| Type | Meaning |
|------|---------|
| `machine` | A deterministic script performs the check. No LLM judgment involved — the script passes or fails. |
| `llm-judged` | The check requires reasoning over the run's artifacts (commits, diffs, task files). The orchestrator or a review skill evaluates whether the clause was satisfied. |

`machine` checks are preferred where possible because they are deterministic
and fast. `llm-judged` checks are used when the criterion is qualitative (e.g.
"did the story commit include both code and task file updates?").

## How the Binding Contract Was Formalized

The original 8 prose rules in `inject-binding-contract.sh` were mapped to
AgentContract clauses:

| Original rule (prose) | Clause id | Section | Severity | Enforcement |
|------------------------|-----------|---------|----------|-------------|
| 1. Every dispatch through execution-gate.sh | `gate-before-dispatch` | must | block | machine |
| 2. Work only in the worktree path | `worktree-only-work` | must | block | machine |
| 3. Checkpoint commit before dispatch | `checkpoint-before-dispatch` | must | rollback | machine |
| 4. Commit + merge + remove worktree after story | `commit-after-story` | must | block | llm-judged |
| 5. Never commit dirty main | `no-commit-dirty-main` | must not | block | machine |
| 6. Never work on stories in main checkout | `no-work-on-main` | must not | block | machine |
| 7. Max 5 simultaneous subagents | `max-parallel-subagents` | may | warn | llm-judged |
| 8. Roll back on failure | `rollback-on-failure` | must | rollback | llm-judged |

One additional `may` clause (`bypass-gate`) was added to document the existing
`SKILL_BYPASS_GATE=1` escape hatch that was previously implicit.

## Relationship to Existing Tools

AgentContract **references** existing enforcement tools — it does not
re-implement them. The contract is the policy; the tools are the mechanism.

### `execution-gate.sh`

The primary machine-enforcement entry point. Implements the checks for:

- `gate-before-dispatch` — the PreToolUse hook (`check-subagent-gate.sh`)
  blocks `run_subagent` calls unless a gate-pass file exists.
- `worktree-only-work` — the gate creates the per-story worktree and returns
  its path; `worktree-isolation-guard.sh` enforces that the subagent stays in
  it.
- `checkpoint-before-dispatch` — the gate records the checkpoint SHA.
- `no-commit-dirty-main` — the gate's Check 1 blocks if on main with
  uncommitted changes; `check-uncommitted-stop.sh` is the Stop-hook backstop.

### `quality-gate.sh`

Implements deterministic `must` checks (test pass, lint clean, build green).
AgentContract references it where applicable; it does not duplicate the check
logic. If a future clause needs a new deterministic check, the check is added
to `quality-gate.sh` (or a new script) and the clause's `check` field names it.

### `code-review-guidance` skill

Implements `llm-judged` checks. When a clause is `enforcement: llm-judged`,
the review skill is the mechanism that evaluates whether the clause was
satisfied. AgentContract names the review process in the `check` field; the
review skill reads the contract to know what to evaluate.

## How to Add a New Clause

1. **Add the clause to `.contract.yaml`** under `must`, `must not`, or `may`.
   Give it a stable `id`, a clear `clause` sentence, a `severity`, and an
   `enforcement` type.
2. **Implement the check.**
   - If `enforcement: machine`, add the check to an existing script
     (`execution-gate.sh`, `quality-gate.sh`) or create a new one. Name the
     script in the `check` field.
   - If `enforcement: llm-judged`, document what the reviewer should look for
     in the `check` field. The `code-review-guidance` skill or orchestrator
     review step is the mechanism.
3. **Reference the implementation.** The `check` field must name the script,
   hook, or review step that enforces the clause. This is the audit trail —
   anyone reading the contract can trace a clause to its enforcement code.
4. **Rebuild.** Run `just build current` so the updated `.contract.yaml` is
   copied to the build output and the injection script picks up the new
   clause.

## File Layout

| File | Role |
|------|------|
| `references/execute-upsert.contract.yaml` | The contract (source of truth). |
| `scripts/inject-binding-contract.sh.tmpl` | The renderer — reads the YAML and injects it as `additionalContext`. |
| `references/agent-contract.md` | This document — format reference. |
