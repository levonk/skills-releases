{{{ include "includes/base-ai-content.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# <Skill Title>

## Outcome

[TODO: State the outcome this skill produces — what the user gets when the
skill runs successfully. One to three sentences. This is the goal, not the
process.]

## Good vs Bad

[TODO: Provide 2-3 examples of good outcomes and 2-3 examples of bad
outcomes. This calibrates the model on what "done right" looks like vs what
to avoid.]

### Good

- [TODO: Good outcome example 1]
- [TODO: Good outcome example 2]

### Bad

- [TODO: Bad outcome example 1 — what went wrong]
- [TODO: Bad outcome example 2 — what went wrong]

## Guardrails

[TODO: Rules that must hold during execution. These are inviolable — the
model must not violate them. Express as clear, testable statements.]

- [TODO: Guardrail 1]
- [TODO: Guardrail 2]

## Calibration

[TODO: Short reasoning for how to decide in gray areas. When two guardrails
conflict, or when the context doesn't clearly match a good/bad example,
what heuristic should the model use?]

## Available Resources

[TODO: List the bundled resources (scripts, references, assets) available
to this skill and when to use each.]

- `scripts/` — [TODO: what scripts are bundled and what they do]
- `references/` — [TODO: what reference docs are available]
- `assets/` — [TODO: what assets are available, if any]

## Current Process

The default process for this skill lives in `references/process.md`. Follow
it by default. To deviate from any step, propose the deviation to the user
with reasoning. Never silently skip a step.

[TODO: If this skill has a detailed process, create references/process.md
and describe it there. If the process is simple enough to inline, describe
it here and remove the references/process.md pointer.]

## Task List

- [ ] [TODO: task 1 — derived from the Current Process steps]
- [ ] [TODO: task 2 — derived from the Current Process steps]
- [ ] [TODO: task 3 — derived from the Current Process steps]

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

**Maintenance protocol:**
1. **Verify in-progress marks.** Before doing anything else, re-check
   every task marked `[~]`. If the work is not actually underway, demote
   it back to `[ ]`.
2. **Start the next available task.** Pick the first `[ ]` task in
   priority order. Mark it `[~]` immediately before starting work on it.
3. **Prefer subagents for parallel work.** When two or more `[ ]` tasks
   are independent, launch them as parallel subagents. Mark each `[~]`
   before launching. Do not parallelize tasks that share files or depend
   on each other's output.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after the
   task's success criteria are met and verified. Never mark `[x]` on
   intent alone.
5. **Record blockers inline.** When a task cannot proceed, mark it `[!]`
   and append the blocker in parentheses on the same line.
6. **Update the list as work reveals new tasks.** Append newly
   discovered tasks as `[ ]` lines in priority order.

## Definition of Done

Before declaring the [TODO: skill-name] run complete, verify every item
below. Items marked **[script]** are deterministically verified by a
script — if the script exits non-zero, the item is NOT done. Items marked
**[manual]** require the agent to check something the scripts cannot
verify.

### [TODO: Deliverable Category 1]

- [ ] **[script]** [TODO: script-invocation] passes (Step N)
- [ ] **[manual]** [TODO: thing the agent must verify] (Step N)

### [TODO: Deliverable Category 2]

- [ ] **[manual]** [TODO: thing the agent must verify] (Step N)

### Not Done (common false-completion signals)

If any of these are true, the run is NOT complete:

- [TODO: <check passes> but <deliverable is wrong> → <the missing or broken thing> (Step N)]
- [TODO: <check passes> but <deliverable is wrong> → <the missing or broken thing> (Step N)]

## References

[TODO: Link to any reference files in the references/ directory. See
references/skill/anatomy.md for the full skill structure, frontmatter
reference, and all optional fields.]

## Improving This Skill

If you identify a pattern or improvement while using this skill that would
benefit other skills, propose it to the user. Do not auto-apply changes.
See `references/skill/anatomy.md` for the skill structure and improvement
guidelines.
