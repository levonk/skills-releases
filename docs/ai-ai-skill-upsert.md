<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# If installed via skills (includes/ is bundled alongside the skill):

> Category: **ai** · Status:  · Version: 2.3.0

Create new skills, modify and improve existing skills, and measure skill performance. Before creating a new skill, researches existing skills locally, on skills.sh, and on GitHub to avoid duplication and incorporate best ideas. Use when users want to create a skill from scratch, convert an existing workflow file into a skill (preserving git history via git mv), edit or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. Make sure to use this skill whenever the user mentions skill creation, skill development, skill testing, skill evaluation, skill benchmarking, skill optimization, workflow-to-skill conversion, find existing skills for a purpose, or wants to package/distribute skills, even if they don't explicitly ask for a "skill creator." Do NOT trigger on general coding questions, bug fixes, feature implementation, or code review — this skill is for skill lifecycle management, not general development.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-skill-upsert` |
| Category | `ai` |
| Version | `2.3.0` |
| Status | `` |
| Owner |  |

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

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving (also used by ai-guidance-improver, ai-workflow-upsert, knowledge-bundle-lifecycle, and creation workflows)
- **project-comparison** (skill, complement) — Shares comparison methodology via comparison-methodology include; project-comparison compares software projects, this skill compares AI skills

---

- **Full skill**: [`skills/ai/ai-skill-upsert/SKILL.md`](skills/ai/ai-skill-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-11T15:49:28Z
