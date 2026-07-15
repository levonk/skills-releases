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
   - **Frontmatter** (see `references/anatomy.md`): required `name` and `description`, `date` block (`created`, `updated`, `last-used`), `tags`, `see-also` relationships. Flag missing or stale fields.
   - **Description quality**: Does it front-load leading words? Does it state both *what* and *when to use*? Is it "pushy" enough to avoid under-triggering? Does it have a "Do NOT trigger on..." clause to prevent over-triggering? Is the trigger-guard include wired in (`---
description: Reusable trigger guard — when a skill is triggered but the question is a poor fit, answer without the skill, explain why, and offer a rerun on a one-word affirmative
---

### Trigger Guard

If this skill is triggered but the question is a poor fit for it — for example, the question matches one of the "Do NOT trigger on..." cases in this skill's description — follow this protocol:

1. **Answer the question directly.** Do not invoke this skill's process, scripts, or multi-step workflow. Provide the best answer you can without the skill.

2. **Explain briefly that the answer was provided without the skill and why.** One or two sentences. Reference the specific reason from the description's negative-trigger clause. Examples:
   - "Answered without the council because this is a factual question with one right answer — the multi-perspective process wouldn't add value."
   - "Answered without peer-review because there's only one response to review — anonymization and comparison need multiple inputs."
   - "Answered without briefingmemo because this is a fast pressure-test, not a high-stakes strategic decision needing research and governance — use think-assist instead."

3. **Offer a rerun.** Tell the user: "If you'd like to run this through the full skill process anyway, respond with `go`." Use `go` as the suggested affirmative — one word, unambiguous, fast to type.

4. **On `go`, run the skill.** If the user responds with `go` (or any clear affirmative), execute the full skill process regardless of the initial guard assessment. The user's explicit request overrides the guard.

**Why this guard exists:** Skills with "pushy" descriptions over-trigger on questions they can't add value to. The guard prevents wasted effort (running a 5-advisor council on "what's the capital of France") while respecting explicit user intent — if the user wants the heavy process run anyway, one word gets it done.
`)?
   - **Structure**: Three-level architecture (metadata / instructions / bundled resources). Should heavy detail move to `references/` or deterministic phases move to `scripts/`?
   - **Progressive disclosure** (see `references/progressive-disclosure.md`): Is detail at the right level? Are audiences separated?
   - **Context declaration**: Is there a Context Declaration section at the bottom with file paths, external resources, and project info? Are paths indirect (not hardcoded user-specific paths)?
   - **Bundled resources**: Are `scripts/`, `references/`, `assets/` properly referenced from `SKILL.md`? Are there unused example files left over from `init_skill.py`? Do all scripts include devbox and rtk detection patterns?
   - **Template file organization**: Are there monolithic `references/template-*.md` files with multiple embedded variant code blocks (e.g., one file with bun/pnpm/npm/yarn, or Rust/Node/Go/Python)? If so, propose splitting each variant into its own file under a subdirectory (e.g., `references/build-docs/bun.md`, `references/build-docs/pnpm.md`). When in skills-src, propose using `{{ include }}` directives for shared headers/boilerplate across variant files. See `references/anatomy.md` — Template Files and `references/progressive-disclosure.md` — Anti-Patterns for the pattern.
   - **Includes**: Does the skill include `base-ai-guidance.md.tmpl` if it should inherit the shared framework?
   - **Stale or contradictory text**: References to deleted files, outdated workflows, rules that were superseded.
   - **Security** (see `references/security.md`): No secrets, keys, or sensitive paths exposed.

Steps 3–8 (prioritize, propose, confirm, apply, update dates, validate) and the
"never silently overwrite" and "deeper analysis" principles follow the shared
audit methodology:

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

#### Step 5: Confirm Before Applying

Present the proposed changes and ask whether to proceed. Let the author:
- Accept all changes
- Accept a subset (cherry-pick)
- Reject entirely

Do not modify the file until the author confirms. The author may have
intentionally deviated from a guideline — propose, explain the benefit, and let
them decide.

#### Step 6: Apply as Separate Commits

Apply approved changes as separate commits, one logical change per commit
(same discipline as format conversion): frontmatter fixes, structure changes,
resource cleanup, include additions — each independently reviewable and
revertable.

#### Step 7: Update Dates

Update `date.updated` and `date.last-used` in the frontmatter when changes are
applied. Set both to the current date (YYYY-MM-DD).

#### Step 8: Validate

After applying improvements:

1. **Check for new conflicts** introduced by changes
2. **Verify all references** point to valid files/sections
3. **Test Go text/templates** render correctly (if `.tmpl` files were modified)
4. **Run `just validate`** to check for leaked delimiters and frontmatter issues
5. **Run `just build`** to confirm the build succeeds

#### Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain
the benefit, and let them decide. Never blindly overwrite the author's intent.

#### Deeper Analysis

For cross-file and system-wide issues (conflicts between files, duplications
across multiple guidance files, scattered context across the AI system), use
the `ai-guidance-improver` skill, which has the full cross-file analysis
framework. Type-specific upsert skills focus on single-file compliance; the
improver handles system-wide consistency.

