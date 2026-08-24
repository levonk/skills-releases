#!/usr/bin/env bash
#
# install-pre-commit-hooks.sh — install the submodule-integrity pre-commit hook
#
# Creates scripts/hooks/pre-commit in the target project and sets
# git config core.hooksPath scripts/hooks. The hook detects the class of bug
# where a git submodule (mode 160000 commit) is accidentally converted to a
# regular directory (mode 040000 tree) in the parent repo's index.
#
# Idempotent: safe to re-run. Overwrites the hook file and re-sets core.hooksPath.
#
# Usage:
#   ./install-pre-commit-hooks.sh [project_path]
#
# If project_path is omitted, defaults to the current directory.
#
# The hook itself skips silently at runtime if .gitmodules doesn't exist or
# is empty — so it is safe to install unconditionally.

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

PROJECT_PATH="${1:-.}"

# Resolve to an absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" 2>/dev/null && pwd)" || {
    log_error "Project path does not exist: ${1:-.}"
    exit 1
}

HOOKS_DIR="$PROJECT_PATH/scripts/hooks"
HOOK_FILE="$HOOKS_DIR/pre-commit"

# ---------------------------------------------------------------------------
# The pre-commit hook content (generalized for ANY .gitmodules submodule).
# Reads ALL submodule paths from .gitmodules — no hardcoded paths.
# ---------------------------------------------------------------------------

read -r -d '' HOOK_CONTENT <<'PRECOMMIT_EOF' || true
#!/usr/bin/env bash
#
# pre-commit hook: prevent submodule paths from being tracked as trees
#
# Detects the class of bug where a git submodule (mode 160000 commit) is
# accidentally converted to a regular directory (mode 040000 tree) in the
# parent repo's index. When this happens, the submodule's files get tracked
# directly in the parent repo instead of the parent pointing to a submodule
# commit hash.
#
# Works for ANY submodule declared in .gitmodules — not hardcoded to any
# specific project.
#
# Approach:
#   Writes the staged index to a tree object (exactly what `git commit`
#   would commit), then checks each .gitmodules submodule path:
#     1. The path must appear as mode 160000 (commit/gitlink), not 040000
#        (tree) or anything else.
#     2. No individual files should exist under the path — the parent repo
#        should only track the gitlink, never the submodule's contents.
#
# Exit 1 on violation, 0 otherwise. Skips silently if no .gitmodules.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# No .gitmodules or empty → no submodules to check.
if [[ ! -s .gitmodules ]]; then
    exit 0
fi

# Extract submodule paths from .gitmodules.
submodule_paths=()
while IFS= read -r path; do
    [[ -n "$path" ]] && submodule_paths+=("$path")
done < <(git config -f .gitmodules --get-regexp 'path$' 2>/dev/null | awk '{print $2}')

if [[ ${#submodule_paths[@]} -eq 0 ]]; then
    exit 0
fi

# Write the staged index to a tree object. This is exactly what `git commit`
# would persist. If write-tree fails (e.g. unresolved merge conflicts), let
# git's own commit logic handle the error — don't block here.
tree_sha="$(git write-tree 2>/dev/null)" || exit 0

violations=0
error_lines=()

for sm_path in "${submodule_paths[@]}"; do
    # Check the top-level entry for the submodule path in the would-be commit.
    #   git ls-tree output format: "<mode> <type> <sha>\t<path>"
    entry="$(git ls-tree "$tree_sha" -- "$sm_path" 2>/dev/null || true)"

    if [[ -z "$entry" ]]; then
        # The submodule path is not in the tree at all. This is fine if the
        # submodule is being removed, but check whether individual files
        # under the path leaked into the parent repo's tree.
        nested="$(git ls-tree -r "$tree_sha" -- "$sm_path/" 2>/dev/null || true)"
        if [[ -n "$nested" ]]; then
            nested_count="$(echo "$nested" | wc -l | tr -d ' ')"
            violations=$((violations + 1))
            error_lines+=(
                "  Submodule '$sm_path' is missing its gitlink but $nested_count file(s) under it are tracked in the parent repo."
                "  The parent repo should track the submodule as a gitlink (160000 commit), not its individual files."
                "  First few files:"
            )
            while IFS=$'\t' read -r _ fpath; do
                [[ -z "$fpath" ]] && continue
                error_lines+=("    $fpath")
            done <<< "$(echo "$nested" | head -5)"
            error_lines+=(
                "  Fix: git rm --cached -r '$sm_path' && git update-index --add --cacheinfo 160000,<submodule-sha>,'$sm_path'"
            )
        fi
        continue
    fi

    # Parse the entry: "<mode> <type> <sha>\t<path>"
    mode="${entry%% *}"
    rest="${entry#* }"        # "<type> <sha>\t<path>"
    obj_type="${rest%% *}"    # "<type>"

    if [[ "$mode" == "160000" && "$obj_type" == "commit" ]]; then
        # Correct: submodule gitlink. Nothing to flag.
        continue
    fi

    if [[ "$mode" == "040000" || "$obj_type" == "tree" ]]; then
        # The submodule path is a tree (directory) instead of a gitlink.
        violations=$((violations + 1))
        # List a few files inside the tree to help the user understand.
        nested="$(git ls-tree -r "$tree_sha" -- "$sm_path/" 2>/dev/null || true)"
        if [[ -n "$nested" ]]; then
            nested_count="$(echo "$nested" | wc -l | tr -d ' ')"
            error_lines+=(
                "  Submodule '$sm_path' is tracked as a TREE (040000) instead of a COMMIT (160000)."
                "  $nested_count file(s) inside the submodule are tracked directly in the parent repo."
                "  First few files:"
            )
            while IFS=$'\t' read -r _ fpath; do
                [[ -z "$fpath" ]] && continue
                error_lines+=("    $fpath")
            done <<< "$(echo "$nested" | head -5)"
        else
            error_lines+=(
                "  Submodule '$sm_path' is tracked as a TREE (040000) instead of a COMMIT (160000)."
            )
        fi
        error_lines+=(
            "  This means the submodule was accidentally converted to a regular directory."
            "  Fix: git rm --cached -r '$sm_path' && git update-index --add --cacheinfo 160000,<submodule-sha>,'$sm_path'"
        )
    else
        # The submodule path is some other mode (blob, symlink, etc.) — also wrong.
        violations=$((violations + 1))
        error_lines+=(
            "  Submodule '$sm_path' is tracked as mode $mode ($obj_type) instead of a COMMIT (160000)."
            "  Fix: git rm --cached '$sm_path' && git update-index --add --cacheinfo 160000,<submodule-sha>,'$sm_path'"
        )
    fi
done

if [[ $violations -gt 0 ]]; then
    echo "ERROR: pre-commit hook detected submodule misrepresentation" >&2
    echo "" >&2
    echo "The following submodule path(s) are tracked incorrectly in the staged index:" >&2
    echo "" >&2
    for line in "${error_lines[@]}"; do
        echo "$line" >&2
    done
    echo "" >&2
    echo "This usually happens when someone runs 'git add' on a submodule directory" >&2
    echo "instead of using 'git submodule add' or letting git track the gitlink." >&2
    echo "" >&2
    echo "Commit aborted. Fix the submodule tracking and try again." >&2
    exit 1
fi

exit 0
PRECOMMIT_EOF

# ---------------------------------------------------------------------------
# Install the hook
# ---------------------------------------------------------------------------

mkdir -p "$HOOKS_DIR"

# Write the hook file (overwrite if it exists — idempotent)
printf '%s\n' "$HOOK_CONTENT" > "$HOOK_FILE"
chmod +x "$HOOK_FILE"

log_info "Installed pre-commit hook at: $HOOK_FILE"

# Set core.hooksPath if inside a git repo. If not a git repo yet, the hook
# file is still in place and will be committed later; re-run this script
# after `git init` to set the config.
if git -C "$PROJECT_PATH" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$PROJECT_PATH" config core.hooksPath scripts/hooks
    log_info "Set core.hooksPath=scripts/hooks in: $PROJECT_PATH"
else
    log_warn "Not a git repo yet — hook file installed but core.hooksPath not set."
    log_warn "Re-run this script after 'git init' to configure core.hooksPath."
fi

log_info "Pre-commit hook installation complete (idempotent — safe to re-run)."
