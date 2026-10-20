# nixpkgs Upstream Requirements

> Binding reference for Step 28b. Nixpkgs is one of the strictest upstreams in
> open source — several of its requirements conflict with the repo's usual
> defaults (no attribution, all-rights-reserved). Those conflicts resolve in
> nixpkgs's favor **inside the nixpkgs worktree only**, and only for the files
> and commits that go into the nixpkgs PR. None of these exceptions bleed back
> into the project repo or any other repo.
>
> Canonical upstream sources:
> [CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md),
> [pkgs/README.md](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md),
> [maintainers/README.md](https://github.com/NixOS/nixpkgs/blob/master/maintainers/README.md),
> [pkgs/by-name/README.md](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md).

## Scoped Exceptions to Local Defaults

| Local default | nixpkgs requirement | Scope of exception |
|---|---|---|
| No AI attribution anywhere | `Assisted-by:` commit trailer **required** when LLM tools produced non-trivial output | Commits in the nixpkgs PR only |
| No tool boilerplate in PR bodies | AI use must be disclosed **again** in the PR body and in review comments | The nixpkgs PR thread only |
| All rights reserved | Submitting implies licensing the contribution under nixpkgs's MIT-like `COPYING` | The diff content only |
| Minimal/pseudonymous identity | `maintainer-list.nix` requires real `name`, `email`, `github`, `githubId` | The `maintainer-list.nix` entry only |

Everything in this page applies inside the nixpkgs worktree. Outside it, the
usual rules still hold — do not add `Assisted-by:` to commits in the upstream
project's PR, do not relicense the in-repo flake, and do not add identity
details to the project's own files.

## Working Copy: Worktree off the Local Clone

Never fresh-clone nixpkgs for a contribution — the repo is multi-GB and the
clone takes a long time. The local base clone is
`~/p/gh/levonk-3rd/nixpkgs` (its `origin` is the fork `levonk/nixpkgs` —
push target; an `upstream` remote points at `NixOS/nixpkgs`). Work happens in
a git worktree under the Orca workspace convention
`~/orca/workspaces/nixpkgs/<slug>`:

```bash
BASE="${NIXPKGS_BASE_CLONE:-$HOME/p/gh/levonk-3rd/nixpkgs}"
WT="${NIXPKGS_WORKTREE_ROOT:-$HOME/orca/workspaces/nixpkgs}/add-${PROJECT}"

# Ensure the upstream remote exists and master is fresh
git -C "$BASE" remote add upstream https://github.com/NixOS/nixpkgs.git 2>/dev/null || true
git -C "$BASE" fetch upstream master

# Branch off upstream/master, never off the fork's possibly-stale master
git -C "$BASE" worktree add -b "add-${PROJECT}" "$WT" upstream/master
cd "$WT"

# ...work... then push to the fork (origin), not upstream
git push --set-upstream origin "add-${PROJECT}"
```

`scripts/prepare-nixpkgs-pr.sh` does this automatically when the base clone
exists (override the location with `NIXPKGS_BASE_CLONE` / `NIXPKGS_WORKTREE_ROOT`);
it falls back to a temp clone only when no base clone is present.

Why a worktree and not a second clone: `git worktree` shares the object store
with the base clone, so the checkout is nearly free and every worktree
benefits from already-fetched upstream history. A `--depth=1` clone both
re-downloads the world and produces a checkout too shallow to rebase or
`nixpkgs-review` comfortably.

## Automation / AI Policy (MANDATORY — highest-risk rule)

Nixpkgs's
[Automation/AI policy](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#automationai-policy)
is enforced and violations get PRs closed and repeat offenders moderated.
Three obligations:

1. **Accountability** — a responsible person must review and understand the
   contribution before submission. "Vibe coding without review is not
   permitted": the contributor must be able to answer review questions about
   the `package.nix` (why this builder, why these deps, what the meta means)
   without proxying everything through the tool.
2. **Disclosure in commits** — every commit containing non-trivial
   LLM-generated content MUST carry an `Assisted-by:` trailer naming the tool
   and the primary model name and version:

   ```
   <package>: init at <version>

   Assisted-by: <tool> (<model> <version>)
   ```

   A `Co-authored-by:` trailer does **not** satisfy the policy — it must be
   `Assisted-by:`.
3. **Disclosure outside commits** — PR summaries and review comments must
   separately disclose automation use. Add one line to the PR body (the
   template in `nixpkgs-pr.md.tmpl` includes it).

Exempt: pure research/debugging use where no substantial output lands in the
contribution; standard deterministic tooling (formatters, `nix-update`,
community bots). Agent-generated `package.nix` scaffolding is **not** exempt.

## Commit Conventions (CI-enforced)

- One commit per logical unit — squash fixup commits before pushing.
- Subject line: **no trailing period**.
- New package: `<attr>: init at <version>` (e.g. `my-tool: init at 1.2.3`).
- Maintainer entry: separate commit `maintainers: add <github-handle>`,
  placed **before** the package commit in the branch.
- Do not squash the `maintainers:` commit into the package commit — they are
  deliberately separate so the maintainer entry can be cherry-picked.
- Signed commits / `Signed-off-by`: not required. `Assisted-by:` **is**
  required (above).

## Maintainer Entry (real identity)

```nix
<handle> = {
  name = "Your Real Name";
  email = "you@example.com";
  github = "<handle>";
  githubId = 12345678; # gh api users/<handle> --jq .id
};
```

- Insert alphabetically by handle in `maintainers/maintainer-list.nix`.
- `name` is your actual name as you want it in the maintainer registry;
  `githubId` must be the numeric id, not the handle — reviewers reject
  placeholders.
- `meta.maintainers = [ lib.maintainers.<handle> ];` in `package.nix` —
  a new package with no maintainer will not be merged.

## Licensing

- Opening the PR licenses the contribution under nixpkgs's MIT-like
  [COPYING](https://github.com/NixOS/nixpkgs/blob/master/COPYING). This
  overrides the all-rights-reserved default **for the diff content only** —
  the upstream project's own files keep their license.
- The upstream project itself must be FLOSS with an identifiable license for
  `meta.license`; an unlicensed upstream cannot be carried (the script
  preflights this).

## Formatting and Style (CI gate)

- All Nix files must be formatted with the official `nixfmt` — run
  `nix fmt` (or `treefmt`) in the worktree before committing. CI fails on
  unformatted files.
- Kebab-case file names; `lowerCamelCase` variables; precise function
  arguments (list exactly what the function uses — no `args:` catch-all, no
  trailing `...` unless genuinely needed).
- Conditional list items use `lib.optional(s)`, not
  `if cond then [ x ] else [ ]`.

## Package Requirements

- `pkgs/by-name/<prefix>/<name>/package.nix` (see `nixpkgs-contribution.md`).
- `src` comes from a fetcher with a real hash — never `src = ./.`.
- `rev` pinned to a release tag (`"v${version}"` when upstream tags that way).
  If upstream has no releases, use the `unstable-YYYY-MM-DD` version
  convention.
- `meta.description`: one short line — no package-name prefix, no leading
  article, no trailing period.
- `meta.license` must map to `lib.licenses.*`; `meta.platforms` must reflect
  reality; set `meta.mainProgram` when the binary name differs from `pname`.
- `meta.homepage` set to the upstream repo or project site.

## Testing and PR Body

- Build with sandboxing: `nix-build -A <pkg>` (sandbox is on by default on
  Linux; on darwin note it in the PR).
- Run the produced binaries: `result/bin/*`.
- Prefer `nixpkgs-review` (`nixpkgs-review wip` or `rev HEAD`) — for new
  leaf packages it mostly verifies the package itself.
- Optional but recommended: `nix run github:jtojnar/nixpkgs-hammering`
  lints for common review findings.
- The PR body should follow nixpkgs's own template sections: a short summary,
  then the **Things done** checklist (built-on-platforms, sandboxing,
  binaries tested, `nixpkgs-review`, "Fits CONTRIBUTING.md, pkgs/README.md,
  maintainers/README.md"). `nixpkgs-pr.md.tmpl` already includes it — answer
  every checkbox truthfully; unchecked boxes signal untested work.
- Branch off `upstream/master` (or the `nixpkgs-unstable` channel commit),
  PR target `master`. New packages are backportable but backporting is
  optional.

## Review Etiquette

- Keep the PR mergeable: rebase and `--force-with-lease` as needed.
- Committers are volunteers; weeks of silence are normal. Ping politely after
  ~a week, or post to the "PRs ready for review" Discourse thread /
  `#review-requests:nixos.org` Matrix room.
- Every review comment requires a real response (applied or politely
  declined with a reason) — comments are non-blocking by default but still
  need acknowledgment.
