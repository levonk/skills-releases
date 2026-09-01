# Capturing Learnings to Project Memory

When the orchestrator decides a learning is worth persisting (per the
trigger criteria in SKILL.md Phase 4 step 4.5), it spawns a
**reflect-style 3-lens review**. This document covers the contract for
that review.

## The 3-Lens Reflect Review

Instead of a single memory-capture subagent, spawn **3 parallel
reviewers** each examining the work from a different lens:

1. **Judgment lens** — what decisions were made, and which ones should
   not be repeated? Looks for decisions that were wrong, slow, or
   fragile. Asks: "what would we do differently next time?"
2. **Tooling lens** — what friction could have been eliminated by a
   tool? Looks for manual steps, repeated workarounds, and procedures
   that a script, lint rule, or runtime check could automate. Asks:
   "what should the tooling enforce next time so we do not have to
   remember?"
3. **Divergent lens** — what did we miss? Looks for assumptions that
   went unexamined, edge cases that were not considered, and
   alternatives that were not explored. Asks: "what blind spot did we
   have?"

Each reviewer returns findings as structured items:

```
LENS: <judgment|tooling|divergent>
FINDING: <one-sentence description>
EVIDENCE: <story-name, commit ref, or specific code location>
ACTION: <doc-edit|tooling-task|backlog-item>
STRUCTURAL: <yes|no>  — can this be enforced by lint/script/metadata/runtime check?
```

## Synthesis: Accepted / Rejected / Backlog

The orchestrator collects all 3 reviewers' findings and synthesizes:

- **Accepted** — findings that become doc edits. Added to the
  developer doc's Known Gotchas section (see below). These are
  judgment-based learnings that cannot be structurally enforced.
- **Rejected** — findings that are factually wrong, out of scope, or
  already addressed. Document why (one line each).
- **Backlog** — findings that become tooling tasks. These are
  learnings that **can** be structurally enforced — moved from
  Accepted to Backlog per the structural enforcement check below.

## Structural Enforcement Check

For any accepted learning, ask: **can this be enforced by a lint rule,
script, metadata flag, or runtime check?** If yes, move it from
Accepted to Backlog — it becomes a tooling task, not a doc edit. This
follows the
[encode-lessons-in-structure](../../knowledge/agent-orchestration-practices/encode-lessons-in-structure.md)
knowledge bundle page: text instructions get skipped, structural
enforcement does not.

The test: can a new agent violate this learning without noticing? If
yes, the learning is text, not structure. Encode it as structure.

Examples:

- "Always run tests through devbox" → encode as a script that refuses
  to run outside devbox (worktree isolation guard pattern). Backlog
  item, not a doc edit.
- "Do not commit secrets" → already encoded as scan-artifacts.sh. No
  doc edit needed.
- "The caching layer has a subtle race when X" → judgment-based, cannot
  be structurally enforced. Accepted as a doc edit.

## Where in the Developer Doc

Add accepted learnings to the "Known Gotchas" section (or equivalent —
"Troubleshooting", "Common Issues", etc.) of the project's developer
docs. If the section does not exist, create it.

The developer docs are the progressively-disclosed documentation
referenced from `AGENTS.md`. This is NOT `AGENTS.md` itself (which is
always-loaded context and must stay lean). Typical locations:

- `.agents/knowledge/developer.md` (skills-src convention)
- `docs/developer-guide.md` (alternative location)
- Whatever path `AGENTS.md`'s "Developer Guide" or "JIT Index" section
  references

The reviewer must read `AGENTS.md` first to find the developer-doc
reference. If no developer doc exists, create one following the
progressive-disclosure pattern (JIT Index → sections → Known Gotchas)
and add a reference to it from `AGENTS.md`.

Each entry should be concise — one paragraph per gotcha:

```markdown
### <gotcha-name>

**Symptom**: <what the agent observes — the error message or behavior>

**Cause**: <why it happens — the underlying reason>

**Fix**: <the sanctioned command or approach>

**Learned from**: <story-name or commit ref where this was encountered>
```

## Rewrite-and-Prune (Not Append-Only)

The learnings section is **dated, evidence-backed, curated, and
updated with inspect-then-update** — rewrite and prune rather than
append forever. A learnings file that only appends becomes a graveyard
of stale entries that no one reads.

When adding a new learning:

1. **Search first** — search the existing learnings for similar
   gotchas. If one exists, extend it with the new detail instead of
   adding a new entry.
2. **Prune stale entries** — if an existing entry references a tool,
   version, or workaround that is no longer relevant (the bug was
   fixed upstream, the tool was replaced), remove or update it.
3. **Keep it curated** — the learnings file should be a curated set of
   currently-relevant gotchas, not a historical log. The git history
   is the historical log; the file is the current state.

## What the Review Returns

- The path to the updated developer doc (if any accepted learnings).
- A one-line summary of each accepted learning.
- A list of backlog items (structural enforcement tasks) with their
  proposed enforcement mechanism (lint rule, script, metadata flag,
  runtime check).
- A list of rejected findings with one-line reasons.

The orchestrator then:

1. Commits the doc update as its own commit (separate from the story's
   code commit) so the learning is traceable in git history.
2. Files backlog items as follow-up stories or tasks in the task index.

## See Also

- [report-templates.md](report-templates.md) — the workaround report
  that triggers this flow
- [worked-examples.md](worked-examples.md) — Example 4 shows a full
  workaround-to-memory-capture flow
- [encode-lessons-in-structure](../../knowledge/agent-orchestration-practices/encode-lessons-in-structure.md)
  — the knowledge bundle page on structural enforcement of learnings
