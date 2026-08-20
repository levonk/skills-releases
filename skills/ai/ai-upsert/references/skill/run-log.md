# Run Log (Crash-Safe Progress Record)

## Table of Contents

1. [Purpose](#purpose)
2. [Initialization](#initialization)
3. [Appending Entries](#appending-entries)
4. [Crash or Interruption](#crash-or-interruption)
5. [Clean Completion](#clean-completion)
6. [Filename Convention](#filename-convention)

## Purpose

Each ai-upsert run appends to a durable run log in `.agents/log/` so that a
crash or interruption leaves a partial but readable record — not nothing. The
run log is **not** a handoff; it is a chronological record of what happened
during this run. It lives outside the handoff tree to avoid littering the
handoff queue with non-handoff documents.

## Initialization

Initialize the run log at the start of Phase 0 (before any work):

```bash
TIMESTAMP=$(date +%Y%m%d%H%M)
SLUG="descriptive-upsert-slug"
LOG_PATH="{REPO_ROOT}/.agents/log/${TIMESTAMP}-ai-upsert-${SLUG}.md"
mkdir -p "$(dirname "$LOG_PATH")"
```

Write the log header:
```markdown
# Run Log: ai-upsert — {SLUG}

**Started**: {YYYY-MM-DD HH:mm}
**Target**: {artifact being upserted}
**Mode**: {A/B/C — filled in after Phase 3}

## Phase Log
```

## Appending Entries

Append after each phase completes (Phase 0 through Phase 5). Each entry is
a short section with the phase name, status, and any notable findings:

```markdown
### Phase {N}: {name} — {CLEAN|WARN|FAIL|BLOCKED}
{one-line summary}
{notable findings, warnings, or blocker details if any}
```

## Crash or Interruption

The log file on disk contains every phase that completed before the crash.
The user can read it to see exactly how far the run got and what happened —
no need to reconstruct from memory or terminal scrollback.

## Clean Completion

The run log contains the full phase-by-phase record. It is **not archived**
— run logs are chronological records, not work-tracking documents with a DoD
gate. They accumulate in `.agents/log/` and can be periodically cleaned
(e.g., `git rm .agents/log/2026/07/*.md` for old months). The log file **is
committed** so the record is durable across clones.

## Filename Convention

`YYYYMMDDHHmm-ai-upsert-{slug}.md` — same date-embedded naming convention as
handoffs, prefixed with `ai-upsert-` to distinguish from other skills' run
logs. No `archive/` subdirectory — logs are flat in `.agents/log/`.
