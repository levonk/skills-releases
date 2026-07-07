<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Codebase Tutorial Generator

> Category: **software-dev** · Status: ready · Version: 1.0.0

Generate beginner-friendly tutorials from codebases. Use when asked to analyze a repository, explain a codebase, create documentation from code, or generate tutorials for GitHub projects. Triggers on 'explain this codebase', 'create a tutorial', 'help me understand this project', 'document this code', or 'generate tutorial'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `codebase-tutorial` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `tutorial`
- `documentation`
- `code-analysis`

## Quick Start

```bash
# Analyze current directory
python scripts/crawl_codebase.py --dir . --include "*.py" --exclude "tests/*" > files.json

# Then follow the workflow below to generate the tutorial
```

## Instructions

### Step 1: Fetch Files (Deterministic)

Run the crawl script to collect codebase files:

```bash
python scripts/crawl_codebase.py \
  --dir /path/to/repo \
  --include "*.py" "*.js" "*.ts" \
  --exclude "tests/*" "node_modules/*" "*test*" \
  --max-size 50000 \
  --output files.json
```

Or for a GitHub URL:

```bash
python scripts/crawl_codebase.py \
  --repo https://github.com/user/repo \
  --include "*.py" \
  --output files.json
```

The output is a JSON file with structure:

```json
{
  "project_name": "repo-name",
  "files": [
    { "index": 0, "path": "src/main.py", "content": "..." },
    { "index": 1, "path": "src/utils.py", "content": "..." }
  ]
}
```

### Step 2: Identify Abstractions (AI Prompt)

Using the files from Step 1, identify the core abstractions.

**Prompt**: See [prompts/01-identify-abstractions.md](prompts/01-identify-abstractions.md)

**Example output**: See [examples/abstractions-flask.yaml](examples/abstractions-flask.yaml)

### Step 3: Analyze Relationships (AI Prompt)

Using the abstractions from Step 2, analyze how they relate to each other.

**Prompt**: See [prompts/02-analyze-relationships.md](prompts/02-analyze-relationships.md)

**Example output**: See [examples/relationships-flask.yaml](examples/relationships-flask.yaml)

### Step 4: Order Chapters (AI Prompt)

Determine the best teaching order for the abstractions.

**Prompt**: See [prompts/03-order-chapters.md](prompts/03-order-chapters.md)

**Example output**: See [examples/chapter-order-flask.yaml](examples/chapter-order-flask.yaml)

### Step 5: Write Chapters (AI Prompt - Batch)

For each chapter in order, generate the tutorial content.

**Prompt**: See [prompts/04-write-chapter.md](prompts/04-write-chapter.md)

**Example output**: See [examples/chapter-flask-app.md](examples/chapter-flask-app.md)

### Step 6: Combine Tutorial (Deterministic)

Run the combine script:

```bash
python scripts/combine_tutorial.py \
  --project-name "MyProject" \
  --abstractions abstractions.json \
  --relationships relationships.json \
  --chapter-order order.json \
  --chapters chapters/ \
  --output output/MyProject/
```

This creates:

- `output/MyProject/index.md` - Main page with summary and mermaid diagram
- `output/MyProject/01_concept_name.md` - Chapter files

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/codebase-tutorial/SKILL.md`](skills/software-dev/codebase-tutorial/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-07T22:59:26Z
