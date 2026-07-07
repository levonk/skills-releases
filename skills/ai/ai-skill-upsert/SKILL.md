---
name: ai-skill-upsert
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, convert an existing workflow file into a skill (preserving git history via git mv), edit or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. Make sure to use this skill whenever the user mentions skill creation, skill development, skill testing, skill evaluation, skill benchmarking, skill optimization, workflow-to-skill conversion, or wants to package/distribute skills, even if they don't explicitly ask for a "skill creator." Do NOT trigger on general coding questions, bug fixes, feature implementation, or code review — this skill is for skill lifecycle management, not general development.
version: 2.1.0
date:
  created: "2026-05-25"
  updated: "2026-07-02"
  last-used: "2026-06-25"
tags:
  - "ai/skill"
  - "skill-creation"
  - "skill-development"
  - "skill-testing"
  - "skill-evaluation"
  - "skill-optimization"
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
---

---

{{{ include "includes/base-ai-guidance.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# Skill Creator

A skill for creating new skills and iteratively improving them through test-driven development and systematic evaluation.

## Overview

### What Skills Provide

1. **Specialized workflows** - Multi-step procedures for specific domains
2. **Tool integrations** - Instructions for working with specific file formats or APIs
3. **Domain expertise** - Company-specific knowledge, schemas, business logic
4. **Bundled resources** - Scripts, references, and assets for complex and repetitive tasks

### Skill Architecture (Three Levels)

1. **Level 1: Metadata (always loaded)** — YAML frontmatter in `SKILL.md` (`name` and `description` fields). Lightweight; included in system prompt (~100 words). See `references/anatomy.md` — Frontmatter for required fields and description guidelines.
2. **Level 2: Instructions (loaded when skill triggers)** — Main body of `SKILL.md`. Core workflow and guidance.
3. **Level 3: Bundled Resources (loaded as needed)** — `scripts/` (executable code), `references/` (documentation), `assets/` (templates and files). Unlimited size; scripts can execute without loading into context. See `references/anatomy.md` — Bundled Resources for when to include each type.

## Decision: Create vs Convert vs Update

Before starting, determine which mode applies:

1. **Check whether the target directory contains a `SKILL.md`.**
2. **If no `SKILL.md` exists:**
   - If the user has an existing workflow file (e.g., from `config/ai/workflows/`) → **Mode B: Convert Workflow to a Skill** (preserves git history).
   - Otherwise → **Mode A: Create a New Skill from Scratch**.
3. **If `SKILL.md` already exists** → **Mode C: Update an Existing Skill (Upsert)**. See `references/skill-upsert.md` for the full update workflow.

## Location Selection

Before creating a new skill (Mode A) or converting a workflow (Mode B), determine where the skill should live. Check whether the `skills-src` repository is checked out at the standard location (`~/p/gh/levonk/skills-src/`). If it exists, present three location options to the user:

1. **skills-src repo** (recommended for skills intended for distribution):
   - Public skills: `~/p/gh/levonk/skills-src/src/current/skills/<category>/<name>/`
   - Private skills: `~/p/gh/levonk/skills-src/src/private/skills/<category>/<name>/`
   - Prototype skills (local only): `~/p/gh/levonk/skills-src/src/prototype/skills/<category>/<name>/`
   - Use this when the skill should be versioned, built, and published via the skills-src pipeline.

2. **Current project** (for project-specific skills):
   - `<project-root>/.agents/skills/<category>/<name>/`
   - Use this when the skill is specific to the current project and should travel with that project's repository.

3. **User directory** (for personal skills available across all projects):
   - `~/.agents/skills/<category>/<name>/`
   - Use this when the skill is personal and should be available in every project on the user's machine.

If `skills-src` is not checked out at the standard location, default to option 2 (current project) or option 3 (user directory) based on the user's preference. The selected location becomes the `<output-directory>` passed to `init_skill.py` in Mode A step 1 and Mode B step 1.

See `references/anatomy.md` — skills-src Repository Structure for the full profile-based layout and how `src/<profile>/skills/<category>/<name>/` maps to distribution targets.

## Mode A: Create a New Skill from Scratch

1. **Initialize the skill directory**: Run `scripts/init_skill.py <skill-name> --path <output-directory>` using the location chosen above. The script creates the skill directory (including any nested parent directories like `src/current/skills/<category>/`) with proper structure, a `SKILL.md` template with frontmatter and TODO placeholders, and example resource directories (`scripts/`, `references/`, `assets/`) with example files that can be customized or deleted.
   ```bash
   # If devbox is available and you are not already in a devbox shell:
   devbox run -- python scripts/init_skill.py <skill-name> --path <output-directory>

   # If devbox is not available or you are already in a devbox shell:
   python scripts/init_skill.py <skill-name> --path <output-directory>
   ```
   **Alternative**: If you prefer to create the structure manually, see `references/anatomy.md` — Directory Structure for the required layout.

2. **Customize frontmatter**: Fill in `name`, `description`, `date` (`created`, `updated`, `last-used`), `tags`, `see-also`. The `description` is the primary triggering mechanism — include both what the skill does AND specific contexts for when to use it. Make it slightly "pushy" to combat under-triggering. Add a "Do NOT trigger on..." clause listing cases where the skill would waste effort. See `references/anatomy.md` — Frontmatter for required fields, description guidelines (including negative-trigger guards), and examples.

3. **Write the SKILL.md body as a high-level step overview**: Apply progressive disclosure — use numbered steps in SKILL.md that call scripts and link to reference files named by topic (not by step number). This makes inserting a step a one-line change instead of renumbering across many files. Each step should make it clear: call a script, then use intelligence on the output; or link to a reference file for sequential intelligence steps. See `references/progressive-disclosure.md` — Pattern 5 (Step overview with topic-named references) for the canonical pattern.

4. **Extract deterministic phases into scripts**: Identify sequences of commands that run without needing AI judgment between them. Extract each phase into a single script in `scripts/` — one script per AI→script handoff. SKILL.md should call the script by name and describe what the AI should do with the output; do not inline the script's code. See `references/anatomy.md` — Scripts for the script output contract (quiet by default, `--verbose`, `--dry-run`) and the one-handoff principle.

5. **Move heavy detail to references**: Any detail that would clutter the step overview goes into `references/<topic>.md`. See `references/progressive-disclosure.md` for patterns (high-level guide with references, domain-specific organization, variant-specific organization, conditional details, step overview) and anti-patterns to avoid (duplicating information, deeply nested references, unclear references, step-numbered filenames, monolithic SKILL.md).

6. **Add the base-ai-guidance and trigger-guard includes**: Add `{{{ include "includes/base-ai-guidance.md" . }}}` if the skill should inherit the shared framework. Add `{{{ include "includes/trigger-guard.md" . }}}` right after it so over-triggering doesn't waste effort (the guard answers without the skill, explains why, and offers a rerun on `go`).

7. **Ensure all scripts include devbox and rtk detection patterns**: All bundled scripts must include detection patterns at the top. See `references/script-execution-standards.md` for full detection code and wrapper patterns (bash and python).

8. **Review security**: Ensure no secrets, keys, or sensitive paths are exposed. See `references/security.md`.

9. **Add evals**: Create `evals/evals.json` and `evals/description_optimization.json` using the templates in `templates/`. See `references/evals-schema.md` for the eval schema and how to run evals.

10. **Package for distribution**: Run `scripts/package_skill.py` to verify structure and package the skill. See `references/anatomy.md` — What NOT to Include for files that should not be part of a skill.

## Mode B: Convert an Existing Workflow to a Skill

When the user provides an existing workflow file and wants it turned into a skill, use this path to preserve the workflow's git history while transforming it into a skill. **See `references/workflow-conversion.md` for the full process**, including the frontmatter requirement (disable auto-loading with `triggers: [user]`), the git-mv-based history preservation, and the optimization checklist.

**High-level steps:**

1. **Create the skill directory** at the target location. Use `init_skill.py` or `mkdir -p` — do NOT create `SKILL.md` yet.
2. **`git mv` the workflow file to `SKILL.md`** inside the new skill directory. This preserves the workflow's git history.
3. **Commit the rename as a standalone commit** — pure rename, no content changes.
4. **Apply skill-based optimizations as separate commits** — frontmatter, structure (progressive disclosure + step overview), script extraction, resources, includes. See `references/workflow-conversion.md` for the full optimization checklist with all sub-bullets.

**Why separate commits:** The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.

## Mode C: Update an Existing Skill (Upsert)

When the target skill directory already exists (`SKILL.md` is present), switch to update mode. The goal is to bring the existing skill into compliance with the skill guidelines without blindly overwriting the author's intent. **See `references/skill-upsert.md` for the full update workflow**, including the audit checklist, prioritized change proposal, and confirmation-before-applying discipline.

**High-level steps:**

1. **Read the existing skill fully** — `SKILL.md`, frontmatter, and all bundled resources.
2. **Audit against the skill guidelines** — frontmatter, description quality, structure, progressive disclosure, context declaration, bundled resources, includes, stale text, security. See `references/skill-upsert.md` for the full audit checklist.
3. **Propose changes — do not apply yet.** Present a prioritized list (Critical / Important / Nice to have) with before/after for each change.
4. **Ask for confirmation before applying.** Let the author accept all, a subset, or reject.
5. **Apply approved changes as separate commits** — one logical change per commit, each independently reviewable and revertable.
6. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied.

**Never silently overwrite.** The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.

## Cross-Cutting Concerns

### Script Execution Standards

All scripts created by or bundled with a skill must include devbox and rtk detection patterns. See `references/script-execution-standards.md` for full detection code and wrapper patterns (bash and python), and guidance on applying these standards when the AI agent runs bundled scripts directly.

### Progressive Disclosure

Keep SKILL.md lean; move detail to `references/` and deterministic phases to `scripts/`. See `references/progressive-disclosure.md` for patterns (high-level guide with references, domain-specific organization, variant-specific organization, conditional details, step overview with topic-named references, audience separation) and anti-patterns to avoid.

### Security

Ensure no secrets, keys, or sensitive paths are exposed in skills. See `references/security.md` for security review guidelines.

### Cross-Linking Skills

When skills reference other skills:

1. **Use see_also in frontmatter**: Document relationships
2. **Specify relationship type**: dependency, alternative, complement
3. **Explain the relationship**: Why this skill is related
4. **Avoid circular dependencies**: Skills shouldn't depend on each other

### Enhanced User Interaction

For skills that require user interaction:

1. **Clear prompts**: Ask specific, actionable questions
2. **Progressive disclosure**: Don't overwhelm with information
3. **Default behavior**: Provide sensible defaults
4. **Confirmation steps**: For destructive operations

### Skill Distribution

When packaging a skill for distribution:

1. **Verify structure**: Ensure all required files are present
2. **Test thoroughly**: Run comprehensive evals
3. **Document dependencies**: List required skills/tools/templates
4. **Create examples**: Provide usage examples
5. **Version appropriately**: Use semantic versioning
6. **License clearly**: Specify usage terms

### Audience Separation

When skills serve multiple audiences (e.g., end users vs developers), apply progressive disclosure with clearly labeled audience sections separated by horizontal rules. See `references/progressive-disclosure.md` — Pattern 5b (Audience separation) for the pattern and implementation guidance.

---
## Context Declaration

### File Paths
- Main skill: `src/current/skills/ai/ai-skill-upsert/SKILL.md` (in the `skills-src` repo at `~/p/gh/levonk/skills-src/`)
- References: `src/current/skills/ai/ai-skill-upsert/references/`
- Templates: `src/current/skills/ai/ai-skill-upsert/templates/`
- Includes: `src/current/includes/`

### External Resources
- Matt Pocock's writing-great-skills guide: https://github.com/matt-pocock/writing-great-skills

### Project Information
- Project: levonk/skills-src
- Repository: https://github.com/levonk/skills-src
- Owner: levonk
