# Skill Anatomy

## skills-src Repository Structure

Skills are versioned in the `skills-src` repository (standard checkout: `~/p/gh/levonk/skills-src/`). The repository uses a profile-based source layout to control which skills are built and published where:

```
skills-src/
├── src/
│   ├── current/          # Public-ready skills → builds to skills-releases
│   │   ├── skills/
│   │   │   └── <category>/<name>/SKILL.md
│   │   ├── includes/
│   │   └── templates/
│   ├── private/          # Private skills → builds to skills-private
│   │   └── skills/
│   │       └── <category>/<name>/SKILL.md
│   ├── prototype/        # Experimental skills → local build only, not published
│   │   └── skills/
│   ├── archive/          # Deprecated skills → not built, kept for reference
│   │   └── skills/
│   └── shared/           # Shared includes accessible by all profiles
│       └── includes/
└── build/                # Build output (gitignored)
```

When creating a new skill in the `skills-src` repo, place it under the appropriate profile:

| Profile | Path | Distribution Target |
|---------|------|---------------------|
| `current` | `src/current/skills/<category>/<name>/` | `skills-releases` (public, via `npx skills add`) |
| `private` | `src/private/skills/<category>/<name>/` | `skills-private` (private) |
| `prototype` | `src/prototype/skills/<category>/<name>/` | Local build only, not published |
| `archive` | `src/archive/skills/<category>/<name>/` | Not built |

Skills can also live outside the `skills-src` repo:

- **Current project**: `<project-root>/.agents/skills/<category>/<name>/`
- **User directory**: `~/.agents/skills/<category>/<name>/`

See the Location Selection section in `SKILL.md` for guidance on choosing the right location.

## Directory Structure

Every skill consists of a required `SKILL.md` file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   ├── description: (required)
│   │   └── date: (created, last-used)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/     # Executable code (Python/Bash/etc.)
    ├── references/  # Documentation intended to be loaded into context as needed
    └── assets/      # Files used in output (templates, icons, fonts, etc.)
```

## SKILL.md Structure

### Frontmatter (YAML)

Required fields:
- **name**: Skill identifier (kebab-case recommended)
- **description**: When to trigger, what it does. This is the primary triggering mechanism.
- **date**:
  - **created**: Creation date (YYYY-MM-DD)
  - **last-used**: Last usage date (YYYY-MM-DD) - update on each use

**Description guidelines**: Include both what the skill does AND specific contexts for when to use it. All "when to use" info goes here, not in the body. Make descriptions slightly "pushy" to combat under-triggering. Add a "Do NOT trigger on..." clause after the positive triggers listing cases where the skill would waste effort (factual questions, pure creation tasks, summary/processing tasks, or anything a lighter skill handles better). This prevents over-triggering and feeds the trigger-guard include's "explain why" step.

**Trigger guard include**: Every skill with a pushy description should wire in the trigger-guard include so over-triggering doesn't waste effort:
```
---
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

```
Place it right after the `base-ai-guidance` include. The guard protocol: when triggered but the question is a poor fit, answer without the skill, explain why, and offer a rerun on a one-word affirmative (`go`).

**Example**:
```yaml
---
name: docx-editor
description: Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks. Do NOT trigger on plain text files, markdown editing, or general file operations — this skill is for .docx files specifically.
date:
  created: "2026-05-25"
  last-used: "2026-05-25"
---
```

### Body (Markdown)

Instructions and guidance for using the skill and its bundled resources.

**Writing guidelines**:
- Use imperative/infinitive form
- Explain "why" things are important rather than heavy-handed MUSTs
- Make the skill general, not super-narrow to specific examples
- Use markdown tables for any structured/tabular data in SKILL.md and reference files. Markdown tables are readable by both humans and AI agents without learning a custom format. Avoid JSON blocks, TOON, or other custom notations in documentation.

## Bundled Resources

### Scripts (scripts/)

Executable code for tasks that require deterministic reliability or are repeatedly rewritten.

**When to include**:
- When the same code is being rewritten repeatedly
- When deterministic reliability is needed
- When converting a workflow, identify deterministic phases — sequences of commands that run without needing AI judgment between them

**Script extraction from workflows**:

When converting a workflow to a skill, extract deterministic phases into scripts using the **one script per AI→script handoff** principle:

- **One handoff = one script**: The AI calls one script, it runs to completion, and control returns to the AI. Do not chain multiple script calls back-to-back within a single phase.
- **AI processing between phases = separate scripts**: If the workflow requires AI analysis of script output before proceeding to the next deterministic phase, those are two separate scripts. The AI reads the output of the first script, makes a decision, then calls the second script.
- **Script boundaries = phase boundaries**: Each script boundary should correspond to a clear phase boundary in the workflow. This makes the skill easier to read because the SKILL.md body shows the AI-level decision flow, while scripts encapsulate the mechanical execution.

**Example**: When nixifying a project, `scripts/check-existing-flake.sh` checks for an existing flake (one handoff), then the AI decides whether to proceed, then `scripts/analyze-repo.sh` gathers repository metadata (second handoff). These are two scripts because the AI needs to evaluate the first result before running the second.

**Benefits**:
- Token efficient
- Deterministic
- May be executed without loading into context
- Makes SKILL.md readable by showing phase boundaries clearly

**Script output contract**:

All scripts extracted from workflows must follow a consistent output contract so the calling AI can function efficiently without reading the script source:

- **Quiet by default**: Scripts emit only the minimum output the calling AI needs to make its next decision (e.g., exit code, a single status line, or a compact JSON summary). Suppress intermediate command output, progress indicators, and verbose diagnostics unless `--verbose` is passed.
- **`--verbose` mode**: When passed, scripts emit full detail — every command run, intermediate results, diagnostic messages. This lets the AI or user understand what happened without reading the source code. Use for debugging or when the user asks for an explanation.
- **`--dry-run` mode**: When passed, scripts print what they would do without making any changes. This lets the AI preview the effect for the user before committing to an action. Dry-run output should be human-readable and show the specific operations that would be performed.

**Example**:
```bash
# Quiet (default) — AI gets just what it needs
scripts/check-existing-flake.sh owner repo
# Output: "no flake found" or "flake exists"

# Verbose — user wants to understand what happened
scripts/check-existing-flake.sh owner repo --verbose
# Output: full curl command, API response, parsed result

# Dry-run — user wants to preview before committing
scripts/fork-and-clone.sh owner repo --dry-run
# Output: "Would fork owner/repo to $USER/repo"
#         "Would clone from $FORK_URL"
#         "Would add upstream remote $UPSTREAM_URL"
```

**SKILL.md should not inline script code**: When a step calls a script, SKILL.md should state the script name, its arguments, and what the AI should do with the output. Do not paste the script's source code into SKILL.md or describe implementation details that can be discovered by reading the script or running it with `--verbose`. This avoids duplication and keeps SKILL.md focused on the decision flow.

**Devbox and RTK detection (required in all scripts):**

All scripts bundled with a skill must include detection patterns for devbox and rtk at the top of the file. This ensures scripts run in the correct environment and optimize token usage automatically.

- **Devbox**: Check if `devbox` is available and a `devbox.json` exists. If so, execute commands via `devbox run --` unless already inside a `devbox shell` (detected via `DEVBOX_SHELL` or `IN_DEVBOX_SHELL` environment variables).
- **RTK**: Check if `rtk` is available with `command -v rtk` (bash) or `shutil.which("rtk")` (python). Use `rtk <tool> <args>` instead of raw commands for any supported tool (git, eslint, prettier, npm, cargo, pytest, etc.). Fallback to the raw command if rtk is not available.

See `references/script-execution-standards.md` for full detection and wrapper patterns (bash and python).

**Note**: Scripts may still need to be read by Claude for patching or environment-specific adjustments.

### References (references/)

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

**When to include**:
- For documentation that Claude should reference while working
- For domain knowledge, schemas, policies, API specifications

**Examples**:
- `references/finance.md` for financial schemas
- `references/mnda.md` for company NDA template
- `references/policies.md` for company policies
- `references/api_docs.md` for API specifications

**Use cases**:
- Database schemas
- API documentation
- Domain knowledge
- Company policies
- Detailed workflow guides

**Benefits**:
- Keeps SKILL.md lean
- Loaded only when Claude determines it's needed
- Avoids duplication (information lives in either SKILL.md or references, not both)

**Best practices**:
- If files are large (>10k words), include grep search patterns in SKILL.md
- For files longer than 100 lines, include a table of contents at the top
- Keep references one level deep from SKILL.md (avoid deeply nested references)

### Assets (assets/)

Files not intended to be loaded into context, but rather used within the output Claude produces.

**When to include**:
- When the skill needs files that will be used in the final output

**Examples**:
- `assets/logo.png` for brand assets
- `assets/slides.pptx` for PowerPoint templates
- `assets/frontend-template/` for HTML/React boilerplate
- `assets/font.ttf` for typography

**Use cases**:
- Templates
- Images
- Icons
- Boilerplate code
- Fonts
- Sample documents that get copied or modified

**Benefits**:
- Separates output resources from documentation
- Enables Claude to use files without loading them into context

## What NOT to Include

A skill should only contain essential files that directly support its functionality. Do NOT create extraneous documentation or auxiliary files:

- ❌ `README.md`
- ❌ `INSTALLATION_GUIDE.md`
- ❌ `QUICK_REFERENCE.md`
- ❌ `CHANGELOG.md`
- ❌ etc.

These files add bloat and are not part of the skill's runtime contract.
