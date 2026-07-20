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
   - **Template/Wrapper integrity**: Does the wrapper's `includeTemplate` call point at an existing content template? Does the content template exist and match the wrapper's expectations? Run `just validate` (or `just build current`) to verify the include resolves.
   - **Context declaration**: Is there a Context Declaration section at the bottom with file paths, external resources, and project info? Are paths indirect (not hardcoded user-specific paths)?
   - **Includes**: Does the wrapper include `base-workflow-guidance.md.tmpl` if it should inherit the shared framework?
   - **Stale or contradictory text**: References to deleted files, outdated workflows, rules that were superseded, paths that moved.
   - **`date.last-used`**: Is it stale? Update it to the current date if the workflow is being touched.

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

