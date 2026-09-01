# Parallel Dispatch — When Multiple Stories Are Dependency-Ready

When Phase 4 finds multiple `[ ] Todo` stories whose dependencies are all
`[x] Done`, dispatch them as parallel background subagents — one per story,
each in its own git worktree — instead of running them sequentially. This
dramatically reduces wall-clock time for phases with parallel-safe stories.

## When to Parallel-Dispatch

Parallel dispatch is appropriate when ALL of the following hold:

1. **Two or more `[ ] Todo` stories** have all dependencies in `[x] Done`
   (or `[!] Blocked` but the story can proceed without them).
2. **The stories do not modify the same files** — check each story's
   "Relevant Files" section (or the PRD's module breakdown). Stories that
   touch shared files (barrel exports, config files, shared utilities) will
   conflict on merge and should be serialized.
3. **The project's test suite supports per-worktree execution** — the
   worktree must be able to run tests independently (symlinked dependencies,
   separate build output).

If only one story is runnable, or stories share files, fall back to the
sequential execution loop described in SKILL.md Phase 4.

## Concurrency Cap

**Cap parallel background subagents at 5 simultaneous.** Each subagent
makes its own API calls (model inference, git operations, package
registry lookups); unbounded concurrency multiplies API load and
triggers rate-limit and secondary-rate-limit bans that block the
orchestrator's token for hours.

When more than 5 stories are dependency-ready at the same time:

1. **Dispatch the first 5** as background subagents (one per worktree).
2. **Queue the rest** in dependency order. Track the queue in the
   progress update so the user can see what is pending.
3. **As each running subagent completes**, dispatch the next queued
   story into the freed slot — do not wait for all 5 to finish before
   starting the next batch.
4. **Report both counts** in every progress emission: how many are
   running and how many are queued (see "Progress Emission" below).

The cap is a ceiling, not a target — if fewer than 5 stories are
runnable, dispatch only those. The cap prevents API exhaustion; it does
not require padding to 5.

## Worktree Setup

For each runnable story:

```bash
# 1. Create a worktree on a new story branch from the integration branch
git worktree add -b <story-branch> /tmp/<project>-worktrees/<story-slug> <base-sha>

# 2. Symlink shared dependencies so the worktree can build and test
#    without re-installing. Adapt to the project's package manager:
ln -sfn <main-repo>/node_modules <worktree>/node_modules

# 3. For monorepos with workspace packages, symlink those too:
ln -sfn <main-repo>/node_modules/@<scope> <worktree>/node_modules/@<scope>
```

For non-JavaScript projects, adapt the dependency symlink (e.g., `target/`
for Rust, `.venv/` for Python). The goal is: the worktree can run the
project's test/lint/build commands without a full install.

## Dispatching Background Subagents

Dispatch one background subagent per worktree, **up to the 5-subagent
concurrency cap** (see "Concurrency Cap" above). When more than 5 stories
are ready, dispatch the first 5 and queue the rest; as each running
subagent completes, dispatch the next queued story into the freed slot.
Each subagent receives the same inputs as a sequential dispatch (see
SKILL.md Phase 4 step 3), plus:

- **Worktree path**: The absolute path to the worktree it should work in.
- **Branch name**: The story branch it should commit to.
- **Constraint**: Work ONLY in the assigned worktree. Do NOT modify files
  outside the worktree. Do NOT modify shared barrel/export files (e.g.,
  `src/index.ts`, `src/lib.ts`) — the orchestrator reconciles those during
  merge.

## Progress Emission (Critical)

**While background subagents are running, emit a progress update after each
subagent completion notification.** Do not go silent during the wait. A
silent orchestrator looks stalled to the user, even when work is progressing
normally.

After each subagent completes, report:

```markdown
### Progress Update

- **Completed**: story NN-NNN — <story title>
  - Tests: <count> passed, <count> failed
  - Status: [x] Done / [!] Blocked
- **Still running**: <N> subagent(s) — story NN-NNN, story NN-NNN
- **Next**: waiting for remaining subagents, then merge reconciliation
```

This pattern prevents the "looks stalled" problem where the user sees no
output for minutes while subagents run in the background.

## Merge Reconciliation

After all parallel subagents complete (or return `BLOCKED`):

1. **Merge each story branch back into the integration branch sequentially.**
   Use `git merge --no-ff` to preserve the story's commit history.

2. **Expect conflicts in shared files.** Even when stories target different
   modules, they may touch shared files (barrel exports, config
   registrations, shared test helpers). Conflicts here are expected, not
   exceptional.

3. **Resolve conflicts by keeping BOTH sides' additions.** When two stories
   add exports/registrations to the same file, keep both blocks. Never
   delete a story's work to resolve a conflict — if a story added an
   export, that export is needed.

4. **Watch for symbol/export name collisions.** Parallel subagents
   independently choose symbol names and may collide (e.g., two stories
   both export `FetchFn`). After merging all branches:
   - Run the project's typecheck (or equivalent static analysis).
   - If collision errors appear (e.g., TypeScript TS2308, duplicate symbol
     errors), rename the newer module's colliding symbol with a
     module-specific prefix (e.g., `FetchFn` → `ActorFetchFn`).
   - Update all references to the renamed symbol within that module.

5. **Run full validation across all affected packages/modules.** After all
   merges: run typecheck + tests + lint across the entire project (not just
   the individual story modules). Fix any integration issues that arise
   from the merge.

6. **Commit the reconciliation** as a single merge-commit:
   ```
   chore: reconcile parallel story merges

   - Merged story NN-NNN, NN-NNN, NN-NNN into integration branch
   - Resolved export collisions in <file>
   - Renamed <symbol> to <prefixed-symbol> in <module>
   - Full typecheck + tests pass across all packages
   ```

7. **Update the task index** to reflect the merged state of all stories.

## Blocked Stories in Parallel Mode

If a subagent returns `BLOCKED`:
- Mark the story `[!] Blocked` in the index with the `blocked_reason`.
- Write the `## Blocker` section into the story file.
- Do NOT block the other parallel subagents — let them finish.
- Include the blocked story in the Phase 5 Blocker Report along with any
  sequentially-blocked stories.

## Verifying Subagent Liveness (Write-Activity-Based)

**Worktree existence does NOT mean agents are working.** A worktree only
proves the setup step ran. If the orchestrator crashed and was restarted,
the subagents are dead but the worktrees remain as tombstones.

The liveness check uses **write-activity detection** — a pane with a
file newer than the start of its own quiet window is alive (or deferred),
not stale. This follows the
[event-driven-supervision](../../knowledge/agent-orchestration-practices/event-driven-supervision.md)
knowledge bundle page: the expensive check runs only in the branch about
to escalate, not on every poll.

### The Quiet Window

Each worktree has a **quiet window** — the time since the last file
write in that worktree. The check is:

- A file newer than the start of the quiet window → **alive or
  deferred**. The subagent wrote recently; it is either still working
  or paused but not dead. Do not escalate.
- No file newer than the start of the quiet window → **stale**. The
  subagent has not written anything within the quiet window. Escalate
  (reclaim or re-dispatch).

The quiet window length is configurable via
`FM_WORKTREE_WRITE_TIMEOUT` (default: 10 minutes). A worktree with no
writes for 10 minutes is stale.

### Bounded Search

The `find` is bounded to prevent scanning the entire filesystem:

- `FM_WORKTREE_WRITE_MAXDEPTH` (default: 5) — limit the directory depth
  of the search. Most work happens in the top few levels; deep scans are
  wasted.
- Prune `node_modules`, `.git`, `build`, `dist`, `.next`, `target` —
  these are generated directories that may have stale timestamps from
  build tools, not from the subagent.

Search **only the worktree recorded for that task** — do not scan
sibling worktrees or the main checkout. Each task's liveness is
independent.

### The Check (Run Only When About to Escalate)

The expensive `find` check runs **only in the branch about to escalate**
— when the orchestrator is about to reclaim or re-dispatch a worktree
it suspects is dead. Do not run it on every poll. The cheap checks (git
HEAD, uncommitted count) run first; the `find` runs only if the cheap
checks are inconclusive.

```bash
# Cheap checks first
head=$(git -C "$wt" rev-parse --short HEAD)
changes=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Expensive check — only if cheap checks are inconclusive
# (head == base AND changes == 0 — might be dead, verify with write activity)
timeout "${FM_WORKTREE_WRITE_TIMEOUT:-600}" \
  find "$wt" -type f \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/build/*' \
    -not -path '*/dist/*' \
    -not -path '*/.next/*' \
    -not -path '*/target/*' \
    -maxdepth "${FM_WORKTREE_WRITE_MAXDEPTH:-5}" \
    -newermt "${FM_WORKTREE_WRITE_TIMEOUT:-10} minutes ago" \
    2>/dev/null | wc -l | tr -d ' '
```

### Interpretation

- `head != base` → has committed work. Progress was made — inspect the
  diff before deciding whether to keep or re-dispatch. Do not escalate.
- `head == base` + `changes > 0` → uncommitted work exists. The
  subagent may be mid-task. Run the write-activity check.
- `head == base` + `changes == 0` + `recent > 0` → **alive or
  deferred**. A file was written within the quiet window. Wait; do not
  escalate.
- `head == base` + `changes == 0` + `recent == 0` → **stale**. No
  commits, no uncommitted changes, no recent writes. Escalate: reclaim
  the worktree, commit any partial work if useful, re-dispatch a fresh
  subagent.

### On Resume After a Crash

1. Run the cheap checks for all worktrees.
2. For worktrees where the cheap checks are inconclusive, run the
   write-activity check.
3. For stale worktrees with partial uncommitted work: inspect the diff.
   If the partial work is usable, commit it as a checkpoint. If not,
   discard it (`git -C <wt> checkout -- . && git -C <wt> clean -fd`).
4. Re-dispatch fresh subagents for the stories that had stale worktrees.
   Do NOT assume the old subagent's partial state — start clean from the
   base SHA unless the committed checkpoint is solid.

This liveness check applies to the parallel-dispatch worktrees created in
the "Worktree Setup" section above. For sequential execution (single
story branch, no worktree), the Phase 6 "Resume Detection" step in
SKILL.md handles branch existence checks — liveness verification is not
needed because the orchestrator itself is the single worker.

## Turn-End Guard (Parallel Mode)

When parallel subagents are still running and the orchestrator turn is
about to end, the orchestrator must **not end the turn blind**. Either:

1. **Block** — wait for the subagents to complete before ending the
   turn. Use `read_subagent` with `block=true` to wait for each
   in-flight subagent.
2. **Follow up** — if the subagents are long-running and blocking would
   exceed the turn budget, write a handoff (via the `handoff` skill)
   that records the in-flight subagent IDs and their worktree paths so
   the next session can resume supervision.

The turn-end guard prevents a common failure mode: the orchestrator
ends its turn, the subagents keep running but no one is watching, and
when they complete their results are lost (no one reads them). The
guard ensures that either the orchestrator waits for completion or
explicitly hands off supervision.

### When to Apply the Guard

Apply the turn-end guard whenever:

- One or more parallel subagents are still running (dispatched but not
  yet read via `read_subagent`).
- The orchestrator is about to end its turn (all sequential work is
  done, or the turn budget is exhausted).

### When to Skip the Guard

Skip the turn-end guard when:

- No parallel subagents are in flight (all have been read and their
  results processed).
- The orchestrator is not ending its turn (more sequential work
  remains).

## Cleanup

After merge reconciliation is complete, remove the worktrees:

```bash
git worktree remove /tmp/<project>-worktrees/<story-slug>
```

Do this only after the merge is committed and validated — if the merge
needs to be redone, the worktree is the recovery point.

## See Also

- [SKILL.md Phase 6](../SKILL.md) — the sequential execution loop that this
  parallel mode optimizes
- [triage-heuristic.md](triage-heuristic.md) — request size and shape
  assessment
- [documentation-update.md](documentation-update.md) — Phase 6 documentation
  updates after execution completes
- [event-driven-supervision](../../knowledge/agent-orchestration-practices/event-driven-supervision.md)
  — the knowledge bundle page on zero-token supervision, write-activity
  liveness, and turn-end guards that this liveness check is based on
