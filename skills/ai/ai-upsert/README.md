# AI Create

A skill for creating and maintaining two types of compounding AI artifacts:
**skills** (executable procedures) and **OKF knowledge bundles** (compounding
knowledge wikis). This skill consolidates the former `ai-skill-upsert` and
`knowledge-bundle-upsert` into a single entry point.

## What It Does

1. **Determines artifact type** — skill vs knowledge bundle — based on the
   user's request
2. **Recommends the best fit** if the user asks for the wrong type, explains
   why, and asks them to choose
3. **Creates, converts, and updates skills** — from scratch, from workflows
   (preserving git history), or existing skills (audit + propose changes)
4. **Creates, ingests, queries, and lints knowledge bundles** — OKF v0.2
   compliant bundles with concept documents, index files, and change logs
5. **Runs evals and benchmarks** skill performance with variance analysis
6. **Reads the repository's AGENTS.md** (or CLAUDE.md, AGENT.md) before
   creating artifacts, to respect host repository conventions

## Benefits

### Token Efficiency
- **Concise guidance bodies**: Main skill content stays focused with deterministic phases extracted to scripts
- **Progressive disclosure**: Detailed information moved to reference files
- **Context preservation**: Context declared at bottom preserves AI cache capability
- **Shared templates**: Jinja templating reduces duplication across skills

### Consistency & Quality
- **Standard frontmatter**: Consistent structure across all AI guidance types
- **Shared principles**: Universal quality guidelines applied consistently
- **Best practices**: Matt Pocock's writing-great-skills principles integrated
- **Type-specific guidance**: Tailored advice for skills, knowledge bundles, workflows, agents, and prompts

### Maintainability
- **Single source of truth**: Common patterns defined once, referenced everywhere
- **Template propagation**: Changes to shared templates update all consuming files
- **Clear separation**: Distinct boundaries between metadata, body, and resources
- **Reduced duplication**: Eliminates repeated instructions and context

### Progressive Disclosure
- **Three-level loading**: Metadata (always) → Body (on trigger) → Resources (as needed)
- **Smart referencing**: Clear pointers with usage guidance for reference files
- **Audience separation**: Different information paths for different user needs
- **Hierarchical structure**: Organized from high-level to detailed information

## Architecture

### Shared Templates

The skill creator leverages shared templates for consistency:

- **`base-frontmatter.md.tmpl`** - Standard frontmatter structure
- **`base-content-principles.md.tmpl`** - Token efficiency and quality guidelines
- **`context-declaration.md.tmpl`** - Context management template
- **`ai-guidance-creation.md.tmpl`** - Universal creation framework

### Skill Structure

```
category-name/skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/     # Executable code
    ├── references/  # Documentation
    └── assets/      # Templates and files
```

### Knowledge Bundle Structure (OKF v0.2)

```
bundle-name/
├── index.md         # Directory of all pages
├── overview.md      # Synthesis of the domain
├── log.md           # Change history
└── *.md             # Concept pages (one concept per file)
```

### Three-Level Architecture

1. **Level 1: Metadata** - Always loaded (~100 words)
2. **Level 2: Instructions** - Loaded when skill triggers
3. **Level 3: Resources** - Loaded as needed (unlimited)

## Usage

### Creating a New Skill

```bash
# Use the ai-upsert skill to guide you through the process
ai-upsert "I want to create a skill for X"

# Or initialize structure manually
python scripts/skill/init_skill.py <skill-name> --path <output-directory>
```

### Creating a Knowledge Bundle

```bash
# Use the ai-upsert skill to create an OKF bundle
ai-upsert "I want to create a knowledge bundle for X best practices"
```

### Improving Existing Skills

When given an existing skill directory, this skill audits it against the skill guidelines (frontmatter, description quality, structure, progressive disclosure, context declaration, bundled resources, stale text), proposes prioritized changes, and asks for confirmation before applying. For cross-file and system-wide analysis (conflicts, duplications across multiple guidance files), use the companion `ai-guidance-improver` skill.

## Related Skills

- **`ai-guidance-improver`** - Analyze and improve existing AI guidance files
- **`ai-workflow-upsert`** - Create and update workflow files
- **`agent-file-upsert`** - Generate AGENTS.md documentation
- **`readme-upsert`** - Generate README.md documentation
- **Shared templates** - Base templates for consistent structure and quality

## Best Practices

- **Front-load leading words** in descriptions for better triggering
- **Use progressive disclosure** to keep main content concise
- **Declare context at bottom** to preserve AI cache capability
- **Apply shared templates** for consistency across guidance types
- **Test iteratively** using the evaluation framework
- **Prune regularly** to remove no-ops and duplications
- **Read the repository's AGENTS.md** before creating artifacts

## Context

- **Main skill**: `src/current/skills/ai/ai-upsert/SKILL.md`
- **Skill references**: `src/current/skills/ai/ai-upsert/references/skill/`
- **Knowledge bundle references**: `src/current/skills/ai/ai-upsert/references/knowledge/`
- **Skill scripts**: `src/current/skills/ai/ai-upsert/scripts/skill/`
- **Shared scripts**: `src/current/skills/ai/ai-upsert/scripts/`
- **Shared templates**: `src/current/includes/`
- **Project**: levonk/skills-src
- **Repository**: https://github.com/levonk/skills-src
