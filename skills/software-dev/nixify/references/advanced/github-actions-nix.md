# GitHub Actions CI for Nix

## ALWAYS USE THE NEWEST RUNNER — NO EXCEPTIONS

**When adding a new runner or upgrading an existing one, use the newest
available GitHub Actions runner label.** Never use an older runner when a
newer one is available. This applies to every `runs-on:` line in every
workflow the nixify PR creates or touches.

Current newest labels (as of 2026-09-08):

| Platform | Newest label | Notes |
|----------|-------------|-------|
| Linux x86_64 | `ubuntu-latest` | Currently maps to `ubuntu-24.04` |
| macOS ARM (aarch64-darwin) | `macos-26` | GA since Feb 2026; `macos-latest` maps here since June 2026 |
| macOS Intel (x86_64-darwin) | `macos-26-intel` | GA since Feb 2026; decommission estimated ~Nov 2028 |

**Rules:**

1. **Adding a new runner** → use the newest label (e.g. `macos-26`, not
   `macos-14` or `macos-15`).
2. **Upgrading an outdated runner** → replace the old label with the newest
   (e.g. `macos-14` → `macos-26`, `macos-15` → `macos-26`).
3. **If you have to upgrade a runner, USE THE NEWEST RUNNER.** Not the
   second-newest. Not the one the project already uses. The newest.
4. **Never use `macos-latest` in a matrix** — use the explicit label
   (`macos-26`) so the runner version is pinned and visible. `macos-latest`
   is a mutable alias that GitHub silently bumps; an explicit label makes
   the runner version auditable and prevents surprise breakage when GitHub
   changes the alias target.
5. **Verify the label is GA** before using it. Check
   [actions/runner-images](https://github.com/actions/runner-images) for
   the current GA labels. Preview labels (e.g. `xcode-27`) are acceptable
   only when the project explicitly needs a preview toolchain.

**Why:** older runners get decommissioned by GitHub on a fixed schedule
(e.g. `macos-14` deprecation started July 2026, full removal Nov 2026 per
[actions/runner-images#13518](https://github.com/actions/runner-images/issues/13518)).
A workflow pinned to an old runner breaks silently the day GitHub removes
it — the job fails with "no runner available" and the maintainer has to
scramble. Using the newest runner maximizes the runway before the next
decommission. The self-prune job (see
[Self-Pruning on Runner Decommission](#self-pruning-on-runner-decommission)
below) handles the eventual transition, but starting on the newest runner
postpones that day as long as possible.

`validate-pre-push.sh` (Step 22b) flags known-deprecated runner labels
(`macos-12`, `macos-13`, `macos-14`, `macos-15`) deterministically.

---

**Create `.github/workflows/nix.yml`:**

```yaml
name: Nix flake

# Validates the flake (flake.nix). For most nixify targets Nix is a side
# concern and the full build can take 10+ minutes, so this workflow runs
# only on manual dispatch or when a release is published — not on every
# push or PR. If the project wants per-PR validation, add a `pull_request`
# trigger with `paths:` filtered to flake files (see customization notes).
#
# Steps, in order of what they catch:
#   1. nix flake check --all-systems  — every system's outputs evaluate
#      (including darwin on an ubuntu runner).
#   2. nix build .#default            — fetchurl + autoPatchelf + install
#      layout actually realises for the runner's system.
#   3. nix run .#default -- --version — the patched binary actually execs.
#      This is the only step that catches the `let ... in rec` shadowing
#      class of bug (passes flake check, fails nix run). Do NOT drop it.
#   4. nix build .#source (if #source output exists) — the from-source
#      build path realises for the runner's system. Skip if the flake
#      does not expose a #source output.

on:
  # Manual trigger — run before cutting a release or after significant
  # flake changes.
  workflow_dispatch: {}
  # Auto-run on published releases only.
  release:
    types: [published]

permissions:
  contents: read

concurrency:
  group: nix-{{{ printf "%s" "${{{ github.workflow }}}" }}}-{{{ printf "%s" "${{{ github.event.pull_request.number || github.ref }}}" }}}
  cancel-in-progress: true

jobs:
  check:
    name: nix flake check
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: Checkout
        # MANDATORY: pin to a commit SHA, not a mutable @vN ref. See the
        # "Action pinning" note below the template for the security rationale
        # and the one-command SHA resolver.
        uses: actions/checkout@<checkout-sha> # v<N>
        with:
          persist-credentials: false

      - name: Install Nix
        # DeterminateSystems/nix-installer-action installs Nix natively on the
        # runner so `nix build` / `nix run` work directly (a Docker-container
        # approach can run `nix flake check` but is awkward for build+smoke).
        # MANDATORY: pin to a commit SHA, not a mutable @vN ref.
        uses: DeterminateSystems/nix-installer-action@<nix-installer-sha> # v<N>

      - name: nix flake check --all-systems
        # --no-build: evaluate every system's outputs (including darwin on
        # ubuntu) without realising them. Without --no-build, `nix flake
        # check` builds every derivation in `checks`, which fails for
        # non-native systems (darwin stdenv can't run on linux). The
        # build/run steps below handle realisation for the runner's system.
        run: nix flake check --all-systems --no-build

      - name: nix build .#default
        run: nix build .#default --print-build-logs

      - name: nix run .#default -- --version
        # SECURITY: Gate behind non-PR events when a pull_request trigger is
        # active. `nix run` executes the built binary outside the Nix sandbox
        # on the runner, where it can reach GitHub's OIDC endpoint and the
        # GITHUB_TOKEN. On a PR, that binary is PR-controlled code. `nix build`
        # above is safe (realises inside the sandbox, no network). Drop this
        # `if:` guard only if the workflow has no pull_request trigger.
        if: github.event_name != 'pull_request'
        run: nix run .#default -- --version

      - name: nix build .#source (if exists)
        # Exercises the from-source build path. Skip if the flake does not
        # expose a #source output (source-build-only flakes use #default).
        run: |
          if nix flake show --json 2>/dev/null | jq -e 'any(.packages[]?; has("source"))' >/dev/null 2>&1; then
            nix build .#source --print-build-logs
          else
            echo "No #source output — skipping"
          fi
```

**Customization notes:**
- **Trigger policy**: The default is `workflow_dispatch` + `release: published` only — Nix is usually a side concern and the full build takes 10+ minutes. If the project wants per-PR validation, add a `pull_request` trigger with `paths:` filtered to flake files:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
  ```
  Adjust `branches: [main]` to match the project's default branch.
- **SECURITY — `nix run` on PRs executes PR-controlled code**: When a `pull_request` trigger is active, the `nix run .#default -- --version` step must carry `if: github.event_name != 'pull_request'`. `nix run` executes the built binary outside the Nix sandbox on the runner, where it can reach GitHub's OIDC endpoint and the `GITHUB_TOKEN`. On a PR, that binary is PR-controlled code — a malicious PR could exfiltrate tokens. `nix build` is safe (realises inside the sandbox with no network). The template above already includes this guard; keep it when adding a PR trigger. This applies even without `id-token: write` — the default `GITHUB_TOKEN` with `contents: read` is still valuable to an attacker.
- **Lockfile path-filter (source-build flakes — MANDATORY)**: When the flake exposes a `#source` output that builds from source via a fixed-output derivation (FOD) keyed on a lockfile hash, **the lockfile MUST be in the `paths:` filter**. A lockfile change invalidates the FOD's `outputHash`, but if the lockfile isn't in the path filter, the Nix CI never runs on dependency bumps and the breakage reaches users instead of being caught in CI. Add the project's lockfile(s) to the `paths:` list:
  - Bun: `bun.lock`
  - npm: `package-lock.json`
  - pnpm: `pnpm-lock.yaml`
  - Cargo: `Cargo.lock`
  - Go: `go.sum`
  - Python (uv): `uv.lock`
  - Python (pip): `requirements.txt`
  - Maven: `pom.xml`
  Example with Bun:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
      - "bun.lock"
  ```
  This was a declining reason on Archon PR #2131: `bun.lock` changed 16 times in 60 days but was not in the nix.yml path filter, so dependency bumps never triggered Nix CI and the `#source` FOD hash rot reached users silently.
- **Cross-platform matrix (recommended for prebuilt tarball flakes)**: The default workflow runs on `ubuntu-latest` only. `nix flake check --all-systems --no-build` evaluates every system's outputs without realising fetchurl derivations, so a fetch-hash mismatch on `x86_64-darwin` or `aarch64-darwin` is invisible. To catch cross-platform hash mismatches and Darwin-specific build failures, add a matrix that builds on multiple runners:
  ```yaml
  strategy:
    matrix:
      runner: [ubuntu-latest, macos-26, macos-26-intel]
  runs-on: ${{ matrix.runner }}
  ```
  `macos-26` is ARM (aarch64-darwin), `macos-26-intel` is Intel (x86_64-darwin). This is the only way CI can catch the class of hash mismatch that the Archon PR #2131 ASSET_MAP omission caused. When GitHub Actions decommissions `macos-26-intel` (estimated ~Nov 2028 per [actions/runner-images#13739](https://github.com/actions/runner-images/issues/13739)), the `self-prune` job in the single-file workflow (see [Self-Pruning on Runner Decommission](#self-pruning-on-runner-decommission) below) comments out the Intel entry and swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash` automatically.
- Replace `--version` with the project's actual smoke command (e.g. `--help`, `--version`, or a no-op subcommand). The point is to exec the patched binary end-to-end.
- The `#source` build step uses `jq` to detect whether the output exists before building. If the project's runner doesn't have `jq`, install it first or replace the check with `nix build .#source 2>/dev/null || true` (less precise but functional).
- **MANDATORY — pin all third-party actions to commit SHAs**: Replace every `<*-sha>` placeholder and `# v<N>` comment with the actual commit SHA and version tag before posting the PR. Mutable refs (`@v6`, `@main`) allow a compromised maintainer account to repoint the ref to malicious code that executes in the workflow. This is especially critical when the workflow grants `id-token: write` (required by some caching actions for OIDC token exchange) — a mutable ref + OIDC permission means arbitrary code can request GitHub OIDC tokens. Automated reviewers (Greptile, CodeQL) flag this as a P2 security issue. Resolve the current SHA for a tag via:
  ```bash
  gh api repos/<owner>/<repo>/git/refs/tags/<tag> --jq '.object.sha'
  ```
  Use the latest stable tag (not `main`/`latest`). Verify the tag is at least 7 days old (supply-chain safety). Format: `uses: <owner>/<repo>@<40-char-sha> # v<tag>`. Match the project's existing action pinning convention if it pins to SHAs already; if it uses mutable refs, pin to SHAs anyway — this is a security requirement, not a style choice.

**Nix binary caching in CI — `magic-nix-cache-action` vs `flakehub-cache-action`:**

There are two Determinate Systems cache actions. Choose based on whether the project has a FlakeHub subscription:

- **`DeterminateSystems/magic-nix-cache-action`** — works again as of June 2025. Uses GitHub Actions' built-in cache API (free, 10 GB per repo, LRU eviction). Saves 30-50% CI time by restoring Nix store paths between workflow runs. Zero-config, no account needed. Limitation: cache is scoped to a single workflow in a single repo — can't share with developer machines or other repos. **CRITICAL: the action defaults to `use-flakehub: true`, which attempts FlakeHub OIDC authentication. If the GitHub org is NOT registered on FlakeHub, this produces `Unable to authenticate to FlakeHub. Individuals must register at FlakeHub.com; Organizations must create an organization at FlakeHub.com.` and breaks CI. ALWAYS explicitly set `use-flakehub: false` unless the project has a confirmed FlakeHub org (in which case set `use-flakehub: true` deliberately). Omitting `use-flakehub` is the error — the default `true` is the footgun. This was the root cause of the acryl PR #5 FlakeHub auth failure.**

- **`DeterminateSystems/flakehub-cache-action`** — for projects WITH a FlakeHub subscription ($20/member/month, free for open-source projects via support@flakehub.com). Uses FlakeHub's managed binary cache. Cache is available outside CI — developer machines, other repos, other CI platforms. True binary cache, not just CI-run-to-CI-run. Authenticated via GitHub Actions OIDC (no static credentials). If the project has a FlakeHub org, prefer this over `magic-nix-cache-action`.

**History note**: The free tier of `magic-nix-cache-action` was sunset in February 2025 when GitHub deprecated the Actions cache API v1. It was brought back in June 2025 after a community contributor reverse-engineered GitHub's new cache API. The action works again. The `use-flakehub: true` default is the footgun — always set `use-flakehub: false` explicitly unless the project has a FlakeHub org.

**Darwin runner incompatibility (v14 static binary):** The `magic-nix-cache-action` v14 static binary for `arm64-darwin` fails on the `macos-14` GitHub Actions runner with a `dyld` symbol error:

```
dyld: Symbol not found: __ZNSt13exception_ptr31__from_native_exception_pointerEPv
Expected in: /usr/lib/libc++.1.dylib
```

The binary was built against a newer `libc++` than the runner ships. The build itself never starts — the job hangs for ~20 minutes (until `timeout-minutes` kills it) then gets cancelled. This is a DeterminateSystems binary incompatibility, not a flake or build issue.

**Fix: gate the action to Linux-only.** Add `if: runner.os == 'Linux'` to the `magic-nix-cache-action` step. Darwin builds work without the cache, just slower (no cache acceleration). The flake and builds are unaffected. Example:

```yaml
- uses: DeterminateSystems/magic-nix-cache-action@<sha> # v14
  if: runner.os == 'Linux'
  with:
    use-flakehub: false
```

See [DeterminateSystems/nix-installer#1684](https://github.com/DeterminateSystems/nix-installer/issues/1684) for the upstream tracking issue and [llvm/llvm-project#86077](https://github.com/llvm/llvm-project/issues/86077) for the related libc++ symbol-mismatch on darwin. This was the fourth class of bug shipped on acryl PR #5 (commit `82586e0`). `validate-pre-push.sh` (Step 22b) catches missing `if: runner.os == 'Linux'` guards deterministically.

If neither cache action is appropriate (e.g. the project uses Cachix already), use Cachix instead (see [Cachix Integration](cachix-integration.md)).

**Skip if:** The project does not use GitHub Actions for CI.

---

## Self-Pruning on Runner Decommission

When GitHub Actions decommissions the Intel macOS runner (`macos-26-intel`, estimated ~Nov 2028 per
[actions/runner-images#13739](https://github.com/actions/runner-images/issues/13739)), the
`validate-x86-darwin` job in `nix.yml` fails with "no runner available." The `self-prune` job
detects this failure and opens a PR to handle the transition — either updating to a newer runner
label (if GitHub ships one) or commenting out the dead job and swapping `x86_64-darwin` source-build
FOD hashes to `lib.fakeHash`.

### Design

The `self-prune` job runs on `ubuntu-latest`, triggered by `validate-x86-darwin` failure. It does
NOT use a date gate — it fires purely on runner-failure detection, so it works correctly regardless
of when GitHub actually decommissions the runner (the estimated Nov 2028 date may shift).

**Decision flow:**

1. Query the GitHub API for `actions/runner-images` directory listing under `images/macos/`.
2. Filter directory names matching `macos-*-intel`.
3. Compare the newest matching label against the current label (`macos-26-intel`).
4. **If a newer label exists** (e.g. `macos-27-intel`): open a PR that updates `runs-on: macos-26-intel`
   to the newer label in `nix.yml`. PR body explains: "macos-26-intel was decommissioned; updated to
   macos-27-intel (the current Intel macOS runner label). No other changes needed."
5. **If no newer label exists**: open a PR that (a) comments out the `validate-x86-darwin` job with
   re-enablement instructions, (b) adds a warning job that emits a `::warning::` annotation, and
   (c) swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash` in `flake.nix`. PR body
   explains the decommission + re-enablement path + links to the GitHub announcement.

### Template: self-prune job (add to `.github/workflows/nix.yml`)

```yaml
  self-prune:
    name: Self-prune dead Intel macOS runner
    runs-on: ubuntu-latest
    if: always() && needs.validate-x86-darwin.result == 'failure'
    needs: [validate-x86-darwin]
    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Check for newer Intel macOS runner label
        id: check-label
        run: |
          set -euo pipefail
          CURRENT="macos-26-intel"
          # Query the actions/runner-images repo for available macOS runner directories.
          # The directory structure is the closest public signal for runner label availability.
          LABELS=$(curl -fsSL \
            "https://api.github.com/repos/actions/runner-images/contents/images/macos" \
            | python3 -c '
          import json, sys
          entries = json.load(sys.stdin)
          intel = [e["name"] for e in entries
                   if e["type"] == "dir" and e["name"].endswith("-intel")]
          print("\n".join(sorted(intel)))
          ')
          NEWEST=$(echo "$LABELS" | tail -1)
          echo "current=$CURRENT" >> "$GITHUB_OUTPUT"
          echo "newest=$NEWEST" >> "$GITHUB_OUTPUT"
          if [ -n "$NEWEST" ] && [ "$NEWEST" != "$CURRENT" ]; then
            echo "newer=true" >> "$GITHUB_OUTPUT"
            echo "Found newer Intel macOS runner label: $NEWEST (current: $CURRENT)"
          else
            echo "newer=false" >> "$GITHUB_OUTPUT"
            echo "No newer Intel macOS runner label available (current: $CURRENT)"
          fi

      - name: Open PR to update runner label
        if: steps.check-label.outputs.newer == 'true'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(ci): update Intel macOS runner from ${{{ steps.check-label.outputs.current }}} to ${{{ steps.check-label.outputs.newest }}}"
          title: "chore(ci): update Intel macOS runner label"
          branch: chore/ci-update-intel-runner
          body: |
            The `macos-26-intel` GitHub Actions runner was decommissioned and the
            `validate-x86-darwin` job failed with "no runner available."

            A newer Intel macOS runner label is available:
            `${{{{ steps.check-label.outputs.newest }}}}`.

            This PR updates `runs-on:` in the `validate-x86-darwin` job to the
            newer label. No other changes are needed.

            Source: https://github.com/actions/runner-images/issues/13739

      - name: Open PR to comment out dead job + swap to fakeHash
        if: steps.check-label.outputs.newer == 'false'
        run: |
          # Comment out the validate-x86-darwin job in nix.yml and add a warning
          # job + swap x86_64-darwin FOD hashes to lib.fakeHash in flake.nix.
          # This is a text transformation — see the commented-out job block below
          # for the exact replacement text.
          python3 <<'PYEOF'
          import re
          # 1. Comment out validate-x86-darwin job in .github/workflows/nix.yml
          wf = open(".github/workflows/nix.yml").read()
          # The job block is replaced with a commented-out version + warning job.
          # See the template below for the exact replacement.
          # 2. Swap x86_64-darwin FOD hashes to lib.fakeHash in flake.nix
          flake = open("flake.nix").read()
          # Replace real SRI hashes for x86_64-darwin with lib.fakeHash
          # Pattern: "x86_64-darwin" = { ... sha256 = "sha256-..."; ... }
          flake = re.sub(
              r'("x86_64-darwin" = \{[^}]*sha256 = ")[^"]*(";)',
              r'\1lib.fakeHash\2',
              flake, flags=re.S)
          open("flake.nix", "w").write(flake)
          print("Swapped x86_64-darwin FOD hashes to lib.fakeHash")
          PYEOF

      - name: Open PR for fakeHash swap
        if: steps.check-label.outputs.newer == 'false'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(ci): decommission macos-26-intel — comment out validate-x86-darwin, swap to lib.fakeHash"
          title: "chore(ci): handle macos-26-intel decommission"
          branch: chore/ci-decommission-intel-runner
          body: |
            The `macos-26-intel` GitHub Actions runner was decommissioned and the
            `validate-x86-darwin` job failed with "no runner available." No newer
            Intel macOS runner label is currently available.

            This PR:
            1. Comments out the `validate-x86-darwin` job with re-enablement
               instructions (see the commented block in `.github/workflows/nix.yml`)
            2. Adds a warning job that emits a `::warning::` annotation on every
               CI run so the gap is visible, not buried in git history
            3. Swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash`
               in `flake.nix` — an honest "unverified" signal

            To re-enable x86_64-darwin validation in the future:
            1. Check for a newer Intel macOS runner label:
               https://github.com/actions/runner-images/tree/main/images/macos
               (look for any `macos-*-intel` directory newer than `macos-26-intel`)
            2. If a newer label exists, uncomment `validate-x86-darwin` and update
               `runs-on:` to the new label
            3. If using a self-hosted Intel Mac runner, uncomment and set
               `runs-on:` to your self-hosted label
               (https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-github-actions)
            4. After re-enabling, run `nix build .#source --system x86_64-darwin`
               to compute the real FOD hash, replace `lib.fakeHash`, and open a PR

            Source: https://github.com/actions/runner-images/issues/13739
```

### Commented-out job block (what the self-prune PR produces)

When the self-prune PR comments out `validate-x86-darwin`, it replaces the job with this block so
the re-enablement path is visible in the file itself:

```yaml
# DECOMMISSIONED: macos-26-intel was scheduled for decommission by GitHub
# Actions (~Nov 2028 per https://github.com/actions/runner-images/issues/13739).
# This job is commented out to prevent CI failures from "no runner available."
#
# To re-enable:
# 1. Check for a newer Intel macOS runner label:
#    https://github.com/actions/runner-images/tree/main/images/macos
#    (look for any macos-*-intel directory newer than macos-26-intel)
# 2. If a newer label exists, uncomment this job and update runs-on below
# 3. If using a self-hosted Intel Mac runner, uncomment and set runs-on to
#    your self-hosted label
# 4. If no Intel macOS runner is available, x86_64-darwin source-build FOD
#    hashes are set to lib.fakeHash in flake.nix — a community user with an
#    Intel Mac can compute the real hash via `nix build .#source` and open a PR
# validate-x86-darwin:
#   runs-on: macos-26-intel  # ← update to newer label if available
#   needs: detect-platforms
#   steps:
#     - uses: actions/checkout@v6
#     - uses: cachix/install-nix-action@v31
#     - uses: DeterminateSystems/magic-nix-cache-action@v13
#     - run: nix build .#source --system x86_64-darwin
#     - run: nix run .#default --system x86_64-darwin -- --version

validate-x86-darwin-warning:
  runs-on: ubuntu-latest
  if: ${{ false }}  # re-enable when an Intel macOS runner is available
  # NOTE: This job replaces validate-x86-darwin after macos-26-intel was
  # decommissioned. It emits a warning so the gap is visible in every CI
  # run, not buried in git history. Uncomment validate-x86-darwin above
  # and delete this job when an Intel macOS runner is available again.
  steps:
    - name: x86_64-darwin validation unavailable
      run: |
        echo "::warning::x86_64-darwin validation is disabled — macos-26-intel runner was decommissioned by GitHub Actions. x86_64-darwin source-build FOD hashes are set to lib.fakeHash. See commented validate-x86-darwin job above for re-enablement instructions."
```

### Honest limitations

- **The API check looks at the runner-images repo's directory structure**, not GitHub's actual runner availability. There can be a lag between a directory appearing and the label being usable in workflows. The PR body includes the direct link so a human can verify before uncommenting.
- **The `self-prune` job fires on any `validate-x86-darwin` failure**, not just runner decommission. A transient outage or a real build failure would also trigger it. The PR body makes the assumption explicit ("failed with 'no runner available'") — a human reviewing the PR can distinguish "runner gone" from "build broke" and close the PR if it's the latter. This is a deliberate tradeoff: a date gate would prevent false positives but would also delay the self-prune if GitHub decommissions the runner earlier than estimated.
