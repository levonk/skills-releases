---
name: project-comparison
description: >-
  Compare multiple software projects to determine whether they belong to the same
  category, map what parts of that category each project addresses, and produce a
  feature matrix comparing them across features, maintainability, activity, and
  meta-features (license, stars, forks, last commit, tech stack, platform support,
  setup difficulty, community). Use when the user asks to compare projects,
  evaluate alternatives, build a feature matrix, landscape analysis, benchmark
  projects, assess which projects are in the same space, determine category
  overlap, or decide between multiple tools/libraries/frameworks addressing the
  same problem. Triggers on 'compare projects', 'feature matrix', 'project
  comparison', 'landscape analysis', 'benchmark projects', 'evaluate
  alternatives', 'which projects are similar', 'category analysis', 'head to
  head', 'compare these repos', or 'project landscape'. Do NOT trigger on
  single-project analysis (use project-detection or repository-health-review),
  technology choice questions with no project list (use tech-maturity), or
  business competitive analysis (use competitive-intelligence skills).
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-07-09"
  updated: "2026-07-09"
  last-used: "2026-07-09"
tags:
  - "ai/skill"
  - "software-development"
  - "project-comparison"
  - "feature-matrix"
  - "landscape-analysis"
  - "evaluation"
  - "decision-making"
  - "alternatives"
see-also:
  - skill: project-detection
    relationship: dependency
    description: "Provides per-project tech stack, build system, and CI/CD detection"
  - skill: repository-health-review
    relationship: dependency
    description: "Provides per-project health score for the maintainability axis"
  - skill: tech-maturity
    relationship: complement
    description: "Provides per-project maturity scoring (42 capabilities, 6 dimensions) for deep maintainability assessment"
  - rule: feature-matrix
    relationship: output-format
    description: "Defines the output format for the feature matrix (icons, meta-features, table layout)"
  - template: comparison-methodology
    relationship: shared-methodology
    description: "Shared comparison methodology (category discovery, coverage mapping, matrix output) — also used by ai-skill-upsert"
  - template: base-ai-guidance
    relationship: base-framework
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: project-detection
    reason: "Required for detecting tech stack, build systems, and CI/CD per project"
  - type: skill
    name: repository-health-review
    reason: "Optional for per-project health scoring in the maintainability axis"
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
    reason: "Required for metadata-gathering scripts"
  - type: nix
    name: ripgrep
    url: https://github.com/BurntSushi/ripgrep
    reason: "Required for pattern searching in local project analysis"
  - type: url
    name: GitHub REST API
    url: https://docs.github.com/en/rest
    reason: "Required for fetching GitHub metadata (stars, forks, license, last commit)"
  - type: url
    name: GitHub CLI
    url: https://cli.github.com/
    reason: "Required for authenticated GitHub API calls via gh api"
triggers:
  - user
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


---
description: Python script standards for skills — PEP 723 inline metadata for uv, modern type hints, pathlib, error handling, and best practices for runnable skill scripts
---

### Python Script Standards

All Python scripts bundled with a skill MUST include a [PEP 723](https://peps.python.org/pep-0723/) inline script metadata header so they run via `uv run <script>.py` with no build step, no virtualenv activation, and no manual dependency installation. This makes skill scripts self-contained and portable.

**Minimal header (stdlib-only scripts):**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
```

**Header with dependencies:**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31.0",
# ]
# ///
```

The `#!/usr/bin/env -S uv run --script` shebang makes the script directly executable (`./script.py`) when `uv` is on PATH; `uv run --script script.py` works regardless. The `# /// script` block is the PEP 723 metadata that `uv` parses to provision an ephemeral environment.

**Placement:** Shebang first, then the PEP 723 block, then the module docstring, then imports.

**Best practices for skill Python scripts:**

1. **PEP 723 header required** — every `.py` file in `scripts/` starts with the shebang + metadata block above. Pin `requires-python` to `>=3.11` unless the script uses newer syntax.
2. **Declare third-party deps in the header** — never `pip install` at runtime; list them in the `dependencies` array so `uv run` resolves them automatically.
3. **Prefer the stdlib** — if a task needs no third-party package, omit the `dependencies` array. Fewer deps = faster cold start and fewer supply-chain risks.
4. **Devbox + rtk detection** — keep the existing detection wrappers (see `references/script-execution-standards.md`). The PEP 723 header is additive; it does not replace devbox/rtk patterns.
5. **Quiet by default, `--verbose` / `--dry-run`** — follow the script output contract from `references/anatomy.md`.
6. **Type hints + `if __name__ == "__main__":`** — keep the `main()` entry point so the script is importable for testing.
7. **No inline `pip install` / `subprocess` env mutation** — `uv run` handles environment provisioning; scripts should not modify their own environment.
8. **Modern type hint syntax (PEP 604/585)** — use built-in generics (`list[str]`, `dict[str, int]`) and union syntax (`X | Y`, `X | None`). Never import `List`, `Dict`, `Union`, `Optional` from `typing`. Use `type` statement (PEP 695) for aliases on Python 3.12+.
9. **`pathlib.Path` over `os.path`** — use `Path` for all filesystem paths: `Path("foo") / "bar"`, `path.exists()`, `path.read_text()`. Reserve `os` for `os.environ` and `os.path.isfile` in detection guards.
10. **Specific exceptions, no bare `except:`** — catch concrete exception types (`except FileNotFoundError`, `except json.JSONDecodeError`). Use `except Exception` only at top-level boundaries with `logging.exception()` or `sys.exit(1)`. Never swallow errors silently.
11. **f-strings for string formatting** — use f-strings (`f"{name}: {value}"`) instead of `.format()` or `%`. For logging, use `logger.info("msg %s", val)` to defer formatting until the log level is active.
12. **Import ordering** — stdlib first, then third-party, then local, with a blank line between groups. If using ruff, `I` (isort) enforces this automatically.
13. **Google-style docstrings** — module docstring (after PEP 723 block), then function/class docstrings: one-line summary, blank line, detailed description, `Args:`, `Returns:`, `Raises:` sections.
14. **`dataclass` for structured records** — use `@dataclass` (with `frozen=True` for immutability, `slots=True` for efficiency) instead of plain classes or dicts for structured data. Use `StrEnum` with `auto()` for enumerations.
15. **`Protocol` over ABC for interfaces** — define structural types with `Protocol` (PEP 544) instead of `ABC` + `abstractmethod`. Enables duck typing without inheritance coupling.

**When uv is unavailable:** `python script.py` still works for stdlib-only scripts (the PEP 723 block is a comment Python ignores). Scripts with declared dependencies require `uv run` (or a pre-provisioned venv matching the declared deps).

See `references/script-execution-standards.md` for the full devbox/rtk detection code and the combined header + detection template.


# Feature Comparison Prompt

This is a AI Prompt to trigger a feature comparison.

## Guidelines

- Be concise and direct
- Provide accurate information
- Use markdown formatting for feature matrix output
- When appropriate, suggest follow-up questions or actions

## Rules

1. Always respond as if content is for publication
5. Link to external sources when referencing companies, software, frameworks, etc.
6. Add footnotes for claims that aren't common knowledge
7. Use iconography to help compare options (🏆 best, ✅ good, ➖ neutral, ⚠️ bad, ❌ worst)

## Feature Comparison Format

When comparing features:
- Anything that has identical value & rating for all items being compared put on the bottom of the comparison table
- Items being compared should be across the top
- Link inline to the items being compared
- Be detailed with features and implementations
- Use icons for quick comparison
- Compare as many features across the selections as possible
- Recommended **MINIMUM** **software** `meta` features to include with category specific features:
  - ⭐ FOSS, ☑️ OSS, ⚠️ Free, ❌ Paid
  - UX/UI (or CLI equivalent)
  - Setup Difficulty
  - Community
  - last commit day ago (to determine activity)
  - stars
  - forks
  - Year Introduced
  - Public repository link
  - Run Modes, Server, GUI app, CLI, Android, iOS, Chrome, Firefox, Web App
  - Implementation Tech Stack
  - separate rows for software-specific features, one per line with inline links if available
  - Platform Support, which operating systems
  - Notes


---
description: Shared comparison methodology — category discovery, coverage mapping, and matrix output. Included by skills that compare multiple items (projects, skills, tools) to determine category membership, map coverage, and produce a feature matrix.
---

# Comparison Methodology

Shared methodology for comparing multiple items to determine category membership,
map what parts of a category each item addresses, and produce a feature matrix.
Included by `project-comparison` (software projects) and `ai-skill-upsert`
research phase (AI skills). Domain-specific metadata gathering, search tactics,
and meta-features stay in each skill's own reference files.

## Category Discovery (3-Tier)

Determine whether all items belong to the same category, and discover candidate
items when the user provides only a category name.

1. **Known names** — start from items the user names or that are well-known in
   the category. Read each item's description; extract category signals
   (self-description, tags, topics, "alternatives" sections).
2. **Category search** — search for additional items explicitly tagged or
   described as belonging to the category. Filter by relevance, activity, and
   significance.
3. **Adjacent categories** — look at neighboring categories that may overlap.
   Include adjacent-category items only if they meaningfully compete in the
   target category.

### Membership Verification

| Signal | Strong evidence | Weak evidence |
|---|---|---|
| Self-description | Explicitly names the category | Mentions a related keyword |
| Tags/topics | Tags include the category | Tags are related but not the category |
| Community perception | Listed in curated category lists, comparison articles | Mentioned in a tangential discussion |
| Functionality | Core functionality addresses the category's primary use case | Has a feature that overlaps with the category |

**Rule**: An item is a member if it has at least 2 strong signals, or 1 strong +
2 weak signals. Items with only weak signals are "borderline" and should be
flagged to the user.

### Handling Mismatches

When items don't all belong to the same category:

1. **Report the mismatch clearly**: Name the category each item belongs to and
   explain why they differ.
2. **Offer options**:
   - **Narrow**: Exclude non-matching items and compare only same-category ones.
   - **Broaden**: Expand the category definition to encompass all items (if
     reasonable).
   - **Cross-category comparison**: Proceed but label it as cross-category,
     noting the different categories in the matrix.
3. **Respect the user's choice**: If the user wants to compare across categories
   despite the mismatch, do so — but make the category difference visible.

## Coverage Mapping

Determine which parts of a category each item addresses. A category is defined
by a set of **dimensions** (capabilities, features, use cases). Each item covers
some dimensions fully, some partially, and lacks others.

### Defining Category Dimensions

1. **Start from the category's purpose**: What problem does this category solve?
2. **Identify core capabilities**: What capabilities are essential to deliver
   that purpose?
3. **Identify extended capabilities**: What capabilities differentiate items
   within the category?
4. **Identify integration capabilities**: How do items integrate with the
   broader ecosystem?
5. **Check existing comparisons**: Look at existing comparison articles,
   curated lists, and item documentation for dimensions others have used.

Aim for 8-15 dimensions. Too few misses meaningful distinctions; too many makes
the matrix unwieldy.

Organize dimensions into groups: **Core** (essential), **Extended**
(differentiating), **Integration** (ecosystem connections), **Operations**
(deployment/maintenance), **DX** (developer/user experience).

### 5-Level Coverage Scale

For each item × dimension, assign a coverage rating using the full 5-level
icon scale (matching the `feature-matrix` rule):

| Icon | Meaning | Criteria |
|---|---|---|
| 🏆 | Best-in-class | Standout, industry-leading implementation — the item's marquee feature |
| ✅ | Full support | First-class, well-supported feature |
| ➖ | Partial support | Supported but limited, requires plugins, or has caveats |
| ⚠️ | Problematic | Exists but broken, deprecated, actively harmful, or has serious known issues |
| ❌ | Not supported | Not addressed, or requires significant custom work |

Reserve 🏆 for true standouts (not every ✅ is a 🏆). Use ⚠️ when a feature
exists but is broken or deprecated — distinct from ➖ (works but limited) and ❌
(doesn't exist).

### Identifying Gaps and Overlaps

After mapping all items:

1. **Table-stakes dimensions**: All items have ✅. Baseline — move to bottom of
   matrix.
2. **Differentiating dimensions**: Items vary. Most interesting — keep prominent.
3. **Gap dimensions**: No item has ✅. Unmet needs — note in recommendation.
4. **Unique dimensions**: Only one item has ✅. Competitive advantage —
   highlight in recommendation.

## Matrix Output Format

The feature matrix follows the `feature-matrix` rule for icons and table
layout. Additional structural guidance:

### Table Structure

- **Items across the top** (column headers), with inline links
- **Features down the side** (row headers), grouped into sections
- **Icons in cells** for quick visual comparison
- **Identical-value rows at the bottom** (features where all items have the
  same rating)

### Meta-Features Section

The top of the table contains standard meta-features that apply to all
comparisons. Each skill defines its own meta-features appropriate to its domain
(see the skill's own reference files for the specific meta-features to include).

### Recommendation Framework

Structure recommendations **by use case, not by item**. Each bullet is a
use-case context, and names the item that fits best with a one-line reason.

**Order recommendations progressively** — either least→most demanding or
most→least demanding — and pick a direction and stick with it. This gives the
reader a natural escalation path: "start here, move up when you outgrow it."

#### Choosing Recommendation Axes

Pick 3-6 axes that represent the real decision dimensions a user faces. Common
axis families:

| Axis family | Example axes | When to use |
|---|---|---|
| **Expertise / complexity** | Beginner, intermediate, expert | Tools with steep learning curves |
| **Scale** | No scale needs, medium, high scale, enterprise | Tools where architecture affects throughput |
| **Performance** | Latency-sensitive, throughput-focused, balanced | Tools where perf characteristics differ meaningfully |
| **Rigor / compliance** | Quick-and-dirty, production-grade, regulated/audit | Tools where operational maturity matters |
| **Deployment context** | Homelab, small team, enterprise, cloud-native | Self-hosted tools, platforms, infrastructure |
| **Team composition** | Solo developer, small team, large org | Collaboration-heavy tools |
| **Ecosystem preference** | React ecosystem, Python-native, language-agnostic | Tools tied to a language or framework ecosystem |

Don't use all families — pick the 3-6 most relevant to the category being
compared.

#### Recommendation Template

```markdown
## Recommendation

*(Ordered from least to most demanding)*

- **For [use case A]**: Item X — [reason: why it fits]
- **For [use case B]**: Item Y — [reason: why it fits]
- **For [use case C]**: Item Z — [reason: why it fits]
- **Avoid**: Item W — [reason: abandoned, critical issues, or outclassed]
- **Watch**: Item V — [reason: new but promising, not production-ready yet]
```

Include **Avoid** only if an item genuinely should be avoided. Include **Watch**
only if there's an item worth tracking that isn't ready for recommendation yet.


# Project Comparison

Compare multiple software projects to determine category membership, map
category coverage, and produce a feature matrix with maintainability and
activity metrics. Orchestrates `project-detection`, `repository-health-review`,
and `tech-maturity` as per-project inputs, then synthesizes results into a
single comparison artifact.

## Quick Start

```bash
# Gather GitHub metadata for a list of repos (outputs JSON)
uv run --script scripts/gather_github_metadata.py owner1/repo1 owner2/repo2 owner3/repo3
# Or directly (uv on PATH, script is executable):
./scripts/gather_github_metadata.py owner1/repo1 owner2/repo2 owner3/repo3

# Gather local project metadata (tech stack, build system, CI/CD)
uv run --script scripts/gather_local_metadata.py /path/to/project-a /path/to/project-b

# Both scripts support --verbose for full detail and --dry-run for preview
```

After gathering metadata, follow the workflow below to classify, assess, and
emit the feature matrix.

## When to Use

| Situation | Use this skill? |
|---|---|
| Compare 2+ projects to see if they're in the same category | Yes — canonical case |
| Build a feature matrix across multiple projects | Yes — canonical case |
| Landscape analysis: map what slice of a category each project covers | Yes — canonical case |
| Benchmark alternatives before choosing one | Yes |
| Evaluate project maintainability across alternatives | Yes |
| Single project analysis | No — use `project-detection` or `repository-health-review` |
| Technology choice with no project list | No — use `tech-maturity` |
| Business competitive analysis (companies, markets) | No — use competitive-intelligence skills |

## Workflow

### Step 1 — Gather the Project List

Collect the projects to compare from the user. Accept:
- GitHub repos (`owner/repo` shorthand or full URLs)
- Local paths (`/path/to/project`)
- Git URLs (`https://github.com/owner/repo.git`)
- Mixed lists

If the user provides a category name but no projects, discover candidates
using the 3-tier search in `references/category-discovery.md` (known names →
category search → adjacent categories).

### Step 2 — Gather Metadata

Run the appropriate metadata-gathering script per project type:

1. **GitHub repos**: Run `scripts/gather_github_metadata.py` with the list of
   `owner/repo` identifiers. The script fetches stars, forks, watchers, license,
   primary language, topics, created date, last push, open issues, archived
   status, and description via `gh api`. Output is JSON to stdout.

2. **Local paths**: Run `scripts/gather_local_metadata.py` with the list of
   paths. The script invokes `project-detection` detection scripts to extract
   build systems, package managers, CI/CD platforms, and tech stack. Output is
   JSON to stdout.

3. **Review the output**: Check for failed lookups (private repos, deleted
   repos, invalid paths). Report failures to the user and ask whether to
   exclude them or provide alternatives.

### Step 3 — Classify into Category

Determine whether all projects belong to the same category. See
`references/category-discovery.md` for the full 3-tier classification process.

1. **Identify the category** from project descriptions, topics, READMEs, and
   known positioning. Name the category explicitly (e.g., "static site
   generators", "AI coding agents", "key-value stores").
2. **Check membership**: For each project, confirm it belongs to the category.
   Flag any that don't fit and explain why.
3. **Identify sub-categories**: If projects span different sub-categories
   within the same space, note the sub-category each belongs to.
4. **Surface mismatches**: If projects are NOT in the same category, tell the
   user clearly. Offer to (a) narrow the comparison to same-category projects,
   (b) broaden the category definition, or (c) compare across categories as
   alternatives.

### Step 4 — Map Category Coverage

For each project, determine which parts of the category it addresses. See
`references/coverage-mapping.md` for the coverage-mapping process.

1. **Define category dimensions**: Identify the key capabilities/axes that
   define the category (e.g., for static site generators: templating, asset
   pipeline, content management, deployment, plugins, themes).
2. **Map each project's coverage**: For each dimension, note which projects
   support it, partially support it, or lack it. Use the full 5-level scale:
   🏆 (best-in-class) / ✅ (full) / ➖ (partial) / ⚠️ (problematic) / ❌ (missing).
3. **Identify gaps and overlaps**: Note which dimensions are uncovered by any
   project, and which are covered by all (table-stakes dimensions).

### Step 5 — Compare Architecture

Compare how the projects work at a high level — their architectural approach,
data flow, and component structure. See `references/architectural-comparison.md`
for the comparison process and mermaid diagram patterns.

1. **Identify architectural patterns**: For each project, determine its
   high-level architecture (e.g., plugin-based, monolithic, microservices,
   event-driven, pipeline, server-client).
2. **Compare approaches**: Are the projects architecturally similar or
   fundamentally different? If similar, state so briefly — don't manufacture
   differences where none exist.
3. **Diagram if non-trivial**: If the architectures differ meaningfully,
   produce a mermaid diagram per project (or a single side-by-side diagram)
   showing the high-level component flow. If they're architecturally similar,
   one shared diagram suffices with a note like "Architecturally there is
   little difference of note."
4. **Summarize implications**: Note how architectural differences affect
   extensibility, performance characteristics, deployment, or operational
   complexity — but only where there are real differences. Don't repeat the
   feature matrix; focus on *how* the systems work, not *what* they support.

### Step 6 — Assess Maintainability

Score each project's maintainability using available signals. See
`references/maintainability-scoring.md` for the scoring rubric.

1. **Activity signals** (from Step 2 metadata): last push, commit frequency
   (if available), open issues, archived status, stars/forks trend.
2. **Health signals**: If local paths are available, run
   `repository-health-review` per project for a health score. If only GitHub
   repos, assess from metadata (archived, last push, open issues ratio).
3. **Maturity signals** (optional, deep dive): Run `tech-maturity` per project
   for the 42-capability, 6-dimension rubric. Use when the user wants a deep
   maintainability comparison.
4. **Score**: Combine signals into a maintainability rating per project using
   the rubric in `references/maintainability-scoring.md` (🏆 excellent / ✅
   good / ➖ neutral / ⚠️ concerning / ❌ abandoned or critical issues).

### Step 7 — Emit the Feature Matrix

Produce the final comparison artifact following the output format defined in
`references/matrix-output-format.md` (based on the `feature-matrix` rule).

1. **Build the matrix table**: Projects across the top (with inline links),
   features down the side. Use icons: 🏆 best, ✅ good, ➖ neutral, ⚠️ bad,
   ❌ worst.
2. **Meta-features section** (top of table): License (⭐ FOSS, ☑️ OSS, ⚠️ Free,
   ❌ Paid), UX/UI, Setup Difficulty, Community, Last Commit, Stars, Forks,
   Year Introduced, Public Repo Link, Run Modes, Tech Stack, Platform Support.
3. **Category-specific features** (middle): One row per feature, with inline
   links where available. Use the dimensions from Step 4.
4. **Identical-value rows** (bottom): Any feature where all projects have the
   same rating goes at the bottom of the table.
5. **Notes row**: Per-project notes, caveats, and notable observations.
6. **Recommendation**: Provide a use-case-ordered recommendation — which
   project fits which context (beginner vs expert, homelab vs enterprise, no
   scale vs high scale, quick-and-dirty vs regulated). Order progressively
   (least→most demanding or most→least) so the reader gets an escalation
   path. Include "Avoid" only if a project genuinely should be avoided, and
   "Watch" for promising-but-not-ready projects. See
   `references/matrix-output-format.md` — Recommendation Structure for the
   axis families, ordering guidance, and domain-specific examples.

## Output Artifacts

The skill produces:

- **Feature matrix** (`project-comparison-[category]-[timestamp].md`) — the
  main comparison document with architectural comparison (mermaid diagrams if
  non-trivial), the feature matrix table, maintainability ratings, and
  recommendation.
- **Metadata JSON** (`project-metadata-[timestamp].json`) — raw metadata
  gathered by the scripts, for reproducibility and re-runs.

## Important Notes

- **Always link to external sources** when referencing projects, companies,
  frameworks. Inline links in the matrix table cells where possible.
- **Add footnotes** for claims that aren't common knowledge.
- **Be honest about data gaps**: If GitHub metadata is unavailable (private
  repo, deleted repo), say so rather than guessing.
- **Don't fabricate metrics**: If stars/forks/last-commit can't be fetched,
  mark as "N/A" rather than estimating.
- **Category-first**: The classification step (Step 3) is not optional.
  Comparing projects that aren't in the same category produces a misleading
  matrix. Always confirm category membership before building the table.

## References

- [category-discovery.md](references/category-discovery.md) — the 3-tier
  category classification process (known names → category search → adjacent
  categories) and how to handle mismatches
- [coverage-mapping.md](references/coverage-mapping.md) — how to define
  category dimensions and map each project's coverage with the 5-level
  🏆/✅/➖/⚠️/❌ scale
- [architectural-comparison.md](references/architectural-comparison.md) — how
  to compare project architectures, when to produce mermaid diagrams vs. a
  brief "no difference" note, and diagram patterns
- [maintainability-scoring.md](references/maintainability-scoring.md) — the
  maintainability scoring rubric combining activity, health, and maturity
  signals into 🏆/✅/➖/⚠️/❌ ratings
- [matrix-output-format.md](references/matrix-output-format.md) — the feature
  matrix output format with meta-features, category features, identical-value
  rows, and recommendation section

## Context Declaration

- **Bundled scripts**: `scripts/gather_github_metadata.py` (GitHub API metadata
  via `gh api`), `scripts/gather_local_metadata.py` (local project detection
  via `project-detection` skill)
- **Consumes**: `project-detection` (tech stack), `repository-health-review`
  (health score), `tech-maturity` (optional deep maturity scoring)
- **Outputs via**: `feature-matrix` rule (output format)
- **External dependencies**: Python 3 stdlib, `gh` CLI (for GitHub API calls),
  `project-detection` scripts (for local analysis)
