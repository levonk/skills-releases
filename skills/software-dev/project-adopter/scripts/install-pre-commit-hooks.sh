#!/usr/bin/env bash
#
# install-pre-commit-hooks.sh — install pre-commit hooks for adopted projects
#
# Creates scripts/hooks/ in the target project with:
#   - pre-commit (composite entry point that calls all checks)
#   - pre-commit-submodule-integrity.sh (submodule-as-tree protection)
#   - pre-commit-worktree-isolation.sh (block commits to main outside worktree)
#
# Sets git config core.hooksPath scripts/hooks.
#
# Also scans .gitmodules for file:// submodule URLs and prints an advisory
# warning if found (CVE-2022-39253 awareness — per-repo opt-in may be needed
# if the environment denies file:// transport globally). Detect-and-inform
# only; never auto-applies the override.
#
# Idempotent: safe to re-run. Overwrites hook files and re-sets core.hooksPath.
#
# Usage:
#   ./install-pre-commit-hooks.sh [project_path]
#
# If project_path is omitted, defaults to the current directory.
#
# The submodule hook skips silently at runtime if .gitmodules doesn't exist
# or is empty — so it is safe to install unconditionally.
#
# The worktree isolation hook blocks commits to main/master outside a linked
# worktree. Bypass: SKILL_ALLOW_MAIN_WRITE=1 env var, or
# .agents/config/script-guards.toml [worktree-isolation] allow_main_write=true.

set -euo pipefail

[[ -z "${RED:-}" ]] && readonly RED='\033[0;31m' || true
[[ -z "${GREEN:-}" ]] && readonly GREEN='\033[0;32m' || true
[[ -z "${YELLOW:-}" ]] && readonly YELLOW='\033[1;33m' || true
[[ -z "${NC:-}" ]] && readonly NC='\033[0m' || true

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
# Install the hooks
# ---------------------------------------------------------------------------

mkdir -p "$HOOKS_DIR"

# Write the submodule-integrity hook as a separate file
SUBMODULE_HOOK="$HOOKS_DIR/pre-commit-submodule-integrity.sh"
printf '%s\n' "$HOOK_CONTENT" > "$SUBMODULE_HOOK"
chmod +x "$SUBMODULE_HOOK"
log_info "Installed submodule-integrity hook at: $SUBMODULE_HOOK"

# Write the worktree-isolation hook as a separate file
WORKTREE_HOOK="$HOOKS_DIR/pre-commit-worktree-isolation.sh"
cat > "$WORKTREE_HOOK" <<'WORKTREE_EOF'
#!/usr/bin/env bash
# pre-commit-worktree-isolation.sh — block commits to protected branches outside a worktree
#
# Bypass layers (in order):
#   1. SKILL_ALLOW_MAIN_WRITE=1 environment variable (user sets in shell)
#   2. .agents/config/script-guards.toml [worktree-isolation] allow_main_write=true
#   3. git commit --no-verify (emergency bypass, skips all hooks)
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$repo_root" ]]; then
  exit 0
fi

if [[ "${SKILL_ALLOW_MAIN_WRITE:-0}" == "1" ]]; then
  exit 0
fi

cfg="$repo_root/.agents/config/script-guards.toml"
cfg_bypass=0
if [[ -f "$cfg" ]]; then
  section="$(awk '/^\[worktree-isolation\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
  if printf '%s' "$section" | grep -Eq 'allow_main_write[[:space:]]*=[[:space:]]*true'; then
    cfg_bypass=1
  fi
fi

if [[ "$cfg_bypass" -eq 1 ]]; then
  exit 0
fi

current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

protected_branches=("main" "master")
if [[ -f "$cfg" ]]; then
  section="$(awk '/^\[worktree-isolation\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
  pb_line="$(printf '%s' "$section" | grep -E 'protected_branches[[:space:]]*=' || true)"
  if [[ -n "$pb_line" ]]; then
    pb_values="$(printf '%s' "$pb_line" | sed 's/.*=\s*//; s/^\[//; s/\]$//; s/"//g; s/,/\n/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' || true)"
    if [[ -n "$pb_values" ]]; then
      # shellcheck disable=SC2206
      protected_branches=($pb_values)
    fi
  fi
fi

on_protected=0
for pb in "${protected_branches[@]}"; do
  if [[ "$current_branch" == "$pb" ]]; then
    on_protected=1
    break
  fi
done

if [[ "$on_protected" -eq 0 ]]; then
  exit 0
fi

abs_git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null || echo "")"
if [[ "$abs_git_dir" == *"/.git/worktrees/"* ]]; then
  exit 0
fi

echo "" >&2
echo "PRE-COMMIT REJECTED: committing to '$current_branch' outside a worktree." >&2
echo "  Feature work must happen in a worktree on a feature branch." >&2
echo "  Use treehouse: devbox run -- treehouse get --lease" >&2
echo "  Or manual: git worktree add ../<name> -b feature/<scope>/<slug>" >&2
echo "  Bypass: SKILL_ALLOW_MAIN_WRITE=1 git commit ..." >&2
echo "  Bypass (emergency): git commit --no-verify" >&2
echo "" >&2
exit 1
WORKTREE_EOF
chmod +x "$WORKTREE_HOOK"
log_info "Installed worktree-isolation hook at: $WORKTREE_HOOK"

# Write the composite pre-commit entry point that calls all hooks in order
cat > "$HOOK_FILE" <<'COMPOSITE_EOF'
#!/usr/bin/env bash
# pre-commit (composite) — calls all pre-commit checks in order
#
# This file is generated by install-pre-commit-hooks.sh. To add a new
# check, create a pre-commit-<name>.sh script in this directory and
# add a call to it below.
set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Worktree isolation — block commits to main/master outside a worktree
bash "$HOOKS_DIR/pre-commit-worktree-isolation.sh" || exit 1

# 2. Submodule integrity — prevent submodules from being tracked as trees
bash "$HOOKS_DIR/pre-commit-submodule-integrity.sh" || exit 1
COMPOSITE_EOF
chmod +x "$HOOK_FILE"
log_info "Installed composite pre-commit at: $HOOK_FILE"

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

# ---------------------------------------------------------------------------
# file:// submodule URL advisory (CVE-2022-39253 awareness)
# ---------------------------------------------------------------------------
# Git 2.38.1 changed protocol.file.allow default from 'always' to 'user' to
# close CVE-2022-39253 (submodule-initiated file:// exfiltration). Many
# environments set protocol.file.allow=never globally for defense-in-depth.
# Repos with file:// submodule URLs will hit:
#   fatal: transport 'file' not allowed
# until a per-repo override is applied. This is a deliberate opt-in — we
# detect and inform, never auto-apply, because auto-applying would defeat
# the deny-by-default stance.
if [[ -s "$PROJECT_PATH/.gitmodules" ]]; then
    file_urls=""
    while IFS= read -r url; do
        [[ -n "$url" ]] && file_urls+="  $url"$'\n'
    done < <(git config -f "$PROJECT_PATH/.gitmodules" --get-regexp '\.url$' 2>/dev/null | awk '{print $2}' | grep -E '^file://' || true)
    if [[ -n "$file_urls" ]]; then
        log_warn "This repo has file:// submodule URLs in .gitmodules:"
        printf '%s' "$file_urls" >&2
        log_warn "Git operations (clone --recurse-submodules, submodule update) may fail with:"
        log_warn "  fatal: transport 'file' not allowed"
        log_warn "This is a security default (CVE-2022-39253). If you trust this repo, apply a per-repo override:"
        log_warn "  git -C \"$PROJECT_PATH\" config protocol.file.allow always"
        log_warn "Do NOT set this in ~/.gitconfig or /etc/gitconfig — per-repo only."
    fi
fi

log_info "Pre-commit hook installation complete (idempotent — safe to re-run)."
