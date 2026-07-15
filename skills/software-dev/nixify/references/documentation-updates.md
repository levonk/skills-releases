# Documentation Updates

## Table of Contents

- [Finding Install Documentation](#finding-install-documentation)
- [README Insertion Examples](#readme-insertion-examples)
- [Docs-Site Installation Pages](#docs-site-installation-pages)
- [Releasing Documentation](#releasing-documentation)
- [Translated READMEs](#translated-readme)

---

## Finding Install Documentation

Check in this order:
1. `README.md`
2. `README.<lang>.md` (e.g., `README.ko.md`)
3. `docs/install.md`
4. `docs/getting-started/installation.md`
5. `docs/index.mdx` (landing page with install splash)
6. `CONTRIBUTING.md` or `.github/CONTRIBUTING.md`
7. `.github/ISSUE_TEMPLATE/*.md` and `.github/PULL_REQUEST_TEMPLATE.md`

If the README only has a brief mention and links to another file, update **that referenced file** instead.

Only add Nix instructions if the doc already has a comparable quick install or "From source" section. Do not create a new install section from scratch.

**CRITICAL — branch on `flake_type` (from Step 11):** The README and docs content differs between Source Build and Prebuilt Tarball flakes. Source Build flakes exist at every git tag, so tag-pinning (`github:.../vX.Y.Z`) works. Prebuilt Tarball flakes are bumped *after* the release tag is cut (by the scheduled lag-check workflow), so tag-pinning does NOT work — a tag ref either lacks the flake or contains the previous version's hashes. Use the correct snippet file below.

---

## README Insertion Examples

Each snippet file below is the complete template content — copy the file contents directly into the README at the appropriate location, after substituting `$UPSTREAM_OWNER`/`$UPSTREAM_REPO`.

### Source Build Flake (`flake_type = source_build`)

Use `references/snippets/readme-nix-source-build.md`.

### Prebuilt Tarball Flake (`flake_type = prebuilt_tarball`)

Use `references/snippets/readme-nix-prebuilt-tarball.md`.

**Do NOT add** any of the following to a Prebuilt Tarball README:
- `nix run github:.../vX.Y.Z` (tag-pinning — the tag predates the flake bump)
- `nix develop github:...` (no devShell unless explicitly added)

**Note on `#source`:** The Prebuilt Tarball template now includes a `#source` output by default. If the project cannot be built from source in Nix and the `source` outputs were removed from the flake, also remove `#source` from the README/docs snippets above.

### With Devbox subsection (only when devbox is included in this PR)

Add after the Nix subsection — **only when `include_devbox=true`** (Step 13). For prebuilt tarball flakes without devbox (the default), skip this subsection entirely.

Use `references/snippets/readme-devbox.md`.

---

## Docs-Site Installation Pages

### If `docs/getting-started/installation.md` exists

Add a `### Nix (Flakes)` subsection under the "Quick Install" or equivalent section.

#### Source Build Flake

Use `references/snippets/docs-install-source-build.md`.

#### Prebuilt Tarball Flake

Use `references/snippets/docs-install-prebuilt-tarball.md`.

### If `docs/index.mdx` (or similar landing page) exists

Add a Nix code block variant inside the `:::code-group` block under "## Install in seconds" (or equivalent):

#### Source Build Flake

Use `references/snippets/docs-index-source-build.md`.

#### Prebuilt Tarball Flake

Use `references/snippets/docs-index-prebuilt-tarball.md`.

---

## Releasing Documentation

If `docs/contributing/releasing.md` (or similar) exists, add a note about the Nix flake update step.

### Source Build Flake

No per-release action needed — the flake builds from source at any tag.

### Nix flake

No action required — the flake builds from source and works at any release tag.

### Prebuilt Tarball Flake

The scheduled lag-check workflow (`.github/workflows/nix-release.yml`) handles this automatically — do NOT document manual hash updates.

### Nix flake

The `.github/workflows/nix-release.yml` workflow runs daily and automatically
bumps `version` and per-platform `sha256` hashes in `flake.nix` when a new
release is detected, then opens a PR. No manual action required — just merge
the auto-generated bump PR after each release.

---

## Translated READMEs

Repeat documentation updates for every translated README that contains install instructions (e.g., `README.ko.md`). Use the same `flake_type`-appropriate snippet as the main README.
