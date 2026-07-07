---
name: ai-guidance-improver
description: Analyze and improve existing AI guidance files (skills, workflows, agents, prompts, AGENTS.md) and interactive prompts by identifying conflicts, duplications, inadequate frontmatter, poor progressive disclosure, scattered context, and specific solutions where general would be better. Use when users want to improve the quality and maintainability of their AI guidance files, ensure consistency across their AI system, apply best practices for token efficiency and progressive disclosure, or get real-time suggestions for prompts they're actively writing.
version: 1.0.0
date:
  created: "2026-06-25"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags:
  - "ai/skill"
  - "guidance-improvement"
  - "quality-assurance"
  - "token-efficiency"
  - "progressive-disclosure"
  - "best-practices"
  - "interactive-prompt-improvement"
  - "real-time-suggestions"
  - "staleness-detection"
see-also:
  - skill: "ai-skill-upsert"
    relationship: "complement"
    description: "For creating new AI guidance files"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# AI Guidance Improver

A skill for analyzing and improving existing AI guidance files to ensure they follow best practices for token efficiency, progressive disclosure, and maintainability.

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
Analyzes and improves existing AI guidance files (skills, workflows, agents, prompts, AGENTS.md) stored in the filesystem. This mode can apply jinja templating, restructure files, and make persistent changes.

**Use when:**
- Improving existing guidance files in your codebase
- Applying consistent improvements across multiple files
- Restructuring guidance to use shared templates
- Doing batch improvements to guidance files

#### Interactive Mode
Provides real-time suggestions and improvements for prompts users are actively writing or editing inline. This mode works with the text directly without file operations or jinja templating.

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

## Interactive Mode Workflow

When operating in interactive mode (real-time prompt improvement), follow the streamlined 5-step process:

1. **Analyze the Prompt** — Check for clarity, structure, efficiency, and completeness issues
2. **Provide Immediate Suggestions** — Offer specific, actionable improvements per issue type
3. **Offer Improvements** — Provide concrete before/after with reasons, prioritized as Critical/Important/Nice-to-have
4. **Iterate** — Allow user to accept, request alternatives, or provide additional context
5. **Finalize** — Deliver the improved prompt with explanation of key changes

For the full detailed workflow with examples, see: [`references/interactive-mode.md`](references/interactive-mode.md)

## File-Based Mode Workflow

When operating in file-based mode (analyzing and improving existing files), follow the comprehensive analysis framework:

1. **Identify Issues** — Check for conflicts, duplication, inadequate frontmatter, poor progressive disclosure, scattered context, stale text, and more
2. **Prioritize Improvements** — Group by High/Medium/Low priority
3. **Apply Improvements** — Fix frontmatter, implement progressive disclosure, consolidate context, separate audiences, apply jinja templating
4. **Validate Changes** — Check for new conflicts, verify references, test templates
5. **Document Changes** — Record what changed, benefits, and any breaking changes

The framework also includes type-specific guidance for Skills, Workflows, Agents, Prompts, and AGENTS.md files, plus batch processing strategies.

For the full detailed framework with examples and type-specific guidance, see: [`references/file-based-analysis.md`](references/file-based-analysis.md)

## Decision Tree: Which Mode to Use

```
Is the user working with an existing file in the filesystem?
├── YES → File-Based Mode
│   Use when: improving existing guidance files, batch improvements,
│   restructuring to shared templates, applying consistent changes
│   across multiple files
│
└── NO → Interactive Mode
    Use when: writing a new prompt, iteratively improving a prompt
    during creation, getting quick suggestions without file operations
```

**Key distinction:**
- **File-Based Mode** can apply jinja templating, restructure files, and make persistent changes
- **Interactive Mode** works with text directly without file operations or jinja templating

## Communicating with Users

When presenting analysis results:

1. **Summarize findings** - High-level overview of issues found
2. **Prioritize recommendations** - Group by priority level
3. **Provide examples** - Show before/after for key improvements
4. **Estimate impact** - Token savings, maintainability improvements
5. **Get approval** - Confirm changes before applying

When applying improvements:

1. **Explain each change** - Why it's being made
2. **Show the diff** - Before/after comparison
3. **Highlight benefits** - What this improves
4. **Check for concerns** - Any breaking changes or side effects
5. **Document next steps** - What the user should do next

---
## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/ai-guidance-improver/SKILL.md`
- Interactive mode reference: `references/interactive-mode.md`
- File-based analysis reference: `references/file-based-analysis.md`
- Includes: `config/ai/skills/includes/`
- Base templates: `config/ai/skills/includes/base-*.md.tmpl`

### Related Skills
- ai-skill-upsert (complement) — For creating new AI guidance files
- base-ai-guidance (base-framework) — Shared framework for all AI guidance types
- base-frontmatter (structure-standard) — Standard frontmatter template

### External Resources
- Project documentation: https://github.com/levonk/dotfiles
- DOX framework (inspiration for staleness/contract quality patterns): https://github.com/agent0ai/dox

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk
