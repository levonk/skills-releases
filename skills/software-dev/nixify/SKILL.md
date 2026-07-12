---
name: nixify
description: Add Nix flake support to a project so it can be installed via nix run github:... or nix profile install github:.... Use when the user wants to make a project installable via Nix flakes from a remote GitHub repository, add devbox.json for reproducible development environments, or package a project for Nix profile installation. Covers forking, cloning, architecture analysis, flake template selection, documentation updates, CI setup, and PR creation.
version: 2.7.0
date:
  created: "2026-06-01"
  updated: "2026-07-06"
  last-used: "2026-07-06"
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
description: Shared CLI tool discovery — run cli-tool-discovery.sh to find and run tools through environment wrappers and standard PATH locations before giving up
---

### CLI Tool Discovery

Before concluding a CLI tool is unavailable, run `cli-tool-discovery.sh`. It
detects environment wrappers (devbox, mise, flox, direnv, nix), searches 30+
standard PATH locations, checks package managers (brew, mise, asdf), and
accounts for the project's tech stack — all in one pass. **Never give up on
the first `command -v` failure.**

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

#### When to Use

- **Always**, before reporting a tool as "not found" or "not installed"
- When a build/test/lint command fails with "command not found"
- When a skill or workflow script needs a tool that isn't on PATH
- When the user reports a tool "should be installed" but `command -v` fails

#### Anti-Patterns

- **Giving up on first `command -v` failure** — run the script instead
- **Installing a tool without asking** — always confirm before adding packages
- **Ignoring environment wrappers** — if a `devbox.json` exists, the tool is
  likely inside devbox, not on the bare shell


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
nix profile install github:<owner>/<repo>
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

4. **Check for prebuilt release tarballs**: Run `scripts/check-releases.sh <owner> <repo>`. If tarballs exist, use the fetchurl approach (see `references/flake-templates.md` — Prebuilt Tarball Flake). This is the preferred path. **MANDATORY, not preferred, when the binary resolves runtime assets beside itself** (vendored `runtime/`, `node_modules`, N-API `.node` addons, etc.) — a from-source flake is broken for that class of project even if it builds cleanly. See `references/architecture-analysis.md` — Check for Prebuilt Release Tarballs.

5. **Analyze distribution complexity**: If no prebuilt tarballs (AND the project does not ship runtime assets beside the binary — see Step 4's MANDATORY rule), analyze the project for complex multi-component distribution (runtime assets, native addons, workspace exclusions). See `references/architecture-analysis.md` for decision guidance, success/failure patterns, and build script Nix-awareness tips.

6. **Fork and clone**: Run `scripts/fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>`. Use `--dry-run` to preview. Always rebase from upstream after cloning.

7. **Detect release trigger mechanism**: Run `scripts/check-release-trigger.sh` from within the cloned repo. This inspects `.github/workflows/` for how releases are created (`secrets.GITHUB_TOKEN` vs PAT/App token) and outputs a JSON recommendation (`trigger: scheduled_lag_check` or `release_published`). **Store the `trigger` value — it determines which workflow template to use at Step 16.** This prevents the GITHUB_TOKEN trap where a `release: published` workflow silently never fires because GitHub does not start new runs from `GITHUB_TOKEN`-authored events.

8. **Validate existing tests**: Run the project's test suite to establish a baseline. Document any pre-existing failures — do not fix source code in a Nix-only PR.

9. **Set up branch and git author**: Run `scripts/setup-branch.sh`. Creates `feat-nix-package-manager-install` branch and verifies git author is configured with public identity (not private info).

10. **Check nixpkgs for upstream packages**: Run `scripts/check-nixpkgs.sh <project-name> [dep1 dep2 ...]`. Decide: use upstream nixpkgs package (preferred), build from source with nixpkgs dependencies, or build everything from source. See `references/flake-templates.md` — Using Upstream nixpkgs Packages.

11. [fork] **Inspect existing nixpkgs derivation**: Run `scripts/inspect-nixpkgs-derivation.sh <project-name>`. If the project (or a close analog) is already packaged in nixpkgs, this fetches the full derivation source and resolved dependency lists (`buildInputs`, `nativeBuildInputs`, `propagatedBuildInputs`, `runtimeDependencies`). **Read the derivation source carefully** and catalog every dependency, patch, `postInstall`/`preInstall` hook, wrapper script (`makeWrapper` args), and special build flag. Cross-check this catalog against your planned flake.nix at Step 12 — anything in the nixpkgs derivation that your flake omits is a candidate for a "builds but doesn't work" failure. If the project itself isn't in nixpkgs but a similar project is (e.g. packaging a new browser — inspect `brave`'s derivation), run the script with the analog's name and extract the patterns that apply. See `references/architecture-analysis.md` — Inspecting Existing nixpkgs Derivations for the full checklist of what to look for. This step is the diligence check that prevents missing runtime dependencies, required patches, and postInstall setup.

12. **Generate flake.nix**: Choose the appropriate template from `references/flake-templates.md` based on Step 4 results and the derivation analysis from Step 11:
    - Prebuilt tarballs -> Prebuilt Tarball Flake (preferred) — **store `flake_type=prebuilt_tarball`**
    - Binary releases -> Binary Release Flake Template — **store `flake_type=prebuilt_tarball`**
    - No releases -> Source Build Flake Template (Rust/Node/Go/Python variants) — **store `flake_type=source_build`**
    - Project in nixpkgs -> nixpkgs wrapper — **store `flake_type=nixpkgs_wrapper`**

    **Store the `flake_type` value — it determines documentation content at Step 15, advanced features at Step 16, and PR body at Step 22.** Source Build and Prebuilt Tarball flakes have fundamentally different properties: Source Build flakes exist at every git tag (tag-pinning works), while Prebuilt Tarball flakes are bumped *after* the release tag is cut (tag-pinning does NOT work). Mixing these up produces broken install instructions.

    **MANDATORY — expose `.#<project-name>`: Every template in `references/flake-templates.md` exposes the package under the project's own name (`packages.<system>.<project-name>` and `apps.<system>.<project-name>`) alongside `default`. Users naturally try `nix run .#<project-name>` / `nix build .#<project-name>` before reaching for `#default` or `#latest`; a flake that only exposes `default` is reported as "broken" by users who try the named output and get `error: flake output 'packages.<system>.<project-name>' not found`. Do not strip the named output when filling in a template. See `references/flake-templates.md` — Exposing Flake Output Variants.

13. **Check for existing devbox.json**: Run `scripts/check-devbox.sh <owner> <repo>`. If no devbox exists, create one using the appropriate template from `references/devbox-templates.md` (Rust, Node.js, Go, Python, Darwin variants).

14. **Update .gitignore**: Run `scripts/update-gitignore.sh`. Adds `/result` and `/result-*` symlinks to prevent committing Nix build artifacts.

15. **Update installation documentation**: Update README and docs with Nix and Devbox install instructions. **Use the `flake_type` value from Step 12** to select the correct template — `references/documentation-updates.md` has separate sections for Source Build and Prebuilt Tarball flakes. Do NOT mix: Prebuilt Tarball READMEs must not include tag-pinning (`github:.../vX.Y.Z`) or `#source` output examples. See `references/documentation-updates.md` for insertion examples, docs-site installation pages, releasing documentation, and translated README handling.

16. **Add advanced features**: See `references/advanced-features.md`. The first item is required for release-based repos; the rest are optional:
    - **Release-triggered hash automation** — REQUIRED for the Prebuilt Tarball Flake path: a GitHub Action that auto-bumps `version` and refreshes per-platform `sha256` hashes in `flake.nix`, then opens a PR. This is the deliverable that makes a repo-owned flake acceptable to maintainers who don't know Nix; without it every release needs manual hash updates and the flake rots one release after merge. **Use the `trigger` value from Step 7** to select the correct template: `scheduled_lag_check` -> Template A (daily lag-check, recommended for `GITHUB_TOKEN`-created releases); `release_published` -> Template B (`release: published`, only for PAT/App-token releases). See `references/advanced-features.md` — Release-Triggered Hash Automation. **After adding the workflow, verify it via manual `workflow_dispatch`** (see the Verification subsection) — the automation is not exercised by the PR's own CI.
    - Home-manager module for declarative configuration
    - Modular Nix structure for complex projects
    - Flake-compat shims for legacy Nix support
    - treefmt configuration for automated formatting
    - GitHub Actions CI for Nix validation
    - Cachix integration for binary caching (push your builds)
    - Upstream cache consumption via `nixConfig` (pull others' pre-built deps)
    - Input `follows` for nixpkgs deduplication across inputs
    - `forAllSystems` / `perSystem` pattern (eliminate `flake-utils` dependency)

17. **Stage and test**: Run `scripts/validate-flake.sh <binary-name> <project-name>`. Stages flake.nix, runs `nix flake check --no-build`, `nix build`, `nix run . -- --help`, and `nix run .#<project-name> -- --help` (the runnable check that the `.#<project-name>` output from Step 12 actually exists and runs). Iterate until all pass.

18. **Commit, rebase, and push**: Squash iterative commits into a single clean commit. Use the commit message template from `references/issue-pr-templates.md`. Pull latest upstream and rebase before pushing. Never merge upstream into the feature branch — always rebase.

19. **Create orientation issue (fork only)**: Generate issue content from `references/issue-pr-templates.md` — Orientation Issue Template. Present to user for review. Record issue number for PR body. **Follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of that file**: substitute `$UPSTREAM_OWNER`/`$UPSTREAM_REPO`/`$CURRENT_USER` by text replacement, write the body to a file, and post with `gh issue create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted and `\n` ends up literal).

20. **Update changelog (if applicable)**: If CHANGELOG.md exists, add entry under `## Unreleased` -> `### Added`. See `references/issue-pr-templates.md` — Changelog Entry.

21. **Validate PR cleanliness**: Verify no merge commits, no unrelated changes, clean linear history from upstream/main to HEAD.

22. **Generate PR description**: Use the PR template from `references/issue-pr-templates.md` — Pull Request Template. **Use the `flake_type` value from Step 12** to select the correct install examples — Prebuilt Tarball PRs must not advertise tag-pinning or `#source` output. Present to user for review. Do NOT open PR automatically. **When you do open it, follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of that file**: substitute the `$UPSTREAM_*`/`$CURRENT_USER`/`<issue-number>` placeholders by text replacement, write the body to a file, and post with `gh pr create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted to empty and `\n` ends up literal in the stored body).

23. **Validate posted issue and PR bodies**: After the issue (Step 19) and PR (Step 22) are created, run `scripts/validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>` for each. This is the runnable check that the Step-19/22 posting guard held — it catches the two corruption modes that have shipped broken nixify posts in the wild (literal `\n` instead of newlines, and stripped backtick code spans / unsubstituted `$UPSTREAM_*` placeholders). If it exits non-zero, the body is corrupted: re-fetch the template, fix the posting method, and `gh pr/issue edit --body-file` until the validator passes. Do not declare the skill run complete with a failing validator.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `nix run .` fails with "not tracked by Git" | `flake.nix` is untracked | `git add flake.nix` |
| `devbox run build` fails with "command not found" | Devbox not installed or not in PATH | `curl -fsSL https://get.jetify.dev/devbox \| bash` or `brew install jetify-com/devbox/devbox` |
| `devbox.json` schema validation fails | Invalid JSON or missing required fields | Verify JSON syntax and check against devbox schema |
| Darwin build fails with `apple_sdk_11_0 removed` | Deprecated `apple_sdk` reference | Remove `pkgs.darwin.apple_sdk.frameworks.Security`, keep only `pkgs.libiconv` |
| `release: published` workflow never fires | Releases created with `secrets.GITHUB_TOKEN` — GitHub does not start new runs from `GITHUB_TOKEN` events | Run `scripts/check-release-trigger.sh`; use the scheduled lag-check template (Template A) instead |
| PR/issue body is one unreadable line of `## What\n\n...` | Body was passed as a string literal with `\n` escapes via `gh --body "..."` | Rebuild from template, write to a file, repost with `gh ... edit --body-file`; see `references/issue-pr-templates.md` — CRITICAL section |
| PR/issue body has blank spots where `` `code` `` and `$UPSTREAM_*` should be | Body went through an unquoted heredoc or `echo "..."` — backticks command-substituted to empty, `$VARS` expanded by shell | Same fix; always use `--body-file` with a pre-substituted file |
| `validate-pr-issue.sh` exits non-zero after posting | One of the two corruption modes above | Re-fetch template, substitute placeholders by text replacement, repost with `--body-file`, re-run validator until it passes |

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
