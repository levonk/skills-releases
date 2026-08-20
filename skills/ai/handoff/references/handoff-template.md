# Handoff Document Template

## Storage Lifecycle & Commit Conventions

Handoff documents use a two-stage lifecycle (todo → archive) per the shared
`work-lifecycle` include. The include supports **audience variants** (agent
vs human) — see its "Audience Variants" section for routing criteria.

### Agent Handoffs (default)

| Stage | Path | When |
|-------|------|------|
| **Pending** | `.agents/handoffs/todo/YYYYMMDDHHmm-handoffslug.md` | Created — awaiting work |
| **Archived** | `.agents/handoffs/archive/YYYY/MM/YYYYMMDDHHmm-handoffslug.md` | All DoD tasks `[x]` — moved via `git mv` |

### Human Handoffs

| Stage | Path | When |
|-------|------|------|
| **Pending** | `.agents/handoffs/human/todo/YYYYMMDDHHmm-slug.md` | Blocked on human action — awaiting response |
| **Archived** | `.agents/handoffs/human/archive/YYYY/MM/YYYYMMDDHHmm-slug.md` | Blocker resolved — moved via `git mv` |

The filename never changes between stages. The archive `YYYY/MM/` is derived
from the filename's embedded timestamp (creation date, not completion date).

**Frontmatter dates** (per the `work-lifecycle` include):
```yaml
date:
  created: "2026-07-11"        # set on creation, never changed
  completed: "2026-07-15"      # set only when archiving
  last-activity: "2026-07-14"  # updated on every work session
```

**Commit messages** (both include a mandatory `#tag` array as the last body
line):

- **Capture** (new handoff):
  ```
  docs(handoff): capture context for {slug}

  Handoff document for session continuation. Records repo state at commit {sha}.

  #project-{project} #module-handoff #type-docs #skill-handoff-capture #skill-grm-created
  ```
- **Archive** (completed handoff, `git mv` todo/ → archive/):
  ```
  docs(handoff): archive completed handoff {slug}

  All Task List items verified [x] and Definition of Done checks pass. Moved from todo/ to archive/{YYYY}/{MM}/.

  #project-{project} #module-handoff #type-docs #skill-handoff-archived #skill-grm-created
  ```

## Document Template

Use this template for consistency when creating handoff documents:

```markdown
---
date:
  created: "YYYY-MM-DD"
  completed: ""               # set only when archiving
  last-activity: "YYYY-MM-DD" # update on every work session
---

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

## Skill Contract

If this work was started under a skill (e.g. `execute-upsert`, `ai-upsert`),
the receiving session MUST follow that skill's `INSTRUCTIONS.md` — including
its phase workflow, commit steps, and Definition of Done checklist. The skill
name and phase pin the binding contract; the summary does not reproduce it.

**Skill**: {skill-name}, Phase {N} ({phase name}) — story: "{story title}"
**Binding**: Read `~/.agents/skills/{skill-name}/INSTRUCTIONS.md` before
declaring work done. Follow its phase workflow and DoD checklist. Do not
invent constraints that conflict with the skill's contract.

If no skill was active, replace this section with: "No skill contract — this
work was not started under a skill. Apply the project's AGENTS.md and standard
development conventions."

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

## Task List

A checkbox-tracked task list. The receiving session maintains these marks as it
works. Each line is one task; do not collapse multiple tasks into one line.

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

```markdown
- [ ] {task pending}
- [ ] {task pending}
- [ ] {task pending}
```

**Maintenance protocol (receiving session):**
1. **Verify in-progress marks.** Before doing anything else, re-check every
   task marked `[~]`. If the work is not actually underway (no evidence in the
   working tree, no running process, no recent edit), demote it back to `[ ]`.
   A stale `[~]` is worse than an unstarted `[ ]` because it hides available
   work from the next agent.
2. **Start the next available task.** Pick the first `[ ]` task in priority
   order. Mark it `[~]` immediately before starting work on it.
3. **Prefer subagents for parallel work.** When two or more `[ ]` tasks are
   independent (no shared file writes, no ordering dependency), launch them as
   parallel `run_subagent` calls rather than working them sequentially — this
   is the expected mode of operation, not an optional optimization. Mark each
   `[~]` before launching so concurrent agents see them as claimed. Do not
   parallelize tasks that touch the same files or depend on each other's
   output — run those sequentially.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after the task's
   Definition of Done checks pass (see below). Never mark `[x]` on intent
   alone.
5. **Record blockers inline.** When a task cannot proceed, mark it `[!]` and
   append the blocker in parentheses on the same line, e.g.
   `- [!] {task blocked (waiting on upstream API access)}`. Move on to the
   next `[ ]` task — do not stall the whole list on one blocker.
6. **Update the list as work reveals new tasks.** Append newly discovered
   tasks as `[ ]` lines in priority order. Do not silently delete tasks; if a
   task is no longer relevant, mark it `[x]` with a note
   (`- [x] {task} (obsolete: reason)`).

## Definition of Done

Before declaring the handoff's work complete, verify every item below.
Items marked **[script]** are deterministically verified by a script — if
the script exits non-zero, the item is NOT done. Items marked **[manual]**
require the agent to check something the scripts cannot verify. Each item
is a checkbox — do not skip any.

- [ ] **[manual]** Every Task List item is `[x]` or marked `[x]` with an
  obsolete note — no `[ ]` or `[~]` items remain
- [ ] **[script]** `git status --porcelain` shows no uncommitted changes
  (all work is committed)
- [ ] **[manual]** The handoff document's Git State commit SHA matches
  `git rev-parse HEAD` (the document is up to date)
- [ ] **[manual]** Each completed task's deliverable matches what was
  described in the handoff (not just marked done — the actual output is
  correct)
- [ ] **[script]** Project-specific validation passes (e.g. `just test`,
  `npm test`, `cargo test` — whichever applies)

### Not Done (common false-completion signals)

If any of these are true, the work is NOT complete:

- All Task List items marked `[x]` but `git status` shows uncommitted
  changes → work was done but not committed
- All items `[x]` but the handoff's Git State SHA doesn't match `HEAD` →
  the handoff document is stale (was not updated after the last commit)
- Items marked `[x]` without verification → the agent marked done on
  intent, not on evidence (re-verify each `[x]` item)
- `just test` passes but the deliverable doesn't match the handoff's
  described outcome → the wrong thing was built

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

## Human Handoff Template

Use this template when a task is blocked on human-only action (API keys,
access, decisions, approvals). The document is **self-contained** — a human
should be able to read just this file (or the GitHub issue created from it)
and understand the full picture without reading the agent handoff. See the
`work-lifecycle` include's "Audience Variants" section for routing criteria.

```markdown
---
date:
  created: "YYYY-MM-DD"
  completed: ""
  last-activity: "YYYY-MM-DD"
github_issue: 42
---

# {Action needed — one line, e.g., "Provide OpenAI API key for eval runner"}

**Project Context:**
- Project: {project name}
- What it is: {1-2 sentence description of the project}

**Feature Context:**
- Feature: {what feature or work was being attempted}
- Why it matters: {the goal — why this work is being done}

**Current State:**
- Done: {completed items, or "none yet"}
- In progress: {in-progress items}
- Blocked: {where this blocker sits in the overall work}

**What I need from you:**
1. {specific action step}
2. {specific action step}

**Why I can't proceed:** {blocker explained for a non-agent reader —
what is missing and why the agent cannot generate or obtain it}

**What I tried:**
- {approach 1 and why it didn't work}
- {approach 2 and why it didn't work}

**Context:**
- Agent handoff: `.agents/handoffs/todo/{filename}.md`
- Run log: `.agents/log/{filename}.md` (if applicable)
- Relevant files: {paths}

**How to unblock me:** {what to do after the action is taken — e.g.,
"re-run the ai-upsert skill" or "tell me the API key is in `.env`"}
```

**GitHub issue creation:** after writing the file, if `gh` is available and
the repo has a GitHub remote, create a GitHub issue from the file content.
The issue is the visibility layer — it shows up in the issue list and stays
open until the human resolves the blocker. The file is always created first
(crash safety); the issue is conditional.

```bash
# Create the label if it doesn't exist
gh label create "human-handoff" \
  --description "Action item requiring human input (API keys, access, decisions, approvals)" \
  --color "BFD4F2" 2>/dev/null || true

# Create the issue from the file content (use --body-file, never --body)
gh issue create \
  --title "{action needed — one line}" \
  --body-file ".agents/handoffs/human/todo/{TIMESTAMP}-{SLUG}.md" \
  --label "human-handoff"
```

Record the issue number in the file's frontmatter (`github_issue: 42`). If
`gh` is unavailable or no remote exists, skip issue creation — the file
alone is durable. See the `gh-posting-guard` include for why `--body-file`
is mandatory.

**Human handoff DoD** (two items):
- [ ] The blocker was resolved and the requesting task in the agent handoff
  is marked `[x]`
- [ ] The GitHub issue (if created) is closed

**Human handoff archive:** when the DoD is met, `git mv` from
`human/todo/` to `human/archive/YYYY/MM/` per the `work-lifecycle` include.
If a GitHub issue was created, verify it is closed before archiving.

**Archive trigger — reconciliation:** the AI does not poll for issue closure.
The next ai-upsert run reconciles human handoffs in Phase 0: it scans
`human/todo/` for files with `github_issue` frontmatter, checks each issue's
state via `gh issue view {number} --json state`, and archives any whose
issues are `CLOSED`. This piggybacks on the existing run lifecycle — no
separate process needed.

## Extended Example: Complex Project Handoff

Based on the infrahub example, a more detailed handoff for complex projects:

```markdown
---
date:
  created: "YYYY-MM-DD"
  completed: ""
  last-activity: "YYYY-MM-DD"
---

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

## Skill Contract

If this work was started under a skill (e.g. `execute-upsert`, `ai-upsert`),
the receiving session MUST follow that skill's `INSTRUCTIONS.md` — including
its phase workflow, commit steps, and Definition of Done checklist. The skill
name and phase pin the binding contract; the summary does not reproduce it.

**Skill**: {skill-name}, Phase {N} ({phase name}) — story: "{story title}"
**Binding**: Read `~/.agents/skills/{skill-name}/INSTRUCTIONS.md` before
declaring work done. Follow its phase workflow and DoD checklist. Do not
invent constraints that conflict with the skill's contract.

If no skill was active, replace this section with: "No skill contract — this
work was not started under a skill. Apply the project's AGENTS.md and standard
development conventions."

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

## Task List

A checkbox-tracked task list. The receiving session maintains these marks as it
works. Each line is one task; do not collapse multiple tasks into one line.

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

```markdown
- [ ] {task pending}
- [ ] {task pending}
- [ ] {task pending}
```

**Maintenance protocol (receiving session):**
1. **Verify in-progress marks.** Re-check every `[~]` task. If work is not
   actually underway, demote it back to `[ ]`. A stale `[~]` hides available
   work from the next agent.
2. **Start the next available task.** Pick the first `[ ]` task in priority
   order. Mark it `[~]` before starting.
3. **Prefer subagents for parallel work.** Launch independent `[ ]` tasks as
   parallel `run_subagent` calls rather than working them sequentially — this
   is the expected mode of operation, not an optional optimization. Mark each
   `[~]` before launching. Do not parallelize tasks that share files or
   depend on each other's output.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after the
   Definition of Done checks pass (see below).
5. **Record blockers inline.** Mark blocked tasks `[!]` with the blocker in
   parentheses. Move on to the next `[ ]` task.
6. **Update the list as work reveals new tasks.** Append new tasks as `[ ]` in
   priority order. Mark obsolete tasks `[x]` with a note rather than deleting.

## Definition of Done

Before declaring the handoff's work complete, verify every item below.
Items marked **[script]** are deterministically verified by a script — if
the script exits non-zero, the item is NOT done. Items marked **[manual]**
require the agent to check something the scripts cannot verify. Each item
is a checkbox — do not skip any.

- [ ] **[manual]** Every Task List item is `[x]` or marked `[x]` with an
  obsolete note — no `[ ]` or `[~]` items remain
- [ ] **[script]** `git status --porcelain` shows no uncommitted changes
- [ ] **[manual]** The handoff document's Git State commit SHA matches
  `git rev-parse HEAD`
- [ ] **[manual]** Each completed task's deliverable matches what was
  described in the handoff
- [ ] **[script]** Project-specific validation passes (e.g. `just test`,
  `npm test`, `cargo test` — whichever applies)

### Not Done (common false-completion signals)

If any of these are true, the work is NOT complete:

- All Task List items marked `[x]` but `git status` shows uncommitted
  changes → work was done but not committed
- All items `[x]` but the handoff's Git State SHA doesn't match `HEAD` →
  the handoff document is stale
- Items marked `[x]` without verification → re-verify each `[x]` item
- `just test` passes but the deliverable doesn't match the handoff's
  described outcome → the wrong thing was built

## Files Modified This Session

1. [File path 1]
2. [File path 2]

## Additional Context

- **Project**: [Project name]
- **ADR Compliance**: [Reference to relevant ADRs]
- **Git Workflow**: [Commit strategy]
```
