#!/usr/bin/env bash
# Prepare a nixpkgs contribution for a project that is not yet packaged in
# nixpkgs. Scaffolds a package.nix file following the pkgs/by-name convention,
# forks NixOS/nixpkgs, creates a branch, and prepares the PR body.
#
# Preflights the upstream repo for the two acceptance requirements that block
# a pkgs/by-name PR before doing any forking:
#   1. An identifiable license — meta.license must map to a real license; an
#      unlicensed upstream is all-rights-reserved and cannot be redistributed.
#   2. A git tag matching the project version — fetchFromGitHub needs a rev.
# When either is missing the script exits 1 with remediation guidance (the
# draft package.nix is still generated for reference). Under --dry-run the
# blockers are reported but do not fail.
#
# This script is called at Step 28b AFTER the in-repo flake has been validated
# and the main PR (Step 27) has been created. The nixpkgs PR references the
# working in-repo flake as evidence the package builds and runs.
#
# Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]
#   project-name: the nixpkgs attribute name (lowercase, hyphenated)
#   project-dir: path to the cloned project directory (with working flake.nix)
#   upstream-owner: the GitHub owner of the upstream project
#   upstream-repo: the GitHub repo name of the upstream project
#
# The nixpkgs working copy is a git worktree off the existing local clone at
# $NIXPKGS_BASE_CLONE (default ~/p/gh/levonk-3rd/nixpkgs), created under
# $NIXPKGS_WORKTREE_ROOT (default ~/orca/workspaces/nixpkgs) — see
# references/nixpkgs-requirements.md — Working Copy. When no base clone
# exists it falls back to a --depth=1 clone in a temp dir.
#
# Output: JSON with:
#   package_nix_path   — path to the generated package.nix
#   nixpkgs_fork       — URL of the forked nixpkgs repo
#   nixpkgs_branch     — branch name in the fork
#   nixpkgs_checkout   — path of the nixpkgs worktree (or temp clone)
#   pr_body_path       — path to the generated PR body file
#   maintainer_entry   — suggested maintainer entry for maintainer-list.nix
#   by_name_path       — the pkgs/by-name/<prefix>/<name>/ path in nixpkgs
#
# Requires: nix (with flakes), gh, git, jq, curl
# See: https://nixos.org/manual/nixpkgs/stable/#chap-quick-start

set -euo pipefail

PROJECT="${1:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
PROJECT_DIR="${2:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
UPSTREAM_OWNER="${3:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
UPSTREAM_REPO="${4:?Usage: prepare-nixpkgs-pr.sh <project-name> <project-dir> <upstream-owner> <upstream-repo> [--dry-run]}"
MODE="${5:-}"

# Validate project name — nixpkgs attribute names are lowercase, hyphenated
if echo "$PROJECT" | grep -qE '[^a-z0-9-]'; then
	echo "ERROR: project name must be lowercase with hyphens only (nixpkgs attribute convention)" >&2
	exit 1
fi

# Compute the pkgs/by-name path — first 2 chars of the package name, lowercased
PREFIX=$(echo "$PROJECT" | cut -c1-2)
BY_NAME_PATH="pkgs/by-name/${PREFIX}/${PROJECT}"

# --- Detect project metadata for package.nix --------------------------------
# Read version and description from the project's flake.nix or manifest files
VERSION=""
DESCRIPTION=""

# Try to get version from the project's Cargo.toml, package.json, etc.
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
	VERSION=$(grep -m1 '^version' "$PROJECT_DIR/Cargo.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
	DESCRIPTION=$(grep -m1 '^description' "$PROJECT_DIR/Cargo.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
elif [ -f "$PROJECT_DIR/package.json" ]; then
	VERSION=$(jq -r '.version // empty' "$PROJECT_DIR/package.json" || echo "")
	DESCRIPTION=$(jq -r '.description // empty' "$PROJECT_DIR/package.json" || echo "")
elif [ -f "$PROJECT_DIR/pyproject.toml" ]; then
	VERSION=$(grep -m1 '^version' "$PROJECT_DIR/pyproject.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
	DESCRIPTION=$(grep -m1 '^description' "$PROJECT_DIR/pyproject.toml" | sed 's/.*= *"\(.*\)".*/\1/' || echo "")
fi

# --- Upstream preflight: nixpkgs acceptance requirements --------------------
# (a) License — prefer GitHub's detected SPDX id; fall back to manifest
# license fields and LICENSE/COPYING files in the checkout.
BLOCKERS=""
LICENSE_ATTR=""
GH_LICENSE=$(gh api "repos/${UPSTREAM_OWNER}/${UPSTREAM_REPO}" --jq '.license.spdx_id // empty' 2>/dev/null || echo "")
case "$(echo "$GH_LICENSE" | tr '[:upper:]' '[:lower:]')" in
mit) LICENSE_ATTR="lib.licenses.mit" ;;
apache-2.0) LICENSE_ATTR="lib.licenses.asl20" ;;
gpl-3.0-only) LICENSE_ATTR="lib.licenses.gpl3Only" ;;
gpl-3.0 | gpl-3.0-or-later) LICENSE_ATTR="lib.licenses.gpl3Plus" ;;
gpl-2.0*) LICENSE_ATTR="lib.licenses.gpl2Only" ;;
lgpl-3.0*) LICENSE_ATTR="lib.licenses.lgpl3Plus" ;;
agpl-3.0*) LICENSE_ATTR="lib.licenses.agpl3Plus" ;;
mpl-2.0) LICENSE_ATTR="lib.licenses.mpl20" ;;
bsd-2-clause) LICENSE_ATTR="lib.licenses.bsd2" ;;
bsd-3-clause) LICENSE_ATTR="lib.licenses.bsd3" ;;
0bsd) LICENSE_ATTR="lib.licenses.bsd0" ;;
isc) LICENSE_ATTR="lib.licenses.isc" ;;
unlicense) LICENSE_ATTR="lib.licenses.unlicense" ;;
cc0-1.0) LICENSE_ATTR="lib.licenses.cc0" ;;
esac

LICENSE_PRESENT=""
if [ -n "$LICENSE_ATTR" ]; then
	LICENSE_PRESENT="1"
elif compgen -G "${PROJECT_DIR}/LICENSE"* >/dev/null 2>&1 ||
	compgen -G "${PROJECT_DIR}/LICENCE"* >/dev/null 2>&1 ||
	compgen -G "${PROJECT_DIR}/COPYING"* >/dev/null 2>&1; then
	LICENSE_PRESENT="1"
elif grep -qsE '^[[:space:]]*license(-file)?[[:space:]]*=' "$PROJECT_DIR/Cargo.toml" 2>/dev/null ||
	grep -qsE '^[[:space:]]*license[[:space:]]*=' "$PROJECT_DIR/pyproject.toml" 2>/dev/null ||
	[ -n "$(jq -r '.license // empty' "$PROJECT_DIR/package.json" 2>/dev/null)" ]; then
	LICENSE_PRESENT="1"
fi

if [ -z "$LICENSE_PRESENT" ]; then
	# Look for an existing upstream issue requesting a license before
	# filing one — a duplicate request is noise, a tracked one is signal.
	LICENSE_ISSUE_URL=""
	EXISTING=$(gh issue list --repo "${UPSTREAM_OWNER}/${UPSTREAM_REPO}" \
		--search "license in:title" --state all --limit 5 \
		--json number,title,state,url 2>/dev/null || echo "[]")
	OPEN_URL=$(echo "$EXISTING" | jq -r '[.[] | select(.state == "OPEN")][0].url // empty' 2>/dev/null || echo "")
	if [ -n "$OPEN_URL" ]; then
		LICENSE_REMEDY="an upstream issue already requests a license: ${OPEN_URL} — track it and re-run once a LICENSE lands."
	else
		CLOSED_URL=$(echo "$EXISTING" | jq -r '.[0].url // empty' 2>/dev/null || echo "")
		if [ -n "$CLOSED_URL" ]; then
			LICENSE_REMEDY="upstream closed a license request without adding one: ${CLOSED_URL} — nixpkgs packaging is likely not possible; check that thread before proceeding."
		elif [ "$MODE" != "--dry-run" ]; then
			# Nothing exists — file the request. This mirrors the manual
			# remediation step: the nixpkgs PR cannot land until upstream
			# adds a LICENSE anyway, so opening it here saves a round-trip.
			LICENSE_ISSUE_BODY=$(
				cat <<ISSUE_EOF
Hi — I'd like to package ${UPSTREAM_REPO} for nixpkgs, but the repo currently has no license. Without an explicit license the code is "all rights reserved," which means downstream redistributors like nixpkgs can't legally carry it.

Could you add a LICENSE? Common choices for projects like this are MIT, Apache-2.0, or dual MIT OR Apache-2.0.

What it unblocks on our side: pkgs/by-name requires an identifiable meta.license, plus a tagged release for fetchFromGitHub. A package.nix is ready to PR once a license is in place.

Happy to open a PR adding the license file(s) if that helps — just let me know which license you'd like.
ISSUE_EOF
			)
			LICENSE_ISSUE_URL=$(gh issue create --repo "${UPSTREAM_OWNER}/${UPSTREAM_REPO}" \
				--title "Please add a license" --body "$LICENSE_ISSUE_BODY" 2>/dev/null || echo "")
			if [ -n "$LICENSE_ISSUE_URL" ]; then
				LICENSE_REMEDY="no upstream license request existed — opened one: ${LICENSE_ISSUE_URL}. Re-run once a LICENSE lands."
			else
				LICENSE_REMEDY="open an upstream issue requesting a LICENSE (or a manifest license field) — issue creation failed, file it manually."
			fi
		else
			LICENSE_REMEDY="open an upstream issue requesting a LICENSE (dry-run: not created)."
		fi
	fi
	BLOCKERS="${BLOCKERS}  - no license detected on ${UPSTREAM_OWNER}/${UPSTREAM_REPO} — ${LICENSE_REMEDY}\n"
elif [ -z "$LICENSE_ATTR" ]; then
	echo "WARNING: a license is present but GitHub could not map it to a SPDX id — set meta.license in package.nix manually." >&2
fi

# (b) fetchFromGitHub rev — needs a git tag on upstream matching the version.
UPSTREAM_TAGS=$(git ls-remote --tags "https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}" 2>/dev/null | awk -F/ '{print $NF}' | sed 's/\^{}//' | sort -u || true)
REV_EXPR='"v${version}"'
TAG_MATCH=""
if [ -n "$VERSION" ]; then
	for cand in "v${VERSION}" "${VERSION}"; do
		if printf '%s\n' "$UPSTREAM_TAGS" | grep -qx "$cand"; then
			TAG_MATCH="$cand"
			break
		fi
	done
fi
if [ -z "$TAG_MATCH" ]; then
	if [ -n "$VERSION" ]; then
		BLOCKERS="${BLOCKERS}  - no git tag matching 'v${VERSION}' or '${VERSION}' on ${UPSTREAM_OWNER}/${UPSTREAM_REPO} — fetchFromGitHub needs a rev. Tag a release upstream first (or pin rev to a commit SHA).\n"
	else
		BLOCKERS="${BLOCKERS}  - could not detect a version from project manifests — fetchFromGitHub needs a tag or rev to fetch.\n"
	fi
elif [ "$TAG_MATCH" != "v${VERSION}" ]; then
	REV_EXPR='"${version}"'
fi

# --- Generate package.nix ---------------------------------------------------
# The package.nix follows the pkgs/by-name convention from the nixpkgs manual.
# It is a function that takes dependencies as arguments and returns a derivation.
# The agent fills in the language-specific build framework (buildRustPackage,
# buildNpmPackage, stdenv.mkDerivation, etc.) based on the project's language.

PACKAGE_NIX_DIR=$(mktemp -d)
PACKAGE_NIX_PATH="${PACKAGE_NIX_DIR}/package.nix"

cat >"$PACKAGE_NIX_PATH" <<'PACKAGE_NIX_EOF'
# TODO: Fill in the language-specific build framework.
# See https://nixos.org/manual/nixpkgs/stable/#chap-language-support
# for the correct builder for this project's language.
#
# Common builders:
#   Rust:    rustPlatform.buildRustPackage
#   Node.js: buildNpmPackage / buildPnpmPackage
#   Python:  python3Packages.buildPythonApplication
#   Go:      buildGoModule
#   Generic: stdenv.mkDerivation
#
# The in-repo flake.nix in the upstream project already has a working build —
# use it as the reference for buildInputs, nativeBuildInputs, and build phases.
{
  lib,
  stdenv,
  # Add build-time and runtime dependencies here as arguments.
  # callPackage auto-fills them from the top-level package set.
  # Example for a Rust project:
  # rustPlatform,
  # pkg-config,
  # openssl,
}:

# TODO: Replace with the correct builder for this project's language.
# Example (Rust):
# rustPlatform.buildRustPackage {
stdenv.mkDerivation {
  pname = "PROJECT_NAME_PLACEHOLDER";
  version = "VERSION_PLACEHOLDER";

  src = fetchFromGitHub {
    owner = "UPSTREAM_OWNER_PLACEHOLDER";
    repo = "UPSTREAM_REPO_PLACEHOLDER";
    rev = REV_PLACEHOLDER;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    # TODO: Set the correct hash — use `nix hash to-sri --type sha256 <hash>`
    # after the first build attempt with a fake hash gives the correct one.
  };

  # TODO: Add buildInputs, nativeBuildInputs, buildPhase, installPhase
  # based on the in-repo flake.nix's #source output.

  meta = {
    description = "DESCRIPTION_PLACEHOLDER";
    homepage = "https://github.com/UPSTREAM_OWNER_PLACEHOLDER/UPSTREAM_REPO_PLACEHOLDER";
    # TODO: Verify this matches the upstream LICENSE — auto-detected from
    # the GitHub SPDX id when possible. See
    # https://nixos.org/manual/nixpkgs/stable/#sec-meta-license
    license = LICENSE_ATTR_PLACEHOLDER;
    # Requires a maintainer-list.nix entry in a separate commit — the script
    # emits a suggested entry.
    maintainers = MAINTAINERS_PLACEHOLDER;
    # TODO: Set platforms — use lib.platforms.unix or a specific subset
    mainProgram = "PROJECT_NAME_PLACEHOLDER";
    platforms = lib.platforms.unix;
  };
}
PACKAGE_NIX_EOF

# Substitute placeholders
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/${PROJECT}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/VERSION_PLACEHOLDER/${VERSION}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/UPSTREAM_OWNER_PLACEHOLDER/${UPSTREAM_OWNER}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/UPSTREAM_REPO_PLACEHOLDER/${UPSTREAM_REPO}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s|DESCRIPTION_PLACEHOLDER|${DESCRIPTION:-A package for ${PROJECT}}|g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/REV_PLACEHOLDER/${REV_EXPR}/g" "$PACKAGE_NIX_PATH"
sed -i.bak "s/LICENSE_ATTR_PLACEHOLDER/${LICENSE_ATTR:-lib.licenses.mit}/g" "$PACKAGE_NIX_PATH"

# --- Generate maintainer entry suggestion -----------------------------------
# The contributor must add themselves to maintainers/maintainer-list.nix
# in a separate commit before this PR. Resolve the githubId now — reviewers
# reject entries with placeholder ids.
CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "YOUR_GITHUB_HANDLE")
CURRENT_USER_ID=""
if [ "$CURRENT_USER" != "YOUR_GITHUB_HANDLE" ]; then
	CURRENT_USER_ID=$(gh api "users/${CURRENT_USER}" --jq '.id' 2>/dev/null || echo "")
fi
MAINTAINER_ENTRY="{ name = \"${CURRENT_USER}\"; email = \"YOUR_EMAIL\"; github = \"${CURRENT_USER}\"; githubId = ${CURRENT_USER_ID:-YOUR_GITHUB_ID}; }"
MAINTAINERS_EXPR="[ ]"
if [ "$CURRENT_USER" != "YOUR_GITHUB_HANDLE" ]; then
	MAINTAINERS_EXPR="[ lib.maintainers.${CURRENT_USER} ]"
fi
sed -i.bak "s/MAINTAINERS_PLACEHOLDER/${MAINTAINERS_EXPR}/g" "$PACKAGE_NIX_PATH"
rm -f "${PACKAGE_NIX_PATH}.bak"

# --- Generate PR body -------------------------------------------------------
PR_BODY_PATH="${PACKAGE_NIX_DIR}/pr-body.md"

cat >"$PR_BODY_PATH" <<PR_BODY_EOF
## Description

Add \`${PROJECT}\` to nixpkgs.

${DESCRIPTION:-}

## What is this?

${PROJECT} is a tool from ${UPSTREAM_OWNER}/${UPSTREAM_REPO}. The upstream
project already has a working in-repo Nix flake
(https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}) which was used as the
reference for this packaging.

## Things done

<!-- Answer every checkbox truthfully — unchecked boxes signal untested work. -->

- Built on platform:
  - [ ] x86_64-linux
  - [ ] aarch64-linux
  - [ ] x86_64-darwin
  - [ ] aarch64-darwin
- [ ] Tested, as applicable:
  - [NixOS test(s)](https://nixos.org/manual/nixos/unstable/index.html#sec-nixos-tests) in [nixos/tests](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests)
  - [Package tests](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#package-tests) at \`passthru.tests\`
- [ ] Ran \`nixpkgs-review\` on this PR
- [ ] Tested basic functionality of all binary files (usually in \`./result/bin/\`)
- [ ] Fits [CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md), [pkgs/README.md](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md), [maintainers/README.md](https://github.com/NixOS/nixpkgs/blob/master/maintainers/README.md) and other READMEs

## Testing

The package was tested by:

1. Building: \`nix-build -A ${PROJECT}\`
2. Running: \`result/bin/${PROJECT} --version\`
3. The in-repo flake at https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}
   also validates the build via CI

## Maintainer

I have added myself to maintainers/maintainer-list.nix in a separate commit
(\`maintainers: add <handle>\`, before the package commit).

## Disclosure

<!-- Required by nixpkgs's Automation/AI policy — do not remove. -->
<!-- Fill in the actual tool and model used; keep it accurate. -->
Parts of this contribution were prepared with assistance from an AI coding
tool (<tool> (<model>)). The changes were reviewed before submission; see the
\`Assisted-by:\` trailers on the commits.
PR_BODY_EOF

# --- Preflight gate ---------------------------------------------------------
# Everything above is draft artifact generation; blockers only stop the
# fork/PR step so the scaffolded package.nix stays available for reference.
if [ -n "$BLOCKERS" ]; then
	echo "" >&2
	echo "UPSTREAM BLOCKERS — resolve before a nixpkgs PR can land:" >&2
	printf '%b' "$BLOCKERS" >&2
	echo "Draft package.nix: ${PACKAGE_NIX_PATH}" >&2
	if [ "$MODE" != "--dry-run" ]; then
		exit 1
	fi
fi

# --- Fork nixpkgs and create branch (unless --dry-run) ---------------------
NIXPKGS_FORK=""
NIXPKGS_BRANCH="add-${PROJECT}"

# Preferred working copy: a git worktree off the existing local clone
# (see references/nixpkgs-requirements.md — Working Copy). The base clone's
# object store is shared with the worktree, so no multi-GB re-clone.
NIXPKGS_BASE_CLONE="${NIXPKGS_BASE_CLONE:-$HOME/p/gh/levonk-3rd/nixpkgs}"
NIXPKGS_WORKTREE_ROOT="${NIXPKGS_WORKTREE_ROOT:-$HOME/orca/workspaces/nixpkgs}"
NIXPKGS_WORKTREE="${NIXPKGS_WORKTREE_ROOT}/${NIXPKGS_BRANCH}"
NIXPKGS_CHECKOUT=""
USE_WORKTREE=""
if git -C "$NIXPKGS_BASE_CLONE" rev-parse --git-dir >/dev/null 2>&1; then
	USE_WORKTREE="1"
fi

if [ "$MODE" = "--dry-run" ]; then
	echo "DRY RUN — would perform:" >&2
	echo "  1. Fork NixOS/nixpkgs to ${CURRENT_USER}/nixpkgs" >&2
	if [ -n "$USE_WORKTREE" ]; then
		NIXPKGS_CHECKOUT="$NIXPKGS_WORKTREE" # planned — not created in dry-run
		echo "  2. Worktree off ${NIXPKGS_BASE_CLONE} at ${NIXPKGS_WORKTREE}, branch '${NIXPKGS_BRANCH}' off upstream/master" >&2
	else
		echo "  2. Clone fork, create branch '${NIXPKGS_BRANCH}' (no base clone at ${NIXPKGS_BASE_CLONE})" >&2
	fi
	echo "  3. Create ${BY_NAME_PATH}/package.nix" >&2
	echo "  4. Open PR to NixOS/nixpkgs with title: '${PROJECT}: init at ${VERSION}'" >&2
	echo "" >&2
	echo "Generated files:" >&2
	echo "  package.nix: ${PACKAGE_NIX_PATH}" >&2
	echo "  PR body:     ${PR_BODY_PATH}" >&2
	echo "  Maintainer entry: ${MAINTAINER_ENTRY}" >&2
else
	# Fork nixpkgs
	gh repo fork NixOS/nixpkgs --clone=false 2>/dev/null || true
	NIXPKGS_FORK="https://github.com/${CURRENT_USER}/nixpkgs"

	if [ -n "$USE_WORKTREE" ]; then
		# Ensure the upstream remote exists and master is fresh
		if ! git -C "$NIXPKGS_BASE_CLONE" remote get-url upstream >/dev/null 2>&1; then
			git -C "$NIXPKGS_BASE_CLONE" remote add upstream https://github.com/NixOS/nixpkgs.git
		fi
		git -C "$NIXPKGS_BASE_CLONE" fetch upstream master

		mkdir -p "$NIXPKGS_WORKTREE_ROOT"
		if git -C "$NIXPKGS_BASE_CLONE" worktree list --porcelain | grep -qx "worktree ${NIXPKGS_WORKTREE}"; then
			# Worktree already exists (re-run) — reuse it
			cd "$NIXPKGS_WORKTREE"
		elif git -C "$NIXPKGS_BASE_CLONE" show-ref --verify --quiet "refs/heads/${NIXPKGS_BRANCH}"; then
			# Branch exists but no worktree — check it out in a new worktree
			git -C "$NIXPKGS_BASE_CLONE" worktree add "$NIXPKGS_WORKTREE" "$NIXPKGS_BRANCH"
			cd "$NIXPKGS_WORKTREE"
		else
			git -C "$NIXPKGS_BASE_CLONE" worktree add -b "$NIXPKGS_BRANCH" "$NIXPKGS_WORKTREE" upstream/master
			cd "$NIXPKGS_WORKTREE"
		fi
	else
		# No local base clone — fall back to a shallow temp clone
		NIXPKGS_CLONE_DIR=$(mktemp -d)
		git clone --depth=1 "$NIXPKGS_FORK" "$NIXPKGS_CLONE_DIR/nixpkgs" 2>/dev/null || {
			# If clone fails (fork may not exist yet), try cloning upstream and adding fork remote
			git clone --depth=1 "https://github.com/NixOS/nixpkgs" "$NIXPKGS_CLONE_DIR/nixpkgs"
		}
		cd "$NIXPKGS_CLONE_DIR/nixpkgs"

		# Create branch
		git checkout -b "$NIXPKGS_BRANCH"
	fi
	NIXPKGS_CHECKOUT="$(pwd)"

	# Create the package directory and copy package.nix
	mkdir -p "$BY_NAME_PATH"
	cp "$PACKAGE_NIX_PATH" "$BY_NAME_PATH/package.nix"
	git add "$BY_NAME_PATH/package.nix"

	echo "nixpkgs checkout at: ${NIXPKGS_CHECKOUT}" >&2
	echo "Branch: ${NIXPKGS_BRANCH}" >&2
	echo "Package path: ${BY_NAME_PATH}/package.nix" >&2
	echo "" >&2
	echo "Next steps:" >&2
	echo "  1. Edit ${BY_NAME_PATH}/package.nix — fill in the correct builder, deps, and hash" >&2
	echo "  2. Add yourself to maintainers/maintainer-list.nix (commit 'maintainers: add <handle>' BEFORE the package commit)" >&2
	echo "  3. Build: nix-build -A ${PROJECT}" >&2
	echo "  4. Test: result/bin/${PROJECT} --version" >&2
	echo "  5. Format: nix fmt (CI enforces nixfmt)" >&2
	echo "  6. Commit '${PROJECT}: init at ${VERSION}' WITH an 'Assisted-by: <tool> (<model>)' trailer — required by nixpkgs's AI policy" >&2
	echo "  7. Push to fork: git push --set-upstream origin ${NIXPKGS_BRANCH}" >&2
	echo "  8. Open PR: gh pr create --repo NixOS/nixpkgs --body-file ${PR_BODY_PATH}" >&2
	echo "  See references/nixpkgs-requirements.md for the full upstream requirements." >&2
fi

# --- Output -----------------------------------------------------------------
jq -n \
	--arg package_nix_path "$PACKAGE_NIX_PATH" \
	--arg nixpkgs_fork "${NIXPKGS_FORK:-https://github.com/${CURRENT_USER}/nixpkgs}" \
	--arg nixpkgs_branch "$NIXPKGS_BRANCH" \
	--arg nixpkgs_checkout "$NIXPKGS_CHECKOUT" \
	--arg pr_body_path "$PR_BODY_PATH" \
	--arg maintainer_entry "$MAINTAINER_ENTRY" \
	--arg by_name_path "$BY_NAME_PATH" \
	--arg version "$VERSION" \
	'{package_nix_path: $package_nix_path,
    nixpkgs_fork: $nixpkgs_fork,
    nixpkgs_branch: $nixpkgs_branch,
    nixpkgs_checkout: $nixpkgs_checkout,
    pr_body_path: $pr_body_path,
    maintainer_entry: $maintainer_entry,
    by_name_path: $by_name_path,
    version: $version}'
