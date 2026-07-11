---
name: agent-file-upsert
description: Generate or update hierarchical AGENTS.md documentation for AI agents working in codebases. Context-aware — detects and follows the project's existing convention (AGENTS.md, CLAUDE.md, AGENT.md, or combinations via referral/symlink). When updating existing docs, runs delta analysis (git changes since last update) via a script + subagent to extract positive findings, anti-patterns, and improvement candidates. Use when onboarding an AI agent to an existing codebase (Brownfield) to establish context and conventions, or when updating existing agent documentation after significant repo changes. Triggers on requests like "create AGENTS.md", "create CLAUDE.md", "generate agent documentation", "update AGENTS.md", "help AI understand this codebase", or "set up agent guidance for this repo". Do NOT trigger on README generation (use readme-upsert), general coding questions, or skill creation (use ai-skill-upsert).
version: 3.1.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-12-07"
  updated: "2026-07-11"
  last-used: "2026-07-10"
tags: ["ai/skill", "software-development", "documentation", "agents", "brownfield", "hierarchical-docs", "convention-detection", "delta-analysis"]
dependencies: []
see-also:
  - skill: "readme-upsert"
    relationship: "related"
    description: "Generate or update README documentation with similar hierarchical principles"
  - skill: "ai-skill-upsert"
    relationship: "complement"
    description: "For creating new AI skills — pairs with agent-file-upsert for full AI guidance setup"
  - skill: "ai-guidance-improver"
    relationship: "complement"
    description: "Cross-file analysis and system-wide consistency for AI guidance — use when agent-file-upsert surfaces conflicts that span multiple guidance files"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "research-phase"
    relationship: "shared-include"
    description: "Shared research phase — search for existing artifacts and anti-patterns before creating or improving"
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
description: Shared audit and improvement methodology for upserting/improving existing AI guidance files
---

### Audit Methodology

When updating or improving an existing AI guidance file (skill, workflow, agent,
prompt, rule, AGENTS.md), follow this process. The type-specific audit checklist
stays in each consumer's own reference file; this include covers the shared
process discipline that applies to all guidance types.

#### Step 1: Read Fully

Read the existing file completely — frontmatter, body, and any bundled resources
(`scripts/`, `references/`, `assets/`, `evals/`). Understand what the guidance
currently does before proposing any changes. Do not skip this step even if the
file looks familiar.

#### Step 2: Audit Against Guidelines

Check the existing file for compliance with the type-specific guidelines. The
audit checklist for each type lives in the consumer's own reference file — this
step is where type-specific knowledge is applied. Flag every issue found.

#### Step 3: Prioritize

Not all issues are equally important. Group findings into three tiers:

- **Critical**: Missing required frontmatter, broken references, stale text that
  misleads, anything that breaks functionality or discovery.
- **Important**: Description quality, progressive disclosure, context
  declaration, structure issues that cause token inefficiency.
- **Nice to have**: Tag cleanup, see-also relationships, unused example files,
  minor audience separation issues.

#### Step 4: Propose — Do Not Apply Yet

Present a prioritized list of specific, actionable changes. For each change,
show the before/after so the author can see exactly what will change and why.
Do not modify the file at this stage.

#### Step 5: Confirm Before Applying

Present the proposed changes and ask whether to proceed. Let the author:
- Accept all changes
- Accept a subset (cherry-pick)
- Reject entirely

Do not modify the file until the author confirms. The author may have
intentionally deviated from a guideline — propose, explain the benefit, and let
them decide.

#### Step 6: Apply as Separate Commits

Apply approved changes as separate commits, one logical change per commit
(same discipline as format conversion): frontmatter fixes, structure changes,
resource cleanup, include additions — each independently reviewable and
revertable.

#### Step 7: Update Dates

Update `date.updated` and `date.last-used` in the frontmatter when changes are
applied. Set both to the current date (YYYY-MM-DD).

#### Step 8: Validate

After applying improvements:

1. **Check for new conflicts** introduced by changes
2. **Verify all references** point to valid files/sections
3. **Test Go text/templates** render correctly (if `.tmpl` files were modified)
4. **Run `just validate`** to check for leaked delimiters and frontmatter issues
5. **Run `just build`** to confirm the build succeeds

#### Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain
the benefit, and let them decide. Never blindly overwrite the author's intent.

#### Deeper Analysis

For cross-file and system-wide issues (conflicts between files, duplications
across multiple guidance files, scattered context across the AI system), use
the `ai-guidance-improver` skill, which has the full cross-file analysis
framework. Type-specific upsert skills focus on single-file compliance; the
improver handles system-wide consistency.


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

# Agent File Upsert

Generate or update a hierarchical AGENTS.md system to help AI agents work efficiently with minimal token usage (JIT context). Context-aware: detects and follows the project's existing agent-file convention (AGENTS.md, CLAUDE.md, AGENT.md, or combinations). When updating, runs delta analysis to surface positive findings, anti-patterns, and improvement candidates from repository changes since the last update.

## Quick Start

When invoked, this skill analyzes the codebase and creates or updates:
- `AGENTS.md` (Root — primary; CLAUDE.md/AGENT.md maintained as referral or symlink)
- `apps/**/AGENTS.md` (Sub-projects)
- `packages/**/AGENTS.md` (Sub-packages)
- `internal-docs/oos/` (Out-of-scope documentation)
- `internal-docs/improvements/` (Potential improvements — INDEX.md + date-stamped files)
- `internal-docs/anti-patterns/` (Things NOT to do — INDEX.md with 🛑 + date-stamped files)

## Core Principles

- **AGENTS.md is primary**: Always create/maintain AGENTS.md as the canonical source. CLAUDE.md and AGENT.md are referrals or symlinks to it.
- **Lightweight Root**: Keep root AGENTS.md minimal (~100-200 lines)
- **Nearest-wins Hierarchy**: Agents read the closest AGENTS.md first
- **JIT Indexing**: Point to sub-AGENTS.md files rather than duplicating content
- **Token Efficiency**: Prioritize small, actionable guidance over encyclopedic text
- **Progressive Disclosure for Institutional Memory**: Improvements and anti-patterns use INDEX.md (summaries) → detailed files (full rationale). Agents scan the index first, drill in only when the task touches that area.
- **Triple-Mark Anti-Patterns**: Anti-patterns are marked as negative in the AGENTS.md reference, the INDEX.md preamble, and the detailed file title/preamble. Never mistake an anti-pattern for a recommendation.

## Workflow

### Phase 0: Convention Detection

Before generating or updating, detect the project's existing agent-file convention. This determines which files to create, update, and how they relate.

**See `references/convention-detection.md.tmpl`** for the full detection workflow, classification table, and primary file policy.

Summary:
1. Check for `AGENTS.md`, `CLAUDE.md`, `AGENT.md` at root and in major subdirectories
2. Classify the relationship (symlink, referral, independent, single)
3. Determine the convention and apply the primary file policy (AGENTS.md is always primary)
4. When both AGENTS.md and CLAUDE.md exist with independent content, ask the user before consolidating

### Phase 0b: Research Phase

Run the research phase before creating or updating. Skip only if the user explicitly says "skip research" or "don't search".

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


**Artifact-specific search** — search for existing AGENTS.md hierarchies, agent documentation frameworks, and AGENTS.md/CLAUDE.md conventions:
- Local: check for existing `AGENTS.md`, `CLAUDE.md`, `AGENT.md` files in the project
- GitHub: `gh api search/code -f q="AGENTS.md in:path" -f q="repo:{owner}/{repo}"` for existing agent docs in the repo
- External: search for AGENTS.md conventions, CLAUDE.md import syntax, agent documentation best practices
- **Anti-patterns**: search git history for revert/removal commits, check for existing `internal-docs/anti-patterns/`, check issue trackers for rejected approaches

### Phase 1: Repository Analysis

1. **Review Documentation**: Check README.md, docs/, internal-docs/
2. **Analyze Structure**: Identify repo type (monorepo/polyrepo), tech stack, build system
3. **Map Components**: Identify major directories (`apps/`, `services/`, `packages/`)
4. **Identify Patterns**: Code organization, naming conventions, critical files
5. **Output**: A structured map of the repository

### Phase 1b: Delta Analysis (Update Mode Only)

When updating an existing AGENTS.md (not creating from scratch), analyze what changed in the repository since the AGENTS.md was last updated. This surfaces new patterns, removed patterns, and practices that were reverted or abandoned — raw material for improvements and anti-patterns.

**Two-stage process:**

1. **Script — Generate Structured Report**: Run the delta analysis script to produce a deterministic, structured JSON report of commits, new/deleted files, new directories, revert/removal commits, and dependency changes since the cutoff date.
   ```bash
   uv run --script scripts/analyze_git_delta.py {REPO_ROOT} --agents-file AGENTS.md --verbose
   ```
   The cutoff date is determined from the AGENTS.md frontmatter `date.updated` field, or the last git commit that modified the AGENTS.md file (fallback).

2. **Subagent — Interpret the Report**: Spawn a subagent (`subagent_explore` profile) to interpret the structured report and extract three categorized lists:
   - **POSITIVE**: things to add to AGENTS.md (new patterns, conventions, directories, dependencies)
   - **NEGATIVE**: anti-pattern candidates (practices that were reverted, removed, or replaced — with origin)
   - **IMPROVEMENTS**: improvement candidates (gaps or opportunities revealed by the changes)

**See `references/delta-analysis.md.tmpl`** for the full workflow, subagent prompt template, scope control, and output integration.

**When to skip delta analysis:**
- User explicitly says "skip delta analysis" or "just update the docs I pointed you at"
- AGENTS.md was created today (no meaningful delta)
- Repository has no git history

### Phase 2: Generate Root AGENTS.md and Developer Guide

Split content across two files by audience. The root `AGENTS.md` serves **users** (people deploying/using the project); a separate `.agents/knowledge/developer.md` serves **developers** (people working on the code). This is progressive disclosure — developer content is only loaded when an agent is editing code, not when a user is setting up or running the project.

**Root `AGENTS.md`** (user-facing):
- **Project Snapshot**: Repo type, stack
- **Project Overview**: 2-3 sentences on what it does and who it's for
- **Root Setup**: Install, build, test commands (users run these too)
- **Tech Stack**: What's included
- **JIT Index**: Directory map pointing to sub-AGENTS.md files **and the developer guide**
- **Out of Scope Reference**: Link to `internal-docs/oos/`
- **Universal Contracts**: Only rules that bind users (tooling, environment activation)
- **Developer Guide Reference**: Link to `.agents/knowledge/developer.md`

**`.agents/knowledge/developer.md`** (developer-facing):
- **JIT Index**: Pointer to `internal-docs/oos/` (check before adding features)
- **Commands**: Environment-specific commands (devbox, etc.)
- **Workflow**: Branching, TDD, PR process
- **Key Directories**: Repo structure
- **Key Files**: Config files, documentation files
- **Patterns**: Code conventions (✅ DO / ❌ DON'T)
- **Boundaries**: Always / ask-first / never rules
- **Known Gotchas**: Warnings specific to working on the code
- **Definition of Done**: PR checklist

**Audience Separation Rules:**
- Do NOT mix user and developer content in the same file — split them
- The root AGENTS.md links to the developer guide in its JIT Index and a Developer Guide section
- Setup commands appear in the user file (both audiences need them); workflow/process appears in the developer file
- Universal Contracts in the root file contain only rules that bind users; developer-specific rules go in the developer file's `<boundaries>` section

#### Root AGENTS.md Template

See: `references/AGENT-project-root-template.md.tmpl`

The root template provides the user-facing structure: Project Snapshot, Setup, JIT Index (pointing to sub-AGENTS.md files and the developer guide), Out of Scope reference, Universal Contracts, and a Developer Guide link.

#### Developer Guide Template

See: `references/AGENT-project-developer-template.md.tmpl`

Lives at `.agents/knowledge/developer.md`. Contains workflow, key-directories, key-files, patterns, boundaries, known-gotchas, and Definition of Done.

### Phase 3: Generate Sub-Folder AGENTS.md

For each major package/directory, create a detailed file with:

- **Identity**: What it does, tech used
- **Setup & Run**: Package-specific commands
- **Patterns & Conventions**: Most important. File org, naming, "✅ DO / ❌ DON'T" examples
- **Touch Points**: Key files (Auth, API, Config)
- **JIT Index Hints**: Specific search commands (`rg`, `find`) for this package
- **Gotchas**: Specific warnings

#### Sub-Folder AGENTS.md Template

See: `references/AGENT-project-subfolder-template.md.tmpl`

Lives at `{package}/AGENTS.md`. Developer-focused (agents working in code). Contains the DOX-influenced contract sections: Purpose, Ownership, Local Contracts, Patterns, Key Files, Search Hints, Verification, and JIT Index.

### Phase 4: Special Considerations

- **Design System**: Document component usage and tokens
- **Database**: Document ORM, migrations, seeding
- **API**: Document routes, middleware, validation
- **Testing**: Document patterns, mocks, coverage

### Phase 5: Out of Scope Documentation

Maintain an `{REPO_ROOT}/internal-docs/oos/` directory documenting what the repository explicitly does NOT do. This prevents scope creep and helps agents check boundaries before suggesting features.

**Naming Convention:**
- Files: `oos-YYYYMMDDHHmm-{slug}.md` (date-embedded, chronologically sortable)
- Directory: `internal-docs/oos/YYYY/MM/` structure

**Integration:**
- Root AGENTS.md: brief `## Out of Scope` section pointing to `internal-docs/oos/`
- Developer guide: JIT Index entry pointing to `internal-docs/oos/` with a note to check before adding features

### Phase 5b: Improvements Documentation

Maintain an `{REPO_ROOT}/internal-docs/improvements/` directory documenting potential improvements to architecture, standards, and processes. These are **suggestions to consider**, not decisions yet. Populated from delta analysis (Phase 1b) and research phase (Phase 0b) findings.

**Structure:**
- `internal-docs/improvements/INDEX.md` — progressive disclosure entry point (table of all improvements with one-line summaries, status, and links to detailed files)
- `internal-docs/improvements/YYYY/MM/improvements-YYYYMMDDHHmm-{slug}.md` — detailed files with full rationale, current state, proposed change, and origin
- `internal-docs/improvements/{package}/INDEX.md` — package-specific index for monorepos

**See `references/improvements-template.md.tmpl`** for the INDEX.md template, detailed file template, naming convention, and maintenance rules.

**Integration:**
- Root AGENTS.md: `## Improvements` section pointing to `internal-docs/improvements/INDEX.md`
- Developer guide: JIT Index entry pointing to the improvements directory with a note to check before proposing changes (to avoid re-proposing already-evaluated improvements)

### Phase 5c: Anti-Patterns Documentation

Maintain an `{REPO_ROOT}/internal-docs/anti-patterns/` directory documenting things explicitly NOT to do — practices that were tried and found harmful or inferior. Populated from delta analysis (Phase 1b) revert/removal commits and research phase (Phase 0b) anti-pattern discovery.

**Structure:**
- `internal-docs/anti-patterns/INDEX.md` — progressive disclosure entry point. **Every entry summary is prefixed with 🛑** and the preamble says "Do NOT implement any of these approaches."
- `internal-docs/anti-patterns/YYYY/MM/anti-patterns-YYYYMMDDHHmm-{slug}.md` — detailed files with `🛑 Anti-Pattern:` title, `DO NOT DO THIS` preamble, what not to do, why it's wrong, and what to do instead
- `internal-docs/anti-patterns/{package}/INDEX.md` — package-specific index for monorepos

**See `references/anti-patterns-template.md.tmpl`** for the INDEX.md template, detailed file template, naming convention, and the triple-marking rules.

**Critical — Triple Marking:**
Anti-patterns must be clearly marked as negative in **three places** so no reader (human or AI) mistakes them for positive recommendations:
1. **In the AGENTS.md reference**: link text says "things NOT to do" and "do NOT implement"
2. **In the INDEX.md preamble**: header says "Do NOT implement any of these approaches" and every entry summary is prefixed with 🛑
3. **In the detailed file**: title starts with `🛑 Anti-Pattern:` and preamble says `DO NOT DO THIS`

**Integration:**
- Root AGENTS.md: `## Anti-Patterns` section with explicit negative framing pointing to `internal-docs/anti-patterns/INDEX.md`
- Developer guide: JIT Index entry pointing to the anti-patterns directory with a note to check before implementing changes (to avoid re-introducing known-bad approaches)

### Phase 6: Usage Protocol

AGENTS.md files are binding work contracts for their subtrees. Everything in a subtree must stay understandable from the nearest AGENTS.md plus every parent above it. Agents using the generated hierarchy must follow this traversal before editing:

1. Read the root AGENTS.md
2. Identify every file or folder expected to be touched
3. Walk from the repository root to each target path
4. Read every AGENTS.md found along each route
5. If a parent AGENTS.md lists a child AGENTS.md whose scope contains the path, read that child and continue from there
6. Use the nearest AGENTS.md as the local contract and parent docs for repo-wide rules
7. If docs conflict, the closer doc controls local work details, but no child doc may weaken the hierarchy

Do not rely on memory. Re-read the applicable AGENTS.md chain in the current session before editing.

### Phase 7: Maintenance Protocol

When auditing or updating existing AGENTS.md files, follow the shared **Audit Methodology** (included above) for the generic process discipline — read fully, audit against guidelines, prioritize findings, propose before applying, confirm with the author, apply as separate commits, update dates, and validate. The AGENTS.md-specific closeout checklist below covers what the shared process does not.

Every meaningful change requires a documentation pass before the task is done. Update the closest owning AGENTS.md when a change affects:

- Purpose, scope, ownership, or responsibilities
- Durable structure, contracts, workflows, or operating rules
- Required inputs, outputs, permissions, constraints, side effects, or artifacts
- User preferences about behavior, communication, process, organization, or quality
- AGENTS.md creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Small edits that do not change behavior or contracts may leave docs unchanged, but the documentation pass still must happen.

**Closeout checklist:**

1. Re-check changed paths against the AGENTS.md chain
2. Update nearest owning docs and any affected parents or children
3. Refresh every affected JIT Index
4. Remove stale or contradictory text
5. Run existing verification when relevant
6. Report any docs intentionally left unchanged and why

### Phase 8: Consistency Verification

Run the consistency checker to verify the AGENTS.md hierarchy is internally consistent and does not conflict with README.md (produced by the `readme-upsert` skill):

```bash
uv run --script scripts/verify_consistency.py {REPO_ROOT} --verbose
```

**Internal checks** (AGENTS.md hierarchy):
- Root `AGENTS.md` exists
- `.agents/knowledge/developer.md` exists if referenced
- All markdown links in AGENTS.md files point to existing files
- `internal-docs/oos/` exists if referenced
- `internal-docs/improvements/INDEX.md` exists if improvements directory is referenced
- `internal-docs/anti-patterns/INDEX.md` exists if anti-patterns directory is referenced
- Root AGENTS.md is under 250 lines (token efficiency)

**Convention checks** (CLAUDE.md / AGENT.md):
- If `CLAUDE.md` exists, verify it is a valid referral (contains `@AGENTS.md` or a link) or symlink to `AGENTS.md`
- If `AGENT.md` exists, verify it is a valid referral or symlink to `AGENTS.md`
- If `CLAUDE.md`/`AGENT.md` is a symlink, verify the symlink target exists
- If `CLAUDE.md`/`AGENT.md` is a referral, verify the referenced `AGENTS.md` exists

**Cross-checks** (against README.md, if it exists):
- README.md links to AGENTS.md
- Project name (first H1) matches between README.md and root AGENTS.md
- No content duplication (identical paragraph blocks >100 chars)
- README.md doesn't contain AGENTS.md-style sections (JIT Index, Universal Contracts, Definition of Done, Boundaries, Known Gotchas)

Fix all issues before reporting the task complete. The script exits non-zero if any check fails — issues are printed to stderr.

**Semantic consistency check** (not automated — the agent must do this manually):

The script above catches structural conflicts (broken links, duplicated text, wrong sections). It cannot catch **semantic** conflicts — where documentation states facts that disagree with the **code**, with each other, or with **docs**. After the script passes, perform a full-surface semantic consistency check across all four sources of truth:

**Surface area:**
1. **Code** — actual source files, config files (`devbox.json`, `package.json`, `Cargo.toml`, `Justfile`, `Makefile`, etc.), directory structure on disk
2. **AGENTS.md tree** — root `AGENTS.md`, `.agents/knowledge/developer.md`, all sub-folder `AGENTS.md` files
3. **README.md** — the human-facing entry point (if it exists)
4. **docs/** — `internal-docs/oos/`, `internal-docs/improvements/`, `internal-docs/anti-patterns/`, `internal-docs/adr/`, `docs/`, any other documentation directories

**Checks (every fact that appears in more than one source must agree):**

- **Project description**: What the project does and who it's for — same across README.md, root AGENTS.md, and any docs/ overview
- **Tech stack**: Package managers, languages, frameworks, runtime versions, build tools listed in docs must match what's actually in config files (`devbox.json`, `package.json`, `Cargo.toml`, etc.) and what the code actually uses
- **Commands**: Every command referenced in any doc (`just build`, `npm test`, `cargo run`, etc.) must actually exist in the Justfile/Makefile/package.json scripts — no phantom commands
- **Directory structure**: Every directory named in any doc must exist on disk; directories that exist but aren't documented should be evaluated for inclusion
- **Port numbers, URLs, config paths**: Any concrete value mentioned in docs must match what the code actually uses (check config files, source constants, `.env.example`)
- **Dependencies and requirements**: Runtime versions, required tools, minimum versions stated in docs must match what config files pin and what the code requires
- **Architecture decisions**: ADRs in `internal-docs/adr/` must match the architecture the code actually implements — if an ADR says "we chose PostgreSQL" but the code uses SQLite, that's a conflict
- **Out-of-scope claims**: Files in `internal-docs/oos/` claim the repo does NOT do X — verify the code doesn't actually do X. If it now does, the OOS file is stale and must be updated or removed
- **Anti-pattern claims**: Files in `internal-docs/anti-patterns/` claim practice X is harmful — verify the code doesn't actually do X. If it does, either the code or the anti-pattern file needs updating. Anti-pattern files must be clearly marked as negative (🛑, "DO NOT DO THIS") in the file, the INDEX.md, and the AGENTS.md reference
- **Improvement status**: Files in `internal-docs/improvements/` with status `implemented` should correspond to actual changes in the code. If an improvement is marked `implemented` but the code doesn't reflect it, the status is stale
- **Patterns and conventions**: ✅ DO / ❌ DON'T rules in AGENTS.md and the developer guide must match what the code actually does. If the guide says "always use pnpm" but scripts call `npm`, that's a conflict
- **Ownership and boundaries**: If a sub-folder AGENTS.md claims ownership of a directory, verify that directory exists and the described responsibilities match the code in it

**Resolution rule:** When sources disagree, the **code is the source of truth** for what the project actually does. Fix the documentation to match the code. If the code is wrong (not just the docs), flag it to the user — do not silently change code to match docs. If a fact belongs in only one file (e.g., branching strategy is developer-only → AGENTS.md developer guide), ensure the other files link to it rather than restating it differently. Do not leave contradictory facts across any of the four sources.

## Instructions

- **Token Efficiency**: Prioritize small, actionable guidance over encyclopedic text
- **Examples**: Always provide real file paths as examples
- **Commands**: Ensure commands are copy-paste ready
- **Hierarchy**: Agents should read the closest `AGENTS.md` first
- **Structured Data**: Use markdown tables for any tabular data in AGENTS.md files (categories, compliance scores, file inventories, etc.). Markdown tables are readable by both humans and AI agents without learning a custom format. Avoid JSON blocks, TOON, or other custom notations in documentation — markdown tables are the standard.

Example:
```markdown
| Category | Rating | Status | Source Files |
|----------|--------|--------|--------------|
| Auth     | 100%   | ✅ Full | src/auth/    |
| API      | 75%    | ⚠️ Partial | src/api/  |
```

## Design By Contract

### Preconditions
- Access to a readable codebase

### Postconditions
- `AGENTS.md` exists at root (user-facing, primary)
- `CLAUDE.md` and/or `AGENT.md` exist as referral or symlink to `AGENTS.md` (if the project uses those conventions)
- `.agents/knowledge/developer.md` exists (developer-facing)
- `AGENTS.md` files exist in major sub-directories
- `internal-docs/oos/` directory exists with decision documentation
- `internal-docs/improvements/INDEX.md` exists (if delta analysis or research produced improvement candidates)
- `internal-docs/anti-patterns/INDEX.md` exists (if delta analysis or research produced anti-pattern candidates)
- `scripts/verify_consistency.py` passes (no broken links, no README conflicts, CLAUDE.md/AGENT.md referrals valid)

## Example Session

```
User: Create AGENTS.md for this codebase

Claude:
0. Detecting convention...
   [Finds no existing agent files — greenfield, will create AGENTS.md as primary]

0b. Researching existing artifacts and anti-patterns...
   [Searches local, GitHub, external for AGENTS.md conventions and anti-patterns]

1. Analyzing repository structure...
   [Identifies monorepo structure, tech stack, major directories]

2. Generating root AGENTS.md...
   [Creates lightweight root with JIT index]

3. Generating sub-folder AGENTS.md files...
   [Creates detailed guides for apps/web/, packages/core/, etc.]

4. Setting up out-of-scope documentation...
   [Creates internal-docs/oos/ directory structure]

5b. No improvements to record (greenfield — no delta to analyze)

5c. No anti-patterns to record (greenfield — no history to mine)

Done! Created:
- AGENTS.md (root)
- apps/web/AGENTS.md
- packages/core/AGENTS.md
- internal-docs/oos/YYYY/MM/oos-YYYYMMDDHHmm-initial.md
```

```
User: Update the AGENTS.md files — we've made significant changes

Claude:
0. Detecting convention...
   [Finds AGENTS.md + CLAUDE.md (symlink) — following existing convention]

0b. Researching existing artifacts and anti-patterns...
   [Searches for new AGENTS.md conventions, checks existing anti-patterns]

1. Analyzing repository structure...
   [Identifies new packages/auth/ directory, updated tech stack]

1b. Running delta analysis...
   [Script: analyze_git_delta.py — 247 commits since last update]
   [Subagent: extracts 3 positive findings, 2 anti-pattern candidates, 1 improvement]

2-3. Updating AGENTS.md files with positive findings...
   [Adds packages/auth/AGENTS.md, updates root JIT Index]

5b. Recording improvement candidate...
   [Creates internal-docs/improvements/INDEX.md + detailed file]

5c. Recording anti-patterns...
   [Creates internal-docs/anti-patterns/INDEX.md with 🛑 entries + detailed files]

8. Verifying consistency...
   [verify_consistency.py passes — all links valid, CLAUDE.md symlink valid]

Done! Updated:
- AGENTS.md (root — added packages/auth to JIT Index)
- packages/auth/AGENTS.md (new)
- internal-docs/improvements/INDEX.md + improvements-YYYYMMDDHHmm-add-websocket-support.md
- internal-docs/anti-patterns/INDEX.md + anti-patterns-YYYYMMDDHHmm-direct-nx-commands.md
```

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/agent-file-upsert/SKILL.md`
- Convention detection: `references/convention-detection.md.tmpl`
- Delta analysis: `references/delta-analysis.md.tmpl`
- Root template: `references/AGENT-project-root-template.md.tmpl`
- Developer template: `references/AGENT-project-developer-template.md.tmpl`
- Sub-folder template: `references/AGENT-project-subfolder-template.md.tmpl`
- Improvements template: `references/improvements-template.md.tmpl`
- Anti-patterns template: `references/anti-patterns-template.md.tmpl`
- Consistency checker: `scripts/verify_consistency.py`
- Delta analysis script: `scripts/analyze_git_delta.py`
- Output files: `AGENTS.md`, `CLAUDE.md` (referral/symlink), `.agents/knowledge/developer.md`, `**/AGENTS.md`
- Out of scope directory: `{REPO_ROOT}/internal-docs/oos/`
- Improvements directory: `{REPO_ROOT}/internal-docs/improvements/`
- Anti-patterns directory: `{REPO_ROOT}/internal-docs/anti-patterns/`

### Related Skills
- readme-upsert (related) — Generate or update README documentation
- ai-skill-upsert (complement) — For creating new AI skills
- ai-guidance-improver (complement) — Cross-file analysis for system-wide consistency
- base-ai-guidance (base-framework) — Shared framework for all AI guidance types
- research-phase (shared-include) — Shared research phase with anti-pattern discovery

### External Resources
- Project documentation: https://github.com/levonk/dotfiles
- DOX framework (inspiration for usage/maintenance protocols): https://github.com/agent0ai/dox

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk

<!-- vim: set ft=markdown -->
