# Converting an Existing Skill to a Workflow

When the user provides an existing skill directory and wants it turned back into a workflow, use this path instead of creating from scratch. The goal is to preserve the skill's git history while transforming it into a workflow. This is the reverse of `ai-skill-upsert`'s Mode B (Convert Workflow to a Skill).

## Table of Contents

1. [When Conversion Is Appropriate](#when-conversion-is-appropriate)
2. [Frontmatter Requirement — Switch Back to Workflow Schema](#frontmatter-requirement--switch-back-to-workflow-schema)
3. [Process — Preserve History, Separate the Rename from Optimizations](#process--preserve-history-separate-the-rename-from-optimizations)
4. [Why Separate Commits](#why-separate-commits)

## When Conversion Is Appropriate

Conversion is appropriate when the skill no longer needs the resources that workflows cannot bundle:

- **No `scripts/`** — the skill's scripts are either unused, or their functionality can be inlined as prose steps in the content template.
- **No `references/`** — the skill's reference material is small enough to live in the content template directly, or is no longer needed.
- **No `evals/`** — the skill's evals are no longer needed (workflows don't have a description-triggering surface to eval).
- **No `assets/`** — the skill has no bundled assets.

If the skill relies on any of these, conversion loses functionality. **Warn the user** and suggest keeping it as a skill instead. Conversion is irreversible in the sense that the bundled resources would need to be recreated if the workflow is later converted back to a skill.

## Frontmatter Requirement — Switch Back to Workflow Schema

Skills use `name`, `description`, `triggers`, `version` frontmatter. Workflows use `workflow`, `slug`, `description`, `use`, `role`, `date`, `tags`, `see-also`. The conversion must:

- **Add**: `workflow` (display name), `slug` (kebab-case id), `use` (when to invoke)
- **Remove**: `name`, `triggers`, `version` (skill-only fields)
- **Keep**: `description` (may need rewording — workflows use `use` for the trigger surface, `description` for the summary), `date`, `tags`, `see-also`
- **Remove includes**: `trigger-guard.md.tmpl` (skill-specific), `base-ai-guidance.md.tmpl` (skill-specific — workflows use `base-workflow-guidance.md.tmpl` instead)
- **Add include**: `base-workflow-guidance.md.tmpl` (bundles the workflow-specific framework)

## Process — Preserve History, Separate the Rename from Optimizations

1. **Verify conversion is appropriate** — check that the skill does not rely on `scripts/`, `references/`, `evals/`, or `assets/` that workflows cannot bundle. If it does, warn the user and stop.
2. **Create the wrapper location** at `config/ai/workflows/<category>/<name>.md.tmpl` — use `mkdir -p` on the parent directory, but do NOT create the file yet (the `git mv` in step 3 will place it).
3. **`git mv` the skill's `SKILL.md` to the wrapper path** (renaming to `<name>.md.tmpl`). This preserves the skill's git history so `git log --follow <name>.md.tmpl` traces back through the original skill.
   ```bash
   git mv <skill-dir>/SKILL.md <workflow-dir>/<name>.md.tmpl
   ```
4. **Commit the rename as a standalone commit** — pure rename, no content changes. This keeps the history-preserving move distinct from the optimizations that follow.
   ```bash
   git commit -m "Rename <skill-name>/SKILL.md to <name>.md.tmpl"
   ```
5. **Apply workflow-based optimizations as separate commits**, one logical change per commit, so each optimization is independently reviewable and revertable:
   - **Frontmatter**: Convert from skill schema to workflow schema — add `workflow`, `slug`, `use`; remove `name`, `triggers`, `version`; reword `description` for the workflow context. Strip skill-only includes (`trigger-guard`, `base-ai-guidance`) and add `base-workflow-guidance`.
   - **Structure**: Move body content to the content template at `config/ai/templates/<category>/<name>-template.md`. The wrapper should contain only frontmatter + a single `includeTemplate` call. Restructure the body for the linear step format (Initialize, Plan, Apply, Verify, Deliver) if it was structured as a skill's step-overview with references.
   - **Resource cleanup**: If the skill had `scripts/`, `references/`, `evals/`, `assets/` directories, decide whether to delete them (conversion loses them) or warn the user. Delete only after explicit confirmation.
   - **Includes**: Add `---
description: Base workflow guidance include that bundles workflow-specific templates on top of base AI guidance
---

---
description: Base AI guidance include that bundles common templates for all AI guidance types
---

---
description: Self-update requirement template for AI guidance files to track usage for maintenance and cleanup
---

### Self-Update Requirement

**CRITICAL**: When this guidance file is called, you MUST update the `last-used` field in this file's front-matter to the current date (YYYY-MM-DD format) before proceeding with any other work. This tracks usage for maintenance and cleanup purposes.


---

---
description: Shared CLI tool discovery — run cli-tool-discovery.sh to find and run tools through environment wrappers and standard PATH locations before giving up. Also resolves the canonical ad-hoc runner for an ecosystem (python/node/rust/go) via --runner.
---

### CLI Tool Discovery

Before concluding a CLI tool is unavailable, run `cli-tool-discovery.sh`. It
detects environment wrappers (devbox, mise, flox, direnv, nix), searches 30+
standard PATH locations, checks package managers (brew, mise, asdf), and
accounts for the project's tech stack — all in one pass. **Never give up on
the first `command -v` failure.**

For ad-hoc package execution (e.g. `uvx`, `pnpm dlx`, `cargo binstall`, `go
install`), use `--runner <ecosystem>` instead of resolving the binary and
hardcoding the invocation. The runner mode is the single source of truth for
"how do I invoke an ad-hoc command in ecosystem X?" — it pairs the binary
resolution with the canonical invocation pattern from the tech-stack table.

#### Get the script

```bash
# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time
bash scripts/cli-tool-discovery.sh <tool-name>

# Workflows, agents, and rules (no scripts/ directory): fetch from the public releases repo
curl -fsSL https://raw.githubusercontent.com/levonk/skills-releases/main/includes/cli-tool-discovery.sh -o /tmp/cli-tool-discovery.sh
bash /tmp/cli-tool-discovery.sh <tool-name>
```

#### Usage

```bash
# Resolve only — print where the tool is or how to run it
cli-tool-discovery.sh <tool-name>          # text output
cli-tool-discovery.sh <tool-name> --json   # JSON output (for scripts)

# Resolve and exec — runs the tool through the right wrapper/path, never returns
cli-tool-discovery.sh -- <tool-name> [args...]

# Resolve the ad-hoc runner for an ecosystem (JSON only)
cli-tool-discovery.sh --runner <python|node|rust|go>
```

#### Output (resolve mode)

| Output | Meaning | Action |
|--------|---------|--------|
| `FOUND: <path>` | Tool found at a specific path | Use that path directly |
| `WRAPPER: <wrapper-cmd>` | Tool is inside an environment wrapper | Run via the wrapper (e.g. `devbox run -- <tool>`) |
| `NOT_FOUND: <tool>` | Tool not found anywhere | Install it (ask user first) |

In exec mode (`--`), the script resolves the tool and replaces itself with
the tool process — stdout/stderr/exit code pass through directly. If the tool
is inside a wrapper, it execs through the wrapper. If not found, exits 127.

#### Output (runner mode)

`--runner <ecosystem>` emits JSON only:

```json
{
  "ecosystem": "python",
  "binary": "uv",
  "binary_status": "found",
  "binary_path": "/usr/local/bin/uv",
  "wrapper": "",
  "script": "uv run --script",
  "package": "uvx",
  "fallback": "pip install + python3",
  "fallback_runner": "python3",
  "recommendation": ""
}
```

| Field | Meaning |
|-------|---------|
| `binary` | The canonical binary for the ecosystem (`uv`, `pnpm`/`bun`, `cargo`, `go`) |
| `binary_status` | `found` (use `binary_path`), `wrapper` (use `wrapper`), `not_found` (use `fallback`/`recommendation`) |
| `script` | The runner for inline-metadata scripts (PEP 723). Empty for ecosystems without an equivalent. |
| `package` | The runner for ad-hoc package execution (`uvx`, `pnpm dlx`, `bunx`, `cargo binstall -y`, `go install`) |
| `fallback` | The fallback approach when the binary is not found (e.g. `pip install + python3`). Empty if no fallback exists. |
| `fallback_runner` | The command to use for the fallback. Empty if no fallback exists. |
| `recommendation` | When `binary_status` is `not_found`: either "add to devbox.json", "use fallback", or "install manually". Empty otherwise. |

Ecosystem mapping:

| Ecosystem | Binary | Script runner | Package runner | Fallback |
|-----------|--------|---------------|----------------|----------|
| `python` | `uv` | `uv run --script` | `uvx` | `pip install + python3` |
| `node` (host) | `pnpm` | — | `pnpm dlx` | none (install pnpm) |
| `node` (container) | `bun` | — | `bunx` | none |
| `rust` | `cargo` | — | `cargo binstall -y` | `cargo install` |
| `go` | `go` | — | `go install` | none |

Container detection for `node`: checks `/.dockerenv`, `$DOCKER_CONTAINER`, or
container markers in `/proc/1/cgroup`. This matches the tech-stack table's
"inside a container → bunx" rule.

The Python include (`cli-tool-discovery.py.tmpl`) provides `resolve_runner(ecosystem)`
returning the same dict shape, for use inside Python scripts that need to
discover the runner programmatically.

#### When to Use

- **Always**, before reporting a tool as "not found" or "not installed"
- When a build/test/lint command fails with "command not found"
- When a skill or workflow script needs a tool that isn't on PATH
- When the user reports a tool "should be installed" but `command -v` fails
- **For ad-hoc package execution**, use `--runner <ecosystem>` instead of
  hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install` — the
  runner mode keeps the binary resolution and the invocation pattern paired
  and consistent with the tech-stack table

#### Anti-Patterns

- **Giving up on first `command -v` failure** — run the script instead
- **Installing a tool without asking** — always confirm before adding packages
- **Ignoring environment wrappers** — if a `devbox.json` exists, the tool is
  likely inside devbox, not on the bare shell
- **Hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install`** — use
  `--runner <ecosystem>` instead so the binary and invocation stay paired
  and the policy lives in one place (the tech-stack table, mirrored by the
  runner mode)


---
description: Shared reference resolution — run scripts/resolve-reference.sh to resolve links to other skills and knowledge bundles in any deploy context
---

### Reference Resolution

When a skill or knowledge bundle needs content from another skill or knowledge
bundle, do **not** use bare relative paths like `../../knowledge/foo/overview.md`
or `../other-bundle/overview.md`. Those paths break the moment the artifact is
installed standalone via `pnpm dlx skills add`.

Instead, use the three-tier fallback resolver: `scripts/resolve-reference.sh`.
It tries three resolution strategies in order:

1. **Local relative path** — finds the target file in the source tree
   (`src/<ref>` or `<ref>`) by walking up from the current directory. Works in
   development and full-profile installs.
2. **Remote fetch** — downloads the target file from the published distribution
   repo (`levonk/skills-releases` for public content, `levonk/skills-private`
   for private content). Works for online standalone installs.
3. **Materialized copy** — reads the target file from
   `references/included/<ref>` inside the current skill/bundle. Populated at
   build time with the templater's `includeTree` function. Works for offline
   standalone installs.

#### Use in skills

For skills that reference knowledge bundles or other skills:

1. Add `scripts/resolve-reference.sh` to the skill by creating a
   `scripts/resolve-reference.sh.tmpl` file containing a single include directive
   using the project's `/` delimiters. In rendered guidance this is shown
   with `{{`/`}}` to avoid delimiter leakage:

   ```
   {{ include "includes/resolve-reference.sh" . }}
   ```

2. If the skill's workflow needs the referenced content at runtime (offline,
   no network), materialize the dependency with `includeTree`:

   ```
   {{ includeTree "knowledge/<bundle-name>/" . }}
   ```

   This copies the bundle under
   `<skill>/references/included/knowledge/<bundle-name>/` at build time. The
   resolver checks this location as tier 3.

3. Reference the dependency through the resolver:

   ```bash
   scripts/resolve-reference.sh knowledge/<bundle-name>/overview.md
   ```

#### Use in knowledge bundles

Knowledge bundles do not have a `scripts/` directory. Cross-bundle links should
be rewritten to published URLs at build time. Intra-bundle links (e.g.
`overview.md` → `mermaidjs.md`) remain relative and work in all deploy contexts.

#### Using the resolver from markdown

When authoring a skill, replace relative links with resolver calls or links to
the materialized copy. Examples:

- Old (broken after standalone install):
  `[diagram practices](knowledge/documentation-diagram-practices/overview.md)`
- With `includeTree` (recommended for runtime content):
  Add `{{ includeTree "knowledge/documentation-diagram-practices/" . }}` to
  the SKILL.md, then link to the materialized copy:
  `[diagram practices](references/included/knowledge/documentation-diagram-practices/overview.md)`
- Direct resolver call (for scripts):
  `bash scripts/resolve-reference.sh knowledge/documentation-diagram-practices/overview.md`

#### Resolver syntax

```bash
# Print content to stdout
scripts/resolve-reference.sh knowledge/foo/overview.md

# Force a specific tier (useful for testing)
scripts/resolve-reference.sh knowledge/foo/overview.md --tier 3

# Write content to a file
scripts/resolve-reference.sh knowledge/foo/overview.md --out /tmp/foo.md
```

#### When to materialize with includeTree

- The skill's workflow applies the dependency's content at runtime (e.g. the
  AUTHOR phase reads syntax conventions from the bundle).
- The dependency is small and stable.
- The user may run the skill offline.

Do **not** materialize when:

- The reference is attribution-only ("this skill is related to that bundle").
- The dependency is huge and the skill only points at it for background.
- The user is always online and the URL fallback is sufficient.

For attribution-only references, use a URL to the published repo instead:
`https://github.com/levonk/skills-releases/blob/main/knowledge/<bundle-name>/overview.md`.


---
description: Base template for creating AI guidance files (skills, workflows, agents, prompts) with shared principles and patterns
---

### AI Guidance Creation Framework

This framework provides shared principles and patterns for creating AI guidance files across all types: skills, workflows, agents, and prompts.

## Universal Creation Process

At a high level, the process of creating AI guidance goes like this:

1. **DECONSTRUCT**: Identify the domain expertise and use cases
2. **UNDERSTAND**: Gather concrete examples of usage
3. **PLAN**: Analyze examples for reusable components
4. **INITIALIZE**: Create the guidance structure
5. **DEVELOP**: Implement the guidance content
6. **TEST**: Run evals with-guidance vs baseline
7. **ITERATE**: Refine based on evaluation results
8. **PACKAGE**: Prepare for distribution

## Step 1: Capture Intent

Start by understanding the user's intent. The current conversation might already contain a workflow the user wants to capture (e.g., they say "turn this into a skill"). If so, extract answers from the conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed.

Ask these questions:
1. What should this guidance enable the AI to do?
2. When should this guidance trigger? (what user phrases/contexts)
3. What's the expected output format?
4. Should we set up test cases to verify the guidance works?

**Test case guidance**: Guidance with objectively verifiable outputs (file transforms, data extraction, code generation, fixed workflow steps) benefits from test cases. Guidance with subjective outputs (writing style, art) often doesn't need them. Suggest the appropriate default based on the guidance type, but let the user decide.

## Step 2: Interview and Research

Proactively ask about edge cases, input/output formats, example files, success criteria, and dependencies. Wait to write test prompts until you've got this part ironed out.

Check available MCPs - if useful for research (searching docs, finding similar guidance, looking up best practices), research in parallel via subagents if available.

**To avoid overwhelming users**, avoid asking too many questions in a single message. Start with the most important questions and follow up as needed for better effectiveness.

Conclude this step when there is a clear sense of the functionality the guidance should support.

## Step 3: Plan Reusable Guidance Contents

Analyze each concrete example by:
1. Considering how to execute the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

**Example**: For a pdf-editor guidance to handle "Help me rotate this PDF":
- Rotating a PDF requires re-writing the same code each time
- A `scripts/rotate_pdf.py` script would be helpful

**Example**: For a frontend-webapp-builder guidance for "Build me a todo app":
- Writing a frontend webapp requires the same boilerplate HTML/React each time
- An `assets/hello-world/` template containing the boilerplate would be helpful

**Example**: For a big-query guidance for "How many users have logged in today?":
- Querying BigQuery requires re-discovering table schemas each time
- A `references/schema.md` file documenting the table schemas would be helpful

## Step 4: Initialize the Guidance Structure

**Skip this step only if the guidance being developed already exists, and iteration or packaging is needed. In this case, continue to the next step.**

When creating new guidance from scratch, use the appropriate initialization script or template:

**For skills:**
```bash
python scripts/init_skill.py <skill-name> --path <output-directory>
```

**For workflows/agents/prompts:**
Use the appropriate template from `config/ai/templates/meta/` or create from the base frontmatter template.

The initialization creates:
- Guidance directory with proper structure
- Main file template with proper frontmatter and TODO placeholders
- Example resource directories: `scripts/`, `references/`, and `assets/`
- Example files in each directory that can be customized or deleted

Customize or remove the generated example files as needed.

### Scaffolder Script Pattern

When creating an upsert skill that scaffolds other artifacts (agents, AGENTS.md
hierarchies, workflows, prompts), use a **scaffolder script** that reads from a
**template file** in `references/` — do NOT embed template content inline in the
script. The script handles deterministic substitutions; the template holds the
structure.

**Pattern:**
1. Create a plain template file in `references/` (e.g., `agent-scaffold-template.md`)
   with placeholder markers like `<agent-name>`, `<YYYY-MM-DD>`, `<Skill Title>`
2. The scaffolder script loads the template file and performs string substitution
   on the deterministic placeholders (dates, names, slugs)
3. All other fields remain as TODO placeholders for the author to fill in
4. The script does NOT embed template content — it reads from the template file

**Why template files, not embedded templates:**
- The template is editable independently of the script
- No duplication between the script and the references directory
- The template can be reviewed and tested separately
- Changes to the template don't require changing the script

**Examples:**
- `ai-skill-upsert/scripts/init_skill.py` loads `references/skill-template.md`
- `agent-upsert/scripts/init-agent.py` loads `references/agent-scaffold-template.md`
- `agent-file-upsert/scripts/init-agents-md.py` loads `references/AGENT-project-*-template.md.tmpl`

**When a scaffolder is needed:** When there is deterministic structure to create
(directory hierarchy, multiple files with known relationships, placeholder
substitution). When the artifact is a single file with no deterministic
substitution, a template file alone (without a script) may suffice.

## Step 5: Develop the Guidance Content

### Degrees of Freedom Framework

Match the level of specificity to the task's fragility and variability:

- **High freedom** (text-based instructions): Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.
- **Medium freedom** (pseudocode or scripts with parameters): Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.
- **Low freedom** (specific scripts, few parameters): Use when operations are fragile and error-prone, consistency is critical, or a specific sequence must be followed.

Think of the AI as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Progressive Disclosure

Guidance uses a three-level loading system:

1. **Metadata** (name + description) - Always in context (~100 words)
2. **Body** - In context whenever guidance triggers (<500 lines ideal)
3. **Bundled resources** - As needed (unlimited, scripts can execute without loading)

**Key patterns:**
- Keep body under 500 lines; if approaching this limit, add hierarchy with clear pointers
- Reference files clearly from body with guidance on when to read them
- For large reference files (>300 lines), include a table of contents

### Description Writing

**Front-load leading words**: Start description with the most important trigger words. The AI reads descriptions left-to-right and matches on early words.

**One trigger per branch**: Each distinct trigger phrase should have its own branch in the description. Don't try to combine multiple triggers in one phrase.

**Add negative-trigger guards**: Pushy descriptions over-trigger. After the positive triggers, add a "Do NOT trigger on..." clause listing the cases where the skill would waste effort — factual questions with one right answer, pure creation tasks, summary/processing tasks, or anything a lighter skill handles better. This clause does two things: (1) helps the AI decide not to invoke the skill, and (2) feeds the trigger-guard include's "explain why" step when the skill is triggered anyway.

**Example good description:**
```
Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. Do NOT trigger on general coding questions, bug fixes, or feature implementation — this skill is for skill lifecycle management, not general development.
```

**Example bad description:**
```
A comprehensive skill management system for creating, editing, testing, and optimizing AI skills with various evaluation and benchmarking capabilities.
```

### Trigger Guard Include

Every skill with a "pushy" description should wire in the trigger-guard include so over-triggering doesn't waste effort:

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

Place it right after the `base-ai-guidance` include. The guard protocol: when triggered but the question is a poor fit, answer without the skill, explain why (referencing the description's "Do NOT trigger on..." clause), and offer a rerun on a one-word affirmative (`go`). The user's explicit request always overrides the guard.

### Information Hierarchy

**In-skill steps**: Step-by-step instructions that fit in the main body
**In-skill reference**: Quick reference tables or summaries
**External reference**: Detailed documentation in separate files

**When to use each:**
- In-skill steps: Core workflow that's always needed
- In-skill reference: Frequently needed information (parameter lists, error codes)
- External reference: Detailed implementation guides, troubleshooting procedures

### Context Management

**Declare context at the bottom**: All file paths, URLs, and project-specific information should be declared at the bottom of the file in a Context Declaration section. This preserves AI cache capability.

**Use indirect references**: Instead of hardcoding full paths like `/Users/micro/p/gh/levonk/dotfiles/...`, use indirect references like "the project's AGENTS.md" or "the skill's references directory".

**Never leak the user's home directory**: A guidance file must never contain an absolute home path like `/Users/johndoe/...`, `/home/johndoe/...`, or `C:\Users\johndoe\...`. These bake in the current author's username, break for every other user/machine, and leak PII. Rules, in order of preference:

1. Use an indirect reference ("the project's AGENTS.md", "the skill's references directory").
2. Use a repo-relative path (`config/ai/skills/...`).
3. Only if a home path is truly unavoidable, use `~/` (e.g. `~/.config/...`) — never the literal home directory of any specific user.

When upserting an existing skill, treat any `/Users/<name>/`, `/home/<name>/`, or `C:\Users\<name>\` occurrence as stale text and replace it with `~/` (or an indirect reference if the path is repo-internal).

**Example:**
```markdown
## Context Declaration

### File Paths
- Main guidance: `config/ai/skills/ai/ai-skill-upsert/SKILL.md`
- References: `config/ai/skills/ai/ai-skill-upsert/references/`

### External Resources
- Documentation: https://example.com/docs
```

## Step 6: Test and Iterate

### Evaluation Framework

**When to test:**
- Skills with objectively verifiable outputs (file transforms, data extraction, code generation)
- Workflows with specific success criteria
- Agents with defined capabilities

**When testing is optional:**
- Creative tasks (writing style, art)
- Advisory tasks (strategic advice, recommendations)

**Testing approach:**
1. Create baseline test cases
2. Run with guidance vs without guidance
3. Measure improvement in:
   - Accuracy (correctness of output)
   - Efficiency (time to completion)
   - Consistency (repeatability of results)
4. Iterate based on results

### Pruning Techniques

**Single source of truth**: Ensure each piece of information exists in exactly one place. Reference it rather than duplicating.

**No-op hunting**: Identify and remove instructions that don't actually change behavior. If the AI would do it anyway, remove the instruction.

**Leading words**: Ensure descriptions start with the most important trigger words for better matching.

### Failure Modes

**Premature completion**: Guidance that stops before the task is complete. Add verification steps.

**Duplication**: Same information repeated in multiple places. Consolidate to single source.

**Sediment**: Old, outdated information that's no longer relevant. Remove or update.

**Sprawl**: Guidance that grows beyond 500 lines without hierarchy. Add structure and references.

**No-op**: Instructions that don't change behavior. Remove unnecessary guidance.

## Type-Specific Considerations

### Skills
- Focus on specialized workflows and domain expertise
- Include bundled resources (scripts, references, assets)
- Use progressive disclosure for complex information
- Keep body under 500 lines

### Workflows
- Define clear phases (Initialize, Plan, Apply, Verify, Deliver)
- Specify concurrency and safety controls
- Include step-by-step execution guidance
- Document tool usage and dependencies

### Agents
- Define role and capabilities clearly
- Specify input/output schemas
- Include runtime constraints
- Document integration points

### Prompts
- Focus on specific task patterns
- Include template variables
- Document expected inputs and outputs
- Provide usage examples

## Communicating with the User

The guidance creator is used by people across a wide range of technical familiarity. Pay attention to context cues to adjust your communication:

- "evaluation" and "benchmark" are borderline but OK
- For "JSON" and "assertion", wait for cues that the user knows these terms before using them without explanation

It's OK to briefly explain terms if you're in doubt. Feel free to clarify with short definitions.


---
description: Core content principles for AI guidance files - token efficiency, progressive disclosure, quality guidelines
---

### Core Content Principles

#### Token Efficiency

The context window is a public good. AI guidance files share the context window with system prompt, conversation history, other guidance metadata, and the actual user request.

**Default assumption**: The AI is already very smart. Only add context the AI doesn't already have. Challenge each piece of information:

- "Does the AI really need this explanation?"
- "Does this paragraph justify its token cost?"

**Guidelines:**
- Prefer concise examples over verbose explanations
- Use progressive disclosure to defer detailed information
- Reference external resources instead of duplicating content
- Use indirect references (e.g., "the project's AGENTS.md") instead of full paths
- Use ~ to represent the user's home directory in paths
- Create information dense content that maximizes value per token

#### Progressive Disclosure

AI guidance uses a three-level loading system:

1. **Metadata** (always loaded) - Frontmatter name + description (~100 words)
2. **Body** (loaded when triggered) - Main instructions (<500 lines ideal)
3. **Resources** (loaded as needed) - Reference files, scripts, templates (unlimited)

**Implementation Patterns:**

**Keep body concise:**
- If approaching 500 lines, add hierarchy with clear pointers
- For large reference files (>300 lines), include a table of contents
- Move detailed examples to reference files

**Reference file structure:**
```markdown
## Detailed Reference: [Topic]

For comprehensive information on [topic], see: `references/[topic].md`

### Quick Reference
- Key point 1
- Key point 2

### When to Read Full Reference
- When you need detailed implementation guidance
- When troubleshooting complex issues
- When extending or modifying the core functionality
```

**Context declaration pattern:**
Place all file paths, URLs, and project-specific context at the bottom of the file to preserve AI cache capability:

```markdown
---
## Context Declaration

### File Paths
- Main skill: `config/ai/skills/category/skill-name/SKILL.md`
- References: `config/ai/skills/category/skill-name/references/`
- Templates: `config/ai/skills/category/skill-name/templates/`

### External Resources
- Documentation: https://example.com/docs
- API reference: https://api.example.com

### Project Information
- Project: my-project
- Repository: https://github.com/user/repo
```

#### Quality Guidelines

**Clarity over cleverness:**
- Use clear, direct language
- Avoid jargon unless necessary and explained
- Provide concrete examples

**Actionable guidance:**
- Prefer "do X" over "consider doing X"
- Include copy-paste ready commands
- Specify exact file paths when possible

**Validation and testing:**
- Define success criteria
- Include verification steps
- Specify test commands

**Error handling:**
- Document common failure modes
- Provide troubleshooting guidance
- Include recovery procedures

#### Audience Separation

When serving multiple audiences, use progressive disclosure to separate concerns:

**Example: Boilerplate repository**
```markdown
## Using Boilerplates

For deploying existing boilerplates, see: [Quick Start Guide](docs/quick-start.md)

For creating or modifying boilerplates, see: [Boilerplate Development Guide](docs/development.md)
```

**Implementation:**
- Keep common information in the main file
- Move audience-specific information to separate files
- Use clear pointers to guide each audience

#### Conflict and Duplication Prevention

**Check for conflicts:**
- Review existing guidance before creating new
- Ensure no contradictory instructions
- Validate consistency across related files

**Avoid duplication:**
- Reference existing content instead of duplicating
- Use jinja templating to share common patterns
- Create base templates for repeated structures

**General over specific:**
- Use indirect references instead of hardcoded paths
- Prefer patterns over specific solutions
- Design for flexibility when possible

#### Jinja Templating Usage

**When to use jinja:**
- Sharing common patterns across multiple files
- Reducing duplication of frontmatter or structure
- Creating variable-based content (paths, URLs, versions)

**When NOT to use jinja:**
- When content is unique to a single file
- When templating adds complexity without benefit
- When content changes frequently

**Pattern:**
```jinja2
{{ include "includes/base-frontmatter.md" . }}

{{ include "includes/base-content-principles.md" }}

## Skill-Specific Content
[Your unique content here]

---
## Context Declaration
{{ include "includes/context-declaration.md" . }}
```


---
description: Guidance for delegating work to subagents with reduced initial memory — front-load context, review results, and choose serialization vs parallelization deliberately
---

### Subagent Delegation

When the runtime supports subagents that start with a reduced (or fresh) context window, prefer delegation over doing the work in the orchestrator's context. The orchestrator's context is a scarce, shared resource; a subagent's fresh context is cheap and disposable.

#### Step Marker: `[fork]`

A workflow or skill author can tag a step with `[fork]` to signal that this step is a strong delegation candidate. The marker is a pointer, not a directive — it says "consider forking this to a subagent" without restating the full guidance below.

**When you see `[fork]` on a step:** apply the delegation protocol in this include (front-load context, review the result, choose serialization vs parallelization for any sibling `[fork]` steps).

**When authoring — mark a step with `[fork]` only if:**

- The step is self-contained (a subagent can complete it without asking back).
- The step is context-heavy (doing it in the orchestrator would burn context the orchestrator needs later).
- The step has a clear deliverable the orchestrator can review.

Do NOT mark every step. Steps needing orchestrator judgment, iterative back-and-forth, or cross-step state belong in the orchestrator — marking those `[fork]` is noise.

**Example:**

```markdown
1. Read the user's request and identify the target module.
2. `[fork]` Search the codebase for all callers of `parseConfig()` and return the file:line list.
3. Based on the caller list, decide which callers need updating.
4. `[fork]` For each caller identified in step 3, apply the signature change and run its targeted test.
```

Steps 2 and 4 are marked: both are self-contained, context-heavy, and have reviewable deliverables. Step 3 is not — it's the orchestrator's judgment call using step 2's output. Step 4 forks are parallelizable (independent callers), but each depends on step 3's decision, so they serialize after step 3.

#### When to Delegate

Delegate when the work is **self-contained** — the subagent can complete it without asking clarifying questions back. Subagents are stateless: they cannot see the orchestrator's context and cannot prompt for clarification. If a task needs iterative back-and-forth, do it in the orchestrator.

Good delegation candidates: a bounded search, a file transform with a known shape, a single function implementation, a review of a specific diff, a one-shot investigation with a defined deliverable.

#### Front-Load the Starting Context

A subagent succeeds or fails on the prompt it's given. Before dispatching, assemble a complete starting context:

- **Goal**: what the subagent should produce, in one sentence.
- **Inputs**: exact file paths, symbol names, line ranges, or URLs it should read. Don't make it search for what you already know.
- **What's already known**: findings the orchestrator has already established that the subagent would otherwise re-derive.
- **Constraints**: conventions to follow, what NOT to touch, output format expected.
- **What to return**: the specific artifact or answer shape the orchestrator needs back.

If you can't write this prompt confidently, the task isn't ready to delegate — finish scoping it in the orchestrator first.

#### Review the Subagent's Work

Delegation is not abdication. After the subagent returns:

1. **Verify the deliverable** against the goal stated in the prompt. Check it actually does what was asked, not just what was literally typed.
2. **Check the blast radius**: did it edit only what was intended? Grep callers of any function it touched.
3. **Run the smallest check that would fail if the work is wrong** — typecheck, a targeted test, or an assert-based self-check.
4. **Re-dispatch only the failing slice** if the result is partially correct. Don't re-run the whole task for one fix.

#### Serialization vs Parallelization

Choose deliberately, not by default:

- **Parallel** when tasks are independent (no shared output, no read-after-write dependency between them). Launch all in one batch and collect results as they complete. Example: reviewing three unrelated PRs, searching three unrelated code areas.
- **Serial** when one task's output is another's input, or when tasks write to the same files/state. Running them in parallel produces conflicts or wasted work. Example: implement, then test the implementation, then refactor based on test results.

When unsure, ask: "does task B need to read what task A produced?" If yes, serialize. If no, parallelize.

#### Anti-Patterns

- **Vague dispatch**: "investigate the auth flow" with no file paths. The subagent re-explores what the orchestrator already knows.
- **Delegating the decision, not the work**: asking a subagent to "decide the approach" when the orchestrator should own strategy. Delegate execution, keep judgment.
- **Parallelizing dependent tasks**: spawning implement + test simultaneously, then the test runs against code that doesn't exist yet.
- **Serializing independent tasks "to be safe"**: three independent searches run one-after-another when they could have run concurrently. Costs 3x the wall time for no safety gain.
- **Skipping review**: trusting the subagent's self-report without running a check. The subagent's "done" and the orchestrator's "correct" are different bars.



---
description: Core methodology framework for structured problem-solving with deconstruction, requirements gathering, solution design, and validation
---

## THE LEVONK METHODOLOGY

### 1. DECONSTRUCT
- Understand the objective, context, and constraints.
- Identify what is provided vs. what is missing.
- Detect blockers early (missing inputs, unsafe assumptions, unclear success criteria).

### 2. DIAGNOSE
- Choose reasoning depth (basic vs detailed) appropriate to the task.
- Decide on execution mode (read-only vs apply) within safety constraints.
- Plan tool usage intentionally and only when it reduces uncertainty.

### 3. DEVELOP
- Plan briefly, then execute in small, observable steps.
- Keep actions reversible where possible.
- Continuously cross-check progress against the objective and constraints.

### 4. DELIVER
- Present results in a clear, scannable structure.
- Call out what changed, how to verify, and any limitations or follow-ups.
- Maintain traceability to files, commands, and key decisions.

---
description: Documentation structure and layout guidelines for prompt-related files in the internal-docs directory
---

## PROMPT FILES LAYOUT

Prompt-related files live under `./internal-docs/prompts/`.

### Prompt filename pattern

Prompt files in the prompt directories follow this pattern:

```text
./internal-docs/prompts/<state>/<project-slug>-prompt-<YYYYMMDDHHMM>-<step>-<parallel>-<prompt-slug>.md
```

- `<state>`: `todo`, `processing`, `rework`, or `completed`.
- `<project-slug>`: short identifier for the project or domain (for example, `resume`, `dns-chain`).
- `<YYYYMMDDHHMM>`: timestamp when the prompt was created.
- `<step>`: zero-padded **sequential phase number** (for example, `01`, `02`).
- `<parallel>`: zero-padded **parallel prompt index** within that phase (for example, `01`, `02`).
- `<prompt-slug>`: short, kebab-cased description of the prompt (for example, `gather-job-history`).

#### Sequential vs. parallel semantics

- Prompts with the **same** `<step>` and different `<parallel>` values are **parallel-capable** within that phase.
- Prompts with **increasing** `<step>` values represent **dependent phases** that should be handled in order.

Example:

```text
./internal-docs/prompts/todo/resume-prompt-2025111423-01-01-gather-job-history.md
./internal-docs/prompts/todo/dns-chain-prompt-202511150930-02-01-configure-dnsdist.md
./internal-docs/prompts/todo/dns-chain-prompt-202511150930-02-02-configure-coredns.md
```

In this example, the two `dns-chain` prompts at step `02` can be run in parallel, but only after any step `01` prompts for that series have been completed.


---
description: Guidelines for memory behavior in AI workflows, emphasizing ephemeral sessions and explicit persistence instructions
---

## MEMORY BEHAVIOR

- Treat each workflow run as **ephemeral** by default:
  - Use information only for the current session unless explicitly asked to persist something.
- Do **not** save user content, code, or artifacts into long-term memory unless there is a clear, explicit instruction to do so.
- When persisting information:
  - Save only what is necessary (for example, finalized prompts, high-level checklists, or reference snippets).
  - Avoid storing secrets, credentials, or sensitive personal data.
- Make any intentional persistence **visible** in your summary (what was saved and where).


### Workflow Design Principles

- **Purpose & Inputs**
  - Clearly state what the workflow is for, when it should run, and what success looks like.
  - Define required vs. nice-to-have inputs; be explicit about defaults and assumptions.

- **Args and Semantics**
  - Document each argument: name, type, allowed values, and how it affects behavior.
  - Prefer a small set of powerful toggles over many overlapping flags.

- **Transform Rules**
  - Describe how raw inputs are transformed into outputs in domain terms.
  - Capture domain conventions:
    - For content: thematic vs. timeline ordering, linking rules, backlink/footnote formats.
    - For code/docs: file path conventions, idempotency, validation requirements.
  - Include "if possible" guidance:
    - Fill fields only when they can be derived reliably.
    - When data cannot be trusted or inferred, leave a clear TODO instead of guessing.

- **High-Level Algorithm**
  - Outline the main phases in 5–7 steps, such as:
    1. Parse inputs and detect scope/complexity.
    2. Gather or infer missing context (ask clarifying questions when appropriate).
    3. Structure the work (cluster topics, select patterns, or choose templates).
    4. Draft metadata/frontmatter and core body/steps.
    5. Apply domain rules and validations (links, timecodes, file paths, tests).
    6. Summarize outputs and next actions.

- **Output Overview**
  - Briefly list the expected shape of the result:
    - Metadata/frontmatter or headers (which key fields should exist).
    - Main sections or phases (e.g., Overview, Thematic Sections, Action Items).
    - Where to put references, links, or footnotes.
  - Delegate exact section names and layout to dedicated templates when possible.

- **Reuse & Templates**
  - Prefer reusing existing templates or patterns over creating one-off outputs.
  - When a new pattern is clearly reusable, consider designing a dedicated template that follows `config/ai/templates/meta/template-template.md`.

### Data Format Requirements for AI/Service Interfaces

When designing workflows, skills, agents, templates, or prompts that involve data exchange between AI agents and services, follow these format guidelines:

- **Web Interfaces**: Use HTML format for end-user facing web interfaces
- **AI Agent Interfaces**: Support standard AI agent consumption patterns:
  - Direct service API access
  - Markdown output format
  - Both API and markdown output options
- **AI-to-Service Data Exchange**:
  - **Single Records**: Use JSON format for plaintext protocol exchanges (do not use binary formats like Protocol Buffers, Apache Thrift, Captain Proto, Apache Avro for plaintext protocols)
  - **Bulk Data Transfer**: Use ToonFormat (https://toonformat.dev/) instead of JSON to minimize token usage when transferring large datasets between AI agents and services
- **Service-to-AI Data Exchange**:
  - **Single Records**: Use JSON format for plaintext protocol responses
  - **Bulk Data Transfer**: Use ToonFormat (https://toonformat.dev/) instead of JSON to minimize token usage when providing large datasets to AI agents

<!-- vim: set ft=markdown -->

` to the wrapper.

## Why Separate Commits

The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.
