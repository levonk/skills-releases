# Evolution Protocol

## Overview

Requirements evolve. The ledger records both the current state and the
history of changes. The current file is the living spec; history
snapshots are taken before each substantive change. Plans for future
changes live in `proposed/` and `todo/`.

## The Four States

```
proposed/ ──(matures)──→ todo/ ──(implemented)──→ current/ updated + todo → history/
current/  ──(superseded)──→ history/ (snapshot of pre-change version)
```

See `granularity-guidance.md` for the full four-state lifecycle
description.

## When to Snapshot

Snapshot before any change that alters the requirement's meaning,
constraints, or verification. Do NOT snapshot for:

- Typo fixes
- Formatting changes
- Adding a see-also link
- Updating the Change Log itself

DO snapshot for:

- Changing a threshold (2.5s → 2.0s)
- Adding or removing a constraint
- Changing the verification approach
- Superseding the requirement

## Snapshot Process (current → history)

1. Run `scripts/snapshot-requirement.sh --project {proj} --module {module}
   --slug {slug}`.
2. The script reads the current file and writes a copy to
   `history/YYYY/MM/{proj}/{module}/req-YYYYMMDDHHmm-{slug}.md`.
3. The snapshot's frontmatter is updated:
   - `status: superseded` (or `status: created` if no prior history)
   - `date.superseded: "YYYY-MM-DD"` (when superseded)
   - `superseded-by:` pointing to the current file path
4. The current file is then edited in place.

## Process Todo (todo → history + current updated)

When execute-upsert implements a change described in a todo file:

1. Run `scripts/process-todo.sh --project {proj} --module {module}
   --slug {slug}`.
2. The script snapshots the pre-change `current/` requirement to
   `history/` (if one exists).
3. The todo file is moved to
   `history/YYYY/MM/{proj}/{module}/todo-YYYYMMDDHHmm-{slug}.md` via
   `git mv` (preserving git history), then its frontmatter is updated
   in place to `status: implemented` with `date.implemented` set.
4. **If no `current/` file exists** (new requirement): the AI creates
   one fresh from `references/requirement-template.md`. The archived
   todo is reference material only — read it to understand what was
   implemented, but write `current/` as a pure description of how the
   system works now. Do NOT copy the todo into `current/` — that would
   import plan baggage (Desired Behavior, gap analysis, status:
   implemented) into a file that should describe only current reality.
   One file per requirement in `current/`, no previous-state content.
5. **If `current/` already exists** (changed requirement): the AI
   updates it to reflect the new behavior, bumps `date.last-revised`,
   and appends a Change Log entry referencing the archived todo.
6. For new requirements, run `snapshot-requirement.sh` to create the
   initial history snapshot.
7. Run `index-requirements.sh` to regenerate INDEX.md and INDEX.html.

## Proposed → Todo Transition

When a proposed plan matures and is ready to be implemented:

1. Set `date.ready` in the frontmatter to today's date.
2. Set `status: todo`.
3. Move the file from `proposed/{proj}/{module}/` to
   `todo/{proj}/{module}/` using `git mv` (preserves git history).
4. Regenerate INDEX.md: `scripts/index-requirements.sh`.

## Full Evolution Chain

```
proposed/{proj}/{module}/{proj}_{module}_{slug}.md
  │
  │ git mv (matures: set status=todo, date.ready)
  ▼
todo/{proj}/{module}/{proj}_{module}_{slug}.md
  │
  │ process-todo.sh: git mv todo to history/ (status=implemented)
  │ AI writes current/ fresh from requirement-template.md
  ▼
history/YYYY/MM/{proj}/{module}/todo-YYYYMMDDHHmm-{slug}.md  (archived plan)
  +
current/{proj}/{module}/{proj}_{module}_{slug}.md            (new requirement, written fresh)
  │
  │ snapshot-requirement.sh on next change
  ▼
history/YYYY/MM/{proj}/{module}/req-YYYYMMDDHHmm-{slug}.md   (superseded snapshot)
```

Every file move uses `git mv` to preserve git history — never plain
`rm` + create. The todo→current transition is NOT a file move: the
todo is archived to `history/` via `git mv`, and `current/` is written
fresh from `requirement-template.md` using the archived todo as
reference material only. This keeps `current/` as a clean description
of how the system works today, with no plan baggage — you can recreate
the production product from `current/` alone without digging through
previous states.

## Supersession

When a requirement is no longer active (replaced by a different
requirement, or the constraint no longer applies):

1. Take a final snapshot.
2. Set `status: superseded` in the current file.
3. Set `date.superseded` to today.
4. The current file stays in `current/` — it is the latest state, even
   if that state is "no longer active". INDEX.md marks it as
   _(superseded)_.

Do NOT move the current file to history. The current file is always the
latest version. History contains the snapshots of what it was before
each change.

## Change Log Format

Append to the Change Log section at the bottom of the current file:

```
- YYYY-MM-DD — {what changed} — [snapshot](history/YYYY/MM/{proj}/{module}/req-YYYYMMDDHHmm-{slug}.md)
```

Or, when the change was driven by a todo:

```
- YYYY-MM-DD — {what changed} — [todo](history/YYYY/MM/{proj}/{module}/todo-YYYYMMDDHHmm-{slug}.md)
```

Keep entries terse — one line per change. The snapshot or archived todo
has the full pre-change content and the plan that drove the change.

## Relationship to ADRs

A requirement says **what** the system must do. An ADR says **why** a
particular approach was chosen. When a requirement changes because of an
architectural decision, link the ADR in the requirement's `see-also` and
mention the ADR in the Change Log entry.
