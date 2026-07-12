<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Systematic development workflow for AI agents with ticket management, reflection, and continuous improvement. Use when working on ticketr-based projects, needing structured development cycles, running the dev loop orchestrator, or following a systematic build-test-commit workflow. Triggers on 'dev loop', 'development cycle', 'next ticket', 'start work on ticket', or 'systematic development workflow'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-development-loop` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `development-workflow`
- `ticket-management`

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

## References

- ticketr CLI documentation: `tkr help`
- Project AGENTS.md for specific patterns
- ai-skill-upsert for codifying discovered patterns
- Workflow templates in `.windsurf/workflows/`

---

*This skill ensures consistent, high-quality development while maintaining clear ticket state tracking and continuously improving the development process through reflection and opportunity identification.*

## Related Skills
- **code-quality-validation** (skill, dependency) — For comprehensive code quality checks including linting, formatting, and testing
- **git-repository-management** (skill, dependency) — For organized, secure repository operations and commit management
- **project-detection** (skill, dependency) — For detecting project types and environment management systems
- **repository-health-review** (skill, dependency) — For repository health assessment and validation
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills

---

- **Full skill**: [`skills/software-dev/ai-development-loop/SKILL.md`](skills/software-dev/ai-development-loop/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T00:50:23Z
