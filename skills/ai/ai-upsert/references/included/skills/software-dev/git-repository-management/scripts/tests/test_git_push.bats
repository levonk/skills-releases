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

# Environmental preflight: these tests drive git through local-path remotes.
# git >= 2.38.1 restricts the 'file' transport (protocol.file.allow=user), and
# on newer versions pushes/fetches against a configured local-path remote can
# be denied with "transport 'file' not allowed". setup_repo() pins
# protocol.file.allow=always per fixture repo — this probe verifies that
# pinning actually works here and prints an actionable diagnostic when it
# does not, instead of letting tests fail with misleading "couldn't find
# remote ref" errors.
setup_file() {
    local probe="$TEST_BASE/.preflight"
    rm -rf "$probe"
    mkdir -p "$probe"
    git init -q "$probe/work" 2>/dev/null
    git -C "$probe/work" config user.email "test@test.com"
    git -C "$probe/work" config user.name "Test"
    git -C "$probe/work" config protocol.file.allow always
    git -C "$probe/work" commit -q --allow-empty -m "probe" 2>/dev/null
    git init -q --bare "$probe/remote" 2>/dev/null
    git -C "$probe/work" remote add origin "$probe/remote"
    if ! git -C "$probe/work" push -q origin 'HEAD:refs/heads/probe' 2>"$probe/err"; then
        echo "PREFLIGHT FAIL: git push to a local-path remote was denied even" >&3
        echo "  with repo-local protocol.file.allow=always. Error:" >&3
        sed 's/^/  /' "$probe/err" >&3
        echo "  The fixture repos pin this config, but the failure means this" >&3
        echo "  environment overrides it. Fix: run via 'just bats' (the recipe" >&3
        echo "  injects protocol.file.allow=always via GIT_CONFIG_* env) or set" >&3
        echo "  'git config --global protocol.file.allow always'." >&3
    fi
    rm -rf "$probe"
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
    # Allow the 'file' transport for this fixture repo. git >= 2.38.1 defaults
    # protocol.file.allow to 'user', which blocks pushes/fetches to remotes
    # configured in .git/config on some builds (observed: git 2.55, macOS).
    git -C "$dir" config protocol.file.allow always
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

@test "poisoned upstream: checkout -b from origin/main + push.default=upstream does not push to main" {
    local dir; dir="$(setup_repo poisoned-upstream)"
    setup_remote "$dir"

    # Publish main so the remote has a ref, then branch from it. This records
    # branch.feature/x.merge=refs/heads/main — upstream points at origin/main.
    git -C "$dir" push -q origin 'HEAD:refs/heads/main'
    git -C "$dir" fetch -q origin
    local main_sha; main_sha="$(git -C "$dir" rev-parse origin/main)"
    git -C "$dir" checkout -q -b feature/x origin/main
    git -C "$dir" config push.default upstream
    git -C "$dir" commit -q --allow-empty -m "feature work"

    local out
    out="$(run_push "$dir" origin feature/x --slug poisoned-upstream-test 2>&1)" || true

    # The push must land on feature/x via explicit refspec — never on main.
    assert_contains "REMOTE_STATUS:NEW_BRANCH" "$out"
    assert_contains "UPSTREAM_MISMATCH:configured=origin/main expected=origin/feature/x" "$out"
    assert_contains "PUSH_SUCCESS:origin/feature/x" "$out"

    # Remote-tracking main must be untouched — a bare push would have moved it.
    [[ "$(git -C "$dir" rev-parse origin/main)" == "$main_sha" ]] || {
        echo "origin/main moved — push escaped to the upstream branch" >&3
        return 1
    }

    # Upstream should be repaired to origin/feature/x.
    local upstream
    upstream="$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")"
    [[ "$upstream" == "origin/feature/x" ]] || {
        echo "expected upstream repaired to origin/feature/x, got: $upstream" >&3
        return 1
    }
}

@test "existing branch with poisoned upstream gets upstream repaired on push" {
    local dir; dir="$(setup_repo repair-upstream)"
    setup_remote "$dir"
    git -C "$dir" push -q origin 'HEAD:refs/heads/main'
    git -C "$dir" fetch -q origin
    git -C "$dir" checkout -q -b feature/y origin/main
    git -C "$dir" config push.default upstream
    git -C "$dir" commit -q --allow-empty -m "feature work"

    # First push creates the remote ref (and repairs upstream).
    run_push "$dir" origin feature/y --slug repair-first >/dev/null 2>&1 || true

    # Re-poison the upstream to simulate a stale config on an existing branch.
    git -C "$dir" branch --set-upstream-to origin/main feature/y
    git -C "$dir" commit -q --allow-empty -m "more work"

    local out
    out="$(run_push "$dir" origin feature/y --slug repair-second 2>&1)" || true

    assert_contains "REMOTE_STATUS:UP_TO_DATE" "$out"
    assert_contains "UPSTREAM_MISMATCH:configured=origin/main expected=origin/feature/y" "$out"
    assert_contains "PUSH_SUCCESS:origin/feature/y" "$out"

    local upstream
    upstream="$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")"
    [[ "$upstream" == "origin/feature/y" ]] || {
        echo "expected upstream repaired to origin/feature/y, got: $upstream" >&3
        return 1
    }
}

@test "non-HEAD branch with poisoned upstream is detected and repaired" {
    local dir; dir="$(setup_repo nonhead-upstream)"
    setup_remote "$dir"
    git -C "$dir" push -q origin 'HEAD:refs/heads/main'
    git -C "$dir" fetch -q origin

    # Create feature/z WITHOUT checking it out (HEAD stays on the default
    # branch), poison its upstream, then push it by name.
    git -C "$dir" branch feature/z origin/main
    git -C "$dir" config branch.feature/z.remote origin
    git -C "$dir" config branch.feature/z.merge refs/heads/main
    git -C "$dir" config push.default upstream

    local out
    out="$(run_push "$dir" origin feature/z --slug nonhead-test 2>&1)" || true

    assert_contains "UPSTREAM_MISMATCH:configured=origin/main expected=origin/feature/z" "$out"
    assert_contains "PUSH_SUCCESS:origin/feature/z" "$out"

    local upstream
    upstream="$(git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name 'feature/z@{u}' 2>/dev/null || echo "")"
    [[ "$upstream" == "origin/feature/z" ]] || {
        echo "expected feature/z upstream repaired to origin/feature/z, got: $upstream" >&3
        return 1
    }
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
