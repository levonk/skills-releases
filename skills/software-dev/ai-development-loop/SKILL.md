---
name: ai-development-loop
description: Systematic development workflow for AI agents with ticket management, reflection, and continuous improvement. Use when working on ticketr-based projects, needing structured development cycles, running the dev loop orchestrator, or following a systematic build-test-commit workflow. Triggers on 'dev loop', 'development cycle', 'next ticket', 'start work on ticket', or 'systematic development workflow'.
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "development-workflow", "ticket-management"]
see-also:
  - skill: code-quality-validation
    relationship: "dependency"
    description: "For comprehensive code quality checks including linting, formatting, and testing"
  - skill: git-repository-management
    relationship: "dependency"
    description: "For organized, secure repository operations and commit management"
  - skill: project-detection
    relationship: "dependency"
    description: "For detecting project types and environment management systems"
  - skill: repository-health-review
    relationship: "dependency"
    description: "For repository health assessment and validation"
  - skill: base-ai-guidance
    relationship: "base-framework"
    description: "Base AI guidance framework for all AI skills"
dependencies:
  - type: skill
    name: repository-health-review
  - type: skill
    name: project-detection
  - type: skill
    name: git-repository-management
  - type: skill
    name: code-quality-validation
  - type: workflow
    name: tasks
  - type: url
    name: GitHub REST API
    url: https://docs.github.com/en/rest
---

{{{ include "includes/base-ai-guidance.md" . }}}

# AI Development Loop

A systematic workflow for AI agents working with ticketr to ensure consistent, high-quality development cycles.

## Quick Start

🚨 **CRITICAL WARNING**: NEVER remove features or test coverage unless explicitly required by the ticket. Doing so will result in immediate termination!

When starting development work, use the AI Development Loop script which handles the core workflow steps:

```bash
# Use the orchestrator script for automated step-by-step execution
./scripts/orchestrator.sh --verbose loop

# Or use the generic helper directly
./scripts/dev-loop-helper.sh --verbose foundation
./scripts/dev-loop-helper.sh --verbose next
./scripts/dev-loop-helper.sh --verbose start <ticket-id>
./scripts/dev-loop-helper.sh --verbose complete <ticket-id>
```

**The script handles these core steps automatically:**
- **Step 0**: Foundation Check - Environment validation and security scanning
- **Step 1**: Ticket Selection - Get next actionable ticket
- **Step 2**: Start Work - Mark ticket as in_progress
- **Step 6**: Verification - Use code-quality-validation skill for testing and quality checks
- **Step 7**: Ticket Audit - Coverage validation against ticket requirements (90%+ threshold)
- **Step 8**: Completion - Use git-repository-management skill for commit organization and repository cleanup

**For detailed step-by-step execution, add `--verbose` to any command. The script provides in-situ instructions for any errors encountered.**

**Manual steps you need to perform (not handled by script):**
- **Step 3**: High Quality - Ensure upstream has adequate testing
- **Step 4**: Strategy - Determine implementation approach
- **Step 5**: Implementation - Do the actual work
- **Step 9**: Commit Changes - Use git-repository-management skill for commit organization
- **Step 10**: Assess - Opportunities for improvement in technology, process, and project
- **Step 11**: Codify - Create tickets for identified improvements and prioritize them
- **Step 12**: Commit Changes - Use git-repository-management skill for final cleanup
- **Step 13**: Loop Again - Grab next ticket and repeat

## Development Loop Integration

### Environment Management Integration

The development loop automatically detects and integrates with your preferred environment management system. For detailed environment management configuration, command examples, and directory-based activation, see [Environment Management](references/environment-management.md).

### Security Features

The development loop includes automatic security scanning for configuration analysis, command injection prevention, container security, and package verification. For detailed security scan results and examples, see [Security Features](references/security-features.md).

### Architecture Overview

The ai-development-loop skill uses an orchestrator pattern to delegate to language-specific helpers. For detailed architecture information, orchestrator pattern, language-specific helpers, and standard loop targets, see [Architecture](references/architecture.md).

### Language-Specific Helpers

For detailed migration path, script-automated steps, manual step execution (Steps 3-13), ticket audit methodology, assessment framework, and codification process, see [Language Helpers](references/language-helpers.md).

### Migration Path

For critical warnings, workflow principles, ticket status flow, dependency management, reflection phase, opportunity identification, continuous improvement loop, quality checklist, examples, and troubleshooting, see [Migration Path](references/migration-path.md).

## References

- ticketr CLI documentation: `tkr help`
- Project AGENTS.md for specific patterns
- ai-skill-upsert for codifying discovered patterns
- Workflow templates in `.windsurf/workflows/`

---

*This skill ensures consistent, high-quality development while maintaining clear ticket state tracking and continuously improving the development process through reflection and opportunity identification.*

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/ai-development-loop/SKILL.md`
- Scripts: `scripts/orchestrator.sh`, `scripts/dev-loop-helper.sh`, `scripts/node-loop-helper.sh`, `scripts/python-loop-helper.sh`, `scripts/rust-loop-helper.sh`, `scripts/go-loop-helper.sh`, `scripts/cmake-loop-helper.sh`, `scripts/make-loop-helper.sh`
- References: `references/environment-management.md`, `references/security-features.md`, `references/architecture.md`, `references/language-helpers.md`, `references/migration-path.md`

### Related Skills
- code-quality-validation (dependency)
- git-repository-management (dependency)
- project-detection (dependency)
- repository-health-review (dependency)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
