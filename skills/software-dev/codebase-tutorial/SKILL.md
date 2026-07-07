---
name: codebase-tutorial
description: "Generate beginner-friendly tutorials from codebases. Use when asked to analyze a repository, explain a codebase, create documentation from code, or generate tutorials for GitHub projects. Triggers on 'explain this codebase', 'create a tutorial', 'help me understand this project', 'document this code', or 'generate tutorial'."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "tutorial", "documentation", "code-analysis"]
see-also:
  - template: base-ai-guidance
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
  - type: python
    name: json
    url: https://docs.python.org/3/library/json.html
  - type: python
    name: pathlib
    url: https://docs.python.org/3/library/pathlib.html
  - type: node
    name: mermaid
    url: https://www.npmjs.com/package/mermaid
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Codebase Tutorial Generator

Transform any codebase into a beginner-friendly tutorial with clear explanations, diagrams, and examples.

## Quick Start

```bash
# Analyze current directory
python scripts/crawl_codebase.py --dir . --include "*.py" --exclude "tests/*" > files.json

# Then follow the workflow below to generate the tutorial
```

## Workflow Overview

This Skill follows a 6-step pipeline:

1. **Fetch Files** (deterministic) → Crawl codebase, collect files
2. [fork] **Identify Abstractions** (AI) → Find 5-10 core concepts
3. **Analyze Relationships** (AI) → Map how concepts interact
4. **Order Chapters** (AI) → Determine teaching sequence
5. [fork] **Write Chapters** (AI) → Generate tutorial content
6. **Combine Tutorial** (deterministic) → Assemble final output

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

## Output Format

The tutorial generates an `index.md` with project summary and mermaid diagram, plus individual chapter files with motivation, key concepts, usage examples, and code walkthroughs.

For detailed output format examples and chapter structure templates, see [references/output-format.md](references/output-format.md).

## Best Practices

- **File filtering**: Exclude tests, configs, and generated files
- **Abstraction count**: 5-10 is ideal; more becomes overwhelming
- **Code snippets**: Aggressively simplify; use comments to skip details
- **Diagrams**: Keep mermaid diagrams simple (max 5 participants)
- **Analogies**: Every concept should have a real-world analogy
- **Links**: Always use proper Markdown links between chapters

## Example Session

```
User: Create a tutorial for https://github.com/pallets/flask

Claude:
1. Crawling repository...
   [runs crawl_codebase.py]
   Found 45 Python files.

2. Identifying core abstractions...
   [AI analysis]
   Found 8 abstractions: Flask App, Blueprints, Request Context, ...

3. Analyzing relationships...
   [AI analysis]
   Generated project summary and relationship map.

4. Ordering chapters...
   [AI analysis]
   Order: Flask App → Request Context → Blueprints → ...

5. Writing chapters...
   [AI generation - batch]
   Writing Chapter 1: Flask App...
   Writing Chapter 2: Request Context...
   ...

6. Combining tutorial...
   [runs combine_tutorial.py]
   Tutorial saved to output/flask/

Done! Tutorial available at output/flask/index.md
```

## Limitations

- Large codebases (>100 files) may need aggressive filtering
- Binary files and images are skipped
- Generated tutorials benefit from human review for accuracy
- Multi-language codebases work best when filtered to primary language

## Security Notes

- Only crawl repositories you have permission to access
- GitHub tokens (if used) should have minimal required permissions
- Generated tutorials may expose code patterns; review before publishing

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/codebase-tutorial/SKILL.md`
- Scripts: `scripts/crawl_codebase.py`, `scripts/combine_tutorial.py`
- References: `references/output-format.md`

### Related Skills
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
