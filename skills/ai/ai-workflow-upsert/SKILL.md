---
name: ai-workflow-upsert
description: Create new workflows, modify and improve existing workflows, and convert between workflow and skill formats. Use when users want to create a workflow from scratch, update or audit an existing workflow, convert a skill back into a workflow (preserving git history via git mv), edit or optimize an existing workflow's frontmatter or steps, or scaffold a new workflow file with the Template/Wrapper pattern. Make sure to use this skill whenever the user mentions workflow creation, workflow design, workflow scaffolding, workflow updating, workflow auditing, workflow optimization, skill-to-workflow conversion, or wants to package a multi-step procedure into a reusable workflow file, even if they don't explicitly ask for a "workflow creator." Do NOT trigger on general coding questions, one-off scripts, single-step tasks, bug fixes, feature implementation, or code review — this skill is for workflow lifecycle management, not general development. For skill lifecycle management (create/update/convert/eval/benchmark), use ai-skill-upsert instead.
version: 3.1.0
user-invocable: true
disable-model-invocation: true
date:
  created: "2025-12-20"
  updated: "2026-07-11"
  last-used: "2026-07-11"
tags:
  - "ai/workflow/workflow/upsert"
  - "skill"
  - "workflow-creation"
  - "workflow-design"
  - "workflow-update"
  - "workflow-conversion"
see-also:
  - template: "base-workflow-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
  - template: "research-phase"
    relationship: "shared-include"
    description: "Shared research phase — search for existing artifacts before creating or improving"
  - skill: "ai-skill-upsert"
    relationship: "sibling"
    description: "Full lifecycle management for skills (create/update/convert/eval). Use when the target is a skill, not a workflow, or when converting a workflow into a skill (the reverse of this skill's Mode B)."
---

---

---
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
description: Shared research phase rules — when to search, gap assessment, create-vs-reuse decision, and how to incorporate findings. Each consumer adds its own artifact-specific search tactics (inline or via a type-specific include).
---

# Research Phase: Search Before You Create or Improve

Before creating or improving any AI guidance artifact, research what already
exists. This prevents duplicating effort, ensures new artifacts incorporate
the best ideas from existing work, and surfaces existing artifacts the user
could adopt instead of creating from scratch.

## When to Run

- **Always**, unless the user explicitly says "skip research", "don't
  search", or "just create it"
- Before **creating** a new artifact (skill, workflow, agent, prompt, template,
  knowledge bundle)
- Before **improving** an existing artifact — to understand the landscape and
  avoid regressing below the state of the art

If the user provides an existing file to convert or update, the research phase
still applies: check whether better alternatives exist that the user could
adopt instead of converting/updating their current file.

## Anti-Pattern and Inferior-Solution Discovery

As part of researching existing artifacts, also search for **anti-patterns**
and **inferior solutions** — approaches that were tried and found harmful or
worse than the current approach. These are negative findings: things NOT to
do, or approaches that are known to be inferior.

Sources to check:
- **Git history**: commits that reverted or removed an approach (revert
  commits, "remove X" commits, "switch from X to Y" commits)
- **Issue trackers**: closed issues labeled "wontfix" or "invalid" where an
  approach was rejected, with rationale
- **ADR / OOS files**: architecture decisions that explicitly rejected an
  alternative; out-of-scope files that document what the repo does NOT do
- **Existing anti-patterns files**: `internal-docs/anti-patterns/` if it
  exists — check the INDEX.md for previously recorded anti-patterns
- **Code comments**: `// HACK`, `// FIXME`, `// TODO: replace`, `// DEPRECATED`
  markers that signal known-bad approaches
- **External research**: blog posts, discussions, or documentation that
  describe why an approach is inferior (when the artifact type warrants it)

Record discovered anti-patterns clearly marked as negative — they must never
be mistaken for positive recommendations. If the consumer skill produces an
anti-patterns file (see `agent-file-upsert`), write findings there. Otherwise,
note them in the research summary with explicit "❌ DO NOT" framing.

## Artifact-Specific Search

Each artifact type has different search tactics. See the consumer's own
section below (inline or via a type-specific include) for how to search for
that artifact type. The gap assessment and decision framework that follow
apply to all artifact types.

## Gap Assessment

After researching, determine whether there's a gap:

| Situation | Gap? | Action |
|---|---|---|
| No existing artifacts found | Yes — clear gap | Proceed to create |
| Artifacts found but none cover the user's need | Yes — coverage gap | Proceed to create, incorporating best ideas |
| Artifacts found, partially cover the need | Yes — scope gap | Proceed to create, noting what existing artifacts miss |
| Artifacts found, fully cover the need | No gap | Offer to adopt the best match (see below) |
| Multiple artifacts found, each covers part | Partial gap | Consider creating one that combines the best parts |

### What Counts as "Fully Covered"

A need is fully covered when an existing artifact:
1. Addresses the user's specific use case (not just a related one)
2. Has acceptable quality (structured, maintained, has evals/tests)
3. Matches the user's constraints (language, platform, distribution)
4. Is installable and usable by the user

If any of these fail, there's at least a partial gap.

## Decision: Create vs Reuse

### If there IS a gap

Present the findings to the user:
- What artifacts exist and what they cover
- What's missing (the gap)
- How the new artifact would be better

Then offer to create. The user's ideas/constraints + best practices the LLM
knows + the best ideas from existing artifacts all feed into the new
artifact's design.

### If there is NO gap

Present the best existing artifact(s) with:
- Name, description, and link (so the user can investigate themselves)
- Why it fits the user's need
- Any caveats (quality, maintenance, scope limitations)

Then ask the user:
1. **Adopt the existing artifact?** — Provide the install/usage command.
2. **Still create a new one?** — The user may have reasons to create their
   own (customization, learning, different constraints). Respect their choice
   and proceed with creation.

### If the user wants to investigate

Always provide links so the user can investigate existing artifacts themselves
before deciding. Do not make the decision for them — present the evidence and
let them choose.

## Incorporating Findings

When proceeding to create after finding existing artifacts:

1. **Note the best ideas**: What did existing artifacts do well? (structure,
   patterns, reference organization, eval design)
2. **Note the gaps**: What did existing artifacts miss? This is the value
   proposition of the new artifact.
3. **Note the user's ideas/constraints**: What does the user want that
   existing artifacts don't address?
4. **Apply best practices**: Use the LLM's knowledge of design best practices
   for the artifact type.
5. **Synthesize**: Combine all three inputs (existing ideas + gap filling +
   best practices) into the new artifact's design.

The new artifact should be **better than any single existing artifact** — not
just different. If it's merely a reimplementation, reconsider whether creation
is warranted.


---
description: Reusable cross-linking guidance for AI guidance artifacts — see-also frontmatter format, relationship types, and circular dependency avoidance
---

### Cross-Linking

When an AI guidance artifact references other artifacts (skills, workflows, rules,
prompts, templates, agents):

1. **Use `see-also` in frontmatter**: Document every relationship to other
   artifacts. The `see-also` field is an array of entries, each with:
   - `template`, `skill`, `workflow`, or `rule` — the artifact kind
   - `relationship` — the relationship type (see below)
   - `description` — one line explaining the relationship

2. **Specify relationship type**: Use one of:
   - `dependency` — this artifact requires the other to function
   - `alternative` — this artifact can be used instead of the other
   - `complement` — this artifact works alongside the other
   - `sibling` — this artifact is in the same family/category

3. **Explain the relationship**: The `description` field should make clear why
   the relationship exists and when a user would follow the link. One line is
   enough.

4. **Avoid circular dependencies**: Artifacts should not depend on each other
   bidirectionally. If A depends on B, B should not also depend on A — restructure
   so the dependency flows one direction, or use `complement`/`sibling` for the
   reverse link.

**Example `see-also` entry:**
```yaml
see-also:
  - skill: "readme-upsert"
    relationship: "sibling"
    description: "Same upsert family — handles README.md creation and updates"
```


---
description: Reusable date management guidance for upsert operations — when to update date.updated and date.last-used in frontmatter
---

### Date Management

AI guidance artifacts track two dates in their frontmatter under the `date:` key:

| Field | When to update | Meaning |
|-------|----------------|---------|
| `date.updated` | When content changes are applied | Last time the artifact's content was modified |
| `date.last-used` | When the artifact is invoked | Last time the artifact was actually used |

**Format**: Both dates use `YYYY-MM-DD` as a quoted string in YAML:
```yaml
date:
  updated: "2026-07-11"
  last-used: "2026-07-11"
```

**When updating an existing artifact (Mode C):**
- Set `date.updated` to the current date when you apply content changes.
- Set `date.last-used` to the current date when the skill is invoked (even if no
  changes are made).

**Relationship to `self-update-requirement`:**
The `self-update-requirement` include handles the invocation-time `last-used`
update — it fires every time the skill is called. This include handles the
change-time `updated` update, which only fires when content is actually modified.
Both should be wired into upsert skills: `self-update-requirement` for
invocation tracking, this include for change tracking.


---
description: Shared clarifying-questions protocol — ask numbered multiple-choice questions before generating or updating any artifact, until complete clarity is achieved. Generic across all generative skills.
---

### Clarifying Questions (Mandatory Before Generation)

Before generating or updating an artifact, ask clarifying questions until you
have complete clarity on what the user wants. Only ask about gaps that
materially affect the output — skip questions where the answer is already clear
from the prompt, the codebase, or prior context.

#### What to Ask About

Ask about gaps in any of these areas (only the ones that are unclear):

- **Problem / goal** — What is the user trying to achieve?
- **Core functionality** — What should the artifact do or contain?
- **Scope boundaries** — What is explicitly in scope and out of scope?
- **Success criteria** — How will the user know the output is correct?
- **Target audience** — Who is the primary consumer of the output?
- **Priority / effort** — Is this P1 (critical), P2 (high), or P3 (medium)?
- **Constraints** — Known dependencies, deadlines, or technical constraints?
- **Existing context** — Are there designs, tickets, specs, or prior work to incorporate?

#### Formatting Requirements

- Number questions: `1.`, `2.`, `3.`, etc.
- Provide multiple-choice options per question: `A.`, `B.`, `C.`, `D.`, ...
- Make it easy for the user to reply like: `1A, 2C, 3B`.
- Keep questions concise — one sentence per question.
- 2–4 options per question (never more than 5).
- Include an "Other" implication: the user can always write a custom answer
  instead of picking a letter.

#### Example Question Format (for style only)

```text
1. What is the primary goal of this feature?
   A. Improve user onboarding experience
   B. Increase user retention
   C. Reduce support burden
   D. Generate additional revenue

2. Who is the target user for this feature?
   A. New users only
   B. Existing users only
   C. All users
   D. Admin users only

3. What is the priority level for this feature?
   A. P1 - Critical, needs immediate attention
   B. P2 - High priority, next sprint
   C. P3 - Medium priority, backlog
```

#### When to Stop Asking

- Stop when you have enough clarity to produce a correct, complete artifact.
- Do not ask more than 7 questions in a single round — if you need more, batch
  them and let the user answer what they can.
- If the user's initial prompt is already detailed and unambiguous, you may ask
  only 1–2 confirmation questions or skip straight to generation with a brief
  summary of your understanding.

#### After the User Answers

- Synthesize the answers into a brief understanding statement before proceeding.
- If any answer is ambiguous or contradicts another answer, ask one focused
  follow-up question.
- Then proceed to the next phase (research, generation, etc.) — do not re-ask
  questions already answered.


---
description: Shared script materialization guidance — materialize shared scripts into new skills' scripts/ dirs via .tmpl includes so artifacts are self-contained after installation
---

### Script Materialization

When creating a new artifact, shared scripts that the artifact needs at runtime
must be materialized into the artifact's own directory tree — not referenced from
an external location. This ensures the artifact is self-contained after
installation (via `npx skills add` or copy).

#### Skills (have `scripts/` directories)

If a skill needs a shared script (like `cli-tool-discovery.sh`), create a
`scripts/<name>.sh.tmpl` file containing a single include directive:

```
{{ include "includes/<name>.sh" . }}
```

The templater inlines the shared script content at build time, producing a
self-contained `scripts/<name>.sh` in the built skill. This is the same pattern
used for `.md` includes — the `.tmpl` extension marks it for rendering, and the
include is resolved relative to the profile root. `init_skill.py` does this
automatically for `cli-tool-discovery.sh`.

#### Workflows, Agents, Prompts, Rules (no `scripts/` directory)

These artifact types don't have `scripts/` directories. They reference
`cli-tool-discovery.sh` via the online URL fallback:

```bash
curl -fsSL https://raw.githubusercontent.com/levonk/skills-releases/main/includes/cli-tool-discovery.sh -o /tmp/cli-tool-discovery.sh
bash /tmp/cli-tool-discovery.sh <tool-name>
```

#### General Principle

Never make an artifact depend on a file outside its own directory tree after
installation. If a shared script is needed at runtime, either:

1. **Materialize** it via a `.tmpl` include file in the artifact's `scripts/`
   directory (for skills), or
2. **Fetch** it from a stable online URL (for artifacts without `scripts/` dirs)

Do not reference scripts via relative paths like `../../includes/` or
`$(dirname "$0")/../includes/` — these break after installation because the
includes/ directory is not bundled with the artifact.


# AI Workflow Upsert

## Workflow-Specific Search

When researching before creating or improving a workflow:

1. **Local**: Scan `config/ai/workflows/` for workflow files matching the
   query. Check frontmatter `description` and `use` fields.
2. **skills.sh / GitHub**: Search for "workflow" + keywords. Many workflow
   patterns are published as skills (which can be converted to workflows via
   Mode B, or used directly as skills via `ai-skill-upsert`).
3. **Cross-check with skills**: A skill may already exist that does what the
   workflow would do. If so, consider using the skill instead, or converting
   it to a workflow.

A skill for creating new workflows and iteratively improving them through structured audit and conversion. Handles the full workflow lifecycle: create from scratch, update existing, and convert between workflow and skill formats.

## Overview

### What Workflows Provide

1. **Repeatable processes** - Multi-step procedures with clear phases (Initialize, Plan, Apply, Verify, Deliver)
2. **Template/Wrapper pattern** - Content template + frontmatter wrapper, separable and reusable
3. **Step-based execution** - Sequences of prompts/tools with defined concurrency and safety controls

### Workflow Architecture

1. **Wrapper file** — `config/ai/workflows/<category>/<name>.md.tmpl`: YAML frontmatter (metadata, triggering) + `includeTemplate` call pulling in the content template.
2. **Content template** — `config/ai/templates/<category>/<name>-template.md`: The workflow steps and logic, no frontmatter. Reusable across wrappers.
3. **Bundled resources** — Workflows do NOT support `scripts/`, `references/`, `evals/`, or `assets/` subdirectories. If a workflow needs these, convert it to a skill (see Mode B in `ai-skill-upsert`, or Mode B below for the reverse direction).

## Decision: Create vs Convert vs Update

Before starting, determine which mode applies:

1. **Check whether the target wrapper file already exists** at `config/ai/workflows/<category>/<name>.md.tmpl`.
2. **If no wrapper exists:**
   - If the user has an existing skill they want as a workflow → **Mode B: Convert a Skill to a Workflow** (preserves git history).
   - Otherwise → **Mode A: Create a New Workflow from Scratch**.
3. **If the wrapper already exists** → **Mode C: Update an Existing Workflow (Upsert)**. See `references/workflow-upsert.md` for the full update workflow.

## Location Selection

Before creating a new workflow (Mode A) or converting a skill (Mode B), determine where the workflow should live. Check whether the `skills-src` repository is checked out at the standard location (`~/p/gh/levonk/skills-src/`). If it exists, present three location options to the user:

1. **skills-src repo** (recommended for workflows intended for distribution):
   - `~/p/gh/levonk/skills-src/src/current/workflows/<category>/<name>.md.tmpl`
   - Use this when the workflow should be versioned, built, and published via the skills-src pipeline.

2. **Current project** (for project-specific workflows):
   - `<project-root>/.agents/workflows/<category>/<name>.md.tmpl`
   - Use this when the workflow is specific to the current project and should travel with that project's repository.

3. **User directory** (for personal workflows available across all projects):
   - `~/.agents/workflows/<category>/<name>.md.tmpl`
   - Use this when the workflow is personal and should be available in every project on the user's machine.

If `skills-src` is not checked out at the standard location, default to option 2 (current project) or option 3 (user directory) based on the user's preference. The selected location becomes the `<output-directory>` passed to `init_workflow.py` in Mode A step 1 and the target path in Mode B step 2.

## Mode A: Create a New Workflow from Scratch

### Workflow Design Focus

- Create workflows that execute sequences of prompts/tools
- Define clear phases: Initialize, Plan, Apply, Verify, Deliver
- Specify concurrency and safety controls

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

### Inputs

- Process description
- Required steps and tools
- Safety requirements

### Operation

1. **Initialize**: Define workflow purpose and scope. Run `scripts/init_workflow.py <workflow-name> --path <output-directory>` to scaffold the workflow wrapper and content template with TODO placeholders. See `references/anatomy.md` for the directory layout the scaffolder creates.
2. **Plan**: Map steps and dependencies. Identify which phases are deterministic (candidates for script extraction if later converted to a skill) and which require AI judgment.
3. **Apply**: Implement using the Template/Wrapper pattern:
   - Content template in `config/ai/templates/<category>/<name>-template.md` (no frontmatter) — the scaffolder creates this with section headers.
   - Workflow wrapper in `config/ai/workflows/<category>/<name>.md.tmpl` with frontmatter including `date.last-used` set to current date (YYYY-MM-DD) and `includeTemplate` call — the scaffolder creates this with TODO placeholders.
   - Fill in the placeholders.
4. **Verify**: Validate step sequencing and template syntax. Run `chezmoi execute-template` on the wrapper to confirm the include resolves.
5. **Deliver**: Save to `internal-docs/workflows/` and update `date.last-used` in the frontmatter.
6. **Packaging verification**: Verify the workflow structure before considering the task complete:
   - **Frontmatter**: Confirm the wrapper starts with valid YAML frontmatter (delimited by `---`) and contains required fields (`name`/`description` or workflow-specific `workflow`/`slug`/`use`/`role`).
   - **Forbidden files**: Ensure no extraneous documentation files (`README.md`, `INSTALLATION_GUIDE.md`, `QUICK_REFERENCE.md`, `CHANGELOG.md`) are bundled alongside the workflow. Workflows do not support `scripts/`, `references/`, `evals/`, or `assets/` subdirectories — if any are present, the workflow should be converted to a skill (see Mode B).
   - **Template/Wrapper split**: Confirm the content template (no frontmatter) and wrapper (frontmatter + `includeTemplate` call) are separate files.
   - This mirrors the verification pattern from `ai-skill-upsert/scripts/package_skill.py` (validate frontmatter, check for forbidden files).

## Mode B: Convert an Existing Skill to a Workflow

When the user provides an existing skill directory and wants it turned back into a workflow, use this path to preserve the skill's git history while transforming it into a workflow. **See `references/skill-to-workflow-conversion.md` for the full process**, including when conversion is appropriate (the skill no longer needs scripts/evals/references), the git-mv-based history preservation, and the optimization checklist.

**High-level steps:**

1. **Verify conversion is appropriate** — the skill should not rely on `scripts/`, `references/`, `evals/`, or `assets/` that workflows cannot bundle. If it does, conversion loses functionality; warn the user.
2. **Create the wrapper location** at `config/ai/workflows/<category>/<name>.md.tmpl` — do NOT create the file yet.
3. **`git mv` the skill's `SKILL.md` to the wrapper path** (renaming to `<name>.md.tmpl`). This preserves the skill's git history so `git log --follow` traces back through the original skill.
4. **Commit the rename as a standalone commit** — pure rename, no content changes.
5. **Apply workflow-based optimizations as separate commits** — convert frontmatter from skill schema to workflow schema (strip `name`/`description`/`triggers`, add `workflow`/`slug`/`use`/`role`), move body content to the content template, restructure for the linear step format. See `references/skill-to-workflow-conversion.md` for the full optimization checklist.

**Why separate commits:** The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.

## Mode C: Update an Existing Workflow (Upsert)

When the target workflow wrapper already exists, switch to update mode. The goal is to bring the existing workflow into compliance with the workflow guidelines without blindly overwriting the author's intent. **See `references/workflow-upsert.md` for the full update workflow**, including the audit checklist, prioritized change proposal, and confirmation-before-applying discipline.

**High-level steps:**

1. **Read the existing workflow fully** — wrapper frontmatter, content template, and any `see-also` references.
2. **Audit against the workflow guidelines** — frontmatter, description/use quality, step structure, context declaration, includes, stale text. See `references/workflow-upsert.md` for the full audit checklist.
3. **Propose changes — do not apply yet.** Present a prioritized list (Critical / Important / Nice to have) with before/after for each change.
4. **Ask for confirmation before applying.** Let the author accept all, a subset, or reject.
5. **Apply approved changes as separate commits** — one logical change per commit, each independently reviewable and revertable.
6. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied.

**Never silently overwrite.** The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.

## Cross-Cutting Concerns

### Script Execution Standards

This skill bundles `scripts/init_workflow.py`. All scripts bundled with or created by this skill must include devbox and rtk detection patterns. See `references/anatomy.md` in `ai-skill-upsert` for the script output contract (quiet by default, `--verbose`, `--dry-run`) and the one-handoff principle.

### Cross-Linking

See the cross-linking include wired in above for guidance on `see-also`
frontmatter format, relationship types (dependency/alternative/complement/sibling),
and circular dependency avoidance.

### When to Convert to a Skill

If a workflow grows to need `scripts/`, `references/`, `evals/`, or `assets/`, it has outgrown the workflow format. Use `ai-skill-upsert` Mode B to convert it to a skill (the reverse of this skill's Mode B). Signs a workflow needs conversion:

- Repeatedly inlining the same script code in prose
- Needing evals to test triggering accuracy
- Reference material growing too large for the content template
- Needing bundled assets (templates, icons, fonts)

### Command Handling

This skill also handles **commands** — workflow-adjacent artifacts that encapsulate a single reusable shell command or short command sequence. Commands use the same Template/Wrapper pattern and location conventions as workflows:

- **Wrapper**: `<location>/commands/<category>/<name>.md.tmpl` with YAML frontmatter and an `includeTemplate` call.
- **Content template**: `<location>/templates/<category>/<name>-template.md` with the command logic, no frontmatter.

When the user asks to create, update, or convert a command, follow the same Mode A / Mode B / Mode C decision tree and location selection above, substituting `commands/` for `workflows/` in the output paths. Commands do not support bundled subdirectories (`scripts/`, `references/`, `evals/`, `assets/`) — if a command grows to need them, convert it to a skill via `ai-skill-upsert`.

### Security

Ensure no secrets, keys, or sensitive paths are exposed in workflows. Before packaging or delivering a workflow, review:

- **Frontmatter**: Check for secrets, API keys, tokens, or passwords in workflow frontmatter fields.
- **Steps**: Scan workflow steps for hardcoded credentials, API keys, or tokens.
- **Paths**: No hardcoded absolute paths — use indirect references and the Context Declaration.
- **External fetches**: If the workflow fetches external URLs, document what is being fetched, use HTTPS with certificate validation, and implement timeouts.

See `ai-skill-upsert/references/security.md` for the full security review guidelines, including the security checklist (no hardcoded credentials, no malicious code, all inputs validated, file operations restricted to appropriate directories).

---
## Context Declaration

### File Paths
- Main skill: `src/current/skills/ai/ai-workflow-upsert/SKILL.md` (in the `skills-src` repo at `~/p/gh/levonk/skills-src/`)
- Scaffolder script: `src/current/skills/ai/ai-workflow-upsert/scripts/init_workflow.py`
- References: `src/current/skills/ai/ai-workflow-upsert/references/` (including `anatomy.md`, `workflow-upsert.md.tmpl`, `skill-to-workflow-conversion.md.tmpl`)
- Includes: `src/current/includes/` (shared includes wired in at build time)
- Workflow output (skills-src repo): `src/current/workflows/<category>/<name>.md.tmpl`
- Content template output: `src/current/templates/<category>/<name>-template.md`

### External Resources
- skills.sh API: https://www.skills.sh/docs/api
- skills.sh search: https://www.skills.sh/vercel-labs/skills/find-skills

### Project Information
- Project: levonk/skills-src
- Repository: https://github.com/levonk/skills-src
- Owner: levonk

<!-- vim: set ft=markdown -->
