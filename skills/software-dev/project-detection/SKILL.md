---
name: project-detection
description: "Comprehensive detection of project types, build systems, package managers, and CI/CD platforms. Use when needing to analyze a project's tech stack, detect build systems, identify CI/CD platforms, extract build targets, or understand project structure. Triggers on 'detect project type', 'analyze project', 'identify build system', 'detect CI/CD', or 'project analysis'."
version: 2.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "project-detection", "build-systems", "ci-cd", "project-analysis", "tooling", "foundational-component"]
see-also:
  - skill: project-adopter
    relationship: "dependent"
    description: "Uses project-detection for comprehensive project analysis before adoption"
  - skill: project-configuration
    relationship: "dependent"
    description: "Uses project-detection to understand existing tooling before configuration"
  - skill: surgical-config
    relationship: "complementary"
    description: "Often used together for safe configuration modifications"
  - templates: boilerplates
    relationship: "reference-source"
    description: "Provides detection patterns for standard project structures"
  - template: base-ai-guidance
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
    reason: "Required for Python-based detection scripts"
  - type: debian
    name: find
    reason: "Required for file system scanning"
  - type: debian
    name: grep
    reason: "Required for pattern matching"
  - type: nix
    name: ripgrep
    url: https://github.com/BurntSushi/ripgrep
    reason: "Required for fast pattern searching"
  - type: python
    name: json
    url: https://docs.python.org/3/library/json.html
    reason: "Required for JSON output formatting"
  - type: python
    name: yaml
    url: https://pyyaml.org/
    reason: "Required for YAML parsing and output"
  - type: url
    name: Build System Detection Patterns
    url: https://github.com/github/linguist
    reason: "Reference for file extension and pattern detection"
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



# Project Detection Skill

A reusable skill for detecting and analyzing project configurations, build systems, package managers, and CI/CD platforms. This skill serves as a foundational component for other development skills that need to understand project structure and tooling.

## Purpose

This skill provides comprehensive detection capabilities that can be used by:

- **Project Configuration Skill** - Configure projects with standard tooling (devbox, justfile, CI/CD)
- **Monorepo Extractor Skill** - Extract projects while preserving tooling and workflows
- **Project Migration Skill** - Migrate projects between different tooling stacks
- **Environment Setup Skill** - Set up development environments based on detected tooling

## Quick Start

```bash
# Detect all systems in a project
./scripts/detect-all-systems.sh /path/to/project

# Detect specific categories
./scripts/detect-build-systems.sh /path/to/project
./scripts/detect-ci-cd-systems.sh /path/to/project
./scripts/detect-workspace-configs.sh /path/to/project

# Extract build targets from existing configurations
./scripts/extract-build-targets.sh generate /path/to/project
./scripts/extract-build-targets.sh show /path/to/project

# Get detailed analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose
```

## Build Target Extraction

The skill includes **build target extraction** that reads existing configuration files (package.json, Cargo.toml, Makefile, pyproject.toml, go.mod, pom.xml, build.gradle, devbox.json) and generates justfiles with actual project targets.

For detailed extraction examples and supported configuration files, see [references/build-target-extraction.md](references/build-target-extraction.md).

## Core Detection Capabilities

The skill detects build systems, package managers, CI/CD platforms, workspace/monorepo tools, and development tools across a wide range of languages and platforms including JavaScript/TypeScript, Rust, Python, Go, Java, .NET, Ruby, PHP, Elixir, Haskell, Clojure, C/C++, Container, and Infrastructure.

For detailed lists of all supported detection capabilities, see [references/detection-capabilities.md](references/detection-capabilities.md).

## Usage Patterns

The skill can be used as a library (sourced by other skills) or as a standalone tool with JSON/human-readable output. It integrates with project-configuration, monorepo-extractor, and other skills.

For detailed usage patterns and integration examples, see [references/usage-patterns.md](references/usage-patterns.md).

## API Reference

### Detection Functions

#### `detect_systems(repo_path, verbose)`
Detect build systems and package managers.

**Parameters:**
- `repo_path`: Path to repository
- `verbose`: Show detailed output (true/false)

**Returns:** Space-separated list of detected systems

#### `detect_ci_cd_systems(repo_path, verbose)`
Detect CI/CD platforms and configurations.

**Parameters:**
- `repo_path`: Path to repository
- `verbose`: Show detailed output (true/false)

**Returns:** Space-separated list of detected CI/CD systems

#### `analyze_workspace_configs(repo_path, project_name, verbose)`
Analyze workspace configurations and monorepo structures.

**Parameters:**
- `repo_path`: Path to repository
- `project_name`: Target project name
- `verbose`: Show detailed output (true/false)

**Returns:** Analysis of workspace configurations

### Output Formats

#### Human Readable
```
✓ pnpm (via pnpm-lock.yaml)
✓ github-actions (via .github/workflows)
✓ turbo (via turbo.json)
```

#### Machine Readable (JSON)
```json
{
  "build_systems": ["pnpm", "typescript", "tailwind"],
  "ci_cd_systems": ["github-actions", "github-actions-node"],
  "workspace_configs": {
    "pnpm": {
      "file": "pnpm-workspace.yaml",
      "packages": ["apps/*", "packages/*"]
    }
  }
}
```

## Scripts

### Core Detection Scripts

- `scripts/detect-build-systems.sh` - Detect build systems and package managers
- `scripts/detect-ci-cd-systems.sh` - Detect CI/CD platforms
- `scripts/detect-workspace-configs.sh` - Detect workspace configurations

### Analysis Scripts

- `scripts/analyze-project-structure.sh` - Comprehensive project analysis
- `scripts/analyze-workspace-configs.sh` - Detailed workspace analysis
- `scripts/analyze-ci-cd-configs.sh` - CI/CD configuration analysis

### Utility Scripts

- `scripts/detect-all-systems.sh` - Run all detection scripts
- `scripts/export-detection-results.sh` - Export results in various formats
- `scripts/validate-detection.sh` - Validate detection accuracy

## Integration Guide

### For Skill Authors

#### 1. Source the Detection Functions
```bash
# At the top of your script
DETECTION_SKILL_PATH="$(dirname "${BASH_SOURCE[0]}")/../project-detection"
source "$DETECTION_SKILL_PATH/scripts/detect-build-systems.sh"
source "$DETECTION_SKILL_PATH/scripts/detect-ci-cd-systems.sh"
```

#### 2. Use Detection Results
```bash
# Detect systems
build_systems=$(detect_systems "$PROJECT_PATH" "false")
ci_cd_systems=$(detect_ci_cd_systems "$PROJECT_PATH" "false")

# Make decisions based on detection
if [[ "$build_systems" == *"pnpm"* ]]; then
    configure_pnpm_project "$PROJECT_PATH"
fi

if [[ "$ci_cd_systems" == *"github-actions"* ]]; then
    setup_github_actions "$PROJECT_PATH"
fi
```

#### 3. Handle Multiple Systems
```bash
# Handle multiple detected systems
for system in $build_systems; do
    case "$system" in
        "pnpm") configure_pnpm ;;
        "cargo") configure_cargo ;;
        "python") configure_python ;;
        *) echo "Unknown system: $system" ;;
    esac
done
```

### For Direct Usage

#### 1. Quick Detection
```bash
# Simple detection
./scripts/detect-all-systems.sh /path/to/project
```

#### 2. Detailed Analysis
```bash
# Comprehensive analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose --format json
```

#### 3. Export Results
```bash
# Export to file
./scripts/export-detection-results.sh /path/to/project --output project-analysis.json
```

## Configuration

### Detection Patterns

Detection patterns are defined in associative arrays in each script:

```bash
declare -A BUILD_SYSTEMS=(
    ["pnpm"]="pnpm-lock.yaml"
    ["npm"]="package.json"
    ["cargo"]="Cargo.toml"
    # ... more patterns
)
```

### Adding New Systems

To add support for a new system:

1. **Add to Detection Array**
```bash
["new-system"]="indicator-file-or-pattern"
```

2. **Add Validation Logic** (if applicable)
```bash
validate_new_system_targets() {
    # System-specific validation logic
}
```

3. **Update Documentation**
```bash
# Add to SKILL.md documentation
```

## Testing

### Unit Tests
```bash
# Test detection functions
./tests/test-detection-functions.sh

# Test specific systems
./tests/test-pnpm-detection.sh
./tests/test-cargo-detection.sh
```

### Integration Tests
```bash
# Test with sample projects
./tests/test-sample-projects.sh

# Test integration with other skills
./tests/test-skill-integration.sh
```

## Performance

### Optimization Strategies
- **Parallel Detection**: Run multiple detection scripts simultaneously
- **Caching**: Cache detection results for repeated analysis
- **Incremental**: Only detect changed files when possible

### Benchmarks
- **Small Project**: < 1 second
- **Medium Project**: < 5 seconds
- **Large Monorepo**: < 30 seconds

## Limitations

### Current Limitations
- **Nested Configurations**: May miss deeply nested configuration files
- **Dynamic Configurations**: Cannot detect runtime-generated configurations
- **Custom Patterns**: May miss custom build system patterns

### Future Improvements
- **Machine Learning**: Use ML to detect custom patterns
- **Plugin System**: Allow custom detection plugins
- **Remote Detection**: Detect systems in remote repositories

## Contributing

### Adding New Detection Support
1. Fork the skill repository
2. Add detection patterns to appropriate script
3. Add validation logic if needed
4. Add tests for new detection
5. Update documentation
6. Submit pull request

### Reporting Issues
- Include project structure details
- Provide expected vs actual detection results
- Include relevant configuration files

## License

This skill is part of the AI skills ecosystem and follows the same licensing terms.

## Integration with Boilerplates

The **boilerplates** directory provides reference templates that inform detection patterns and help identify standard project structures:

### Detection Pattern Sources
- **TypeScript/Next.js**: `boilerplate/apps/web/typescript/nextjs/` - Reference for detecting Next.js projects
- **Rust Packages**: `boilerplate/packages/category/web/domain/package-name/rust/` - Reference for Cargo-based projects
- **Python Packages**: `boilerplate/packages/category/web/domain/package-name/python3/` - Reference for Poetry/setuptools projects
- **Infrastructure**: `boilerplate/apps/infrastructure/` - Reference for Docker, Airflow, and other infrastructure projects

### Standard Structure Detection
The detection scripts use patterns derived from boilerplates to identify:
- **File organization**: Standard `src/`, `tests/`, `docs/` structures
- **Configuration files**: Standard naming and locations for config files
- **Build targets**: Common script names and build patterns
- **Dependency patterns**: Standard dependency management approaches

### Preference Alignment
When integrating with project-adopter or project-configuration skills:
- **Detection informs preferences**: Detected project type maps to appropriate boilerplate preferences
- **Template matching**: Match detected structure against boilerplate templates
- **Compatibility assessment**: Determine which boilerplate preferences are compatible with existing project

### Example Detection Patterns
```bash
# Patterns derived from boilerplates
declare -A PROJECT_TYPES=(
    ["nextjs-typescript"]="next.config.js package.json tsconfig.json"
    ["rust-package"]="Cargo.toml src/ tests/"
    ["python-poetry"]="pyproject.toml poetry.lock src/"
    ["docker-app"]="Dockerfile docker-compose.yml"
)
```

## Related Skills

- **Project Configuration Skill** - Configure projects with standard tooling (devbox, justfile, CI/CD)
- **Monorepo Extractor Skill** - Extract projects from monorepos
- **Environment Setup Skill** - Set up development environments based on detected tooling
- **Project Migration Skill** - Migrate between tooling stacks
- **Project Adopter Skill** - Overwrite preferences with standardized workflows
- **Project Configuration Skill** - Add compatible preferences without overwriting

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/project-detection/SKILL.md`
- Scripts: `scripts/detect-build-systems.sh`, `scripts/detect-ci-cd-systems.sh`, `scripts/detect-workspace-configs.sh`, `scripts/extract-build-targets.sh`, `scripts/analyze-project-structure.sh`, `scripts/detect-all-systems.sh`
- References: `references/build-target-extraction.md`, `references/detection-capabilities.md`, `references/usage-patterns.md`

### Related Skills
- project-adopter (dependent)
- project-configuration (dependent)
- surgical-config (complementary)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

---

*This skill serves as a foundational component for project analysis and tooling detection across the AI skills ecosystem.*
