---
name: briefingmemo
description: >-
  Use when making high-stakes business decisions, strategic choices, partnership
  evaluations, or any decision requiring structured committee deliberation.
  Triggers on requests like 'help me decide', 'strategic decision', 'briefing
  memo', 'committee deliberation', or 'evaluate this decision'. Strategic
  decision-making system using multi-agent committee deliberation that
  transforms strategic questions into well-researched decisions through a
  structured committee process: (1) Create structured brief with required
  sections, (2) Research phase where committee requests additional information,
  (3) Committee deliberation with parallel debate and optional blind peer
  review, (4) CSO final decision memo with one concrete next step, (5)
  Post-decision review by specialized agents. 17-member committee includes
  dedicated Partnership & Opportunities Agent for strategic partnerships,
  government contracts, funding opportunities, and growth synergies, plus an
  Outsider member who catches curse-of-knowledge blind spots. Do NOT trigger
  on fast pressure-tests or "council this" requests (use think-assist instead),
  factual questions with one right answer, pure creation tasks, or
  summary/processing tasks.
version: "1.0.0"
date:
  created: "2026-06-25"
  updated: "2026-07-05"
  last-used: "2026-07-05"
tags:
  - ai/skill
  - decision-making
  - strategic-planning
  - multi-agent
  - committee-deliberation
  - briefing-memo
see-also:
  - skill: think-assist
    relationship: dependency
    description: Thinking-method library consumed by this skill's committee
  - skill: peer-review
    relationship: optional
    description: Blind peer-review round that can be added before the CSO memo
  - skill: ai-guidance-improver
    relationship: complement
    description: For improving guidance file quality
  - template: base-ai-guidance
    relationship: base-framework
    description: Shared framework for creating all AI guidance types
deliberation_protocol: situational-analysis
conflict_resolution: strategic-alignment
leadership_styles:
  - transformational
  - transactional
  - servant
  - autocratic
related_committees:
  - leadership-council
  - management-council
  - executive-strategy-committee
  - legendary-ceos
related_workflows:
  - conflict-resolution/consensus-building
  - conflict-resolution/expert-weighting
  - conflict-resolution/majority-voting
  - think-assist/references/second-order-thinking
  - think-assist/references/systems-thinking
  - think-assist/references/first-principles-thinking
  - think-assist/references/inversion
  - think-assist/references/devils-advocate
  - think-assist/references/scamper
  - think-assist/references/expansionist
  - think-assist/references/outsider
  - think-assist/references/executor
  - general/tasks/task-tracking-ticketr
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

# Briefing to Memo Strategic Decision System

## Overview
This skill implements a deterministic multi-agent decision-making system that transforms strategic questions into well-researched decisions through a structured committee process.

## Related Workflows

This skill integrates with and references the following:

- **Conflict Resolution**: [Consensus Building](../conflict-resolution/consensus-building.md), [Expert Weighting](../conflict-resolution/expert-weighting.md), [Majority Voting](../conflict-resolution/majority-voting.md)
- **Thinking Methods**: [Second-Order Thinking](../../general/think-assist/references/second-order-thinking.md), [Systems Thinking](../../general/think-assist/references/systems-thinking.md), [First Principles Thinking](../../general/think-assist/references/first-principles-thinking.md), [Inversion](../../general/think-assist/references/inversion.md), [Devil's Advocate](../../general/think-assist/references/devils-advocate.md), [SCAMPER](../../general/think-assist/references/scamper.md), [Expansionist](../../general/think-assist/references/expansionist.md), [Outsider](../../general/think-assist/references/outsider.md), [Executor](../../general/think-assist/references/executor.md) — all from the `think-assist` skill
- **Blind Review (optional)**: [Peer Review Protocol](../../general/peer-review/references/review-protocol.md) — can be added before the CSO memo to strip authority bias from committee debate
- **Task Management**: [Task Tracking with tkr](../general/tasks/task-tracking-ticketr.md), [BriefingMemo tkr Integration](../general/tasks/briefingmemo-tkr-integration.md)

### Integration Pattern
1. **Dynamic Selection**: BriefingMemo dynamically selects appropriate workflows based on decision characteristics
2. **Contextual Application**: Thinking models are chosen based on uncertainty and complexity levels
3. **Escalation Path**: Conflict resolution methods escalate from consensus → expert weighting → majority vote
4. **Bidirectional References**: Each workflow references back to BriefingMemo for decision context

## Process Flow

### Phase 1: Brief Creation
1. **Input**: Strategic question or decision point
2. **Create brief** using `scripts/create_brief.py` with required sections:
   - Situation/Debrief
   - Stakes (what's at risk)
   - Constraints (time, budget, legal, regulatory)
   - Key Questions
   - Context files (business metrics, product overview)

### Phase 2: Research Phase
1. **Determine decision significance** using brief analysis:
   - **Strategic Impact Level** (Critical/High/Medium/Low)
   - **Resource Commitment** ($$$/$$/$)
   - **Stakeholder Breadth** (Enterprise/Division/Team/Individual)
   - **Time Horizon** (Long-term/Medium-term/Short-term)
   - **Reversibility** (Permanent/Difficult/Easy/Reversible)
   - **Uncertainty Level** (High/Medium/Low)

2. **Filter research team based on significance**:
   - **Critical decisions**: Full research team (all analysts + Board consultants)
   - **High impact**: Core team (Data Scientist, Legal Analyst, Risk Analyst, Intelligence Analyst + Board advisors)
   - **Medium impact**: Essential team (Legal Analyst, Risk Analyst, Intelligence Analyst + Board consultants)
   - **Low impact**: Minimal team (Intelligence Analyst only + Board advisor)

3. **Select committee members based on decision type**:
   - **Financial decisions**: Financial/Investment Agent, Risk Management Agent, Compounder
   - **Customer decisions**: Customer/User Advocate, Product Strategist, Culture Agent
   - **Technical decisions**: Operations/Execution Agent, Technical Architect, Innovation/R&D Agent
   - **Strategic decisions**: CSO, Futurist, Moonshot, Contrarian, Partnership & Opportunities Agent
   - **Legal/Regulatory**: Legal/Compliance Agent, Risk Management Agent
   - **Market decisions**: Market Analyst, Customer/User Advocate, Financial/Investment Agent
   - **Partnership/Growth decisions**: Partnership & Opportunities Agent, Financial/Investment Agent, Market Analyst
   - **Organizational decisions**: Board Consultant, Culture Agent, Risk Management Agent, CSO

   *For full committee selection logic, research team filtering, and thinking model application details, see [references/committee-selection.md](references/committee-selection.md).*

4. **Apply specialized thinking models** based on complexity:
   - **High uncertainty**: Second-Order Thinking, Systems Thinking
   - **Complex stakes**: First Principles Thinking, Inversion
   - **Innovation needed**: SCAMPER, Devil's Advocate
   - **Consensus required**: Consensus Building workflow
   - **Expert opinions**: Expert Weighting method

5. **Poll committee members** for information needs using `scripts/poll_research_needs.py`
   - Each committee member identifies specific information gaps
   - Requests are based on their expertise and the brief context
   - Use Devil's Advocate to challenge assumptions and identify blind spots
   - Board consultants provide organizational structure and governance insights

6. [fork] **Research agents gather requested information**:
   - Data Scientist, Market Analyst, Industry Analyst, Legal Analyst, Technical Researcher, Customer Researcher, Risk Analyst, Historical Researcher, Psychological Analyst, Game Theory Analyst, Intelligence Analyst, Partnership Researcher

   *For detailed analyst role descriptions and research request mappings, see [references/analyst-roles.md](references/analyst-roles.md).*

7. **Compile research package** with all gathered information for committee review
   - Each committee member receives the research they requested
   - Plus relevant research from other agents for complete context

## Board Structure

### Board of Directors
The Board provides governance oversight and strategic guidance for organizational decisions:

#### Board Members
- **Chair of the Board** - Leads board meetings and strategic direction
- **Independent Directors** - External expertise and governance oversight
- **Executive Directors** - Internal leadership representation
- **Board Consultants** - Specialized advisors for organizational decisions

#### Board Committees
- **Strategy Committee** - Long-term strategic planning and direction
- **Risk Committee** - Enterprise risk management and compliance oversight
- **Governance Committee** - Corporate governance and policy development
- **Compensation Committee** - Executive compensation and succession planning

### Board Research Team
Specialized researchers supporting Board-level decisions:

#### Board Researchers
- **Organizational Structure Analyst** - Analyzes org design, hierarchy, and reporting relationships
- **Governance Specialist** - Corporate governance best practices and compliance
- **Compensation Analyst** - Executive compensation benchmarks and structures
- **Risk Governance Analyst** - Board-level risk oversight and enterprise risk management
- **Strategy Advisor** - Long-term strategic planning and board-level strategy development

#### Board Research Capabilities
- **Organizational Design Analysis** - Role ID systems, department structures, reporting relationships
- **Governance Framework Assessment** - Board composition, committee structures, governance best practices
- **Strategic Alignment Review** - Organizational structure alignment with strategic objectives
- **Risk Governance Evaluation** - Board-level risk oversight and enterprise risk management
- **Succession Planning** - Leadership development and executive succession strategies

### Board Integration with Briefing Process

#### Board Involvement Triggers
- **Organizational restructuring** decisions
- **Executive leadership changes**
- **Major strategic pivots**
- **Governance structure changes**
- **Risk management framework updates**
- **Compensation structure changes**

#### Board Consultation Process
1. **Board Consultant** participates in committee deliberations for organizational decisions
2. **Board Researchers** provide specialized analysis on organizational structure and governance
3. **Board Review** - Critical decisions reviewed by appropriate Board committee
4. **Board Approval** - Major organizational changes require Board approval
5. **Implementation Oversight** - Board monitors implementation of organizational decisions

### Reference Integration
This skill integrates with the **Organizational Development** skill for:
- Role ID system management and validation
- Organizational structure design and analysis
- Department restructuring and role changes
- Single source of truth maintenance
- Board-level organizational governance

*Reference: `~/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/business/org-development/SKILL.md`*

### Phase 3: Committee Deliberation
1. **CSO (Chief of Strategy)** orchestrates deliberation using **situational-analysis** protocol
2. **Apply conflict resolution methods** based on disagreement level:
   - **Minor disagreements**: Consensus Building workflow
     - Position statements from each member
     - Common ground identification
     - Compromise proposals with 80%+ acceptance threshold
   - **Major disagreements**: Expert Weighting method
     - Weight votes by expertise relevance
     - Financial/Investment Agent weighted highest on financial matters
     - Legal/Compliance Agent weighted highest on regulatory matters
     - Customer/User Advocate weighted highest on customer impact
   - **Deadlocked decisions**: Majority Voting with veto power
     - CSO holds tie-breaking veto
     - Simple majority (50%+1) required
     - Must document dissenting opinions
3. **Optional blind peer-review round.** Before the CSO synthesizes, anonymize
   the committee responses and run a blind review round using the
   [peer-review](../../general/peer-review/SKILL.md) skill. This strips
   authority bias — the Financial Agent's opinion gets evaluated on merit, not
   on the title. Each reviewer answers: (1) which response is strongest, (2)
   which has the biggest blind spot, (3) what did all responses miss. The CSO
   receives the de-anonymized bundle plus all reviews. Recommended for
   high-stakes decisions where authority deference is a real risk; skip for
   time-constrained deliberations.
4. **Parallel debate** among committee members with enhanced personas:
   - Financial/Investment Agent: ROI, IRR, financial modeling
   - Legal/Compliance Agent: Regulatory risks, compliance issues
   - Customer/User Advocate: Customer experience impact
   - Market Analyst: Competitive landscape, market sizing
   - Statistician: Data analysis, statistical significance
   - Operations/Execution Agent: Implementation feasibility
   - Culture Agent: Team and company culture impact
   - Futurist: Long-term trends and implications
   - Risk Management Agent: Risk identification and mitigation
   - Innovation/R&D Agent: Technology and innovation implications
   - Compounder: Multi-year compounding advantages
   - Product Strategist: Product-centric decisions
   - Contrarian: Challenges consensus
   - Moonshot: 10x thinking, "what if we're thinking too small?"
   - Outsider: Zero context, fresh eyes — catches curse of knowledge and insider groupthink
   - Technical Architect: Technical feasibility
   - Partnership & Opportunities Agent: Strategic partnerships, growth opportunities, ecosystem expansion
5. **Integrate thinking models** during deliberation:
   - **Second-Order Thinking**: Analyze long-term consequences
   - **Systems Thinking**: Understand interconnected impacts
   - **First Principles**: Break down to fundamental truths
   - **Inversion**: Consider opposite approaches
   - **Devil's Advocate**: Actively challenge consensus
6. **Partnership & Opportunities Agent** specializes in:
   - **Partnership Identification**: Strategic alliance opportunities across industry sectors
   - **Build/Buy Analysis**: Make vs partner vs acquire decision frameworks
   - **Novel Use Cases**: Unconventional applications and market expansions
   - **Charity Strategy**: New charity creation vs collaboration with existing nonprofits
   - **Government Contracts**:
     - Federal opportunities (SAM.gov, Grants.gov, defense contracts)
     - State and local government procurement
     - International government opportunities (UK Crown Commercial, EU procurement, etc.)
     - Contract vehicle eligibility (8(a), HUBZone, SDVOSB, WOSB)
     - GSA Schedule and other contract vehicles
   - **Current Opportunities**:
     - Real-time funding opportunities (VC, PE, angel, strategic investors)
     - Active partnership inquiries and collaboration requests
     - Grant opportunities and RFPs
     - M&A opportunities and strategic acquisitions
     - Joint venture proposals
   - **Cross-Sector Synergy**: Identifying unexpected collaborations and joint ventures
   - **Ecosystem Mapping**: Visualizing partnership networks and value chains
7. **Time constraints**: Default 5 minutes deliberation
8. **Budget constraints**: Default $5 compute budget
9. **Leadership Style Integration**: Each agent embodies a leadership style:
   - Transformational agents inspire and innovate
   - Transactional agents focus on rewards and performance
   - Servant agents prioritize team and stakeholder needs
   - Autocratic agents provide decisive direction when needed

### Phase 4: Decision Memo
1. **CSO creates final memo** with:
   - Decision framework
   - Top recommendations
   - Committee stances (vote count)
   - Resolved and unresolved tensions
   - Next actions
   - Risk assessment
   - **The one thing to do first** — a single concrete next step, not a list. This is the anti-pattern-corrective against producing 10-item action lists. The user can figure out steps 2-10 once they've done step 1. See the [chairman verdict template](../../general/think-assist/references/chairman-verdict-template.md) in think-assist for the rationale.

### Phase 5: Post-Decision Review (Non-influential)
After decision completion, these agents provide perspectives without influencing the decision:
- **Culture Agent**: Cultural implications
- **Philanthropic Agent**: Social impact considerations
- **Environmental Agent**: Environmental impact assessment

## Deterministic Execution

### Fixed Parameters
- Deliberation time: 5 minutes (configurable)
- Compute budget: $5 (configurable)
- Committee composition: 17 members (fixed)
- Decision threshold: Simple majority (default)

### Randomization Control
- Agent response order: Alphabetical by role
- Speaking turns: Round-robin with equal time
- **Conflict Resolution**: Uses **strategic-alignment** method:
   - Context-matching for situational awareness
   - Team-needs-prioritization for stakeholder alignment
   - Strategic-alignment for business objective coherence
   - Principle-weighting for value-based decisions

## Usage Instructions

### Interactive Mode (Recommended)
Launch the TUI interface for full briefing management:
```bash
python3 scripts/manage_briefings.py --tui
```

This provides:
- 📝 Create new briefings with guided input
- ⏳ View and manage pending briefings
- 🔄 Track in-progress deliberations
- ✅ Browse completed decisions
- 🔍 Search through all briefings
- ⚙️ Configure settings

### Starting a Decision
```bash
# Quick start with existing briefing
python3 scripts/start_deliberation.py --brief path/to/brief.md

# With custom parameters
python3 scripts/start_deliberation.py --brief path/to/brief.md --time 10 --budget 10

# Skip research phase
python3 scripts/start_deliberation.py --brief path/to/brief.md --skip-research
```

### Briefing Management
```bash
# List all briefings
python3 scripts/manage_briefings.py --list

# Create new briefing (quick mode)
python3 scripts/manage_briefings.py --create "Strategic Partnership Decision"

# Launch TUI interface
python3 scripts/manage_briefings.py --tui
```

### Creating Brief Template
```bash
scripts/create_brief.py --template --output "new_brief.md"
```

### Customizing Committee
Edit `config/committee.yaml` to adjust:
- Agent roles and personas
- Model assignments (default: Sonnet 4.6 for committee, Opus 4.6 for CSO)
- Expertise file paths
- Interaction patterns

## File Structure
```
briefingmemo/
├── SKILL.md
├── scripts/
│   ├── manage_briefings.py      # TUI briefing management system
│   ├── start_deliberation.py    # Main deliberation orchestrator
│   ├── create_brief.py          # Brief creation template
│   ├── poll_research_needs.py   # Research phase polling
│   ├── gather_research.py        # Research data gathering
│   ├── orchestrate_deliberation.py  # Committee deliberation engine
│   ├── generate_memo.py         # Decision memo generation
│   └── post_decision_review.py  # Post-decision analysis
├── briefings/                    # Active briefings directory
│   ├── briefing_YYYYMMDD_HHMMSS.md
│   └── history/                  # Completed briefings
│       └── completed_YYYYMMDD_HHMMSS_*.md
├── references/
│   ├── brief_template.md
│   ├── committee_roles.md
│   ├── analyst-roles.md          # Detailed analyst role descriptions
│   ├── committee-selection.md    # Committee member selection logic
│   ├── decision_framework.md
│   └── memo_template.md
├── config/
│   ├── committee.yaml
│   ├── deliberation_params.yaml
│   └── agent_personas.yaml
├── outputs/
│   ├── dynamic_sections/         # Generated memo sections
│   └── committee_templates/      # Template references
└── assets/
    ├── memo_templates/
    └── decision_frameworks/
```

## Related Committees
This skill integrates with and references the following committees:
- [Leadership Council](../committees/business/leadership-council.md) - Leadership style integration
- [Management Council](../committees/business/management-council.md) - Team management approaches
- [Executive Strategy Committee](../committees/business/executive/executive-strategy-committee.md) - Strategic alignment
- [Legendary CEOs Council](../committees/legendary-ceos-council.md) - Wisdom synthesis patterns

## Key Principles

1. **Structured Input**: All briefs must follow the template format
2. **Research First**: Committee always has access to relevant data
3. **Parallel Processing**: All agents deliberate simultaneously
4. **Adversarial Design**: Agents have conflicting perspectives to expose all angles
5. **Opportunity-Centric**: Partnership & Opportunities Agent ensures all growth avenues are explored
6. **Post-Decision Review**: Cultural, philanthropic, and environmental impacts assessed after decision

## Error Handling
- Invalid briefs: Auto-reject with specific feedback
- Time/budget exceeded: Graceful termination with partial results
- Agent failures: Continue with available agents, log failures
- Research gaps: Proceed with available information, note gaps

## Output Formats
- **Decision Memo**: Structured markdown with decision rationale
- **Committee Transcript**: Full deliberation log
- **Research Package**: Compiled data and sources
- **Post-Decision Review**: Cultural, social, environmental assessment

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/execution/briefingmemo/SKILL.md`
- Scripts: `scripts/create_brief.py`, `scripts/poll_research_needs.py`
- References: `references/*.md`

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
