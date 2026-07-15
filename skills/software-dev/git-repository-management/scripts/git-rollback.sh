#!/usr/bin/env bash

# git-rollback.sh - Roll back to a tag or SHA with backup branch
# Purpose: Single handoff to reset HEAD to a prior tag or SHA, creating a
#          backup branch first so the pre-rollback state is always recoverable.
# Usage: git-rollback.sh --to <tag-or-sha> [--slug <slug>] [repo_root]
# Output: ROLLBACK_SUCCESS or ROLLBACK_FAILED with backup branch info.

set -euo pipefail

# RTK (Rust Token Killer) detection
if command -v rtk >/dev/null 2>&1; then RTK_AVAILABLE=1; else RTK_AVAILABLE=0; fi

# Devbox detection
if command -v devbox >/dev/null 2>&1 && [[ -f "devbox.json" ]]; then DEVBOX_AVAILABLE=1; else DEVBOX_AVAILABLE=0; fi

# Probe devbox: verify `devbox run` actually responds within a timeout.
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
            echo "⚠️ devbox run hung after 15s, falling back to direct execution" >&2
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

# Run probe after function definitions
probe_devbox || true

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "ERROR: $target_path is not inside a git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

main() {
    local target="" slug="rollback" target_path="."
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --to) target="$2"; shift 2 ;;
            --to=*) target="${1#--to=}"; shift ;;
            --slug) slug="$2"; shift 2 ;;
            --slug=*) slug="${1#--slug=}"; shift ;;
            -h|--help)
                sed -n '2,8p' "$0"
                exit 0
                ;;
            *) target_path="$1"; shift ;;
        esac
    done

    if [[ -z "$target" ]]; then
        echo "ERROR: --to <tag-or-sha> is required" >&2
        echo "Usage: git-rollback.sh --to <tag-or-sha> [--slug <slug>] [repo_root]" >&2
        exit 1
    fi

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    # Resolve the target to a valid SHA — accept tags, SHAs, and branch names
    local target_sha
    target_sha=$(git_cmd rev-parse --verify "$target^{commit}" 2>/dev/null || echo "")
    if [[ -z "$target_sha" ]]; then
        echo "ROLLBACK_FAILED:INVALID_TARGET"
        echo "ERROR: Could not resolve '$target' to a commit" >&2
        exit 1
    fi

    local original_sha
    original_sha=$(git_cmd rev-parse HEAD)

    # Refuse no-op rollback (target is already HEAD)
    if [[ "$target_sha" == "$original_sha" ]]; then
        echo "ROLLBACK_FAILED:ALREADY_AT_TARGET"
        echo "ERROR: HEAD is already at $target_sha" >&2
        exit 1
    fi

    echo "=== ROLLBACK_START ==="
    echo "TARGET:${target}"
    echo "TARGET_SHA:${target_sha}"
    echo "ORIGINAL_SHA:${original_sha}"

    # Step 1: Create backup branch at scratch/rollback/YYYY/MM/YYYYMMDDHHmm-{slug}-pre
    local timestamp backup_branch
    timestamp=$(date -u +%Y%m%d%H%M)
    backup_branch="scratch/rollback/$(date -u +%Y/%m)/${timestamp}-${slug}-pre"
    echo "BACKUP_BRANCH:$backup_branch"
    if ! git_cmd branch "$backup_branch" "$original_sha" 2>/dev/null; then
        echo "ROLLBACK_FAILED:BACKUP_BRANCH_ERROR"
        echo "=== ROLLBACK_END ==="
        exit 1
    fi
    echo "BACKUP_CREATED"

    # Step 2: Reset HEAD to the target
    echo "RESETTING:"
    if git_cmd reset --hard "$target_sha" 2>&1; then
        echo "ROLLBACK_SUCCESS:${target_sha}"
        echo "BACKUP_BRANCH:$backup_branch"
        echo "BACKUP_NOTE:Recover with: git reset --hard $backup_branch"
        echo "BACKUP_REMOVE:git branch -D $backup_branch (when no longer needed)"
    else
        echo "ROLLBACK_FAILED:GIT_ERROR"
        echo "BACKUP_RESTORE:git reset --hard $original_sha"
        echo "=== ROLLBACK_END ==="
        exit 1
    fi

    echo "=== ROLLBACK_END ==="
}

main "$@"
