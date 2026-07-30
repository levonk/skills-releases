# Upserting an Existing Skill

When the target skill directory already exists (i.e., `SKILL.md` is present), switch from create mode to **update mode**. The goal is to bring the existing skill into compliance with the skill guidelines without blindly overwriting the author's intent.

## Table of Contents

1. [Decision Point — Create vs. Update](#decision-point--create-vs-update)
2. [Update Mode Workflow](#update-mode-workflow)
3. [Never Silently Overwrite](#never-silently-overwrite)

## Decision Point — Create vs. Update

1. Check whether the target directory contains a `SKILL.md`.
2. If yes → update mode (this reference). If no → create mode (see SKILL.md — Mode A: Create a New Skill from Scratch, or Mode B: Convert an Existing Workflow to a Skill).

## Update Mode Workflow

1. **Read the existing skill fully** — `SKILL.md`, frontmatter, and any bundled resources (`scripts/`, `references/`, `assets/`, `evals/`). Understand what the skill currently does before proposing changes.
2. **Audit against the skill guidelines.** Check the existing skill for compliance with:
   - **Frontmatter** (see `references/skill/anatomy.md`): required `name` and `description`, `date` block (`created`, `knowledge-basis`, `last-used`), `tags`, `see-also` relationships. Flag missing or stale fields.
   - **Description quality**: Does it front-load leading words? Does it state both *what* and *when to use*? Is it "pushy" enough to avoid under-triggering? Does it have a "Do NOT trigger on..." clause to prevent over-triggering? Is the trigger-guard include wired in (`{{ include "includes/trigger-guard.md" . }}`)?
   - **Structure**: Three-level architecture (metadata / instructions / bundled resources). Should heavy detail move to `references/` or deterministic phases move to `scripts/`?
   - **Progressive disclosure** (see `references/skill/progressive-disclosure.md`): Is detail at the right level? Are audiences separated?
   - **Context declaration**: Is there a Context Declaration section at the bottom with file paths, external resources, and project info? Are paths indirect (not hardcoded user-specific paths)?
   - **Bundled resources**: Are `scripts/`, `references/`, `assets/` properly referenced from `SKILL.md`? Are there unused example files left over from `init_skill.py`? Do all scripts include devbox and rtk detection patterns?
   - **Template file organization**: Are there monolithic `references/template-*.md` files with multiple embedded variant code blocks (e.g., one file with bun/pnpm/npm/yarn, or Rust/Node/Go/Python)? If so, propose splitting each variant into its own file under a subdirectory (e.g., `references/build-docs/bun.md`, `references/build-docs/pnpm.md`). When in skills-src, propose using `{{ include }}` directives for shared headers/boilerplate across variant files. See `references/skill/anatomy.md` — Template Files and `references/skill/progressive-disclosure.md` — Anti-Patterns for the pattern.
   - **Includes**: Does the skill include `base-ai-guidance.md.tmpl` if it should inherit the shared framework?
   - **Stale or contradictory text**: References to deleted files, outdated workflows, rules that were superseded.
   - **Security** (see `references/skill/security.md`): No secrets, keys, or sensitive paths exposed.

Steps 3–9 (prioritize, propose, confirm, apply, update dates, validate,
reflect & promote) and the "never silently overwrite" and "deeper analysis"
principles follow the shared audit methodology:

---
description: Shared audit and improvement methodology for upserting/improving existing AI guidance files
---

### Audit Methodology

When updating or improving an existing AI guidance file (skill, workflow, agent,
prompt, rule, AGENTS.md), follow this process. The type-specific audit checklist
stays in each consumer's own reference file; this include covers the shared
process discipline that applies to all guidance types.

#### Step 1: Read Fully

Read the existing file completely — frontmatter, body, and any bundled resources
(`scripts/`, `references/`, `assets/`, `evals/`). Understand what the guidance
currently does before proposing any changes. Do not skip this step even if the
file looks familiar.

#### Step 2: Audit Against Guidelines

Check the existing file for compliance with the type-specific guidelines. The
audit checklist for each type lives in the consumer's own reference file — this
step is where type-specific knowledge is applied. Flag every issue found.

#### Delegating the Audit to a Subagent

Steps 2–4 (audit, prioritize, propose) are the most context-heavy part of
the update workflow — the subagent reads the full skill, checks every
checklist item, and produces the lettered findings list. This is a strong
`[fork]` candidate per the `subagent-delegation` include. When delegating:

**Front-load to the subagent** (it starts with a fresh context — it does
NOT inherit the inlined includes the orchestrator has in its SKILL.md):

- **Goal**: "Audit the skill at `<path>` against the skill guidelines and
  return a lettered findings list. Propose only — do not apply."
- **Inputs**: exact file paths — `SKILL.md`, frontmatter, `scripts/`,
  `references/`, `assets/`, `evals/`. Don't make it search for what you
  already know.
- **The audit checklist**: copy the type-specific checklist from the
  consumer's reference file (e.g. `skill-upsert.md` Step 2 for skills,
  `workflow-upsert.md` for workflows). The subagent won't have the
  reference file in context.
- **The lettered-findings format**: tell it explicitly — "Each finding
  gets a stable uppercase letter (`A)`, `B)`, `C)`, …) + one-line title +
  before/after + tier (`Critical` / `Important` / `Nice to have`). Group
  by tier first, then letter within tier." The subagent won't have
  Step 4's format spec in context.
- **Constraints**: "Propose only. Do not modify any files. Return the
  findings list in the lettered format."
- **What to return**: the lettered findings list (same shape the
  orchestrator would present to the user per Step 4).

**The orchestrator keeps** (these are orchestrator-user interactions;
the subagent never sees the user):

- **Step 5 (Confirm)**: the ack-rule (`Go` = apply all) is an
  orchestrator-user interaction. The subagent proposes; the orchestrator
  presents to the user; the user acknowledges; the orchestrator applies.
- **Step 6 (Apply)**: the orchestrator applies approved changes (or
  delegates the apply to a second subagent with the approved subset).
- **Step 9 (Reflect & Promote)**: the reflection asks "what did *I*
  have to research/do?" — the "I" is the orchestrator, who reviewed the
  subagent's work and decided to apply it. The subagent's work is an
  *input* to the reflection, not the reflection itself. Feed the
  subagent's findings into the reflection's Q1.

**Review the subagent's work** (per `subagent-delegation` — delegation is
not abdication):

1. Verify the findings list covers every checklist item (not just the
   obvious ones).
2. Check that letters are stable and unambiguous.
3. Run the smallest check that would fail if the audit is wrong — spot
   one finding against the actual file.

#### Step 3: Prioritize

Not all issues are equally important. Group findings into three tiers:

- **Critical**: Missing required frontmatter, broken references, stale text that
  misleads, anything that breaks functionality or discovery.
- **Important**: Description quality, progressive disclosure, context
  declaration, structure issues that cause token inefficiency.
- **Nice to have**: Tag cleanup, see-also relationships, unused example files,
  minor audience separation issues.

#### Step 4: Propose — Do Not Apply Yet

Present a prioritized list of specific, actionable changes. For each change,
show the before/after so the author can see exactly what will change and why.
Do not modify the file at this stage.

**Letter every finding.** Each proposed change gets a stable uppercase letter
(`A)`, `B)`, `C)`, `D)`, …) in addition to its tier label, so the author can
cherry-pick by letter in a subsequent reply (e.g. `Go A C F` or `1A, 2C, 3B`).
Reuse the option format from `clarifying-questions.md` — letter + one-line
title + before/after + tier (`Critical` / `Important` / `Nice to have`). When
the list is long, group by tier first, then letter within tier. The letters
are the contract: a subsequent reply that references letters resolves
unambiguously to these findings.

Example findings list:

```text
Critical:
  A) Add missing `date.knowledge-basis` to frontmatter
     before: (field absent)
     after:  `knowledge-basis: "2026-07-27"`

Important:
  B) Move the 200-line script-inlining block to `scripts/foo.py`
     before: <inline code in SKILL.md body>
     after:  `scripts/foo.py` + one-line call site in SKILL.md

Nice to have:
  C) Add `see-also: skill: cli-tool-upsert` (sibling relationship)
```

#### Step 5: Confirm Before Applying

Present the proposed changes and ask whether to proceed. Let the author:
- Accept all changes
- Accept a subset (cherry-pick by letter, e.g. `Go A C F` or `1A, 2C, 3B`)
- Reject entirely

**Bare acknowledgements mean "apply all".** A reply that is just `Go`, `Run`,
`Yes`, `y`, `continue`, `resume`, `proceed`, `ok`, `do it`, or any other
bare acknowledgement with no letter references is treated as **accept all
proposed changes** — the author is approving the entire findings list, not
asking the agent to pick. Apply every finding from Step 4 in this case. Only
an explicit letter subset (`Go A C F`), an explicit rejection (`No` / `Stop`
/ `Cancel`), or a custom instruction changes that default.

Do not modify the file until the author confirms. The author may have
intentionally deviated from a guideline — propose, explain the benefit, and let
them decide.

#### Step 6: Apply as Separate Commits

Apply approved changes as separate commits, one logical change per commit
(same discipline as format conversion): frontmatter fixes, structure changes,
resource cleanup, include additions — each independently reviewable and
revertable.

#### Step 7: Update Dates

Update `date.knowledge-basis` and `date.last-used` in the frontmatter when changes are
applied. Set both to the current date (YYYY-MM-DD).

#### Step 8: Validate

After applying improvements:

1. **Check for new conflicts** introduced by changes
2. **Verify all references** point to valid files/sections
3. **Test Go text/templates** render correctly (if `.tmpl` files were modified)
4. **Run `just validate`** to check for leaked delimiters and frontmatter issues
5. **Run `just build`** to confirm the build succeeds

#### Step 9: Reflect & Promote

After validation passes, run the post-task reflection pass. The full
protocol is the **Post-Task Reflection** section already inlined into
every guidance skill via `base-ai-guidance.md.tmpl` — run it now. It
asks three questions (what did I have to research/do? is any of it
generic across guidance types? does the include already exist and is
this skill written to consume it?) and produces a short **Reflection**
section appended to the audit summary. The reflection is mandatory
after every apply; if it surfaces nothing to promote, the section is a
single `Reflection: nothing to promote.` line. Do not skip the section
— its presence is the contract that the reflection ran.

This step is the post-task mirror of `research-phase.md`'s pre-task
search: research-phase asks "what already exists that I should reuse?",
Step 9 asks "what did I just do that someone else will have to redo
unless I promote it to a shared include?"

> The protocol is not re-included here. `base-ai-guidance.md.tmpl`
> already inlines `post-task-reflection.md` into every skill that
> includes it (which is every guidance skill, including every upsert
> skill that also includes this audit methodology). Re-including it
> here would duplicate the full protocol in SKILL.md for the 6 upsert
> skills that inline `audit-methodology` directly. If you are reading
> this audit methodology in a context that did NOT also include
> `base-ai-guidance`, load `references/included/...` or the published
> `post-task-reflection.md` via the three-tier resolver — but in
> practice every consumer of this include also consumes
> `base-ai-guidance`, so the protocol is already in context.

#### Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain
the benefit, and let them decide. Never blindly overwrite the author's intent.

#### Deeper Analysis

For cross-file and system-wide issues (conflicts between files, duplications
across multiple guidance files, scattered context across the AI system), use
the `ai-guidance-improver` skill, which has the full cross-file analysis
framework. Type-specific upsert skills focus on single-file compliance; the
improver handles system-wide consistency.


**Letter your findings (Step 4).** Each proposed change carries a stable
uppercase letter so the author can cherry-pick by letter in a subsequent reply
(e.g. `Go A C F`). A bare acknowledgement (`Go`, `Run`, `Yes`, `continue`,
`resume`, `proceed`, `ok`, `do it`, or any other bare acknowledgement with no
letter references) means **accept all proposed changes** — apply every finding
from Step 4. Only an explicit letter subset, an explicit rejection, or a custom
instruction overrides that default.

**Run the reflection (Step 9).** After validation passes, run the post-task
reflection pass: what did you have to research or do to fulfill this change? Is
any of it generic across guidance types? Does the include already exist, and is
this skill written to consume it? Append a short **Reflection** section to the
audit summary (or a single `Reflection: nothing to promote.` line if nothing
surfaced). The reflection is mandatory after every apply — its presence is the
contract that it ran. This is the post-task mirror of the research phase's
pre-task search. The full protocol is the **Post-Task Reflection** section
already inlined into this skill's `SKILL.md` via `base-ai-guidance.md.tmpl` —
do not re-include it here.
