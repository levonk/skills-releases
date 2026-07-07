# Converting an Existing Workflow to a Skill

When the user provides an existing workflow file (e.g., from `config/ai/workflows/`) and wants it turned into a skill, use this path instead of creating from scratch. The goal is to preserve the workflow's git history while transforming it into a skill.

## Table of Contents

1. [Frontmatter Requirement — Disable Auto-Loading](#frontmatter-requirement--disable-auto-loading)
2. [Process — Preserve History, Separate the Rename from Optimizations](#process--preserve-history-separate-the-rename-from-optimizations)
3. [Why Separate Commits](#why-separate-commits)

## Frontmatter Requirement — Disable Auto-Loading

Skills created from workflows must NOT be auto-loaded into the model's context. Set `triggers` to user-only so the skill is only invoked on explicit user request (e.g., `/skill-name`), never auto-triggered by the model:

```yaml
triggers:
  - user
```

The default is `[user, model]`; omitting `model` prevents the model from auto-invoking the skill. This keeps workflow-derived skills opt-in, avoiding context bloat from skills the user hasn't explicitly chosen to activate.

## Process — Preserve History, Separate the Rename from Optimizations

1. **Create the skill directory** at the target location (e.g., `config/ai/skills/<category>/<skill-name>/`). Use `init_skill.py` or `mkdir -p` — but do NOT create `SKILL.md` yet (the `git mv` in step 2 will place it).
2. **`git mv` the workflow file to `SKILL.md`** inside the new skill directory. This preserves the workflow's git history so `git log --follow SKILL.md` traces back through the original workflow.
   ```bash
   git mv <path/to/workflow.md> <skill-dir>/SKILL.md
   ```
3. **Commit the rename as a standalone commit** — pure rename, no content changes. This keeps the history-preserving move distinct from the optimizations that follow.
   ```bash
   git commit -m "Rename <workflow> to <skill-name>/SKILL.md"
   ```
4. **Apply skill-based optimizations as separate commits**, one logical change per commit, so each optimization is independently reviewable and revertable:
   - **Frontmatter**: Add/adjust `name`, `description`, `triggers: [user]`, `date`, `tags`, `see-also`. Strip workflow-only fields (`workflow`, `slug`, `use`, `role`, `inputs`, etc.) that don't apply to skills. Add a "Do NOT trigger on..." clause to the description listing cases where the skill would waste effort. Wire in the trigger-guard include (`{{{ include "includes/trigger-guard.md" . }}}`) right after the `base-ai-guidance` include.
   - **Structure**: Restructure the body for the skill format — apply progressive disclosure, audience separation, and the three-level architecture (metadata / instructions / bundled resources). Move heavy detail to `references/`. Use SKILL.md as a step overview with numbered steps that link to reference files named by topic (not by step number). This makes inserting a step a one-line change in SKILL.md instead of renumbering across many files. See `references/progressive-disclosure.md` Pattern 5 for the step-overview pattern.
   - **Script extraction**: Identify deterministic phases in the workflow — sequences of commands that run without needing AI judgment between them. Extract each such phase into a single script in `scripts/`. One script per AI→script handoff: the AI calls one script, it runs to completion, and control returns to the AI. Do not chain multiple script calls back-to-back within a single phase. If the workflow requires AI processing between two deterministic phases (e.g., AI analyzes script output, then calls another script for the next phase), those are two separate scripts. This makes the skill easier to read because each script boundary corresponds to a clear phase boundary in the workflow. SKILL.md should call the script by name and describe what the AI should do with the output — do not inline the script's code or duplicate details that can be discovered by reading or running the script. All extracted scripts must include the devbox and rtk detection patterns described in `references/script-execution-standards.md`. See `references/anatomy.md` for the script output contract (quiet by default, `--verbose`, `--dry-run`).
   - **Resources**: Add `scripts/`, `references/`, `assets/`, `evals/` as needed, deleting the example files from `init_skill.py` if unused.
   - **Includes**: Add `{{{ include "includes/base-ai-guidance.md" . }}}` if the skill should inherit the shared framework.

## Why Separate Commits

The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.
