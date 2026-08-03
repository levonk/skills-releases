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

## References

[TODO: Link to any reference files in the references/ directory. See
references/skill/anatomy.md for the full skill structure, frontmatter
reference, and all optional fields.]

## Improving This Skill

If you identify a pattern or improvement while using this skill that would
benefit other skills, propose it to the user. Do not auto-apply changes.
See `references/skill/anatomy.md` for the skill structure and improvement
guidelines.
