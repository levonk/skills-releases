# Garnix CI (Hosted Alternative)

[Garnix](https://garnix.io) is a hosted CI service for Nix flake repos. After
installing the Garnix GitHub App on a repository, every push automatically
builds all flake outputs (`packages`, `checks`, `devShells`,
`nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`) and
reports results back as GitHub commit/PR checks. Build outputs are cached on
Garnix's side, so subsequent builds and local `nix run` fetches are fast.

## Relationship to the required `.github/workflows/nix.yml`

Garnix is a **complement**, not a replacement, for the required GitHub Actions
workflow (see [GitHub Actions CI for Nix](github-actions-nix.md)):

- **`nix.yml`** is the **contributor-controlled** CI. The nixify PR adds it,
  and it works immediately on any repo — no maintainer action needed. It is
  the only CI the contributor can guarantee.
- **Garnix** is the **maintainer-opt-in** CI. The contributor cannot install
  the Garnix GitHub App on a repo they don't own. Adding a `garnix.yaml` to
  the PR makes the repo Garnix-ready the moment the maintainer enables the
  app, but it does nothing until then.

Keep `nix.yml` in every PR. Add `garnix.yaml` as an optional artifact when the
maintainer has expressed interest in hosted Nix CI, or when the project's
cross-platform coverage needs exceed what a single-runner GitHub Actions
workflow provides.

## The maintainer-opt-in constraint

nixify PRs go to **upstream third-party repos**. The contributor does not have
permission to install the Garnix GitHub App on the target repo — that requires
the repo owner to visit [app.garnix.io](https://app.garnix.io), install the
app, and authorize it for the repository. Therefore:

1. **`garnix.yaml` in the PR** configures build scope *if* the maintainer later
   enables the app. It is inert until the app is installed — no side effects,
   no broken checks.
2. **The PR body** should mention Garnix as an optional complement, not as
   something the PR activates. Phrase it as: "A `garnix.yaml` is included so
   the repo is ready for [Garnix CI](https://garnix.io) if the maintainer
   chooses to enable it."
3. **Do not** add Garnix badges to the README unless the maintainer has already
   enabled the app — a badge that links to a non-existent Garnix project page
   is worse than no badge.

## `garnix.yaml` configuration

Garnix's **default** build scope is **linux-only**:
`*.x86_64-linux.*`, `defaultPackage.x86_64-linux`, `devShell.x86_64-linux`,
plus all `homeConfigurations.*`, `darwinConfigurations.*`, and
`nixosConfigurations.*`. Mac (`aarch64-darwin`, `x86_64-darwin`) and ARM-linux
(`aarch64-linux`) builds are **opt-in** via the `builds.include` list.

This is the exact cross-platform gap the nixify skill cares about — the
`target_platforms` from Step 4a determines which systems to include. Run
`scripts/detect-garnix-scope.sh` to generate the correct `garnix.yaml` from
the Step 4a output.

**For `platform_scope=all` (all 4 systems):**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=darwin_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=linux_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
```

## FOD checks (hash-rot detection)

For source-build flakes, enable FOD (fixed-output derivation) checks to catch
hash rot — the exact failure mode the lockfile path-filter section documents
(Archon PR #2131: `bun.lock` changed but Nix CI never ran, so the FOD hash rot
reached users silently):

```yaml
fodChecks: true
```

Garnix's FOD checks verify that all fixed-output derivations in the flake
produce the expected hashes. When a lockfile bump invalidates a FOD hash,
Garnix catches it on the next push — before it reaches users. This is
complementary to the `nix.yml` lockfile path-filter: the path-filter ensures
`nix.yml` *runs* on lockfile changes; Garnix's `fodChecks` provides an
independent hosted verification layer.

Enable `fodChecks: true` for `flake_type=source_build` and
`flake_type=prebuilt_tarball` (the `#source` output in prebuilt tarball flakes
also uses FODs). Skip if the flake has no FOD outputs (rare — most source
builds use `fetchurl`/`fetchFromGitHub`/`fetchNpmDeps`/`bun2nix` which are
FODs).

## Full `garnix.yaml` example (all 4 systems, FOD checks on)

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
fodChecks: true
```

## When to add `garnix.yaml` to the PR

- **Add it** when the maintainer has expressed interest in hosted Nix CI, or
  when the project would benefit from cross-platform build coverage that
  exceeds the single-runner `nix.yml` (e.g., the project has darwin-specific
  outputs that `nix.yml` only evaluates via `--no-build`).
- **Skip it** when the project already has a robust GitHub Actions matrix
  (ubuntu + macos-26 + macos-26-intel) and the maintainer hasn't mentioned Garnix.
  Adding an inert config file the maintainer didn't ask for is presumptuous.
- **Never** add it without the `nix.yml` — `nix.yml` is the contributor's
  guarantee; `garnix.yaml` is a bonus that only activates on maintainer opt-in.

## GitHub Actions integration

Garnix is not a GitHub Action (it avoids consuming GitHub Actions minutes).
If the project has existing GitHub Actions workflows that need to gate on
Garnix checks, use the `check_suite` event:

```yaml
on:
  check_suite:
    types: [completed]
```

This fires once per non-GitHub-Actions check-suite completion (i.e., when
Garnix finishes all builds for a commit). See the
[Garnix GitHub Actions Integration docs](https://garnix.io/docs/ci/gh-actions)
for details.

**Skip if:** The maintainer has not expressed interest in hosted Nix CI, or
the project already has a robust cross-platform GitHub Actions matrix.
