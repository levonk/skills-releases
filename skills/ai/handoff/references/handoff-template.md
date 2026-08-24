# Handoff Document Template

## Storage Lifecycle & Commit Conventions

Handoff documents use a two-stage lifecycle (todo → archive) per the shared
`work-lifecycle` include. The include supports **audience variants** (agent
vs human) — see its "Audience Variants" section for routing criteria.

> **Branch policy: handoffs commit to `main`, not feature branches.** Handoff
> documents are operational instructions (control flow) that tell the next
> agent to invoke execute-upsert, which creates feature branches for the work.
> They must be on the default branch (`main`) so the next agent checking out
> `main` can find them. Do NOT create a feature branch for the handoff document
> itself — the work described BY the handoff goes through execute-upsert onto
> feature branches; the handoff document itself does not. This applies to both
> the capture commit (creating the handoff) and the archive commit (`git mv`
> todo/ → archive/). Putting a handoff on a feature branch is a chicken-and-egg
> failure: the handoff tells you to invoke execute-upsert to create branches,
> but the handoff itself must already be on `main` to be found.

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
2. **Defer to execute-upsert for execution.** Invoke execute-upsert with the
   Execution Plan — it handles worktree creation, subagent dispatch, code
   review, and PR landing. Do not hand-roll commits, branches, PRs, or test
   runs outside execute-upsert — that bypasses the worktree-per-story
   discipline and the binding contract.
3. **Mark done only when verified.** Flip `[~]` → `[x]` only after the task's
   Definition of Done checks pass (see below). Never mark `[x]` on intent
   alone.
4. **Record blockers inline.** When a task cannot proceed, mark it `[!]` and
   append the blocker in parentheses on the same line, e.g.
   `- [!] {task blocked (waiting on upstream API access)}`. Move on to the
   next `[ ]` task — do not stall the whole list on one blocker.
5. **Update the list as work reveals new tasks.** Append newly discovered
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

## Execution Plan

Every task below is executed via the `execute-upsert` skill, which enforces
worktree-per-story, checkpoint commits, story branches, PRs, and clean-tree-
before-stop uniformly. The receiving session invokes execute-upsert with this
plan; it does not hand-roll the execution discipline.

**Story type** (`trivial` | `standard` | `research`): a forward-compatible tag.
Today execute-upsert treats all three identically — same worktree, branch, PR,
clean-tree discipline. The type is stored as metadata. If divergence becomes
necessary later, the behavior change is one `case` statement in
`execution-gate.sh` — no handoff documents need re-editing.

| Story slug | Type | Base SHA | DoD |
|------------|------|----------|-----|
| {story-slug-1} | {type} | {base-sha} | {per-story DoD checklist} |
| {story-slug-2} | {type} | {base-sha} | {per-story DoD checklist} |

**Columns:**
- **Story slug**: kebab-case, unique within this handoff. execute-upsert uses
  it as the worktree directory name and story branch name suffix.
- **Type**: one of `trivial` (1-line fix, doc typo), `standard` (feature,
  bugfix, refactor), or `research` (ADR, spike, investigation memo). All
  treated identically today — the tag is for future divergence.
- **Base SHA**: the commit SHA the story branches from. Usually the handoff's
  Git State commit SHA. For sequential stories, re-derive after each lands.
- **DoD**: the per-story Definition of Done checklist, verbatim. This is what
  execute-upsert evaluates against — not a global DoD.

## Open Questions/Blockers
- [Question 1] - [Impact if unresolved]
- [Question 2] - [Impact if unresolved]

## Do Not
- [Things to avoid or approaches rejected]

## Suggested Skills
- execute-upsert - Always invoked to execute the handoff's Execution Plan.
  Enforces worktree-per-story, checkpoint commits, story branches, PRs, and
  clean-tree-before-stop uniformly across all task types.
- [skill-name] - [additional skill if needed for specific task]

## Additional Context
[Any other information crucial for continuation]
```

## Human Handoff Template

Use this template when a task is blocked on human-only action (API keys,
access, decisions, approvals). The reader is a person, not a session-
restoration target — keep it short and action-oriented. See the
`work-lifecycle` include's "Audience Variants" section for routing criteria.

```markdown
---
date:
  created: "YYYY-MM-DD"
  completed: ""
  last-activity: "YYYY-MM-DD"
---

# {Action needed — one line, e.g., "Provide OpenAI API key for eval runner"}

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
- Relevant files: {paths}
- Run log: `.agents/log/{filename}.md` (if applicable)

**How to unblock me:** {what to do after the action is taken — e.g.,
"re-run the ai-upsert skill" or "tell me the API key is in `.env`"}
```

**Human handoff DoD** (single item):
- [ ] The blocker was resolved and the requesting task in the agent handoff
  is marked `[x]`

**Human handoff archive:** when the DoD is met, `git mv` from
`human/todo/` to `human/archive/YYYY/MM/` per the `work-lifecycle` include.

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
2. **Defer to execute-upsert for execution.** Invoke execute-upsert with the
   Execution Plan — it handles worktree creation, subagent dispatch, code
   review, and PR landing. Do not hand-roll commits, branches, PRs, or test
   runs outside execute-upsert.
3. **Mark done only when verified.** Flip `[~]` → `[x]` only after the
   Definition of Done checks pass (see below).
4. **Record blockers inline.** Mark blocked tasks `[!]` with the blocker in
   parentheses. Move on to the next `[ ]` task.
5. **Update the list as work reveals new tasks.** Append new tasks as `[ ]` in
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

## Execution Plan

Every task below is executed via the `execute-upsert` skill, which enforces
worktree-per-story, checkpoint commits, story branches, PRs, and clean-tree-
before-stop uniformly. The receiving session invokes execute-upsert with this
plan; it does not hand-roll the execution discipline.

| Story slug | Type | Base SHA | DoD |
|------------|------|----------|-----|
| {story-slug-1} | {type} | {base-sha} | {per-story DoD checklist} |
| {story-slug-2} | {type} | {base-sha} | {per-story DoD checklist} |

## Files Modified This Session

1. [File path 1]
2. [File path 2]

## Additional Context

- **Project**: [Project name]
- **ADR Compliance**: [Reference to relevant ADRs]
- **Git Workflow**: [Commit strategy]
```
