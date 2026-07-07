#!/usr/bin/env bash

# git-push.sh - Push commits to remote (fetch-rebase-push with auto-resolution)
# Purpose: Push commits to remote, creating a backup branch and attempting
#          automatic conflict resolution before falling back to manual.
# Usage: git-push.sh [remote] [branch] [repo_root] [--slug <slug>]

set -euo pipefail

# Tool detection (same pattern as other scripts)
if command -v rtk >/dev/null 2>&1; then RTK_AVAILABLE=1; else RTK_AVAILABLE=0; fi
if command -v devbox >/dev/null 2>&1 && [[ -f "devbox.json" ]]; then DEVBOX_AVAILABLE=1; else DEVBOX_AVAILABLE=0; fi
if command -v jj >/dev/null 2>&1; then JJ_AVAILABLE=1; else JJ_AVAILABLE=0; fi
if command -v difft >/dev/null 2>&1; then DIFFT_AVAILABLE=1; else DIFFT_AVAILABLE=0; fi
if command -v delta >/dev/null 2>&1; then DELTA_AVAILABLE=1; else DELTA_AVAILABLE=0; fi
if command -v hunk >/dev/null 2>&1; then HUNK_AVAILABLE=1; else HUNK_AVAILABLE=0; fi
if command -v git-summary >/dev/null 2>&1; then GIT_EXTRAS_AVAILABLE=1; else GIT_EXTRAS_AVAILABLE=0; fi

# Probe devbox: verify `devbox run` actually responds within a timeout.
# Tests with the real command chain (rtk git / git) to catch wrapper recursion.
# If it hangs (e.g. broken wrapper recursion, nix store issues), disable
# devbox wrapping for the rest of the script and fall back to direct execution.
probe_devbox() {
    if [[ "$DEVBOX_AVAILABLE" -ne 1 ]]; then return 0; fi
    local _test_cmd=(git --version)
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        _test_cmd=(rtk git --version)
    fi
    devbox run -- "${_test_cmd[@]}" >/dev/null 2>&1 &
    local _pid=$!
    local _elapsed=0
    while kill -0 "$_pid" 2>/dev/null; do
        if [[ "$_elapsed" -ge 15 ]]; then
            kill -9 "$_pid" 2>/dev/null
            wait "$_pid" 2>/dev/null || true
            echo "⚠️ devbox run hung after 15s (likely broken wrapper), falling back to direct execution" >&2
            DEVBOX_AVAILABLE=0
            return 1
        fi
        sleep 1
        _elapsed=$((_elapsed + 1))
    done
    local _exit=0
    wait "$_pid" || _exit=$?
    if [[ "$_exit" -ne 0 ]]; then
        echo "⚠️ devbox run failed (exit $_exit), falling back to direct execution" >&2
        DEVBOX_AVAILABLE=0
        return 1
    fi
    return 0
}

devbox_run() {
    if [[ "$DEVBOX_AVAILABLE" -eq 1 ]]; then devbox run -- "$@"; else "$@"; fi
}

git_cmd() {
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then devbox_run rtk git "$@"; else devbox_run git "$@"; fi
}

# Run probe after function definitions so it can test the real command chain
probe_devbox || true

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git_cmd rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "ERROR: $target_path is not inside a git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

main() {
    local remote="" branch="" target_path="." slug="push"
    local remote_set=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --slug) slug="$2"; shift 2 ;;
            --slug=*) slug="${1#--slug=}"; shift ;;
            *)
                if [[ "$remote_set" -eq 0 ]]; then remote="$1"; remote_set=1
                elif [[ -z "$branch" ]]; then branch="$1"
                else target_path="$1"; fi
                shift ;;
        esac
    done
    [[ -z "$remote" ]] && remote="origin"

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    if [[ -z "$branch" ]]; then
        branch=$(git_cmd rev-parse --abbrev-ref HEAD)
    fi

    local original_sha
    original_sha=$(git_cmd rev-parse HEAD)

    echo "=== PUSH_START ==="
    echo "REMOTE:$remote"
    echo "BRANCH:$branch"
    echo "ORIGINAL_SHA:$original_sha"

    # Step 1: Create backup branch at scratch/merge/YYYY/MM/YYYYMMDDHHmm-{slug}-pre
    local timestamp backup_branch
    timestamp=$(date -u +%Y%m%d%H%M)
    backup_branch="scratch/merge/$(date -u +%Y/%m)/${timestamp}-${slug}-pre"
    echo "BACKUP_BRANCH:$backup_branch"
    if ! git_cmd branch "$backup_branch" "$original_sha" 2>/dev/null; then
        echo "PUSH_FAILED:BACKUP_BRANCH_ERROR"
        echo "=== PUSH_END ==="
        exit 1
    fi
    echo "BACKUP_CREATED"

    # Step 2: Fetch remote
    echo "FETCHING:"
    if ! git_cmd fetch "$remote" "$branch" 2>&1; then
        echo "PUSH_FAILED:FETCH_ERROR"
        echo "BACKUP_RESTORE:git checkout $branch && git reset --hard $original_sha"
        echo "=== PUSH_END ==="
        exit 1
    fi

    # Step 3: Check if remote is ahead
    local remote_sha base_sha
    remote_sha=$(git_cmd rev-parse "${remote}/${branch}" 2>/dev/null || echo "")
    base_sha=$(git_cmd merge-base HEAD "${remote}/${branch}" 2>/dev/null || echo "")

    if [[ -z "$remote_sha" || "$remote_sha" == "$base_sha" ]]; then
        echo "REMOTE_STATUS:UP_TO_DATE"
    else
        echo "REMOTE_STATUS:AHEAD"

        # Step 4a: Try rebase with auto-resolution (-X auto)
        echo "REBASING:"
        if git_cmd rebase -X auto "${remote}/${branch}" 2>&1; then
            echo "REBASE_SUCCESS"
        else
            # Rebase had conflicts — abort and try merge fallback
            echo "REBASE_CONFLICTS_DETECTED"
            git_cmd rebase --abort 2>/dev/null || true

            # Step 4b: Try merge with auto-resolution
            echo "MERGE_FALLBACK:"
            if git_cmd merge -X auto "${remote}/${branch}" 2>&1; then
                echo "MERGE_SUCCESS"
            else
                # Merge has conflicts — leave them in place for AI resolution
                echo "MERGE_CONFLICTS:"
                echo "CONFLICTED_FILES:"
                git_cmd diff --name-only --diff-filter=U 2>/dev/null || echo "<none>"
                echo ""
                echo "CONFLICT_MARKERS:"
                # Show conflict regions for each conflicted file (for AI analysis)
                local conflicted_files
                conflicted_files=$(git_cmd diff --name-only --diff-filter=U 2>/dev/null || echo "")
                if [[ -n "$conflicted_files" ]]; then
                    while IFS= read -r cfile; do
                        echo "---FILE:$cfile---"
                        grep -n -A2 -B2 '^<<<<<<<\|^=======\|^>>>>>>>' "$cfile" 2>/dev/null || echo "<no markers found>"
                    done <<< "$conflicted_files"
                fi
                echo ""
                echo "PUSH_FAILED:MERGE_CONFLICTS_NEED_RESOLUTION"
                echo "BACKUP_BRANCH:$backup_branch"
                echo "MERGE_STATE:IN_PROGRESS"
                echo "NEXT_STEPS:"
                echo "1. Review conflicted files listed above"
                echo "2. Edit each file to resolve conflicts (remove conflict markers)"
                echo "3. Stage resolved files: git add <file>"
                echo "4. Complete merge: git commit --no-edit"
                echo "5. Re-run push: ./scripts/git-push.sh $remote $branch $target_path --slug $slug"
                echo "ABORT_CMD:git merge --abort (to discard merge and restore original)"
                echo "=== PUSH_END ==="
                exit 1
            fi
        fi
    fi

    # Step 5: Push
    echo "PUSHING:"
    if git_cmd push "$remote" "$branch" 2>&1; then
        echo "PUSH_SUCCESS:$remote/$branch"
        echo "BACKUP_BRANCH:$backup_branch"
        echo "BACKUP_NOTE:Remove with: git branch -D $backup_branch"
    else
        echo "PUSH_FAILED:GIT_ERROR"
        echo "BACKUP_RESTORE:git checkout $branch && git reset --hard $original_sha"
        echo "=== PUSH_END ==="
        exit 1
    fi

    echo "=== PUSH_END ==="
}

main "$@"
