---
name: execute-upsert
description: >-
  Generic project execution controller that drives feature implementation from
  request to completion through a PRD → tasks → execute pipeline. Assesses
  request size, creates a PRD if one doesn't exist (for large requests),
  breaks the PRD into parallelizable task stories, executes each story via
  subagents, updates the PRD and task files when scope changes, and updates
  project documentation as the final phase. Use when users want to implement a
  feature or change that is large enough to warrant structured planning, when
  they say "execute", "implement this feature", "build this project", "run the
  project executor", "drive this to completion", or reference a PRD or task
  list they want executed. Do NOT trigger on quick fixes, single-file edits,
  bug fixes with a known root cause, or questions about how something works —
  this skill is for multi-step project execution, not trivial changes.
version: 1.1.0
user-invocable: true
disable-model-invocation: true
date:
  created: "2026-07-11"
  updated: "2026-07-11"
  last-used: "2026-07-11"
tags:
  - "ai/skill"
  - "execution"
  - "project-controller"
  - "prd"
  - "task-management"
  - "subagent-delegation"
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "trigger-guard"
    relationship: "over-triggering-guard"
    description: "Prevents triggering on requests that don't need the full pipeline"
  - workflow: "greenfield-prd"
    relationship: "prd-creation"
    description: "Workflow for generating a PRD from a brief feature prompt — used when no PRD exists"
  - workflow: "tasks-from-prd"
    relationship: "task-breakdown"
    description: "Workflow for breaking a PRD into parallelizable task stories — used when no task files exist"
  - workflow: "tasks-processor"
    relationship: "task-execution"
    description: "Workflow for processing task stories — delegates to subagents for each story"
  - skill: git-repository-management
    relationship: "dependency"
    description: "Provides the commit checkpoint protocol used before each subagent dispatch — shared via pre-task-commit-checkpoint include"
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
description: Reusable user-reference convention — use male pronouns for the user, address him as "user", avoid proper names unless relevant to the output
---

### User Info

When communicating with or about the user, follow this convention:

1. **Male pronouns.** Refer to the user with `he`/`him`/`his`/`himself` in any
   prose, examples, or generated content that mentions the user. Do not use
   `they`/`them` or `she`/`her` for the user.

2. **Address him as "user".** Call the user "user" — even when his real name is
   available in memory, environment variables, git config, or session context.
   The word "user" is the canonical form of address in generated output and
   in-conversation references.

3. **Avoid proper names unless relevant to the output.** Do not insert the
   user's actual name into generated artifacts or conversation unless the name
   is itself the subject of the work (e.g. authoring an `AUTHORS` file, signing
   a commit the user explicitly asked to be attributed to him, or filling a
   `name:` field the user requested). When a name is required and none is
   explicitly requested, use "user".

**Examples:**
- ✅ "The user wants his skill to trigger on kebab-case slugs."
- ✅ "Ask the user for his repo root before materializing the script."
- ❌ "They want their skill to trigger on kebab-case slugs." (wrong pronoun)
- ❌ "Ask John for his repo root." (proper name not relevant to output)


---
description: Reusable naming conventions for artifacts created by upsert skills — kebab-case for file names, identifiers, and slugs; avoid snake_case everywhere
---

### Naming Conventions

When creating or renaming artifacts (skills, workflows, agents, prompts,
rules, templates, knowledge bundles, handoffs), follow this naming convention:

1. **Use kebab-case whenever possible.** File names, directory names, slugs,
   identifiers, frontmatter `name:` fields, tags, and URL/path segments are all
   `kebab-case`: lowercase letters and digits separated by single hyphens.
   - ✅ `ai-skill-upsert`, `greenfield-prd`, `feature-auth-implementation`
   - ✅ `name: agent-file-upsert`
   - ✅ tag: `ai/skill`

2. **Avoid snake_case everywhere.** Do not use `snake_case` (`_` separators) for
   artifact names, file names, slugs, identifiers, or frontmatter fields. If an
   existing artifact uses snake_case and the upsert operation touches its name,
   rename it to kebab-case (preserving git history via `git mv` where applicable).
   - ❌ `ai_skill_upsert`, `greenfield_prd`, `feature_auth_implementation`
   - ❌ `name: agent_file_upsert`

3. **Scope.** This convention applies to the artifacts themselves — the files
   and directories the upsert skills create. It does **not** override language-
   specific conventions inside generated *content* (Python function names stay
   `snake_case`, Rust types stay `PascalCase`, etc.). The rule is about the
   artifact layer, not the code inside artifacts.

4. **Slugs in generated paths.** When a script generates a path containing a
   human-readable slug (e.g. handoff file names, branch names, output
   directories), derive the slug as kebab-case: lowercase, trim, replace
   whitespace and `_` with `-`, collapse repeats, strip leading/trailing `-`.

**Examples:**
- ✅ `skills/ai/agent-file-upsert/SKILL.md` — `name: agent-file-upsert`
- ✅ `workflows/greenfield-prd/WORKFLOW.md` — `name: greenfield-prd`
- ❌ `skills/ai/agent_file_upsert/SKILL.md` — `name: agent_file_upsert`


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


---
description: Shared protocol for committing a clean checkpoint before delegating work to a subagent or starting a commit batch, so failures can be rolled back without losing prior progress
---

### Pre-Task Commit Checkpoint

Before delegating a unit of work to a subagent (or starting any commit batch),
ensure the working tree is at a clean, labeled commit. This creates a rollback
point: if the subagent fails or produces unwanted changes, `git reset` or
`git checkout` returns to the checkpoint without losing prior stories' work.

#### When to Checkpoint

- **Before each subagent dispatch** in a multi-story execution loop.
- **Before the first commit** in a batch commit operation.
- **Before any delegation** where the subagent might modify files you cannot
  easily undo.

Do NOT checkpoint after every file edit inside the orchestrator — only at
delegation boundaries where a fresh context takes over.

#### Checkpoint Protocol

1. **Check for uncommitted changes**:
   ```bash
   git status --porcelain
   ```
   - If the output is empty, the tree is clean — proceed to dispatch.
   - If there are changes, continue to step 2.

2. **Commit the pending work** before dispatching:
   - If the `git-repository-management` skill is installed, use its
     `git-commit-batch.sh` script for structured, rollback-safe commits with
     vertical grouping and mandatory commit bodies.
   - Otherwise, commit directly:
     ```bash
     git add -A
     git commit -m "checkpoint: <what was completed>" -m "- Pre-task checkpoint before <next task description>"
     ```

3. **Record the checkpoint commit hash** so the orchestrator can roll back to
   it if the subagent fails:
   ```bash
   git rev-parse HEAD
   ```

4. **Dispatch the subagent**. The subagent works from the clean checkpoint.

5. **On subagent failure**: roll back to the checkpoint if the subagent left
   the tree in an undesirable state:
   ```bash
   git reset --hard <checkpoint-hash>
   ```
   Never roll back past a checkpoint that represents completed, reviewed work.

#### Commit Quality Rules (Apply at Every Checkpoint)

Even at checkpoint boundaries, commits must follow basic quality standards:

- **Imperative mood**: "Add auth middleware" not "Added auth middleware"
- **Mandatory body**: Every commit includes a body explaining the why, not
  just the what. A subject line alone is never sufficient.
- **No AI signatures**: Never add `Co-authored-by:`, `Generated by:`, or any
  AI attribution trailer. This is a permanent, non-negotiable rule.
- **Vertical grouping**: When a checkpoint spans multiple functional areas,
  group changes by feature (code + tests + docs together), not by file type.
- **Rollback-safe ordering**: When making multiple commits at a checkpoint,
  order least-complicated → most-complicated so a revert of a complex commit
  doesn't pull simpler, unrelated commits with it.

For the full commit organization rules (vertical grouping examples, batch
format, quality check integration, tagging), see the `git-repository-management`
skill.


# Execute Upsert — Project Execution Controller

A controller skill that drives feature implementation from request to
completion. It does NOT do the work itself — it orchestrates a pipeline of
PRD creation, task breakdown, subagent execution, and documentation updates.

## Overview

This skill is a generalized version of the Infrahub project controller
(`do-proj-infrahub.md`). Where the Infrahub controller assumes tasks already
exist and simply chains subagents through them, this skill has the
intelligence to:

1. **Assess** whether a request is large enough to warrant the full pipeline
2. **Create a PRD** if one doesn't exist (for large requests)
3. **Break the PRD into tasks** if task files don't exist
4. **Execute tasks** via subagents, chaining through the project
5. **Update the PRD** when scope changes, and regenerate affected tasks
6. **Update documentation** (project docs + PRD/task files) as the final phase

## Architecture

```
User Request
    │
    ▼
Phase 1: Assess ─────── small? ──→ Direct execution (no pipeline)
    │ large
    ▼
Phase 2: PRD ────────── exists? ──→ skip creation
    │ missing
    ▼
Phase 3: Tasks ──────── exist? ──→ skip breakdown
    │ missing
    ▼
Phase 4: Execute ────── loop: subagent per story
    │
    ▼
Phase 5: Document ───── update PRD, task files, project docs
```

## Phase 1: Assess

Determine whether the request is large enough to warrant the full pipeline.

**Triage heuristic** — the request is "large" if it meets 2 or more of:
- Touches more than 3 files across different modules
- Requires multiple phases (e.g., schema → API → UI → tests)
- Involves new functionality (not a fix to existing code)
- Has ambiguous scope (needs clarifying questions before implementation)
- The user explicitly references a PRD, feature, or project

**See `references/triage-heuristic.md`** for the full decision matrix and examples.

If the request is small (fails the heuristic), confirm with the user:
> "This looks like a focused change. I can implement it directly, or run the
> full PRD → tasks → execute pipeline. Which would you prefer?"

If the user chooses direct execution, implement the change without the
pipeline. Otherwise, proceed to Phase 2.

If the request is large, briefly summarize your assessment and proceed to
Phase 2.

## Phase 2: PRD

### If a PRD exists

- Locate the PRD file under `internal-docs/feature/YYYY/MM/{slug}/`.
- Read it to understand the scope.
- Proceed to Phase 3.

### If no PRD exists

- Ask clarifying questions following the clarifying-questions protocol (see
  `includes/clarifying-questions.md`).
- `[fork]` Create the PRD using the `greenfield-prd` workflow. The subagent
  receives:
  - **Goal**: Generate a PRD from the user's feature request.
  - **Inputs**: The user's request, clarifying-question answers, the project's
    `AGENTS.md` path.
  - **Constraints**: Follow the greenfield-prd workflow's template and process
    exactly. Save to `internal-docs/feature/YYYY/MM/{slug}/`.
  - **What to return**: The path to the saved PRD file.
- Review the PRD: verify it covers the user's request, has clear scope
  boundaries, and is implementable by a junior developer.
- If the PRD is incomplete or off-target, provide feedback and re-dispatch the
  subagent with the feedback.

## Phase 3: Tasks

### If task files exist

- Locate the task index file
  (`internal-docs/feature/YYYY/MM/{slug}/tasks/index-[PRD-NAME].md`).
- Read it to understand the story breakdown and current status.
- Proceed to Phase 4.

### If no task files exist

- `[fork]` Create task files using the `tasks-from-prd` workflow. The subagent
  receives:
  - **Goal**: Break the PRD into parallelizable task stories.
  - **Inputs**: The PRD file path, the project's `AGENTS.md` path.
  - **Constraints**: Follow the tasks-from-prd workflow's process and output
    format exactly. Generate the index file and per-story files.
  - **What to return**: The path to the task index file and a list of story
    file paths.
- Review the task files: verify the story breakdown is logical, dependencies
  are correct (no intra-phase dependencies), and each story is
  self-contained.

### If the PRD was updated during execution

When the PRD is updated (see Phase 5 — PRD Update), the task files are
potentially stale. The controller must:

1. Identify which stories are affected by the PRD changes.
2. For affected stories that are not yet started (`[ ] Todo`): regenerate
   them using the `tasks-from-prd` workflow, scoped to just those stories.
3. For affected stories that are in-progress (`[~] In-Progress`) or completed
   (`[x] Done`): flag them for human review. Do NOT auto-regenerate — the
   existing work may need to be reconciled manually.
4. Update the index file to reflect any new, changed, or removed stories.

## Phase 4: Execute

For each task story that isn't completed yet:

1. **Select the next story**: Read the index file. Find the first story with
   status `[ ] Todo` that has all dependencies completed (`[x] Done`). If no
   pending story has completed dependencies, report blocked stories and wait
   for user direction.

2. **Create a pre-task commit checkpoint**: Before dispatching the subagent,
   follow the Pre-Task Commit Checkpoint protocol (see the include above).
   Commit any pending work from prior stories or orchestrator-side changes,
   and record the checkpoint commit hash. This ensures a clean rollback point
   exists — if the subagent fails or produces unwanted changes, you can
   `git reset --hard <checkpoint-hash>` without losing completed work.

3. **Launch a subagent** to execute the story. The subagent receives:
   - **Goal**: Implement the story by running the `tasks-processor` workflow.
   - **Inputs**: The story file path, the project's `AGENTS.md` path, the
     task directory path.
   - **Constraints**: Follow the tasks-processor workflow's work protocol
     exactly — mark tasks in-progress, run tests, verify acceptance criteria,
     commit with conventional commit format. The subagent starts from the
     checkpoint commit created in step 2; if it fails, the orchestrator rolls
     back to that checkpoint.
   - **What to return**: A summary of what was implemented, test results, and
     the commit hash.

4. **Review the subagent's work**:
   - Verify the story is marked `[x] Done` in the index file.
   - Check the commit exists and includes both code and task file updates.
   - Run the smallest check that would fail if the work is wrong (typecheck
     or targeted test).

5. **Chain to the next story**: If the subagent completed successfully, launch
   the next subagent for the next uncompleted story. If something needs human
   involvement, list the story as blocked and move on to the next story that
   doesn't have blocked dependencies.

6. **Handle PRD updates during execution**: If a subagent discovers that the
   PRD needs updating (e.g., a requirement is infeasible, scope needs to
   change, a new requirement emerged):
   - Pause the execution loop.
   - Update the PRD with the discovered changes.
   - Follow the "If the PRD was updated during execution" process in Phase 3
     to regenerate affected task files.
   - Resume the execution loop.

Work through the entire project.

## Phase 5: Document

After all stories are completed (or when the user pauses execution):

### Update PRD and Task Files

- Update the PRD to reflect what was actually built: status, deviations from
  the original plan, decisions made during implementation, and any deferred
  items.
- Update the task index file: all stories should be `[x] Done` or explicitly
  marked as deferred/blocked with a reason.
- Update per-story files: ensure the "Relevant Files" section lists all files
  created or modified, and acceptance criteria are all checked `[x]`.

### Update Project Documentation

- `[fork]` Update project-level documentation. The subagent receives:
  - **Goal**: Update project documentation to reflect the completed feature.
  - **Inputs**: The PRD file path, the task index file path, the list of
    commits made, the project's `AGENTS.md` path.
  - **What to update**:
    - `README.md` — if the feature adds new user-facing capabilities
    - API documentation — if the feature adds or changes API endpoints
    - Architecture docs — if the feature changes the system architecture
    - `AGENTS.md` — if the feature introduces new conventions or patterns
      that future agents need to know
    - `CHANGELOG.md` — if the project maintains one
  - **What to return**: A list of documentation files updated with a
    one-line summary of each change.

### Final Commit

After all updates are complete (PRD, task files, documentation), commit
everything that remains uncommitted. This is the last step of the pipeline —
no work should be left dirty in the tree.

1. **Check for uncommitted changes**:
   ```bash
   git status --porcelain
   ```
   If the output is empty, the tree is clean — skip to the summary.

2. **Group remaining changes into commits** by functional area, following the
   Commit Quality Rules from the Pre-Task Commit Checkpoint protocol above:
   - **PRD and task files** (`internal-docs/feature/...`) as one commit:
     ```
     docs: update PRD and task files for [PRD-NAME]

     - Mark all stories as done or deferred with reasons
     - Record deviations from the original plan
     - Update relevant-files sections in per-story files
     ```
   - **Project documentation** (README, API docs, architecture docs,
     `AGENTS.md`, `CHANGELOG.md`) as one or more commits, grouped by area:
     ```
     docs: update project documentation for [PRD-NAME]

     - Updated README with new feature capabilities
     - Added API documentation for new endpoints
     - Updated architecture docs for system changes
     ```

3. **Execute the commits**. If the `git-repository-management` skill is
   installed, use its `git-commit-batch.sh` script for structured,
   rollback-safe commits with vertical grouping and mandatory commit bodies.
   Otherwise, commit each group directly:
   ```bash
   git add <files-for-this-group>
   git commit -m "<subject>" -m "<body with bullet points>"
   ```

4. **Verify the tree is clean**:
   ```bash
   git status --porcelain
   ```
   If anything remains, commit it or report it to the user — do not leave
   the tree dirty.

## Context Declaration

### File Paths

- **This skill**: `~/p/gh/levonk/skills-src/src/current/skills/execution/execute-upsert/SKILL.md`
- **PRD creation workflow**: `~/p/gh/levonk/skills-src/src/current/workflows/software-dev/greenfield/greenfield-prd.md`
- **Task breakdown workflow**: `~/p/gh/levonk/skills-src/src/current/workflows/software-dev/tasks/tasks-from-prd.md.tmpl`
- **Task execution workflow**: `~/p/gh/levonk/skills-src/src/current/workflows/software-dev/tasks/tasks-processor.md.tmpl`
- **PRD output**: `internal-docs/feature/YYYY/MM/{slug}/feat-YYYYMMDDHHmm-{slug}.md`
- **Task output**: `internal-docs/feature/YYYY/MM/{slug}/tasks/`

### Reference Files

- `references/triage-heuristic.md` — Decision matrix for assessing request size
- `references/documentation-update.md` — Detailed guidance for Phase 5 documentation updates

### Project Info

- PRD and task files live under `internal-docs/feature/YYYY/MM/{slug}/` in the target project
- All project tool invocations should use the project's standard command wrapper (e.g., `devbox run --` or equivalent)
- Read the target project's `AGENTS.md` before executing any work in it
