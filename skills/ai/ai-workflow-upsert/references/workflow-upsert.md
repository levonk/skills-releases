# Upserting an Existing Workflow

When the target workflow wrapper already exists (i.e., `config/ai/workflows/<category>/<name>.md.tmpl` is present), switch from create mode to **update mode**. The goal is to bring the existing workflow into compliance with the workflow guidelines without blindly overwriting the author's intent.

## Table of Contents

1. [Decision Point — Create vs. Update](#decision-point--create-vs-update)
2. [Update Mode Workflow](#update-mode-workflow)
3. [Never Silently Overwrite](#never-silently-overwrite)

## Decision Point — Create vs. Update

1. Check whether the target wrapper file exists at `config/ai/workflows/<category>/<name>.md.tmpl`.
2. If yes → update mode (this reference). If no → create mode (see SKILL.md — Mode A: Create a New Workflow from Scratch, or Mode B: Convert a Skill to a Workflow).

## Update Mode Workflow

1. **Read the existing workflow fully** — wrapper frontmatter, content template (via the `includeTemplate` call), and any `see-also` references. Understand what the workflow currently does before proposing changes.
2. **Audit against the workflow guidelines.** Check the existing workflow for compliance with:
   - **Frontmatter** (see `references/anatomy.md`): required `workflow`, `slug`, `description`, `use`, `date` block (`created`, `updated`, `last-used`), `tags`, `see-also` relationships. Flag missing or stale fields.
   - **Description/use quality**: Does `use` state clearly when to invoke the workflow? Is `description` specific enough to distinguish from sibling workflows? Does it front-load the leading action?
   - **Step structure**: Are the phases clear (Initialize, Plan, Apply, Verify, Deliver)? Are steps in the right order? Is there unnecessary nesting or ambiguity?
   - **Template/Wrapper integrity**: Does the wrapper's `includeTemplate` call point at an existing content template? Does the content template exist and match the wrapper's expectations? Run `chezmoi execute-template` on the wrapper to verify.
   - **Context declaration**: Is there a Context Declaration section at the bottom with file paths, external resources, and project info? Are paths indirect (not hardcoded user-specific paths)?
   - **Includes**: Does the wrapper include `base-workflow-guidance.md.tmpl` if it should inherit the shared framework?
   - **Stale or contradictory text**: References to deleted files, outdated workflows, rules that were superseded, paths that moved.
   - **`date.last-used`**: Is it stale? Update it to the current date if the workflow is being touched.
3. **For deeper analysis** (conflicts, duplications, scattered context across multiple workflows), use the companion `ai-guidance-improver` skill, which has the full analysis framework. This skill focuses on single-workflow compliance; the improver handles cross-file and system-wide issues.
4. **Propose changes — do not apply yet.** Present a prioritized list of specific, actionable changes:
   - **Critical**: Missing required frontmatter, broken `includeTemplate` references, stale text that misleads.
   - **Important**: Description/use quality, step structure, context declaration.
   - **Nice to have**: Tag cleanup, see-also relationships, `date.last-used` refresh.
   For each change, show the before/after so the author can see exactly what will change and why.
5. **Ask for confirmation before applying.** Present the proposed changes and ask whether to proceed. Let the author accept all, accept a subset, or reject. Do not modify the workflow until the author confirms.
6. **Apply approved changes as separate commits**, one logical change per commit (same discipline as skill-to-workflow conversion): frontmatter fixes, step restructuring, context declaration cleanup, include additions — each independently reviewable and revertable.
7. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied.

## Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.
