# Workflow Anatomy

## Directory Structure

A workflow consists of a Template/Wrapper file pair:

```
<category>/
├── <name>.md.tmpl              # Wrapper: frontmatter + includeTemplate call
└── (template lives elsewhere)

config/ai/templates/<category>/
└── <name>-template.md          # Content template (no frontmatter)
```

## Wrapper Frontmatter (YAML)

Required fields:
- **workflow**: Display name
- **slug**: kebab-case identifier
- **description**: What the workflow does
- **use**: When to invoke the workflow
- **date**:
  - **created**: Creation date (YYYY-MM-DD)
  - **updated**: Last modification date (YYYY-MM-DD)
  - **last-used**: Last usage date (YYYY-MM-DD) — update on each use

**Example**:
```yaml
---
workflow: "AI Agent Create"
slug: "ai-agent-create"
description: "Create expert agents that channel specific expertise"
use: "When needing an agent for specialized tasks"
date:
  created: "2025-12-20"
  updated: "2026-06-25"
  last-used: "2026-06-25"
---
```

## Template/Wrapper Pattern

The wrapper file in `config/ai/workflows/<category>/<name>.md.tmpl` contains frontmatter and a single `includeTemplate` call pulling in the content template from `config/ai/templates/<category>/<name>-template.md`. This separation lets the template be reused across wrappers and keeps frontmatter concerns (triggering, metadata) distinct from content concerns (steps, logic).

## What the Scaffolder Creates

`scripts/init_workflow.py <name> --path <dir>` creates:

1. `<dir>/<name>.md.tmpl` — wrapper with frontmatter TODOs and `includeTemplate` call
2. `config/ai/templates/<category>/<name>-template.md` — content template with section headers
3. Prints next-steps guidance for filling in the placeholders
