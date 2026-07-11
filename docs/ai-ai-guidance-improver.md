<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# If installed via skills (includes/ is bundled alongside the skill):

> Category: **ai** · Status:  · Version: 1.0.0

Analyze and improve existing AI guidance files (skills, workflows, agents, prompts, AGENTS.md) and interactive prompts by identifying conflicts, duplications, inadequate frontmatter, poor progressive disclosure, scattered context, and specific solutions where general would be better. Use when users want to improve the quality and maintainability of their AI guidance files, ensure consistency across their AI system, apply best practices for token efficiency and progressive disclosure, or get real-time suggestions for prompts they're actively writing.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-guidance-improver` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

### What This Skill Provides

1. **Quality Analysis** - Identifies conflicts, duplications, and inefficiencies in AI guidance files
2. **Best Practices Application** - Applies progressive disclosure, context management, and token efficiency principles
3. **Consistency Enforcement** - Ensures consistent frontmatter, structure, and patterns across guidance files
4. **Maintainability Improvement** - Reduces duplication and improves long-term maintainability
5. **Interactive Prompt Improvement** - Real-time suggestions for prompts users are actively writing

### Operating Modes

This skill operates in two distinct modes:

#### File-Based Mode
Analyzes and improves existing AI guidance files (skills, workflows, agents, prompts, AGENTS.md) stored in the filesystem. This mode can apply Go text/template includes, restructure files, and make persistent changes.

**Use when:**
- Improving existing guidance files in your codebase
- Applying consistent improvements across multiple files
- Restructuring guidance to use shared templates
- Doing batch improvements to guidance files

#### Interactive Mode
Provides real-time suggestions and improvements for prompts users are actively writing or editing inline. This mode works with the text directly without file operations or Go text/template includes.

**Use when:**
- Writing a new prompt and want immediate feedback
- Iteratively improving a prompt during creation
- Getting suggestions for a prompt you're about to use
- Wanting quick improvements without file operations

**Interactive mode triggers:**
- "improve this prompt: [your prompt text]"
- "help me refine this prompt: [your prompt text]"
- "make this prompt better: [your prompt text]"
- "suggest improvements for: [your prompt text]"
- "optimize this prompt: [your prompt text]"

## Related Skills
- **ai-skill-upsert** (skill, complement) — For creating new AI guidance files; shares the research-phase and comparison-methodology includes
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files

---

- **Full skill**: [`skills/ai/ai-guidance-improver/SKILL.md`](skills/ai/ai-guidance-improver/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-11T11:03:17Z
