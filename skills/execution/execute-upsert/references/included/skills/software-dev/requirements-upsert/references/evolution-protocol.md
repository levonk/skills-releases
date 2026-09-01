# Evolution Protocol

## Overview

Requirements evolve. The ledger records both the current state and the
history of changes. The current file is the living spec; history
snapshots are taken before each substantive change.

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

## Snapshot Process

1. Run `scripts/snapshot-requirement.sh --project {proj} --module {module}
   --slug {slug}`.
2. The script reads the current file and writes a copy to
   `history/YYYY/MM/{proj}/{module}/req-YYYYMMDDHHmm-{slug}.md`.
3. The snapshot's frontmatter is updated:
   - `status: superseded` (or `status: created` if no prior history)
   - `date.superseded: "YYYY-MM-DD"` (when superseded)
   - `superseded-by:` pointing to the current file path
4. The current file is then edited in place.

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

Keep entries terse — one line per change. The snapshot has the full
pre-change content.

## Relationship to ADRs

A requirement says **what** the system must do. An ADR says **why** a
particular approach was chosen. When a requirement changes because of an
architectural decision, link the ADR in the requirement's `see-also` and
mention the ADR in the Change Log entry.
