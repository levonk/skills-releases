---
type: Concept
title: Composition Chain
description: How primitives compose bottom-up — templates → prompts → workflows → skills → agents → committees — with build-time and runtime composition patterns.
tags: [ai-primitives, composition, chain, templates, prompts, workflows, skills, agents, committees]
timestamp: 2026-07-11T10:30:00Z
---

# Composition Chain

The skills-src primitives compose bottom-up: each layer uses the layers
below it. This document traces the full composition chain and the patterns
used at each level.

## The Chain

```
Templates → Prompts → Workflows → Skills → Agents → Committees
```

Each layer uses the layers below:

1. **Templates** provide reusable structures
2. **Prompts** instantiate templates into specific instructions
3. **Workflows** use prompts as step instructions in multi-step procedures
4. **Skills** invoke workflows for complex procedures and bundle scripts/references
5. **Agents** use skills as capabilities to accomplish domain tasks
6. **Committees** compose agents to deliberate and synthesize

## Layer 1: Templates

Templates are the foundation — reusable structures with variable schemas.

### What Templates Provide

- **Variable schemas** — defined inputs with types, defaults, and rendering rules
- **Section structure** — headings defining the output format
- **Rendering rules** — how variables map to output
- **Composable contracts** — templates that can be safely used without additional explanation

### Template Composition

Templates compose via:
- **Meta-templates** — `templates/meta/template-template.md` defines the
  structure for new templates (a template that creates templates)
- **Includes** — `{{{ include "..." . }}}` pulls in shared content at build time
- **Variable schemas** — templates define inputs that callers must provide

### Template Examples

- `templates/ai/prompt-skeleton.md.tmpl` — Prompt structure skeleton
- `templates/meta/agent-template.md.tmpl` — Agent definition template
- `templates/ai/knowledge-bundle/references/concept-template-resource-bound.md` — Resource-bound concept template

## Layer 2: Prompts

Prompts instantiate templates into specific, structured instructions.

### How Prompts Use Templates

- Prompts can be created from templates via the `ai-prompt-create` workflow
- Templates provide the structure; the prompt fills in the variables
- The Levonk methodology (DECONSTRUCT, DIAGNOSE, DEVELOP, DELIVER) transforms
  vague requests into structured prompts

### Prompt Composition

Prompts compose via:
- **Multi-prompt task sets** — prompts numbered for parallel/sequential execution
- **Thinking triggers** — cues that prompt reasoning before acting
- **Validation hooks** — checks that verify output meets criteria

## Layer 3: Workflows

Workflows use prompts as step instructions in multi-step procedures.

### How Workflows Use Prompts

- Workflow steps are essentially structured prompts
- The Template/Wrapper pattern separates the wrapper (frontmatter + trigger)
  from the content template (the actual steps/prompts)

### How Workflows Use Templates

- **Template/Wrapper pattern**: wrapper file has frontmatter + `includeTemplate`
  call; content template has the actual steps
- `base-workflow-guidance.md.tmpl` bundles shared workflow guidance:
  - `base-ai-guidance.md` (universal creation framework)
  - `levonk-methodology-core.md` (methodology)
  - `workflow-design-principles.md` (design principles)

### Workflow Composition

```go
{{{ include "workflows/ai/includes/base-workflow-guidance.md" . }}}
{{{ include "includes/trigger-guard.md" . }}}
{{{ include "includes/research-phase.md" . }}}
{{{ include "includes/cross-linking.md" . }}}
{{{ include "includes/date-management.md" . }}}
{{{ include "includes/clarifying-questions.md" . }}}
{{{ include "includes/script-materialization.md" . }}}
```

Workflows are lighter than skills — no `scripts/`, `references/`, `evals/`,
or `assets/` subdirectories. If a workflow needs these, convert it to a skill.

## Layer 4: Skills

Skills invoke workflows for complex procedures and bundle scripts/references.

### How Skills Use Workflows

- Skills can invoke workflows for multi-step procedures
- `see-also` with `workflow:` declares runtime dependencies on workflows
- Skills are heavier than workflows — they bundle scripts, references, evals

### How Skills Use Templates

- `see-also` with `template:` declares build-time dependencies (inlined at render)
- Templates provide the structural framework (base-ai-guidance, base-frontmatter)

### How Skills Use Includes

Skills pull in shared guidance at build time:

```go
{{{ include "includes/base-ai-guidance.md" . }}}
{{{ include "includes/trigger-guard.md" . }}}
{{{ include "includes/research-phase.md" . }}}
{{{ include "includes/cross-linking.md" . }}}
{{{ include "includes/date-management.md" . }}}
{{{ include "includes/clarifying-questions.md" . }}}
```

### Skill Composition

A skill is a self-contained directory:
```
skills/<category>/<skill-name>/
├── SKILL.md.tmpl          # Entry point (frontmatter + body)
├── scripts/               # Python/bash scripts (one per AI→script handoff)
│   └── cli-tool-discovery.sh.tmpl  # Materialized shared script
├── references/            # Detailed guidance loaded on demand
│   ├── best-practices.md
│   ├── structure.md
│   └── ...
├── assets/                # Static assets (optional)
└── evals/                 # Evaluation files (optional)
```

## Layer 5: Agents

Agents use skills as capabilities to accomplish domain tasks.

### How Agents Use Skills

- Agents invoke skills as capabilities
- `tools` in agent frontmatter declares available tools with contracts
- Agents can use any skill in the system

### How Agents Use Workflows

- Agents execute workflows for multi-step procedures
- The agent's Primary Workflow (Initialize, Plan, Act, Verify, Deliver) can
  invoke specific workflows

### How Agents Use Prompts and Templates

- Agents use prompts as structured instructions
- Agents use templates for output generation
- The agent body has a **Templates** section defining input/output templates

### Agent Composition

An agent frontmatter declares:
```yaml
tools:
  - name: "read_file"
    description: "Read agent template and existing agent definitions"
    inputs:
      - name: "file_path"
        type: "string"
        required: true
    outputs:
      - name: "content"
        type: "string"
```

The agent body has:
1. Goal → 2. Role → 3. i/o → 4. Primary Workflow → 5. Tools →
6. Instructions → 7. Templates → 8. Guardrails → 9. Design By Contract →
10. Quality Evaluation → 11. Handoffs → 12. References

## Layer 6: Committees

Committees compose agents to deliberate and synthesize.

### How Committees Use Agents

- **Members list** references agent files by slug
- Each member agent runs independently (fork), then results are synthesized
- The committee defines the synthesis protocol, not the agent behavior

### Committee Composition

```yaml
committee: Personality Council
slug: personality-council
members:
  - big-five-analyst      # → agents/humanities/psychology/big-five-analyst.md
  - mbti-typologist       # → agents/humanities/psychology/mbti-typologist.md
  - enneagram-expert      # → agents/humanities/psychology/enneagram-expert.md
  - disc-profiler         # → agents/humanities/psychology/disc-profiler.md
  - colors-analyst        # → agents/humanities/psychology/colors-analyst.md
deliberation_protocol: cross-validation
conflict_resolution: consensus-integration
```

The committee body defines:
1. **Purpose** — what the committee does
2. **Deliberation Process** — how agents interact (fork → validate → resolve → synthesize)
3. **Output Format** — the integrated output structure

## Cross-Cutting Primitives

Three primitives don't fit in the linear chain — they apply across all
layers:

### Rules (Always-On Constraints)

Rules constrain all primitives. They are loaded into the system prompt
permanently and apply to every action:
- "Always use `git mv`" — constrains file operations in all primitives
- "No advertising in commits" — constrains git operations
- "Use `{{{`/`}}}` delimiters" — constrains template authoring

### Memory/Context (Always-On State)

Context files provide state that all primitives can access:
- `IDENTITY.md` — who the agent is
- `SOUL.md` — personality, values, voice
- `TOOLS.md` — available tools
- `USER.md` — operator preferences

### Hooks (Event-Driven Guardrails)

Hooks guard actions across all primitives:
- `pre_write_code` — scans for secrets before any file write
- `pre_run_command` — blocks dangerous commands
- `post_write_code` — lints code after writing

## Build-Time vs Runtime Composition

### Build-Time (inlined at render)

- `{{{ include "..." . }}}` directives — shared includes inlined into the
  output at build time
- `see-also` with `template:` — reference shared templates/frameworks
  (documentation references; actual content inlined via includes)
- The templater renders `.tmpl` files, inlining includes, producing
  self-contained output

### Runtime (consumer must install)

- `see-also` with `skill:` or `workflow:` — point to sibling skills/workflows
  that complement or are invoked by this skill
- `dependencies:` array — explicit list of required skills, tools, or
  templates
- Committee `members:` list — references agent files that must exist at runtime

See [Build-Time vs Runtime Dependencies](../build-system/dependencies.md)
for details.

## The Hub Include Pattern

The composition chain uses a **hub include** pattern for DRY composition:

```
base-ai-guidance.md (hub)
├── self-update-requirement.md
├── ai-guidance-creation.md (8-step creation process)
├── base-content-principles.md
├── subagent-delegation.md
├── cli-tool-discovery.md
└── ...
```

A single `{{{ include "includes/base-ai-guidance.md" . }}}` in a skill
pulls in all sub-includes. This keeps skills small in source form while
being fully self-contained after build.

# Citations

[1] [skills-src README](https://github.com/levonk/skills-src)
[2] [Includes AGENTS.md](src/current/includes/AGENTS.md)
[3] [Developer guide](.agents/knowledge/developer.md)
