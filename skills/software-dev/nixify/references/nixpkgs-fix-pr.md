# nixpkgs Fix/Update Contributions

> **When this applies**: the task is a **fix or version bump to an EXISTING
> nixpkgs package** — not the init of a new package. `nixpkgs-contribution.md`
> covers init only. Both share `nixpkgs-requirements.md` (Assisted-by
> trailers, maintainer-list.nix, nixfmt, commit conventions, worktree
> convention) — read it before opening any nixpkgs PR.

## Why a Separate Procedure

Step 28b's dedup coverage searches the **project's own repo**
(`search-existing-work.sh`) — it cannot see work already open in
`NixOS/nixpkgs`. That gap produced a real duplicate:

- **2026-10-19**: an agent opened NixOS/nixpkgs#576090 ("packer: 1.15.4 ->
  1.16.1") to fix a SIGSEGV on aarch64-darwin.
- The bump was already covered by r-ryantm's bot PR **#545258**, open since
  **2026-07-24** — nearly three months.
- #576090 was closed as a duplicate on **2026-11-07**.

Two independent misses compounded: no search of the target repo, and no
check whether the fix already shipped in a newer upstream release (packer
v1.16.1 vendored the fixed go-m1cpu — the correct contribution was a plain
version bump, which the bot PR already was).

## Step 1 — Classify the Contribution

Before anything else, determine which class this is:

| Class | Signal | Typical title |
|-------|--------|---------------|
| `init` | package not in nixpkgs at all | `<pkg>: init at <version>` |
| `version_bump` | upstream released a newer version; nixpkgs lags | `<pkg>: <old> -> <new>` |
| `fix` | build/runtime fix at the SAME version (patch, override, dep bump) | `<pkg>: fix <what>` |
| `meta` | license, platforms, description, maintainer changes only | `<pkg>: <what>` |

The class changes what "duplicate" means: for `version_bump` and `fix`,
any open PR touching the same package is suspect; for `meta`, only PRs
touching the same meta field matter.

## Step 2 — Search the Target Repo (MANDATORY)

Run the mechanical check — do NOT rely on prose judgment for this:

```bash
scripts/search-nixpkgs-prs.sh <package> --version <target-version> --verbose
```

It searches `NixOS/nixpkgs` (override with `--repo` for other targets —
NixOS/nixpkgs-archive, a distro repo, etc.) for PRs and issues matching the
package, classifies title-scoped PRs (`<pkg>: ...` convention) by state,
flags bot-authored and `nix-update`-labeled PRs, and emits a
`recommendation` field:

| recommendation | Meaning | Action |
|----------------|---------|--------|
| `coordinate` | open package-scoped PR exists | Read it; comment or coordinate with the author. Do NOT open a duplicate. |
| `coordinate_version_match` | open PR already targets your version | Same — the duplicate is certain. |
| `skip_already_landed` | merged PR already carries your version | Do not open anything. |
| `investigate_merged` | merged scoped PRs exist, none match your version | Read them — the fix may already be in. |
| `proceed_closed_only` | only closed-unmerged scoped PRs | Read why they closed first. |
| `proceed` | no scoped PRs found | Continue to Step 3. |

**Present every match to the user before proceeding** — the script reports,
it does not decide. A `proceed` result still lists `bot_prs` and
`other_matches`; scan them for near-misses (a PR titled differently that
touches the same derivation).

## Step 3 — Check Whether Upstream Already Ships the Fix

Before writing a patch, check the upstream project's recent releases and
tags. The needed fix may already exist in a newer release — in which case
the correct nixpkgs contribution is a **version bump**, not a patch.

```bash
# What does nixpkgs currently ship?
grep -r 'version = ' <nixpkgs-worktree>/pkgs/by-name/<prefix>/<pkg>/package.nix

# What has upstream released since?
gh release list --repo <upstream-owner>/<upstream-repo> --limit 10
git ls-remote --tags https://github.com/<upstream-owner>/<upstream-repo> | tail -20
```

For each newer upstream release, check its changelog/commits for the fix
you were about to patch (e.g. a vendored dependency bump — packer v1.16.1
vendored the fixed `go-m1cpu`). If a release ships the fix:

- The contribution is `version_bump`, not `fix` — update `version`,
  `src.rev`, and hashes; do not carry a patch.
- Re-run Step 2 — a bot PR for that bump is very likely already open.

## Step 4 — Check Bot-Maintained Update PRs

nixpkgs update bots are the most likely source of duplicates. The script
flags them in `bot_prs`, but know the patterns:

- **Author `r-ryantm`** — runs nix-update; opens `<pkg>: <old> -> <new>`
  PRs for most packages on a rolling basis. PRs sit open for weeks or
  months awaiting review.
- **Labels** `8.has: package (update)`, `2.status: merge-bot eligible`,
  anything matching `*bot*` or `nix-update`.
- Other known updaters: `nix-update` bot accounts, `dependabot`,
  `renovate` (rare in nixpkgs but present in flakes).

If a bot PR covers the same version bump:

- **Open**: comment on it (e.g. with build/test evidence or platform
  notes) or coordinate — do not open a competing PR. Two PRs for the same
  bump guarantee one is closed as a duplicate and wastes reviewer time.
- **Merged**: the bump is in nixpkgs-unstable already; pick a different
  problem or wait for the next release cycle.
- **Closed unmerged**: read the close reason — maintainers sometimes close
  bot bumps for broken builds; your fix may need to address that reason.

## Step 5 — Decision Summary

```
search-nixpkgs-prs.sh <pkg> --version <v>
        │
        ├─ recommendation=coordinate* ──→ comment/coordinate, STOP
        ├─ recommendation=skip_already_landed ──→ STOP, nothing to do
        ├─ recommendation=investigate_merged ──→ read merged PRs, re-classify
        └─ recommendation=proceed* ──→ Step 3 upstream-release check
                                          │
                                    newer release ships fix?
                                          │ yes → version_bump, re-run Step 2
                                          │ no  → write the fix/patch PR
```

Only after all five steps clear do you write the patch or version bump —
then follow `nixpkgs-requirements.md` (Assisted-by trailer, maintainer
entry, nixfmt, `<pkg>: <action>` title) and the worktree convention exactly
as for init PRs.

## PR Conventions for Fix/Update

Same rules as init, different titles:

- Version bump: `<pkg>: <old> -> <new>` (e.g. `packer: 1.15.4 -> 1.16.1`)
- Fix at same version: `<pkg>: fix <what>` (e.g. `packer: fix aarch64-darwin SIGSEGV`)
- Meta-only: `<pkg>: <what>` (e.g. `packer: mark broken on <platform>`)

The PR body for a fix should state the failure mode, the upstream
reference (issue/commit/release that fixes it), and what you tested. If
your fix duplicates what an open bot PR would deliver, prefer commenting
on that PR over opening your own — see Step 4.
