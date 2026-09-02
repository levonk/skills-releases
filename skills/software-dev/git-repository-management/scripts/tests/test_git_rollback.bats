#!/usr/bin/env bats
# test_git_rollback.bats - unit tests for git-rollback.sh
# Tests rollback to tag/SHA, backup branch creation, invalid target handling,
# already-at-target detection, and cache warming regression.
#
# Run via: bats scripts/tests/test_git_rollback.bats
#
# Creates temp git repos under /tmp/skill-test/git-rollback/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
ROLLBACK="$SCRIPT_DIR/../git-rollback.sh"
TEST_BASE="/tmp/skill-test/git-rollback"

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

# Create a temp git repo with a main branch and initial commit. Echoes the dir.
# Usage: setup_repo scenario_name
setup_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q -b main "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# Run git-rollback.sh on a repo. Echoes the full output.
# Usage: run_rollback <dir> --to <target> [--slug <slug>]
run_rollback() {
    local dir="$1"; shift
    ( cd "$dir" && env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL GIT_CONFIG_GLOBAL=/dev/null WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$ROLLBACK" "$@" "$dir" 2>&1 ) || true
}

# --- Basic rollback ---

@test "rollback to prior commit succeeds" {
    local dir; dir="$(setup_repo rollback-basic)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local out; out="$(run_rollback "$dir" --to "$target_sha" --slug basic)"
    assert_contains "=== ROLLBACK_START ===" "$out"
    assert_contains "TARGET_SHA:$target_sha" "$out"
    assert_contains "BACKUP_CREATED" "$out"
    assert_contains "ROLLBACK_SUCCESS:$target_sha" "$out"
    assert_contains "=== ROLLBACK_END ===" "$out"
    local current_sha
    current_sha=$(git -C "$dir" rev-parse HEAD)
    [[ "$current_sha" == "$target_sha" ]] || { echo "HEAD $current_sha != target $target_sha" >&3; return 1; }
}

@test "rollback to tag succeeds" {
    local dir; dir="$(setup_repo rollback-tag)"
    git -C "$dir" tag v1.0
    git -C "$dir" commit -q --allow-empty -m "after tag"
    local out; out="$(run_rollback "$dir" --to v1.0 --slug tag-test)"
    assert_contains "ROLLBACK_SUCCESS" "$out"
    assert_contains "TARGET:v1.0" "$out"
    local tag_sha current_sha
    tag_sha=$(git -C "$dir" rev-parse v1.0)
    current_sha=$(git -C "$dir" rev-parse HEAD)
    [[ "$current_sha" == "$tag_sha" ]] || { echo "HEAD $current_sha != tag $tag_sha" >&3; return 1; }
}

@test "rollback creates backup branch" {
    local dir; dir="$(setup_repo rollback-backup)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local original_sha
    original_sha=$(git -C "$dir" rev-parse HEAD)
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local out; out="$(run_rollback "$dir" --to "$target_sha" --slug backup-test)"
    assert_contains "BACKUP_BRANCH:scratch/rollback/" "$out"
    assert_contains "BACKUP_CREATED" "$out"
    local backup_branch
    backup_branch=$(echo "$out" | grep '^BACKUP_BRANCH:' | head -1 | cut -d: -f2-)
    [[ -n "$backup_branch" ]] || { echo "no backup branch found in output" >&3; return 1; }
    git -C "$dir" show-ref --verify --quiet "refs/heads/$backup_branch" || { echo "backup branch $backup_branch does not exist" >&3; return 1; }
    local backup_sha
    backup_sha=$(git -C "$dir" rev-parse "$backup_branch")
    [[ "$backup_sha" == "$original_sha" ]] || { echo "backup branch SHA $backup_sha != original $original_sha" >&3; return 1; }
}

@test "rollback outputs recovery instructions" {
    local dir; dir="$(setup_repo rollback-recovery)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local out; out="$(run_rollback "$dir" --to "$target_sha" --slug recovery)"
    assert_contains "BACKUP_NOTE:Recover with:" "$out"
    assert_contains "BACKUP_REMOVE:git branch -D" "$out"
}

@test "rollback --slug sets backup branch slug" {
    local dir; dir="$(setup_repo rollback-slugarg)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local out; out="$(run_rollback "$dir" --to "$target_sha" --slug custom-rollback-slug)"
    assert_contains "custom-rollback-slug-pre" "$out"
}

# --- Error cases ---

@test "rollback fails on invalid target" {
    local dir; dir="$(setup_repo rollback-invalid)"
    local out; out="$(run_rollback "$dir" --to nonexistent-sha --slug invalid)"
    assert_contains "ROLLBACK_FAILED:INVALID_TARGET" "$out"
}

@test "rollback fails when already at target" {
    local dir; dir="$(setup_repo rollback-already)"
    local current_sha
    current_sha=$(git -C "$dir" rev-parse HEAD)
    local out; out="$(run_rollback "$dir" --to "$current_sha" --slug already)"
    assert_contains "ROLLBACK_FAILED:ALREADY_AT_TARGET" "$out"
}

@test "rollback fails without --to argument" {
    local dir; dir="$(setup_repo rollback-noarg)"
    local out; out="$(run_rollback "$dir" --slug noarg)"
    assert_contains "ERROR: --to <tag-or-sha> is required" "$out"
}

# --- Cache warming regression test ---
# git-rollback.sh warms wrapper_prefix() and rtk_prefix() caches after
# probe_devbox so $(git_cmd ...) subshells inherit them. Without warming,
# each $(git_cmd ...) call re-probes wrapper_prefix() (~1s each).

@test "cache warming prevents repeated wrapper probes" {
    local dir; dir="$(setup_repo rollback-cache)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local start_time end_time elapsed
    start_time=$(date +%s)
    run_rollback "$dir" --to "$target_sha" --slug cache >/dev/null 2>&1
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    [[ "$elapsed" -lt 10 ]] || { echo "git-rollback took ${elapsed}s - cache warming may not be working" >&3; echo "expected <10s, got ${elapsed}s" >&3; return 1; }
}

@test "subshell git_cmd inherits parent cache" {
    local dir; dir="$(setup_repo rollback-subshell-cache)"
    git -C "$dir" commit -q --allow-empty -m "second"
    local target_sha
    target_sha=$(git -C "$dir" rev-parse HEAD~1)
    local fake_bin="$TEST_BASE/fake-cli-bin-rollback"
    local log="$TEST_BASE/cli-discovery-log-rollback.txt"
    rm -f "$log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/cli-tool-discovery.sh" <<EOF
#!/usr/bin/env bash
echo "called" >> "$log"
EOF
    chmod +x "$fake_bin/cli-tool-discovery.sh"
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 \
      CLI_TOOL_DISCOVERY="$fake_bin/cli-tool-discovery.sh" \
      bash "$ROLLBACK" --to "$target_sha" --slug subshell "$dir" >/dev/null 2>&1 ) || true
    local call_count
    call_count=$(wc -l < "$log" 2>/dev/null || echo 0)
    rm -f "$log"
    [[ "$call_count" -le 1 ]] || { echo "cli-tool-discovery.sh was called ${call_count} times - cache not inherited by subshells" >&3; echo "expected at most 1 call, got ${call_count}" >&3; return 1; }
}
