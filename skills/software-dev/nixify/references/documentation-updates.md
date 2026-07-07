# Documentation Updates

## Table of Contents

- [Finding Install Documentation](#finding-install-documentation)
- [README Insertion Examples](#readme-insertion-examples)
- [Docs-Site Installation Pages](#docs-site-installation-pages)
- [Releasing Documentation](#releasing-documentation)
- [Translated READMEs](#translated-readmes)

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

**CRITICAL — branch on `flake_type` (from Step 11):** The README and docs content differs between Source Build and Prebuilt Tarball flakes. Source Build flakes exist at every git tag, so tag-pinning (`github:.../vX.Y.Z`) works. Prebuilt Tarball flakes are bumped *after* the release tag is cut (by the scheduled lag-check workflow), so tag-pinning does NOT work — a tag ref either lacks the flake or contains the previous version's hashes. Use the correct template below.

---

## README Insertion Examples

### Source Build Flake (`flake_type = source_build`)

```markdown
## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake builds from source.

```bash
# Latest source from default branch
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Specific release (uses the flake at that git tag)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Named outputs (if the flake exposes them): #latest, #source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source

# Build / develop
nix build github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix develop github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake exposes `packages.<system>.default`, `apps.<system>.default`, `devShells.<system>.default`, and `overlays.default`.

Update through the same Nix workflow you used to install. For profile installs, run `nix profile list` and then `nix profile upgrade <index-or-name>`. For flake inputs, run `nix flake update <repo>` in your own flake and rebuild.
```

### Prebuilt Tarball Flake (`flake_type = prebuilt_tarball`)

```markdown
## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake wraps the prebuilt release binary.

```bash
# Run without installing
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake tracks the default branch and is auto-bumped to the latest release by a
daily [workflow](.github/workflows/nix-release.yml), so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO`
always serves the current release. (Release tags are cut before the bump lands,
so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` is not a valid pin — use the
nixpkgs package or a specific commit SHA if you need reproducibility.)
```

**Do NOT add** any of the following to a Prebuilt Tarball README:
- `nix run github:.../vX.Y.Z` (tag-pinning — the tag predates the flake bump)
- `nix run github:...#source` (no source build output exists in a prebuilt-only flake)
- `nix develop github:...` (no devShell unless explicitly added)

### With Devbox subsection (both flake types)

Add after the Nix subsection:

```markdown
## Devbox

For reproducible development environments, use Devbox:

```bash
# Install Devbox first (if not already installed)
curl -fsSL https://get.jetify.dev/devbox | bash

# Initialize the environment
devbox shell

# Build the project
devbox run build
```

Or install Devbox via Homebrew:

```bash
brew install jetify-com/devbox/devbox
```
```

---

## Docs-Site Installation Pages

### If `docs/getting-started/installation.md` exists

Add a `### Nix (Flakes)` subsection under the "Quick Install" or equivalent section.

#### Source Build Flake

```markdown
### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

**Choose a specific version:**

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Or use named flake outputs if the flake exposes them
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#latest
```

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
nix flake update <repo>
```
```

#### Prebuilt Tarball Flake

```markdown
### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake tracks the default branch and is auto-bumped to the latest release
daily, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` always serves the current
release. For reproducibility, pin to a specific commit SHA or use the nixpkgs
package.

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
nix flake update <repo>
```
```

### If `docs/index.mdx` (or similar landing page) exists

Add a Nix code block variant inside the `:::code-group` block under "## Install in seconds" (or equivalent):

#### Source Build Flake

```markdown
:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest (default branch or latest release)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Specific version
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3

# Or choose an output: #latest, #source
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#latest
```

:::
```

#### Prebuilt Tarball Flake

```markdown
:::code-group

```bash [npm]
npm install -g <package-name>
```

```bash [Homebrew]
brew install <formula>
```

```bash [Nix]
# Latest release (auto-bumped daily)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

:::
```

---

## Releasing Documentation

If `docs/contributing/releasing.md` (or similar) exists, add a note about the Nix flake update step.

### Source Build Flake

No per-release action needed — the flake builds from source at any tag.

```markdown
### Nix flake

No action required — the flake builds from source and works at any release tag.
```

### Prebuilt Tarball Flake

The scheduled lag-check workflow (`.github/workflows/nix-release.yml`) handles this automatically — do NOT document manual hash updates.

```markdown
### Nix flake

The `.github/workflows/nix-release.yml` workflow runs daily and automatically
bumps `version` and per-platform `sha256` hashes in `flake.nix` when a new
release is detected, then opens a PR. No manual action required — just merge
the auto-generated bump PR after each release.
```

---

## Translated READMEs

Repeat documentation updates for every translated README that contains install instructions (e.g., `README.ko.md`). Use the same `flake_type`-appropriate template as the main README.
