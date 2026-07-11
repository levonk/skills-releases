---
name: ai-skill-upsert
description: Create new skills, modify and improve existing skills, and measure skill performance. Before creating a new skill, researches existing skills locally, on skills.sh, and on GitHub to avoid duplication and incorporate best ideas. Use when users want to create a skill from scratch, convert an existing workflow file into a skill (preserving git history via git mv), edit or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. Make sure to use this skill whenever the user mentions skill creation, skill development, skill testing, skill evaluation, skill benchmarking, skill optimization, workflow-to-skill conversion, find existing skills for a purpose, or wants to package/distribute skills, even if they don't explicitly ask for a "skill creator." Do NOT trigger on general coding questions, bug fixes, feature implementation, or code review — this skill is for skill lifecycle management, not general development.
version: 2.3.0
user-invocable: true
disable-model-invocation: true
date:
  created: "2026-05-25"
  updated: "2026-07-11"
  last-used: "2026-07-11"
tags:
  - "ai/skill"
  - "skill-creation"
  - "skill-development"
  - "skill-testing"
  - "skill-evaluation"
  - "skill-optimization"
  - "skill-discovery"
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
  - template: "research-phase"
    relationship: "shared-include"
    description: "Shared research phase — search for existing artifacts before creating or improving (also used by ai-guidance-improver, ai-workflow-upsert, knowledge-bundle-lifecycle, and creation workflows)"
  - skill: project-comparison
    relationship: complement
    description: "Shares comparison methodology via comparison-methodology include; project-comparison compares software projects, this skill compares AI skills"
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
# If installed via skills (includes/ is bundled alongside the skill):
bash "$(dirname "$0")/../includes/cli-tool-discovery.sh" <tool-name>

# If not bundled, fetch from the public releases repo:
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


# Skill Creator

A skill for creating new skills and iteratively improving them through test-driven development and systematic evaluation.

## Overview

### What Skills Provide

1. **Specialized workflows** - Multi-step procedures for specific domains
2. **Tool integrations** - Instructions for working with specific file formats or APIs
3. **Domain expertise** - Company-specific knowledge, schemas, business logic
4. **Bundled resources** - Scripts, references, and assets for complex and repetitive tasks

### Skill Architecture (Three Levels)

1. **Level 1: Metadata (always loaded)** — YAML frontmatter in `SKILL.md` (`name` and `description` fields). Lightweight; included in system prompt (~100 words). See `references/anatomy.md` — Frontmatter for required fields and description guidelines.
2. **Level 2: Instructions (loaded when skill triggers)** — Main body of `SKILL.md`. Core workflow and guidance.
3. **Level 3: Bundled Resources (loaded as needed)** — `scripts/` (executable code), `references/` (documentation), `assets/` (templates and files). Unlimited size; scripts can execute without loading into context. See `references/anatomy.md` — Bundled Resources for when to include each type.

## Decision: Create vs Convert vs Update

Before starting, determine which mode applies:

1. **Check whether the target directory contains a `SKILL.md`.**
2. **If no `SKILL.md` exists:**
   - If the user has an existing workflow file (e.g., from `config/ai/workflows/`) → **Mode B: Convert Workflow to a Skill** (preserves git history).
   - Otherwise → **Mode A: Create a New Skill from Scratch**.
3. **If `SKILL.md` already exists** → **Mode C: Update an Existing Skill (Upsert)**. See `references/skill-upsert.md` for the full update workflow.

## Location Selection

Before creating a new skill (Mode A) or converting a workflow (Mode B), determine where the skill should live. Check whether the `skills-src` repository is checked out at the standard location (`~/p/gh/levonk/skills-src/`). If it exists, present three location options to the user:

1. **skills-src repo** (recommended for skills intended for distribution):
   - Public skills: `~/p/gh/levonk/skills-src/src/current/skills/<category>/<name>/`
   - Private skills: `~/p/gh/levonk/skills-src/src/private/skills/<category>/<name>/`
   - Prototype skills (local only): `~/p/gh/levonk/skills-src/src/prototype/skills/<category>/<name>/`
   - Use this when the skill should be versioned, built, and published via the skills-src pipeline.

2. **Current project** (for project-specific skills):
   - `<project-root>/.agents/skills/<category>/<name>/`
   - Use this when the skill is specific to the current project and should travel with that project's repository.

3. **User directory** (for personal skills available across all projects):
   - `~/.agents/skills/<category>/<name>/`
   - Use this when the skill is personal and should be available in every project on the user's machine.

If `skills-src` is not checked out at the standard location, default to option 2 (current project) or option 3 (user directory) based on the user's preference. The selected location becomes the `<output-directory>` passed to `init_skill.py` in Mode A step 1 and Mode B step 1.

See `references/anatomy.md` — skills-src Repository Structure for the full profile-based layout and how `src/<profile>/skills/<category>/<name>/` maps to distribution targets.

## Mode A: Create a New Skill from Scratch

0. **Research existing skills**: Run the research phase before creating. Skip
   only if the user explicitly says "skip research" or "don't search".

   **Skill-specific search** — run the discovery script:
   ```bash
   uv run --script scripts/discover_skills.py "<skill description>"
   ./scripts/discover_skills.py "<skill description>" --verbose
   ./scripts/discover_skills.py "<skill description>" --sources local,skills.sh
   ```
   Searches three sources: local SKILL.md files (skills-src, `.agents/skills/`),
   skills.sh API, and GitHub (`gh api search/code` for SKILL.md files).
   **See `references/skill-discovery.md`** for the detailed analysis workflow.

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


1. **Initialize the skill directory**: Run `scripts/init_skill.py <skill-name> --path <output-directory>` using the location chosen above. The script creates the skill directory (including any nested parent directories like `src/current/skills/<category>/`) with proper structure, a `SKILL.md` scaffolded from `templates/SKILL.md.template` (with frontmatter, invocation control fields, base-ai-guidance and trigger-guard includes, and TODO placeholders), and example resource directories (`scripts/`, `references/`, `assets/`) with example files that can be customized or deleted. See `references/skill-template.md` for the full skill structure and all optional frontmatter fields.
   ```bash
   # If devbox is available and you are not already in a devbox shell:
   devbox run -- python scripts/init_skill.py <skill-name> --path <output-directory>

   # If devbox is not available or you are already in a devbox shell:
   python scripts/init_skill.py <skill-name> --path <output-directory>
   ```
   **Alternative**: If you prefer to create the structure manually, see `references/anatomy.md` — Directory Structure for the required layout.

2. **Customize frontmatter**: Fill in `name`, `description`, `date` (`created`, `updated`, `last-used`), `tags`, `see-also`. The `description` is the primary triggering mechanism — include both what the skill does AND specific contexts for when to use it. Make it slightly "pushy" to combat under-triggering. Add a "Do NOT trigger on..." clause listing cases where the skill would waste effort. See `references/anatomy.md` — Frontmatter for required fields, description guidelines (including negative-trigger guards), and examples.

3. **Write the SKILL.md body as a high-level step overview**: Apply progressive disclosure — use numbered steps in SKILL.md that call scripts and link to reference files named by topic (not by step number). This makes inserting a step a one-line change instead of renumbering across many files. Each step should make it clear: call a script, then use intelligence on the output; or link to a reference file for sequential intelligence steps. See `references/progressive-disclosure.md` — Pattern 5 (Step overview with topic-named references) for the canonical pattern.

4. **Extract deterministic phases into scripts**: Identify sequences of commands that run without needing AI judgment between them. Extract each phase into a single script in `scripts/` — one script per AI→script handoff. SKILL.md should call the script by name and describe what the AI should do with the output; do not inline the script's code. See `references/anatomy.md` — Scripts for the script output contract (quiet by default, `--verbose`, `--dry-run`) and the one-handoff principle.

5. **Move heavy detail to references**: Any detail that would clutter the step overview goes into `references/<topic>.md`. See `references/progressive-disclosure.md` for patterns (high-level guide with references, domain-specific organization, variant-specific organization, conditional details, step overview) and anti-patterns to avoid (duplicating information, deeply nested references, unclear references, step-numbered filenames, monolithic SKILL.md).

6. **Add the base-ai-guidance and trigger-guard includes**: Add `---
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
# If installed via skills (includes/ is bundled alongside the skill):
bash "$(dirname "$0")/../includes/cli-tool-discovery.sh" <tool-name>

# If not bundled, fetch from the public releases repo:
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

` if the skill should inherit the shared framework. Add `---
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
` right after it so over-triggering doesn't waste effort (the guard answers without the skill, explains why, and offers a rerun on `go`).

7. **Ensure all scripts include PEP 723, devbox, and rtk detection patterns**: All bundled scripts must include the PEP 723 inline script metadata header (Python) and devbox/rtk detection patterns at the top. See `references/script-execution-standards.md` for full detection code, wrapper patterns (bash and python), and the combined Python template.

8. **Review security**: Ensure no secrets, keys, or sensitive paths are exposed. See `references/security.md`.

9. **Add evals**: Create `evals/evals.json` and `evals/description_optimization.json` using the templates in `templates/`. See `references/evals-schema.md` for the eval schema and how to run evals.

10. **Package for distribution**: Run `scripts/package_skill.py` to verify structure and package the skill. See `references/anatomy.md` — What NOT to Include for files that should not be part of a skill.

## Mode B: Convert an Existing Workflow to a Skill

When the user provides an existing workflow file and wants it turned into a skill, use this path to preserve the workflow's git history while transforming it into a skill. **See `references/workflow-conversion.md` for the full process**, including the frontmatter requirement (disable auto-loading with `disable-model-invocation: true`), the git-mv-based history preservation, and the optimization checklist.

**Research phase**: Run Step 0 above before converting — an existing skill may
already do what the workflow does. Skip only if the user explicitly says
"skip research".

**High-level steps:**

1. **Create the skill directory** at the target location. Use `init_skill.py` or `mkdir -p` — do NOT create `SKILL.md` yet.
2. **`git mv` the workflow file to `SKILL.md`** inside the new skill directory. This preserves the workflow's git history.
3. **Commit the rename as a standalone commit** — pure rename, no content changes.
4. **Apply skill-based optimizations as separate commits** — frontmatter, structure (progressive disclosure + step overview), script extraction, resources, includes. See `references/workflow-conversion.md` for the full optimization checklist with all sub-bullets.

**Why separate commits:** The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.

## Mode C: Update an Existing Skill (Upsert)

When the target skill directory already exists (`SKILL.md` is present), switch to update mode. The goal is to bring the existing skill into compliance with the skill guidelines without blindly overwriting the author's intent. **See `references/skill-upsert.md` for the full update workflow**, including the audit checklist, prioritized change proposal, and confirmation-before-applying discipline.

**Research phase**: Run Step 0 above before improving — understand the
landscape and whether better-maintained alternatives exist. Skip only if the
user explicitly says "skip research".

**High-level steps:**

1. **Read the existing skill fully** — `SKILL.md`, frontmatter, and all bundled resources.
2. **Audit against the skill guidelines** — frontmatter, description quality, structure, progressive disclosure, context declaration, bundled resources, includes, stale text, security. See `references/skill-upsert.md` for the full audit checklist.
3. **Propose changes — do not apply yet.** Present a prioritized list (Critical / Important / Nice to have) with before/after for each change.
4. **Ask for confirmation before applying.** Let the author accept all, a subset, or reject.
5. **Apply approved changes as separate commits** — one logical change per commit, each independently reviewable and revertable.
6. **Update `date.updated` and `date.last-used`** in the frontmatter when changes are applied. See the date-management include wired in above.
7. **Consistency verification** — after applying changes, verify the skill is internally consistent:
   - Frontmatter fields are valid (`name`, `description`, `version`, `date`, `tags`, `see-also`)
   - All include directives resolve at build time (no leaked delimiters in built output)
   - All `references/` files referenced in SKILL.md exist
   - All `scripts/` files have PEP 723 headers
   - Run `scripts/package_skill.py` to validate structure

**Never silently overwrite.** The author may have intentionally deviated from a guideline. Propose, explain the benefit, and let them decide.

## Cross-Cutting Concerns

### Script Execution Standards

All scripts created by or bundled with a skill must include the PEP 723 inline script metadata header (for uv) and devbox/rtk detection patterns. See `references/script-execution-standards.md` for the full combined template, detection code, wrapper patterns (bash and python), and guidance on applying these standards when the AI agent runs bundled scripts directly.

### Progressive Disclosure

Keep SKILL.md lean; move detail to `references/` and deterministic phases to `scripts/`. See `references/progressive-disclosure.md` for patterns (high-level guide with references, domain-specific organization, variant-specific organization, conditional details, step overview with topic-named references, audience separation) and anti-patterns to avoid.

### Security

Ensure no secrets, keys, or sensitive paths are exposed in skills. See `references/security.md` for security review guidelines.

### Cross-Linking Skills

See the cross-linking include wired in above for guidance on `see-also`
frontmatter format, relationship types, and circular dependency avoidance.

### Enhanced User Interaction

For skills that require user interaction:

1. **Clear prompts**: Ask specific, actionable questions
2. **Progressive disclosure**: Don't overwhelm with information
3. **Default behavior**: Provide sensible defaults
4. **Confirmation steps**: For destructive operations

### Skill Distribution

When packaging a skill for distribution:

1. **Verify structure**: Ensure all required files are present
2. **Test thoroughly**: Run comprehensive evals
3. **Document dependencies**: List required skills/tools/templates
4. **Create examples**: Provide usage examples
5. **Version appropriately**: Use semantic versioning
6. **License clearly**: Specify usage terms

### Audience Separation

When skills serve multiple audiences (e.g., end users vs developers), apply progressive disclosure with clearly labeled audience sections separated by horizontal rules. See `references/progressive-disclosure.md` — Pattern 5b (Audience separation) for the pattern and implementation guidance.

---
## Context Declaration

### File Paths
- Main skill: `src/current/skills/ai/ai-skill-upsert/SKILL.md` (in the `skills-src` repo at `~/p/gh/levonk/skills-src/`)
- References: `src/current/skills/ai/ai-skill-upsert/references/` (including `skill-discovery.md` for the research phase, `skill-template.md` for the full skill structure and frontmatter reference)
- Scripts: `src/current/skills/ai/ai-skill-upsert/scripts/` (including `discover_skills.py` for the research phase)
- Templates: `src/current/skills/ai/ai-skill-upsert/templates/` (including `SKILL.md.template` used by `init_skill.py`)
- Includes: `src/current/includes/` (including `comparison-methodology.md.tmpl` shared with `project-comparison`)

### External Resources
- Matt Pocock's writing-great-skills guide: https://github.com/matt-pocock/writing-great-skills
- skills.sh API: https://www.skills.sh/docs/api
- skills.sh search: https://www.skills.sh/vercel-labs/skills/find-skills

### Project Information
- Project: levonk/skills-src
- Repository: https://github.com/levonk/skills-src
- Owner: levonk
