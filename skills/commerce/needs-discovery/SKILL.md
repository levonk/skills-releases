---
name: shopping-needs-discovery
description: >
  Discover and refine purchasing requirements through structured interviewing.
  Use when a user needs help figuring out what product or service to buy, needs
  to hire a service provider (plumber, electrician, contractor, tutor, etc.),
  has a problem that requires a purchase to solve, or has a vague idea of what
  they want but needs help narrowing it down. Covers: (1) timeline elicitation
  (nice-to-have vs essential deadlines), (2) product-vs-service classification,
  (3) intelligent numbered questions with lettered answer choices and pre-filled
  best-guess defaults, (4) problem-to-product/service mapping when the user
  describes a problem rather than a product, (5) alternative discovery when the
  user names a specific product, (6) product/service recommendation with
  comparative rationale, (7) constraint identification including known defects,
  version pitfalls, reliability issues, seller reputation, licensing/insurance
  requirements for services, and environmental hazards, (8) replacement part
  identification — when the user has a broken item, determines whether a
  specific replacement part is viable and researches the exact manufacturer
  part number for cheaper sourcing than model-name searches, including a
  repairability check that warns when components are soldered, glued, or
  cryptographically paired and cannot be user-replaced, including repair cost
  vs replacement cost analysis. (9) comprehensive constraint identification
  covering obsolescence risks (OS update horizon, company viability, cloud
  dependency death, ecosystem lock-in), used-specific risks (hidden damage,
  counterfeit, battery degradation, non-transferable warranty, recall
  non-compliance), total cost of ownership (subscription lock-in,
  cheap-to-buy-expensive-to-own, maintenance burden, disposal cost),
  environmental and situational mismatches, financial traps, safety/legal
  issues, and real estate constraints (zoning, terrain, access, utilities,
  title, toxicity, market risks). Uses progressive disclosure — an attribute
  index with applicability matrix so only relevant constraint files are
  loaded (e.g., a watch purchase loads repairability and TCO but not real
  estate or consumables; a property purchase loads real estate but not
  obsolescence). Includes service vendor tier differentiation (CPA vs
  bookkeeper, licensed electrician vs handyman) and consumables-specific
  constraints (shelf life, bulk economics, storage). Real estate is split
  into generic constraints plus sub-domains: residential (owner-occupied),
  investment (flip/hold/develop), rental (landlord), commercial (retail/
  office/industrial), and leasee (tenant-side leasing). Product-specific
  domain files cover automobiles (EV/PHEV, hybrid, exotic, truck, RV),
  major appliances (HVAC, water heater, laundry, kitchen, refrigeration,
  spa, commercial vs consumer), small appliances, cameras, mobile phones,
  collectibles, yard tools, computer parts (CPU/motherboard, GPU, RAM/
  storage, PSU/case/cooling, monitor/peripherals), and tools (woodworking,
  metalworking, welding, gardening, pottery). Leasee (tenant) is split into
  generic tenant constraints plus home rental, apartment rental, and
  commercial lease sub-domains. Section 5 documents the 3-level progressive
  disclosure chain (attribute index → attribute files → domain files) with
  worked examples.
version: 1.8.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-13"
  last-used: "2026-07-13"
tags: ["ai/skill", "commerce", "shopping", "needs-assessment", "product-research"]
see-also:
  - skill: "shopping-deal-intelligence"
    relationship: "dependent"
    description: "Consumes the Needs Discovery Brief to research pricing, sourcing, and timing"
  - skill: "shopping-acquisition"
    relationship: "dependent"
    description: "Final execution layer — completes purchases or service bookings identified by needs-discovery"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-deal-intelligence
  - type: skill
    name: shopping-acquisition
  - type: url
    name: Consumer Reports
    url: https://www.consumerreports.org/
  - type: url
    name: Wirecutter
    url: https://www.nytimes.com/wirecutter/
  - type: url
    name: NHTSA Recalls
    url: https://www.nhtsa.gov/recalls
  - type: url
    name: CPSC Recalls
    url: https://www.cpsc.gov/Recalls
  - type: url
    name: Thumbtack
    url: https://www.thumbtack.com/
  - type: url
    name: Angi
    url: https://www.angi.com/
  - type: url
    name: Google Local Services
    url: https://ads.google.com/local-services-ads/
  - type: url
    name: Yelp
    url: https://www.yelp.com/
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



# Shopping Needs Discovery

Structured intake process that transforms a vague need or problem into a concrete, ranked list of candidate products or services with justified reasoning.

## Effort Tier Awareness

This skill respects the effort tier assigned by the agent in Phase 0. For **Quick** tier items (under $50), compress questioning to 1–2 essential questions and skip deep constraint research. For **Standard** and above, run the full workflow.

## Core Workflow

### 1. Timeline Elicitation

Establish two dates immediately:

| Date | Meaning | Example prompt |
|------|---------|----------------|
| **Nice-to-have** | When life would be easier with the solution | "When would it be *nice* to have this?" |
| **Essential** | Hard deadline after which the need becomes critical | "When is it *essential* — what breaks if you don't have it?" |

Use these dates to gate urgency throughout all downstream skills (deal-intelligence timing, acquisition auto-buy thresholds).

### 2. Intelligent Questioning

Present questions in numbered format with lettered answer choices. Pre-fill best-guess answers based on context so the user can confirm or override. Limit to 3–5 questions per round; follow up if needed.

For the full questioning format example, rules, and product-vs-service classification table, see `references/questioning-examples.md`.

### 2.5. Product vs Service Classification

Before deep questioning, classify the request as **Product**, **Service**, or **Both**. For services, add scope-of-work, urgency, previous-provider, and license/insurance questions to the intelligent questioning round.

For the full classification table and service-specific questions, see `references/questioning-examples.md`.

### 2.6. Replacement Part vs Full Product

When the user describes a **broken or malfunctioning item** they already own,
determine whether they need a specific replacement part or a whole new
product. If a replacement part is viable, identify the **exact manufacturer
part number** — not just the product model number. Searching by part number
yields dramatically cheaper sourcing than searching by model name (model
searches surface pre-packaged repair kits with a convenience markup; part
number searches surface the raw OEM component from multiple suppliers).

For the part-vs-product decision matrix, **repairability check** (verifying
the component is actually user-replaceable — some modern devices have
soldered, glued, or cryptographically paired components that cannot be
swapped), part-number identification workflow, and part number sources
(service manuals, iFixit, parts diagrams, device labels, FCC ID lookup), see
`references/part-identification.md`.

When part identification succeeds, include a `Replacement Part` section in the
Needs Discovery Brief (see the reference for the format) so deal-intelligence
can search by part number instead of model number.

### 2.7. Spec Interpretation — Floors vs Ceilings

Numeric specs the user states (range, capacity, mileage, RAM, storage, power,
runtime, MPG, towing, resolution, etc.) are **minimums (floors)**, not target
values. A product that exceeds a stated spec at equal or better value is a
**benefit**, not a mismatch — surface it and flag the upgrade. Do not narrow
the candidate pool to items that merely match the spec; rank by value
(price ÷ delivered capability), not by closeness to the number the user said.

**Treat a spec as a ceiling (maximum) only when the user explicitly caps it**,
using language like "only", "at most", "no more than", "exactly", "ceiling",
"don't need more than", or "keep it under". Absent an explicit cap, assume floor.

This rule exists because reading a spec as a target produces bad outcomes: a
request for "a BEV with ~90 miles of range" is a request for *at least* enough
range to cover the user's daily driving at a good price — a 200-mile EV priced
below a rare 90-mile model is the better recommendation, not a miss. The user's
number reflects a *need*, not a *limit*.

When the floor interpretation would surprise the user (e.g., the best-value
candidate far exceeds the stated spec), state the assumption explicitly in the
brief and let the user correct it: "Treating 90 mi as a minimum; the best value
is a 220-mi EV at $X — say 'only ~90 mi' if you want a hard cap."

Record every numeric spec in the Needs Discovery Brief as either `min: <value>`
(default) or `ceiling: <value>` (only when the user capped it) so downstream
deal-intelligence cannot misread the intent.

### 3. Problem-to-Product/Service Mapping

When the user describes a **problem** rather than a product or service: restate the problem, identify 2–5 solution categories (both "buy a thing" and "hire someone" where applicable), rank by fit/cost/timeline, and present as a decision table.

For the decision table format example, see `references/questioning-examples.md`.

### 3.5. Alternative Discovery

When the user **names a specific product** (e.g., "I want to buy a Dyson V15"): acknowledge the pick, research alternatives from authoritative sources (Consumer Reports, Wirecutter, Reddit, YouTube reviewers), and present as a comparison table.

For the comparison table format example and skip conditions, see `references/questioning-examples.md`.

### 4. Product/Service Recommendation with Rationale

Once the category is locked, recommend 2–4 specific products or service providers:

- **Why chosen**: 2–3 sentences per pick linking back to user requirements
- **Why not alternatives**: Brief explanation of why each major alternative was rejected (e.g., "Brand X has a known firmware issue on v3.2 that causes overheating", "Brand Y discontinued support in 2025")
- **Comparison matrix** using the standard iconography:

---
description: Shared commerce rating icons for product/service comparison and deal assessment — ⭐ best in class, ☑️ good/acceptable, ⚠️ caution/trade-off, ❌ deal-breaker. Use in needs-discovery, deal-intelligence, and acquisition skills.
---

# Commerce Rating Icons

Use these icons when rating products, services, or deals in commerce skills.
The 4-level scale captures purchase-relevant distinctions from best-in-class
to deal-breaker.

| Icon | Meaning | Criteria |
|---|---|---|
| ⭐ | **Best in class** | Top recommendation — excels on the user's priority requirements |
| ☑️ | **Good / acceptable** | Meets requirements adequately — solid choice, no standout advantage |
| ⚠️ | **Caution / trade-off** | Usable but has a known trade-off, risk, or caveat — proceed with eyes open |
| ❌ | **Deal-breaker** | Fails a hard requirement — disqualify or reject |

## Usage Rules

- **One icon per cell.** Don't combine — pick the most accurate single rating.
- **Reserve ⭐ for the top pick.** Not every acceptable option is best-in-class;
  ⭐ is for the option that best matches the user's stated priorities.
- **Use ⚠️ for known trade-offs.** If a product has a firmware issue, a
  discontinued support timeline, or a TCO concern, mark it ⚠️ with a note.
- **Use ❌ for hard disqualifiers.** Missing license, no insurance, demanding
  full payment upfront — these are non-negotiable failures.

## Comparison Matrix Format

In a product/service recommendation matrix:

```markdown
| Product | Rating | Why |
|---|---|---|
| Brand A | ⭐ Best in class | Excels on [priority requirement] |
| Brand B | ☑️ Good | Meets requirements, no standout |
| Brand C | ⚠️ Caution | Known firmware issue on v3.2 |
| Brand D | ❌ Deal-breaker | Discontinued support in 2025 |
```

## Red-Flag Scoring Format

For deal-intelligence red-flag scoring, the same icons map to severity:

```markdown
| Red Flag | Severity |
|----------|----------|
| No license when required by law | ❌ Disqualify |
| No insurance | ❌ Disqualify |
| No written estimate | ⚠️ Major concern |
| Very new with no reviews | ☑️ Caution — may be fine, get references |
```

## Legend Format

When presenting a commerce comparison, include the legend:

```markdown
**Ratings**: ⭐ Best in class · ☑️ Good · ⚠️ Caution · ❌ Deal-breaker
```


### 5. Constraint Identification

Proactively research and surface constraints before the user asks. The
constraint system uses **3-level progressive disclosure**:

1. **Level 1 — Attribute index** (`references/constraint-attributes.md`):
   Always loaded. Contains an applicability matrix mapping purchase types
   to relevant attributes and domain files. The AI reads this to determine
   which files to load next.
2. **Level 2 — Attribute files** (`references/attributes/*.md`): Loaded
   when the attribute applies to the purchase type. Each file covers one
   cross-cutting constraint (obsolescence, repairability, TCO, used risks,
   situational fit).
3. **Level 3 — Domain files** (`references/domains/*.md` or
   `references/domains/<category>/index.md` + sub-domains): Loaded when the
   purchase matches a product domain. Domain files contain
   product-specific constraints that don't apply elsewhere. Some domains
   have their own sub-domain index (e.g., real-estate, automobiles,
   appliances, computer-parts, tools, leasee) — load the domain index first,
   then the specific sub-domain.

**Load only the files that apply to the current purchase type.** Examples:

- A **watch** purchase: Level 1 index → Level 2 repairability + TCO → Level
  3 collectibles (if luxury). No real estate, no consumables, no
  obsolescence (mechanical).
- A **property purchase**: Level 1 index → Level 2 (none needed for raw
  land) → Level 3 `real-estate/index.md` (generic) → `real-estate/
  residential.md` (if buying a home). No obsolescence, no consumables.
- **Renting an apartment**: Level 1 index → Level 3 `real-estate/index.md`
  (generic) → `real-estate/leasee/index.md` (generic tenant) →
  `real-estate/leasee/apartment.md` (apartment-specific). No repairability,
  no obsolescence.
- A **food/consumable** purchase: Level 1 index → Level 3 `consumables.md`.
  No repairability, no obsolescence, no warranty.
- A **service** hire: Level 1 index → Level 3 `services.md` (including
  vendor tier differentiation — CPA vs bookkeeper, licensed electrician vs
  handyman). No repairability or obsolescence.
- A **used laptop**: Level 1 index → Level 2 obsolescence + repairability +
  TCO + used-risks → Level 3 `computer-parts/` (if building). No real
  estate, no consumables.
- An **EV purchase**: Level 1 index → Level 2 obsolescence + repairability
  + TCO + used-risks (if used) + situational-fit (charging infra) → Level 3
  `automobiles/index.md` + `automobiles/ev-phev.md`.

The index file contains an applicability matrix showing which attributes
apply to common purchase types. Attribute and domain reference files:

- `attributes/obsolescence.md` — OS/firmware update horizon, company
  viability (cloud device bricking), ecosystem lock-in, right-to-repair
  hostility
- `attributes/repairability.md` — iFixit scores, parts availability,
  service network, soldered/paired/glued components, repairability tiers
- `attributes/total-cost-of-ownership.md` — subscription lock-in,
  cheap-to-buy-expensive-to-own, maintenance burden, disposal cost,
  depreciation cliff, TCO calculation
- `attributes/used-risks.md` — buy-new-vs-used rules, hidden damage,
  non-transferable warranty, counterfeit risk, battery degradation,
  title/ownership issues, recall non-compliance, banned substances
- `attributes/situational-fit.md` — climate mismatch, infrastructure
  dependency, space/installation constraints, financial traps
- `domains/real-estate/index.md` — generic real estate constraints (zoning,
  terrain, soil, flood, wetlands, access, utilities, HOA/CC&Rs, mineral
  rights, easements, toxicity, market risks) + sub-domain index
- `domains/real-estate/residential.md` — owner-occupied: schools, commute,
  neighborhood, property condition, HOA livability, financing, resale
- `domains/real-estate/investment.md` — appreciation/ROI: cap rate, cash
  flow, market analysis, exit strategy, risk factors
- `domains/real-estate/rental.md` — landlord: tenant law, rent control,
  eviction, vacancy, property management, tenant screening, insurance, tax
- `domains/real-estate/commercial.md` — commercial: property types, Phase
  I/II environmental, zoning/use, lease types (NNN/gross), tenant credit,
  ADA, TI, financing
- `domains/real-estate/leasee/index.md` — generic tenant constraints: lease
  terms, rent escalation, key provisions, hidden costs, tenant rights,
  negotiation leverage + sub-domain index
- `domains/real-estate/leasee/home.md` — house rental: maintenance
  responsibility split, higher utilities, driveway/garage parking, private
  landlord vs property management, privacy, HOA considerations, neighborhood
- `domains/real-estate/leasee/apartment.md` — apartment rental: noise
  (shared walls, upstairs, hallway), parking scarcity, amenities, building
  management quality, move-in logistics, unit-specific checks, renewal
- `domains/real-estate/leasee/commercial.md` — commercial lease: NNN/gross/
  modified gross, TI negotiation, exclusive use, co-tenancy, personal
  guarantee, percentage rent, customer parking
- `domains/services.md` — vendor tier differentiation (CPA vs bookkeeper,
  electrician vs handyman), licensing, insurance/bonding, permits,
  complaint history, seasonal availability, red flags
- `domains/consumables.md` — shelf life, bulk economics, quality/sourcing,
  storage requirements
- `domains/automobiles/index.md` — generic vehicle constraints (title, VIN,
  recalls, PPI, insurance, financing, depreciation) + sub-domain index
- `domains/automobiles/ev-phev.md` — EV/PHEV: charging, battery health, range,
  tax credits, software horizon
- `domains/automobiles/hybrid.md` — hybrid battery, regen braking, inverter,
  CVT, warranty
- `domains/automobiles/exotic.md` — specialist mechanic, parts, maintenance
  costs, insurance, storage
- `domains/automobiles/truck.md` — payload, towing, diesel vs gas, bed/cab
  configurations
- `domains/automobiles/rv.md` — Class A/B/C, systems, winterization, storage,
  depreciation, roof/tire maintenance
- `domains/appliances/index.md` — generic appliance constraints (energy,
  sizing, delivery, warranty, reliability) + sub-domain index
- `domains/appliances/hvac.md` — SEER2, sizing, refrigerant, ductwork, heat
  pump cold climate
- `domains/appliances/water-heater.md` — tank vs tankless, fuel types, sizing,
  venting
- `domains/appliances/laundry.md` — washer/dryer/combo, front vs top load, gas
  vs electric vs heat pump
- `domains/appliances/kitchen.md` — dishwasher, range/oven, pizza oven, gas vs
  induction
- `domains/appliances/refrigeration.md` — fridge configs, freezer, compressor,
  warranty
- `domains/appliances/spa.md` — sauna (traditional vs infrared), hot tub
  electrical/chemistry/permits
- `domains/appliances/commercial-vs-consumer.md` — durability, NSF, electrical,
  warranty, when to buy commercial
- `domains/small-appliances.md` — blender, food processor, pressure cooker,
  fryer, mixer, meat grinder
- `domains/cameras.md` — DSLR/mirrorless/compact/action, sensor, lens
  ecosystem, used checks
- `domains/mobile-phones.md` — OS horizon, battery health, carrier
  compatibility, repairability, used red flags
- `domains/collectibles.md` — authentication, grading, provenance, storage,
  insurance, liquidity, fakes
- `domains/yard-tools.md` — mowers, trimmers, blowers, chainsaws, gas vs
  battery vs corded, yard size matching
- `domains/computer-parts/index.md` — compatibility, bottleneck analysis, used
  market, warranty + sub-domain index
- `domains/computer-parts/cpu-motherboard.md` — socket, chipset, VRM, BIOS,
  form factor, PCIe
- `domains/computer-parts/gpu.md` — PSU, case clearance, VRAM, driver horizon,
  used mining risks
- `domains/computer-parts/ram-storage.md` — speed/timing, capacity, NVMe vs
  SATA, TBW, CMR vs SMR
- `domains/computer-parts/psu-case-cooling.md` — wattage, efficiency, quality
  tiers, airflow, CPU cooling
- `domains/computer-parts/monitor-peripherals.md` — panel types, resolution,
  HDR, color accuracy, keyboard/mouse
- `domains/tools/index.md` — power source, battery ecosystem, quality tiers,
  safety, used market + sub-domain index
- `domains/tools/woodworking.md` — table saw, miter saw, router, planer,
  jointer, bandsaw, dust collection
- `domains/tools/metalworking.md` — lathe, mill, bandsaw, grinder, measuring,
  workholding
- `domains/tools/welding.md` — MIG/TIG/stick/flux-cored, duty cycle, input
  power, gas, safety
- `domains/tools/gardening.md` — hand tools, long-handle, pruning, soil prep,
  ergonomics
- `domains/tools/pottery.md` — wheel, kiln, clay, glazes, safety (silica,
  ventilation)

## Output Format

Deliver a **Needs Discovery Brief** containing:

```markdown
## Needs Discovery Brief

### Timeline
- Nice-to-have by: YYYY-MM-DD
- Essential by: YYYY-MM-DD

### Effort Tier: [Quick | Standard | Major | High-value]

### Requirements Summary
- Primary need: ...
- Type: [Product | Service | Both]
- Use case: ...
- Budget: ...
- Key specs: [each as `min: <value>` (default) or `ceiling: <value>` (only if user capped it) — e.g., `min: 90 mi range`, `min: 16 GB RAM`, `ceiling: $25k`]
- Key constraints: ...

### Recommended Products/Services
| Rank | Product/Provider | Type | Why | Price Range |
|------|-----------------|------|-----|------------|
| 1 | ... | Product/Service | ... | ... |

### Replacement Part (if applicable)
- Device model: ...
- Manufacturer part number: ...
- Repairability: [User-replaceable / Not replaceable — reason]
- Part-only cost estimate: $X–$Y
- Full replacement cost estimate: $Z
- Repair vs replacement analysis: [Total repair cost vs working used replacement]
- Repair recommendation: ...

### Alternatives Considered (if user named a specific product)
| # | Alternative | vs User's Pick | Verdict |
|---|------------|---------------|---------|

### Constraints & Warnings
- ...

### Next Step
→ Hand off to deal-intelligence skill for pricing research
```

## Handoff

Pass the Needs Discovery Brief to the **shopping-deal-intelligence** skill for pricing, sourcing, and timing analysis.

## Resources

- `references/questioning-examples.md` — Questioning format example, rules, product-vs-service classification table, problem-to-product decision table, alternative discovery comparison table
- `references/constraint-attributes.md` — Index of all constraint attributes and domain-specific checks with applicability matrix; load only the relevant attribute/domain files
- `references/attributes/obsolescence.md` — OS/firmware update horizon, company viability, cloud device bricking, ecosystem lock-in, right-to-repair hostility
- `references/attributes/repairability.md` — iFixit scores, parts availability, service network, soldered/paired/glued components, repairability tiers
- `references/attributes/total-cost-of-ownership.md` — Subscription lock-in, cheap-to-buy-expensive-to-own, maintenance burden, disposal cost, depreciation cliff, TCO calculation
- `references/attributes/used-risks.md` — Buy-new-vs-used rules, hidden damage, non-transferable warranty, counterfeit risk, battery degradation, title/ownership issues, recall non-compliance, banned substances
- `references/attributes/situational-fit.md` — Climate mismatch, infrastructure dependency, space/installation constraints, financial traps
- `references/domains/real-estate.md` — Zoning, terrain, soil, flood, wetlands, access, utilities, HOA/CC&Rs, mineral rights, easements, toxicity, market risks
- `references/domains/services.md` — Vendor tier differentiation (CPA vs bookkeeper, electrician vs handyman), licensing, insurance/bonding, permits, complaint history, seasonal availability, red flags
- `references/domains/consumables.md` — Shelf life, bulk economics, quality/sourcing, storage requirements
- `references/part-identification.md` — Replacement part vs full product decision, repair cost vs replacement cost analysis, repairability check (soldered/paired/locked components), manufacturer part number identification workflow, part number sources

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/commerce/needs-discovery/SKILL.md`
- References: `references/questioning-examples.md`, `references/constraint-attributes.md`, `references/attributes/obsolescence.md`, `references/attributes/repairability.md`, `references/attributes/total-cost-of-ownership.md`, `references/attributes/used-risks.md`, `references/attributes/situational-fit.md`, `references/domains/real-estate/index.md`, `references/domains/real-estate/residential.md`, `references/domains/real-estate/investment.md`, `references/domains/real-estate/rental.md`, `references/domains/real-estate/commercial.md`, `references/domains/real-estate/leasee/index.md`, `references/domains/real-estate/leasee/home.md`, `references/domains/real-estate/leasee/apartment.md`, `references/domains/real-estate/leasee/commercial.md`, `references/domains/services.md`, `references/domains/consumables.md`, `references/domains/automobiles/index.md`, `references/domains/automobiles/ev-phev.md`, `references/domains/automobiles/hybrid.md`, `references/domains/automobiles/exotic.md`, `references/domains/automobiles/truck.md`, `references/domains/automobiles/rv.md`, `references/domains/appliances/index.md`, `references/domains/appliances/hvac.md`, `references/domains/appliances/water-heater.md`, `references/domains/appliances/laundry.md`, `references/domains/appliances/kitchen.md`, `references/domains/appliances/refrigeration.md`, `references/domains/appliances/spa.md`, `references/domains/appliances/commercial-vs-consumer.md`, `references/domains/small-appliances.md`, `references/domains/cameras.md`, `references/domains/mobile-phones.md`, `references/domains/collectibles.md`, `references/domains/yard-tools.md`, `references/domains/computer-parts/index.md`, `references/domains/computer-parts/cpu-motherboard.md`, `references/domains/computer-parts/gpu.md`, `references/domains/computer-parts/ram-storage.md`, `references/domains/computer-parts/psu-case-cooling.md`, `references/domains/computer-parts/monitor-peripherals.md`, `references/domains/tools/index.md`, `references/domains/tools/woodworking.md`, `references/domains/tools/metalworking.md`, `references/domains/tools/welding.md`, `references/domains/tools/gardening.md`, `references/domains/tools/pottery.md`, `references/part-identification.md`

### Related Skills
- `shopping-deal-intelligence` (dependent) — consumes the Needs Discovery Brief for pricing, sourcing, and timing
- `shopping-acquisition` (dependent) — final execution layer for purchases or service bookings
- `base-ai-guidance` (base-framework) — shared framework for all AI guidance types

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
