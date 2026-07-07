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
   - **Description quality**: Does it front-load leading words? Does it state both *what* and *when to use*? Is it "pushy" enough to avoid under-triggering? Does it have a "Do NOT trigger on..." clause to prevent over-triggering? Is the trigger-guard include wired in (`{{{ include "includes/trigger-guard.md" . }}}`)?
   - **Structure**: Three-level architecture (metadata / instructions / bundled resources). Should heavy detail move to `references/` or deterministic phases move to `scripts/`?
   - **Progressive disclosure** (see `references/progressive-disclosure.md`): Is detail at the right level? Are audiences separated?
   - **Context declaration**: Is there a Context Declaration section at the bottom with file paths, external resources, and project info? Are paths indirect (not hardcoded user-specific paths)?
   - **Bundled resources**: Are `scripts/`, `references/`, `assets/` properly referenced from `SKILL.md`? Are there unused example files left over from `init_skill.py`? Do all scripts include devbox and rtk detection patterns?
   - **Includes**: Does the skill include `base-ai-guidance.md.tmpl` if it should inherit the shared framework?
   - **Stale or contradictory text**: References to deleted files, outdated workflows, rules that were superseded.
   - **Security** (see `references/security.md`): No secrets, keys, or sensitive paths exposed.
3. **For deeper analysis** (conflicts, duplications, scattered context, audience separation across multiple files), use the companion `ai-guidance-improver` skill, which has the full analysis framework. This skill focuses on single-skill compliance; the improver handles cross-file and system-wide issues.
4. **Propose changes — do not apply yet.** Present a prioritized list of specific, actionable changes:
   - **Critical**: Missing required frontmatter, broken references, stale text that misleads.
   - **Important**: Description quality, progressive disclosure, context declaration.
   - **Nice to have**: Tag cleanup, see-also relationships, unused example files.
   For each change, show the before/after so the author can see exactly what will change and why.
5. **Ask for confirmation before applying.** Present the proposed changes and ask whether to proceed. Let the author accept all, accept a subset, or reject. Do not modify the skill until the author confirms.
6. **Apply approved changes as separate commits**, one logical change per commit (same discipline as workflow conversion): frontmatter fixes, structure changes, resource cleanup, include additions — each independently reviewable and revertable.
7. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied.

## Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.
