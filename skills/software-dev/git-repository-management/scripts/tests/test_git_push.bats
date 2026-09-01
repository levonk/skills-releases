#!/usr/bin/env bats
# test_git_push.bats — unit tests for git-push.sh
# Tests the brand-new-branch handling, fetch-rebase-push flow, and backup branch
# creation. Uses file:// remotes so no network access is required.
#
# Run via: bats scripts/tests/test_git_push.bats
#
# Creates temp git repos under /tmp/skill-test/git-push/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
GIT_PUSH="$SCRIPT_DIR/../git-push.sh"
TEST_BASE="/tmp/skill-test/git-push"

# Disable nice-relaunch and worktree isolation guard for tests — test repos
# are not linked worktrees and tests need normal priority for reliable timing.
export NICE_RELAUNCH=0
export SKILL_ALLOW_MAIN_WRITE=1

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

# Create a temp git repo with an initial commit. Echoes the dir path.
# Usage: setup_repo scenario_name
setup_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# Create a bare remote repo and add it as 'origin' to the given repo dir.
# Echoes the remote dir path. Usage: setup_remote <work_dir> <remote_name>
setup_remote() {
    local work_dir="$1"
    local remote_name="${2:-origin}"
    local remote_dir="$TEST_BASE/remote-$(basename "$work_dir")"
    rm -rf "$remote_dir"
    git init -q --bare "$remote_dir"
    git -C "$work_dir" remote add "$remote_name" "$remote_dir"
    echo "$remote_dir"
}

# Run git-push.sh in a repo, capturing output. Usage: run_push <dir> [args...]
run_push() {
    local dir="$1"; shift
    ( cd "$dir" && env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL GIT_CONFIG_GLOBAL=/dev/null bash "$GIT_PUSH" "$@" )
}

# --- Brand-new-branch handling (the bug this test file guards against) ---

@test "new branch: fetch fails, push succeeds with -u and sets upstream" {
    local dir; dir="$(setup_repo new-branch)"
    setup_remote "$dir"

    # Create a feature branch with a new commit — the remote has no ref for it.
    git -C "$dir" checkout -q -b feature/foo
    git -C "$dir" commit -q --allow-empty -m "feature work"

    local out
    out="$(run_push "$dir" origin feature/foo --slug new-branch-test 2>&1)" || true

    # The new-branch path should be detected and reported, not a FETCH_ERROR.
    assert_contains "REMOTE_STATUS:NEW_BRANCH" "$out"
    assert_not_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_contains "PUSH_SUCCESS:origin/feature/foo" "$out"

    # Upstream tracking should be set so future fetches work.
    local upstream
    upstream="$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")"
    [[ "$upstream" == "origin/feature/foo" ]] || {
        echo "expected upstream to be origin/feature/foo, got: $upstream" >&3
        return 1
    }

    # The remote should now have the branch ref.
    git -C "$dir" rev-parse origin/feature/foo >/dev/null 2>&1 || {
        echo "expected origin/feature/foo to exist on remote after push" >&3
        return 1
    }
}

@test "new branch: backup branch is still created before the push" {
    local dir; dir="$(setup_repo new-branch-backup)"
    setup_remote "$dir"

    git -C "$dir" checkout -q -b feature/bar
    git -C "$dir" commit -q --allow-empty -m "feature work"

    local out
    out="$(run_push "$dir" origin feature/bar --slug backup-test 2>&1)" || true

    assert_contains "BACKUP_CREATED" "$out"
    assert_contains "BACKUP_BRANCH:scratch/merge/" "$out"
    assert_contains "PUSH_SUCCESS:origin/feature/bar" "$out"
}

@test "existing branch: fetch succeeds, normal UP_TO_DATE path works" {
    local dir; dir="$(setup_repo existing-branch)"
    local remote; remote="$(setup_remote "$dir")"

    # Push main first so the remote has a ref for it.
    git -C "$dir" push -q origin main 2>/dev/null || git -C "$dir" push -q origin master 2>/dev/null || true

    # Add a new commit on the same branch and push via the script.
    git -C "$dir" commit -q --allow-empty -m "second commit"
    local branch; branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"

    local out
    out="$(run_push "$dir" origin "$branch" --slug existing-test 2>&1)" || true

    assert_contains "REMOTE_STATUS:UP_TO_DATE" "$out"
    assert_contains "PUSH_SUCCESS:origin/$branch" "$out"
    assert_not_contains "REMOTE_STATUS:NEW_BRANCH" "$out"
}

@test "fetch failure on existing remote ref still reports FETCH_ERROR" {
    local dir; dir="$(setup_repo fetch-error)"
    # Point origin at a non-existent path so fetch fails, but the remote ref
    # is configured to exist (we set it up then break the remote).
    setup_remote "$dir"
    git -C "$dir" checkout -q -b feature/baz
    git -C "$dir" commit -q --allow-empty -m "work"
    git -C "$dir" push -q origin feature/baz

    # Now corrupt the remote URL so fetch fails, but origin/feature/baz still
    # resolves locally (the tracking ref is cached). This exercises the
    # "fetch failed but remote ref exists" branch → FETCH_ERROR.
    git -C "$dir" remote set-url origin /nonexistent/path/to/remote

    local out
    out="$(run_push "$dir" origin feature/baz --slug fetch-error-test 2>&1)" || true

    assert_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_not_contains "REMOTE_STATUS:NEW_BRANCH" "$out"
    assert_not_contains "PUSH_SUCCESS" "$out"
}
