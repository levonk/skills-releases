# Handoff Document Template

Use this template for consistency when creating handoff documents:

```markdown
# [Descriptive Handoff Title]

**Date**: YYYY-MM-DD
**Session**: [Brief session description]
**Status**: [Current status - e.g., "In progress", "Blocked", "Completed"]

## Current State

### ✅ Completed
- [Completed item 1]
- [Completed item 2]

### ❌ Blocking Issues
1. [Blocking issue 1]
2. [Blocking issue 2]

## Git State

**Commit at handoff**: `<full 40-char SHA>` (captured via `git rev-parse HEAD`
after the pre-handoff commit checkpoint)

This is the exact repo state at handoff time. The receiving session can
reconstruct what was done by inspecting this commit and its history:
- `git show <SHA>` — what the handoff commit changed
- `git log <SHA>..HEAD` — work done since the handoff (during restoration)
- `git diff <SHA>~1 <SHA>` — the last change before handoff

If the target project is not a git repository, replace this section with:
"Not a git repository — no commit hash available."

## Required Reading

Before any other action, read `{REPO_ROOT}/<agent-file>` — it is the root of
this project's progressively-disclosed informational files (JIT index, binding
contracts, conventions). Follow its Usage Protocol and re-read the chain for
any path you touch.

> **Detection**: The capturing session checks in priority order: `AGENTS.md`,
> `AGENT.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `GEMINI.md`,
> `.windsurf/rules/*.md`, `.cursor/rules/*.mdc`, `CONVENTIONS.md`. If multiple
> exist, the largest by byte size wins (pointer/symlink stubs are small).
> Replace `<agent-file>` with the detected path. If none exist, replace this
> section with: "No agent-instructions file found at the project root. No
> progressive-disclosure root to read — proceed without project-level agent
> conventions."

## Project Overview

### Objective
[What we're trying to achieve]

### Current Status
[Where we are in the process]

## Key Decisions Made
- [Decision 1] - [Reason/Brief context]
- [Decision 2] - [Reason/Brief context]

## Technical Context

### Stack/Tools
[List of technologies, frameworks, tools]

### Important Files
- `path/to/file1` - [purpose]
- `path/to/file2` - [purpose]

### Environment Notes
[Any special setup or configuration]

## Next Steps (Priority Order)
1. [Immediate next action]
2. [Following action]
3. [Future action]

## Success Criteria
- [Criteria 1]: [How to verify]
- [Criteria 2]: [How to verify]

## Open Questions/Blockers
- [Question 1] - [Impact if unresolved]
- [Question 2] - [Impact if unresolved]

## Do Not
- [Things to avoid or approaches rejected]

## Suggested Skills
- [skill-name] - [why this skill should be invoked]
- [skill-name] - [why this skill should be invoked]

## Additional Context
[Any other information crucial for continuation]
```

## Extended Example: Complex Project Handoff

Based on the infrahub example, a more detailed handoff for complex projects:

```markdown
# [Descriptive Title]

**Date**: YYYY-MM-DD
**Session**: [Brief description]
**Status**: [Current status]

## Current State

### ✅ Completed
- **[Completed item]**:
  - [Detail 1]
  - [Detail 2]

### ❌ Blocking Issues
1. **[Issue 1]**: [Description]
2. **[Issue 2]**: [Description]

## Git State

**Commit at handoff**: `<full 40-char SHA>` (captured via `git rev-parse HEAD`
after the pre-handoff commit checkpoint)

This is the exact repo state at handoff time. The receiving session can
reconstruct what was done by inspecting this commit and its history:
- `git show <SHA>` — what the handoff commit changed
- `git log <SHA>..HEAD` — work done since the handoff (during restoration)
- `git diff <SHA>~1 <SHA>` — the last change before handoff

If the target project is not a git repository, replace this section with:
"Not a git repository — no commit hash available."

## Required Reading

Before any other action, read `{REPO_ROOT}/<agent-file>` — it is the root of
this project's progressively-disclosed informational files (JIT index, binding
contracts, conventions). Follow its Usage Protocol and re-read the chain for
any path you touch.

> **Detection**: The capturing session checks in priority order: `AGENTS.md`,
> `AGENT.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `GEMINI.md`,
> `.windsurf/rules/*.md`, `.cursor/rules/*.mdc`, `CONVENTIONS.md`. If multiple
> exist, the largest by byte size wins (pointer/symlink stubs are small).
> Replace `<agent-file>` with the detected path. If none exist, replace this
> section with: "No agent-instructions file found at the project root. No
> progressive-disclosure root to read — proceed without project-level agent
> conventions."

## Target Architecture

[Architecture diagram or description]

## Required Tasks

### 1. [Task Name]
**Problem**: [Description]
**Investigation Needed**:
- [Investigation item 1]
- [Investigation item 2]
**Files to Check**:
- [File path 1]
- [File path 2]

### 2. [Task Name]
**Problem**: [Description]
**Solutions to Try**:
- [Solution 1]
- [Solution 2]

## Success Criteria

- ✅ [Criteria 1]
- ✅ [Criteria 2]
- ✅ [Criteria 3]

## Files Modified This Session

1. [File path 1]
2. [File path 2]

## Additional Context

- **Project**: [Project name]
- **ADR Compliance**: [Reference to relevant ADRs]
- **Git Workflow**: [Commit strategy]
```
