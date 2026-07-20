---
name: nixify
description: Add Nix flake support to a project so it can be installed via nix run github:... or nix profile add github:.... Use when the user wants to make a project installable via Nix flakes from a remote GitHub repository, add devbox.json for reproducible development environments, or package a project for Nix profile installation. Covers forking, cloning, architecture analysis, flake template selection, documentation updates, CI setup, and PR creation.
version: 2.9.0
date:
  created: "2026-06-01"
  updated: "2026-07-16"
  last-used: "2026-07-16"
tags:
  - "nix"
  - "nixos"
  - "flake"
  - "devbox"
  - "packaging"
  - "github"
  - "software-dev"
triggers:
  - user
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
---

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



# Nixify: Add Nix Flake Support to a Project

Make a project installable with a single command:

```bash
nix run github:<owner>/<repo>
nix profile add github:<owner>/<repo>
```

**CRITICAL RULE FOR FORKS**: When working on a fork for an upstream repository, ALL code files (flake.nix, README.md, documentation) and commit/issue/PR templates MUST reference the UPSTREAM repository, NOT the fork. The fork is only for testing and development. This skill uses `$UPSTREAM_OWNER` and `$UPSTREAM_REPO` variables to enforce this.

## Prerequisites

- Nix installed with flakes enabled
- Git configured with GitHub access
- Fork permissions on the target repository (if third-party)

## Steps

1. **Check for existing flake**: Run `scripts/check-existing-flake.sh <owner> <repo>`. If flake exists, abort — inspect the existing flake to see if it needs updates instead of replacement.

2. **Detect user and repo access**: Run `scripts/detect-access.sh <owner> <repo>`. Determine fork vs direct clone. Store `UPSTREAM_OWNER`, `UPSTREAM_REPO`, `CURRENT_USER`, and `HAS_DIRECT_ACCESS` for later steps.

3. **Search for existing issues and PRs**: Run `scripts/search-existing-work.sh <owner> <repo>`. If existing work found, present links to user and ask whether to proceed. Check contribution guidelines for project-specific conventions.

4. **Check for prebuilt release tarballs**: Run `scripts/check-releases.sh <owner> <repo>`. If tarballs exist, use the fetchurl approach (see `references/flake-templates/prebuilt-tarball.md`). This is the preferred path. **MANDATORY, not preferred, when the binary resolves runtime assets beside itself** (vendored `runtime/`, `node_modules`, N-API `.node` addons, etc.) — a from-source flake is broken for that class of project even if it builds cleanly. See `references/architecture-analysis.md` — Check for Prebuilt Release Tarballs.

    **Force source-build override**: If the maintainer or a reviewer has explicitly requested a source-building flake (e.g. rejection feedback citing "maintenance liability" on a prebuilt-binary flake), set `force_source_build=true` and proceed to Step 5 regardless of whether tarballs exist. This overrides the "preferred" prebuilt path. Store `force_source_build` — it determines `flake_type` at Step 12 (forced to `source_build`), skips the hash automation workflow at Step 16, and selects the source-build PR/issue templates at Steps 24 and 27.

5. **Analyze distribution complexity**: If no prebuilt tarballs (AND the project does not ship runtime assets beside the binary — see Step 4's MANDATORY rule), analyze the project for complex multi-component distribution (runtime assets, native addons, workspace exclusions). See `references/architecture-analysis.md` for decision guidance, success/failure patterns, and build script Nix-awareness tips.

6. **Fork and clone**: Run `scripts/fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>`. Use `--dry-run` to preview. Always rebase from upstream after cloning.

7. **Detect release trigger mechanism**: Run `scripts/check-release-trigger.sh` from within the cloned repo. This inspects `.github/workflows/` for how releases are created (`secrets.GITHUB_TOKEN` vs PAT/App token) and outputs a JSON recommendation (`trigger: scheduled_lag_check` or `release_published`). **Store the `trigger` value — it determines which workflow template to use at Step 16.** This prevents the GITHUB_TOKEN trap where a `release: published` workflow silently never fires because GitHub does not start new runs from `GITHUB_TOKEN`-authored events.

8. **Validate existing tests**: Run the project's test suite to establish a baseline. Document any pre-existing failures — do not fix source code in a Nix-only PR.

9. **Set up branch and git author**: Run `scripts/setup-branch.sh`. Syncs from upstream (fetch + rebase) to start from a fresh base, then creates the `feat-nix-package-manager-install` branch and verifies git author is configured with public identity (not private info).

10. **Check nixpkgs for upstream packages**: Run `scripts/check-nixpkgs.sh <project-name> [dep1 dep2 ...]`. Decide: use upstream nixpkgs package (preferred), build from source with nixpkgs dependencies, or build everything from source. See `references/flake-templates/nixpkgs-packages.md`.

11. [fork] **Inspect existing nixpkgs derivation**: Run `scripts/inspect-nixpkgs-derivation.sh <project-name>`. If the project (or a close analog) is already packaged in nixpkgs, this fetches the full derivation source and resolved dependency lists (`buildInputs`, `nativeBuildInputs`, `propagatedBuildInputs`, `runtimeDependencies`). **Read the derivation source carefully** and catalog every dependency, patch, `postInstall`/`preInstall` hook, wrapper script (`makeWrapper` args), and special build flag. Cross-check this catalog against your planned flake.nix at Step 12 — anything in the nixpkgs derivation that your flake omits is a candidate for a "builds but doesn't work" failure. If the project itself isn't in nixpkgs but a similar project is (e.g. packaging a new browser — inspect `brave`'s derivation), run the script with the analog's name and extract the patterns that apply. See `references/architecture-analysis.md` — Inspecting Existing nixpkgs Derivations for the full checklist of what to look for. This step is the diligence check that prevents missing runtime dependencies, required patches, and postInstall setup.

12. **Generate flake.nix**: Choose the appropriate template from `references/flake-templates/` based on Step 4 results and the derivation analysis from Step 11:
    - Prebuilt tarballs (and `force_source_build` is false) -> `references/flake-templates/prebuilt-tarball.md` (preferred) — **store `flake_type=prebuilt_tarball`**. This template exposes `#prebuilt` (prebuilt binary, also `#default`), `#source` (from-source build), and `#<project-name>` (alias for `#prebuilt`). **Fill in the `sourceFor` function** using the appropriate language-specific source-build template (`source-build-rust.md`, `source-build-bun.md`, `source-build-node.md`, `source-build-go.md`, `source-build-python.md`). If the project cannot be built from source in Nix, remove the `source` outputs and document why in the PR body.
    - Binary releases (and `force_source_build` is false) -> `references/flake-templates/binary-release.md` — **store `flake_type=prebuilt_tarball`**
    - No releases, or `force_source_build=true` -> Source Build Flake by language:
      - Rust/Cargo -> `references/flake-templates/source-build-rust.md`
      - Node.js (npm/pnpm) -> `references/flake-templates/source-build-node.md`
      - Bun (`bun build --compile`) -> `references/flake-templates/source-build-bun.md`
      - Go -> `references/flake-templates/source-build-go.md`
      - Python -> `references/flake-templates/source-build-python.md`
      — **store `flake_type=source_build`**
    - Project in nixpkgs -> `references/flake-templates/nixpkgs-packages.md` — **store `flake_type=nixpkgs_wrapper`**

    **Store the `flake_type` value — it determines documentation content at Step 15, advanced features at Step 16, and PR body at Step 27.** Source Build and Prebuilt Tarball flakes have fundamentally different properties: Source Build flakes exist at every git tag (tag-pinning works), while Prebuilt Tarball flakes are bumped *after* the release tag is cut (tag-pinning does NOT work). Mixing these up produces broken install instructions.

    **MANDATORY — expose `.#<project-name>`: Every template in `references/flake-templates/` exposes the package under the project's own name (`packages.<system>.<project-name>` and `apps.<system>.<project-name>`) alongside `default`. Users naturally try `nix run .#<project-name>` / `nix build .#<project-name>` before reaching for `#default` or `#latest`; a flake that only exposes `default` is reported as "broken" by users who try the named output and get `error: flake output 'packages.<system>.<project-name>' not found`. Do not strip the named output when filling in a template. See `references/flake-templates/exposing-outputs.md`.

13. **Check for existing devbox.json (source build only by default)**: Run `scripts/check-devbox.sh <owner> <repo>`. **If `flake_type=source_build`**: create a devbox.json using the appropriate template from `references/devbox-templates.md` (Rust, Node.js, Go, Python, Darwin variants) — devbox is included in the same PR because it shares the same toolchain and is natural to review alongside the from-source flake. **If `flake_type=prebuilt_tarball`**: skip devbox entirely — do not create `devbox.json`, do not mention devbox in the issue, PR, or README. The flake wraps prebuilt binaries and has no build toolchain, so devbox is irrelevant to this PR. Only include devbox in a prebuilt tarball PR if the user explicitly asks for both; in that case, set `include_devbox=true` and use the "with devbox" PR template variant. **Store `include_devbox`** (true for source build, false for prebuilt tarball unless user explicitly asked) — it determines documentation content at Step 15 and PR/issue template selection at Steps 24 and 27.

14. **Update .gitignore**: Run `scripts/update-gitignore.sh` (pass `--with-devbox` if `include_devbox=true` from Step 13). Adds `/result` and `/result-*` symlinks to prevent committing Nix build artifacts. When `--with-devbox` is passed, also adds `.devbox/` — the entire `.devbox/` directory is generated by devbox on `devbox shell` / `devbox run` and must never be committed (it contains machine-local paths and generated scripts).

15. **Update installation documentation**: Update README and docs with Nix install instructions. **Use the `flake_type` value from Step 12** to select the correct template — `references/documentation-updates.md` has separate sections for Source Build and Prebuilt Tarball flakes. Do NOT mix: Prebuilt Tarball READMEs must not include tag-pinning (`github:.../vX.Y.Z`) for the prebuilt `#default` output — the `#source` output works at any tag since it builds from source. **Use the `include_devbox` value from Step 13** to decide whether to add the Devbox subsection — include it only when devbox is in this PR. See `references/documentation-updates.md` for insertion examples, docs-site installation pages, releasing documentation, and translated README handling.

16. **Add advanced features**: See `references/advanced-features.md`. The first two items are required; the rest are optional:
    - **GitHub Actions CI for Nix validation** — REQUIRED for all flake types: a `.github/workflows/nix.yml` that runs `nix flake check --all-systems --no-build`, `nix build .#default`, and `nix run .#default -- --version` (or the project's smoke command). Without CI, the Nix path rots silently — a flake that passes today breaks on the next nixpkgs-unstable bump and nobody notices until a user reports it. This is the gate that maintainers demand before accepting a flake PR. See `references/advanced-features.md` — GitHub Actions CI for Nix. **Path-filter the workflow to `flake.nix`, `flake.lock`, `**/*.nix`, and `.github/workflows/nix.yml`** so it only fires when Nix files change, not on every source/docs commit.
    - **Release-triggered hash automation** — REQUIRED for the Prebuilt Tarball Flake path (skip if `flake_type=source_build` or `force_source_build=true`): a GitHub Action that auto-bumps `version` and refreshes per-platform `sha256` hashes in `flake.nix`, then opens a PR. This is the deliverable that makes a repo-owned flake acceptable to maintainers who don't know Nix; without it every release needs manual hash updates and the flake rots one release after merge. **Use the `trigger` value from Step 7** to select the correct template: `scheduled_lag_check` -> Template A (daily lag-check, recommended for `GITHUB_TOKEN`-created releases); `release_published` -> Template B (`release: published`, only for PAT/App-token releases). See `references/advanced-features.md` — Release-Triggered Hash Automation. **After adding the workflow, verify it via manual `workflow_dispatch`** (see the Verification subsection) — the automation is not exercised by the PR's own CI.
    - Home-manager module for declarative configuration
    - Modular Nix structure for complex projects
    - Flake-compat shims for legacy Nix support
    - treefmt configuration for automated formatting
    - Cachix integration for binary caching (push your builds)
    - Upstream cache consumption via `nixConfig` (pull others' pre-built deps)
    - Input `follows` for nixpkgs deduplication across inputs
    - `forAllSystems` / `perSystem` pattern (eliminate `flake-utils` dependency)

17. **Sync and commit feature changes (commit 1 of 2)**: Run `scripts/sync-upstream.sh` to fetch and rebase onto the latest upstream tip — this is the safety net that catches any upstream movement during the work phase (steps 7-16). If it exits non-zero, resolve the conflicts (`git rebase --continue`) and re-run until it reports `synced: true`. Then squash iterative commits into a single clean commit using the `title:` from the PR template selected at Step 27 as the commit message. **Do NOT push yet** — the style commit (Step 20) goes on top before pushing. Never merge upstream into the feature branch — always rebase. This commit contains ONLY the nixify artifacts (flake.nix, workflows, docs, devbox.json, .gitignore) — no format or lint fixes. Keeping style fixes in a separate commit (Step 20) makes them reviewable independently; reviewers can see exactly what nixify added vs what the formatter and linter changed.

18. **Format artifacts**: Run `scripts/format-artifacts.sh` on every non-Nix file nixify created or modified — `.github/workflows/nix.yml`, any hash-automation workflow from Step 16, `.gitignore`, and README files. The script detects the project's own formatter (oxfmt, prettier, biome, deno fmt) from config files and runs it on just those files. If no formatter is found, it exits 0 silently. This prevents review feedback like "run our formatter on the file you created" — the ax upstream maintainer asked for exactly this on PR #27. Format runs **before** lint so the linter sees already-formatted files and doesn't report style issues the formatter would have caught.

19. **Lint and fix artifacts**: Run `scripts/lint-artifacts.sh --fix` on every file nixify created or modified — `flake.nix`, `.github/workflows/nix.yml`, any hash-automation workflow from Step 16, README files, and docs files. The script categorizes files by type and runs the appropriate linter with auto-fix: **markdownlint-cli2 --fix** for Markdown (`.md`/`.mdx`), **statix fix** for Nix patterns, **deadnix --edit -L** for dead Nix code (`-L` avoids breaking callPackage interfaces), and **yamllint** for YAML (check-only — yamllint has no auto-fix; fix its findings manually, only in nixify's sections). Each linter auto-discovers the project's own config (`.yamllint.yaml`, `.markdownlint.json`, `statix.toml`) and conforms to the project's standards. If a linter is not on the host PATH, the script falls back to `nix run nixpkgs#<tool>` — Nix is a prerequisite for this skill, so this always works; running inside `devbox shell` makes the tools available on the host PATH if they're listed in devbox.json. If the project has no lint configs, the linters run with their built-in defaults — nixify's templates are written to pass default lint settings.

    **Massive-change guard**: After auto-fixing, the script checks each file against `HEAD~1` (the feature commit from Step 17). Files nixify **created** (did not exist at `HEAD~1`) keep all fixes — nixify owns them. Files nixify **modified** (existed at `HEAD~1`, e.g. README where nixify added a section) are checked: if the combined format+lint-induced diff exceeds 20 lines (`--threshold`, configurable), the file is **reverted to HEAD** (all style changes discarded) and a warning is printed. The guard checks the combined diff (format from Step 18 + lint from Step 19) against the feature commit, so it catches massive changes from either the formatter or the linter. This prevents a tool from reformatting an entire file nixify only added a section to — those pre-existing style issues belong to the project, not to nixify's PR. If yamllint reports findings on a modified file, fix only the lines nixify added — do not reformat the rest of the file.

20. **Commit format and lint fixes (commit 2 of 2, conditional)**: If formatting (Step 18) or linting (Step 19) produced any changes (check `git diff --stat`), commit them as a **single separate commit** with message `style: format and lint nixify artifacts`. If the script reported yamllint findings (check-only, no auto-fix), fix them manually — only in nixify's sections for modified files — and include them in this commit. If no style changes were produced (everything was already clean), skip this step silently. Format and lint changes go in one commit because they're both style-only changes — splitting them further adds noise without value. This commit is separate from the feature commit (Step 17) so reviewers can see exactly what the tools changed without it being hidden inside the larger feature diff.

21. **Scan files for identity leaks**: Run `scripts/scan-artifacts.sh` on the files nixify created — `flake.nix`, `flake.lock`, `.gitignore`, `.github/workflows/nix.yml`, any hash-automation workflow from Step 16, README files, and devbox.json if present. The script resolves this machine's actual `$HOME`, `whoami`, and `hostname` and scans for those specific strings. If it exits non-zero, review each finding: fix HARD leaks (resolved home paths, usernames in paths, machine names) by replacing with relative or upstream-relative references; confirm REVIEW items (literal `$HOME`/`$USER` in non-shell files) are legitimate or remove them. Re-run until clean. If the user confirms the files are for private use only, pass `--private` to make HARD findings informational (non-blocking). This is the deterministic catch for the class of bug that hit the Archon PR — `.devbox/` with machine-local paths was committed and only caught by review feedback.

22. **Stage and test**: Run `scripts/validate-flake.sh <binary-name> <project-name>`. Stages flake.nix, runs `nix flake check --no-build`, `nix build`, `nix run . -- --help`, and `nix run .#<project-name> -- --help` (the runnable check that the `.#<project-name>` output from Step 12 actually exists and runs). Iterate until all pass. Build and test run **after** format and lint so the build cycle isn't wasted on files that would fail style CI — a flake that builds but fails upstream lint CI still gets rejected.

23. **Push**: Push both commits (feature + style) to the fork branch. Never merge upstream into the feature branch — always rebase.

24. **Create orientation issue (fork only)**: Generate issue content from the appropriate orientation issue template — **branch on `flake_type` (Step 12)**: `source_build` -> `references/orientation-issue-source-build.md`; `prebuilt_tarball` -> `references/orientation-issue-prebuilt-tarball.md`. Present to user for review. Record issue number for PR body. **Follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of the template file**: substitute `$UPSTREAM_OWNER`/`$UPSTREAM_REPO`/`$CURRENT_USER` by text replacement, write the body to a file, and post with `gh issue create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted and `\n` ends up literal).

25. **Update changelog (if applicable)**: If CHANGELOG.md exists, add entry under `## Unreleased` -> `### Added`. See `references/changelog-entry.md`.

26. **Validate PR cleanliness**: Verify no merge commits, no unrelated changes, clean linear history from upstream/main to HEAD. There should be exactly two commits: the feature commit (Step 17) and the style commit (Step 20, if format/lint produced changes).

27. **Generate PR description**: Use the appropriate PR template — **branch on `flake_type` (Step 12) and `include_devbox` (Step 13)**: `source_build` -> `references/pr-source-build.md` (devbox always included); `prebuilt_tarball` + `include_devbox=false` (default) -> `references/pr-prebuilt-tarball.md` (no devbox mentions); `prebuilt_tarball` + `include_devbox=true` (user explicitly asked) -> `references/pr-prebuilt-tarball-devbox.md`. Prebuilt Tarball PRs must not advertise tag-pinning for the prebuilt `#default` output (the `#source` output works at any tag since it builds from source). Present to user for review. Do NOT open PR automatically. **When you do open it, follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of the template file**: substitute the `$UPSTREAM_*`/`$CURRENT_USER`/`<issue-number>` placeholders by text replacement, write the body to a file, and post with `gh pr create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted to empty and `\n` ends up literal in the stored body).

28. **Validate posted issue and PR bodies**: After the issue (Step 24) and PR (Step 27) are created, run `scripts/validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>` for each. This is the runnable check that the Step-24/27 posting guard held — it catches the two corruption modes that have shipped broken nixify posts in the wild (literal `\n` instead of newlines, and stripped backtick code spans / unsubstituted `$UPSTREAM_*` placeholders). If it exits non-zero, the body is corrupted: re-fetch the template, fix the posting method, and `gh pr/issue edit --body-file` until the validator passes. Do not declare the skill run complete with a failing validator.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `nix run .` fails with "not tracked by Git" | `flake.nix` is untracked | `git add flake.nix` |
| `devbox run build` fails with "command not found" | Devbox not installed or not in PATH | `curl -fsSL https://get.jetify.dev/devbox \| bash` or `brew install jetify-com/devbox/devbox` |
| `devbox.json` schema validation fails | Invalid JSON or missing required fields | Verify JSON syntax and check against devbox schema |
| Darwin build fails with `apple_sdk_11_0 removed` | Deprecated `apple_sdk` reference | Remove `pkgs.darwin.apple_sdk.frameworks.Security`, keep only `pkgs.libiconv` |
| `release: published` workflow never fires | Releases created with `secrets.GITHUB_TOKEN` — GitHub does not start new runs from `GITHUB_TOKEN` events | Run `scripts/check-release-trigger.sh`; use the scheduled lag-check template (Template A) instead |
| PR/issue body is one unreadable line of `## What\n\n...` | Body was passed as a string literal with `\n` escapes via `gh --body "..."` | Rebuild from template, write to a file, repost with `gh ... edit --body-file`; see the CRITICAL guard inlined at the top of each template file in `references/` |
| PR/issue body has blank spots where `` `code` `` and `$UPSTREAM_*` should be | Body went through an unquoted heredoc or `echo "..."` — backticks command-substituted to empty, `$VARS` expanded by shell | Same fix; always use `--body-file` with a pre-substituted file |
| `validate-pr-issue.sh` exits non-zero after posting | One of the two corruption modes above | Re-fetch template, substitute placeholders by text replacement, repost with `--body-file`, re-run validator until it passes |
| `scan-artifacts.sh` exits non-zero | Generated file contains resolved `$HOME` path, username, or hostname | Replace personal references with relative or upstream-relative paths; re-run until clean. See Step 21 |
| `lint-artifacts.sh` reports yamllint findings on `.github/workflows/*.yml` | YAML formatting/style doesn't match project config (or yamllint defaults if no config) | Fix the reported issues manually (yamllint has no auto-fix). Only fix lines nixify added for modified files. If the project has `.yamllint.yaml`, conform to it; if not, yamllint's default config applies. See Step 19 |
| `lint-artifacts.sh` reports markdownlint findings on README/docs | Markdown style doesn't match project config (or markdownlint defaults) | `--fix` mode auto-fixes what it can. Unfixable findings need manual correction. If the project has `.markdownlint.json`/`.markdownlint-cli2.jsonc`, conform to it; if not, markdownlint-cli2's built-in defaults apply. See Step 19 |
| `lint-artifacts.sh` reports statix findings on `flake.nix` | Bad Nix pattern detected (e.g. `with` usage, manual `fetchurl` instead of `fetchFromGitHub`) | `--fix` mode runs `statix fix` automatically. If the project has `statix.toml`, it may disable specific rules — check it first. See Step 19 |
| `lint-artifacts.sh` reports deadnix findings on `flake.nix` | Unused `let` bindings in the flake | `--fix` mode runs `deadnix --edit -L` automatically. See Step 19 |
| `lint-artifacts.sh` GUARD reverts a modified file | Format or lint auto-fix produced >20 lines of changes on a file nixify modified (not created) | The file had pre-existing style issues the formatter or linter tried to fix. These belong to the project, not nixify's PR. The revert is correct — do not re-apply. See Step 19 |
| `lint-artifacts.sh` falls back to `nix run nixpkgs#<tool>` (slow) | Linter not on host PATH and not in devbox.json | Add the linter to devbox.json (`yamllint`, `markdownlint-cli2`, `statix`, `deadnix`) so `devbox shell` provides it, or accept the nix run fallback (works but is slower on first invocation due to store fetch) |

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/nixify/SKILL.md`
- Scripts: `config/ai/skills/software-dev/nixify/scripts/`
- References: `config/ai/skills/software-dev/nixify/references/`
- Includes: `config/ai/skills/includes/`

### External Resources
- Nix package search: https://search.nixos.org/packages
- Devbox documentation: https://www.jetify.com/devbox
- Cachix: https://cachix.org

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk
