---
name: tech-maturity
description: Quantify, audit, and visualize a project's technical maturity. Supports both interactive and fully automated AI-driven assessments where AI examines codebases, configuration files, and documentation to score 42 engineering capabilities across 6 dimensions. Use this skill whenever the user asks to assess technical maturity, evaluate engineering practices, audit development processes, score software quality, measure DevOps maturity, analyze code quality practices, review testing coverage, evaluate CI/CD maturity, or wants to understand how mature their technical practices are compared to industry standards.
version: 1.0.0
date:
  created: "2026-06-05"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "tech-maturity", "assessment", "engineering-practices", "audit", "devops-maturity"]
see-also:
  - skill: "repository-health-review"
    relationship: "complement"
    description: "Repository health review skill that complements technical maturity assessment"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
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

# Tech Maturity

Assess and quantify technical maturity across six dimensions: Code, Build & Test, Release, Operations, Security, and Architecture. Use the established rubric from the Tech Maturity project to provide objective, scored evaluations of engineering practices.

## Quick Start

### Interactive Assessment
For manual assessment with guided prompts:

```bash
python scripts/assess_maturity.py /path/to/project --interactive
```

### AI-Driven Automated Assessment
For fully automated AI-driven assessment:

1. Generate an analysis guide:
```bash
python scripts/assess_maturity.py /path/to/project --generate-guide
```

2. [fork] Use the analysis guide to examine the project and score each capability based on evidence

3. Create a JSON file with assessments:
```json
{
  "assessments": {
    "a1": 3,
    "a2": 2,
    "a3": 3,
    ...
  }
}
```

4. Generate the report:
```bash
python scripts/assess_maturity.py /path/to/project --automated assessments.json
```

## Assessment Dimensions

The Tech Maturity rubric evaluates six key areas:

### A. Code
- Code commenting strategy and documentation
- Code management and branching strategy
- Test suite coverage and quality
- Logging and telemetry practices
- Backward/forward compatibility
- Monitoring and alerting
- Quality engineering model
- Code reuse practices
- Availability and resilience testing
- Incremental coding and prototyping
- Feedback and requirements gathering
- Behavior-driven development

### B. Build and Test
- Definition of done completeness
- Code quality metrics
- Security code analysis
- Automated testing
- Continuous integration
- Performance testing and capacity planning
- Configuration file management
- Service consumer tests

### C. Release
- Deployment strategy
- Release automation
- Documentation
- Release communication

### D. Operations
- Incident management
- Monitoring and observability
- Disaster recovery
- Capacity planning
- Change management

### E. Security
- Security policies
- Vulnerability management
- Security testing
- Incident response
- Compliance

### F. Architecture
- System design
- Scalability
- Modularity
- Data management
- Integration patterns

## Scoring System

Each capability is scored on a 1-4 scale:

- **Level 1**: Initial/ad-hoc processes
- **Level 2**: Defined and documented processes
- **Level 3**: Established and standardized processes
- **Level 4**: Optimized and continuously improving

Some capabilities have minimum required levels (specified in the rubric).

## Instructions

The skill supports both interactive and fully automated AI-driven assessment. For the detailed step-by-step process — including the automated assessment workflow, manual assessment steps (Gather Context, Evaluate Capabilities, Generate Report, Analyze Results, Create Improvement Plan), and best practices — see `references/assessment-process.md`.

### Quick Reference

- **Interactive**: `python scripts/assess_maturity.py /path/to/project --interactive`
- **Automated**: Generate guide → examine artifacts → score 42 capabilities → run script → present findings
- **Best practices**: Evidence-based scoring, look for patterns, consider context, document rationale, flag uncertainties

## Examples

### Example 1: AI-Driven Assessment

User: "Assess the technical maturity of my web application project."

Claude's automated workflow:
1. Generates analysis guide with 42 capability definitions and hints
2. Examines project structure, CI/CD configs, documentation, and code
3. Systematically scores each capability based on evidence found:
   - a1 (Code Commenting): Level 3 - Good docstrings and comments
   - a2 (Code Management): Level 2 - Feature branches but >2 weeks lifetime
   - a3 (Test Suite): Level 2 - Basic unit tests, limited integration tests
   - [continues for all 42 capabilities]
4. Generates assessment JSON with all scores
5. Runs assessment script to calculate dimension scores and compliance
6. Presents maturity report with overall score 2.3/4.0, identifies gaps in testing (a3 requires Level 3), and provides prioritized recommendations

### Example 2: Web Application Assessment

Assess a typical web application project:

1. **Code**: Evaluate Git workflow, code review practices, testing coverage
2. **Build & Test**: Review CI pipeline, automated testing, code quality tools
3. **Release**: Check deployment automation, rollback procedures
4. **Operations**: Assess monitoring, alerting, incident response
5. **Security**: Review security scanning, vulnerability management
6. **Architecture**: Evaluate system design, scalability approaches

### Example 2: Microservices Assessment

For a microservices architecture, pay special attention to:
- Service communication patterns
- Distributed tracing
- Configuration management
- Deployment orchestration
- Inter-service testing
- API documentation

### Example 3: Legacy System Assessment

When assessing legacy systems:
- Note technical debt and constraints
- Focus on incremental improvement opportunities
- Identify quick wins that can build momentum
- Consider modernization pathways

## Assessment Best Practices

- **Be objective**: Base scores on evidence, not intentions
- **Use examples**: Document specific examples for each score
- **Involve the team**: Get input from practitioners, not just observations
- **Consider context**: Account for project size, team size, and business constraints
- **Track changes**: Re-assess periodically to measure improvement
- **Benchmark**: Compare against similar projects when possible

## Common Patterns

### Typical Maturity Progression

Most projects follow this progression:
- Start with Level 1-2 in Code and Build & Test
- Improve Build & Test to Level 3-4 before advancing Release
- Operations and Security often lag behind initial development
- Architecture maturity grows with system complexity

### Red Flags

Watch for these warning signs:
- Level 1 in critical security capabilities
- No minimum level compliance in any dimension
- Large gaps between dimensions (e.g., Level 4 Code but Level 1 Operations)
- No testing or CI/CD in place

### Quick Wins

Common high-impact improvements:
- Set up basic CI/CD pipeline
- Add automated testing
- Implement code review process
- Set up basic monitoring and logging
- Document deployment procedures

## References

- **Capabilities Rubric**: `references/capabilities.yaml` - The complete maturity assessment rubric with all capability definitions and scoring criteria
- **Rubric Guide**: `references/rubric-guide.md` - Comprehensive guide for interpreting and using the rubric effectively
- **Assessment Process**: `references/assessment-process.md` - Detailed step-by-step assessment workflow (automated and manual)
- **Assessment Script**: `scripts/assess_maturity.py` - Automated tool for conducting assessments and generating reports (supports --interactive, --automated, and --generate-guide modes)
- **Assessment Template**: `assets/assessments-template.json` - Template JSON file for automated assessments with all 42 capability keys
- **Tech Maturity Project**: https://github.com/techmaturity/techmaturity - Source of the assessment framework

## Output Formats

The assessment generates several outputs:

1. **JSON Report**: Machine-readable scores and metadata
2. **HTML Report**: Interactive visualizations and detailed analysis
3. **Radar Chart**: Visual representation of maturity across dimensions
4. **Bar Charts**: Score breakdowns by capability
5. **Recommendations**: Prioritized improvement suggestions

## Integration with Development Workflows

Consider integrating maturity assessments into:
- Project onboarding and due diligence
- Quarterly engineering health checks
- Pre-acquisition technical due diligence
- Team retrospective processes
- Architecture review processes
- Compliance audits

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/tech-maturity/SKILL.md`
- Scripts: `scripts/assess_maturity.py`
- References: `references/capabilities.yaml`, `references/rubric-guide.md`, `references/assessment-process.md`
- Assets: `assets/assessments-template.json`

### Related Skills
- repository-health-review (complement)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
