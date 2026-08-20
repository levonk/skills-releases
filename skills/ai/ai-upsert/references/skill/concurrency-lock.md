# Concurrency Lock (Phase 4 Serialization)

ai-upsert serializes Phase 4 (Review & Verify) across concurrent runs that
target the same repo and the same skill. Without serialization, two
overlapping runs execute `just test`, `just bats`, `just validate`, and
`just catalog` against the same build output — corrupting results and
wasting compute.

## Scope

| Dimension | Policy |
|-----------|--------|
| Lock key | `sha256(target-repo-path + ":" + skill-name)[:16]` |
| Granularity | Phase 4 only (test/lint/build); Phases 0-3 and 5 run without the lock |
| Storage | `${XDG_CACHE_HOME:-~/.cache}/skills/levonk/skills-releases/skills/ai/ai-upsert/locks/` |
| Config override | `skill-config.sh` key `concurrency.lock_dir` |
| PID reuse guard | PID + process start-time (`ps -o lstart=`) |

Two runs targeting the **same repo + same skill** cannot overlap in Phase
4. Runs targeting different repos, or different skills in the same repo,
proceed concurrently.

## Lock File Lifecycle

```
current/YYYYMMDDHHmmss-{slug}-{key}.sh   (active)
         |
         | (PID dies / start-time mismatch / explicit release)
         v
archive/YYYY/MM/YYYYMMDDHHmmss-{slug}-{key}.sh   (historical)
```

Each lock file is an **executable bash script** that self-validates:

1. **Acquire** (`acquire-lock.sh`): scans `current/` for active locks with
   the same key. If none, creates a new lock file with the caller's PID and
   start-time. If active, applies the action policy (see below).
2. **Check** (`check-lock.sh`): executes each lock file in `current/` with
   the matching key. Each lock file checks `kill -0 <PID>` and compares
   `ps -o lstart=` to the stored start-time. If the PID is dead or the
   start-time differs (PID reuse), the lock file **self-archives** to
   `archive/YYYY/MM/` and reports stale.
3. **Release** (`release-lock.sh`): moves the lock file from `current/` to
   `archive/YYYY/MM/` and appends a completion timestamp.

## Action Policy (when a lock is active)

When a new run detects an active lock, the action depends on the
`AI_UPSERT_LOCK_ACTION` env var or the `--action` flag:

| Action | Behavior | Use when |
|--------|----------|----------|
| `skip` (default) | Skip Phase 4, commit to story branch, create PR, **do NOT merge**. The PR is left open for a later run to pick up tests. | Non-interactive (CI, scripted). Safe default — never silently double-runs. |
| `wait` | Block up to `AI_UPSERT_LOCK_WAIT_TIMEOUT` seconds (default 600s) for the active run to finish, then acquire and run full Phase 4. | Short overlapping windows; interactive runs where the user can wait. |
| `kill` | Send `TERM` (then `KILL` if needed) to the active lock's PID, take the lock, run full Phase 4. | The active run is hung or the user explicitly wants to preempt. |
| `cancel` | Abort this run entirely. Do not acquire the lock. | The user decides not to proceed. |
| `force` | Ignore the active lock, create a new one. Both runs proceed. | Debugging only — defeats the purpose of the lock. |

## Interactive Options

When ai-upsert detects an active lock and the user is interactive, present
these options via the clarifying-questions protocol:

1. **Wait** — block until the active run finishes, then run full Phase 4.
2. **Kill and start** — preempt the active run, take the lock, run full
   Phase 4.
3. **Skip and commit** — skip Phase 4, commit to the story branch, create
   the PR, do not merge (the non-interactive default).
4. **Cancel** — abort this run.

## Non-Interactive Default

When `AI_UPSERT_LOCK_ACTION` is unset and no user is available (CI,
scripted invocation), the default is `skip`:

- Phase 4 (Review & Verify) is **skipped entirely** — no `just test`, `just
  bats`, `just validate`, `just catalog`.
- Phase 5 (Commit) proceeds — the upsert changes are committed to the
  story branch.
- The PR is created (workflow step 7).
- The PR is **not auto-merged** (workflow step 8 is skipped). The PR body
  includes a note: "Phase 4 skipped due to concurrent run — tests deferred."
- A later run (or the concurrent run that held the lock) can re-run Phase 4
  on the same branch and merge.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/lock/acquire-lock.sh` | Acquire a lock or detect an active one. Exit 0 = acquired, 2 = active (caller skips Phase 4), 3 = action failed. |
| `scripts/lock/release-lock.sh` | Release a lock (move to archive). Called at end of Phase 4. |
| `scripts/lock/check-lock.sh` | Check for active locks without acquiring. Prints active lock paths or nothing. |

## Config Key

The lock directory is configurable via `skill-config.sh`:

```toml
# ~/.config/skills/levonk/skills-releases/skills/ai/ai-upsert/config.toml
[concurrency]
lock_dir = "~/.cache/skills/ai-upsert/locks"
```

If the key is absent, the default is
`${XDG_CACHE_HOME:-~/.cache}/skills/levonk/skills-releases/skills/ai/ai-upsert/locks/`.

## Integration Points

- **ai-upsert INSTRUCTIONS.md Phase 4**: acquire lock before 4.1/4.2/4.3;
  release after 4.6 gate. If acquisition returns exit 2 (locked), skip to
  Phase 5 with a run-log note.
- **skill-src-execute workflow step 5b**: the quality gate (`just build
  test validate bats catalog`) runs under the lock. If locked, skip 5b.
- **skill-src-execute workflow step 8**: if Phase 4 was skipped, do not
  auto-merge. The PR stays open.

## Security

- Lock files are stored under `XDG_CACHE_HOME` (default `~/.cache`), not in
  the target repo. They are never committed.
- The lock file contains the repo path, skill name, PID, and start-time —
  no secrets.
- `kill` action sends `TERM` first, then `KILL` after 2 seconds — gives the
  active run a chance to clean up.
- `force` action is documented but discouraged — it creates overlapping
  locks and should only be used for debugging.
