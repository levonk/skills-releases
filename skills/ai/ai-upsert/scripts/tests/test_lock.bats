#!/usr/bin/env bats
# test_lock.bats — unit tests for Phase 4 concurrency lock scripts
#
# Tests acquire-lock.sh, release-lock.sh, check-lock.sh:
#   - Lock acquisition (no prior lock)
#   - Lock detection (active lock blocks)
#   - Self-validation (PID + start-time)
#   - Self-archiving (stale lock moves to archive/)
#   - Release (move to archive)
#   - Action policies (skip, wait, kill, cancel, force)
#   - PID reuse guard (start-time mismatch)
#
# Run via:
#   bats scripts/tests/test_lock.bats
#
# Uses temp dirs under /tmp/skill-test/lock/{scenario}/

TEST_BASE="/tmp/skill-test/lock"

# --- test helpers ---

assert_equals() {
    local expected="$1" actual="$2"
    [[ "$expected" == "$actual" ]] || {
        echo "expected: '$expected'" >&3
        echo "actual:   '$actual'" >&3
        return 1
    }
}

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in: '$haystack'" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in: '$haystack'" >&3
        return 1
    }
}

assert_file_exists() {
    local path="$1"
    [[ -f "$path" ]] || {
        echo "expected file to exist: $path" >&3
        return 1
    }
}

assert_file_not_exists() {
    local path="$1"
    [[ ! -f "$path" ]] || {
        echo "did not expect file to exist: $path" >&3
        return 1
    }
}

# --- setup/teardown ---

setup() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE/scripts/lock"
    # Copy the lock scripts to the test dir.
    # The source files are .tmpl; the built (rendered) files drop the .tmpl
    # extension. Look for both forms — prefer the built (no .tmpl) form
    # since bats runs against the build output.
    local src_dir="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../lock" && pwd)"
    for script in acquire-lock.sh release-lock.sh check-lock.sh; do
        local src="$src_dir/$script"
        if [ ! -f "$src" ]; then
            src="$src_dir/${script}.tmpl"
        fi
        if [ ! -f "$src" ]; then
            echo "setup: cannot find $script or ${script}.tmpl in $src_dir" >&3
            return 1
        fi
        cp "$src" "$TEST_BASE/scripts/lock/$script"
        chmod +x "$TEST_BASE/scripts/lock/$script"
    done
    # Use a per-test lock dir via env var
    export LOCK_TEST_DIR="$TEST_BASE/locks"
    export AI_UPSERT_LOCK_ACTION=""
}

teardown() {
    cleanup_sleeps
    rm -rf "$TEST_BASE"
}

# Helper: start a long-running background sleep and print its PID.
# Uses a subshell that forks, prints the child PID, then exits. The sleep
# is fully detached (all fds redirected) so bats' `run` and `$(...)` do
# not hang waiting for it.
start_holder_pid() {
    # Fork a subshell that starts sleep and prints the PID
    (
        sleep 300 </dev/null >/dev/null 2>&1 &
        echo $! > "$TEST_BASE/holder.pid"
    ) </dev/null >/dev/null 2>&1
    cat "$TEST_BASE/holder.pid"
}

# Helper: run acquire-lock with a custom lock dir by overriding XDG_CACHE_HOME.
# Starts a detached background sleep as the locking PID so the lock stays
# active across subprocess boundaries.
acquire_lock() {
    local repo="$1" skill="$2" slug="$3"
    shift 3
    local sleep_pid
    sleep_pid="$(start_holder_pid)"
    XDG_CACHE_HOME="$TEST_BASE/cache" \
    AI_UPSERT_LOCK_ACTION="${AI_UPSERT_LOCK_ACTION:-}" \
    bash "$TEST_BASE/scripts/lock/acquire-lock.sh" \
        --repo "$repo" --skill "$skill" --slug "$slug" \
        --pid "$sleep_pid" "$@"
}

# Helper: acquire a lock with an explicit PID (no background sleep).
acquire_lock_pid() {
    local repo="$1" skill="$2" slug="$3" pid="$4" start="$5"
    shift 5
    XDG_CACHE_HOME="$TEST_BASE/cache" \
    AI_UPSERT_LOCK_ACTION="${AI_UPSERT_LOCK_ACTION:-}" \
    bash "$TEST_BASE/scripts/lock/acquire-lock.sh" \
        --repo "$repo" --skill "$skill" --slug "$slug" \
        --pid "$pid" --start "$start" "$@"
}

check_lock() {
    local repo="$1" skill="$2"
    shift 2
    XDG_CACHE_HOME="$TEST_BASE/cache" \
    bash "$TEST_BASE/scripts/lock/check-lock.sh" \
        --repo "$repo" --skill "$skill" "$@"
}

release_lock() {
    local lock_file="$1"
    shift
    bash "$TEST_BASE/scripts/lock/release-lock.sh" --lock-file "$lock_file" "$@"
}

# Kill any background sleep processes left over from tests
cleanup_sleeps() {
    pkill -f "sleep 300" 2>/dev/null || true
    pkill -f "bash -c sleep 300" 2>/dev/null || true
}

# --- tests ---

@test "acquire-lock: no prior lock — acquires and prints lock file path" {
    run acquire_lock "/tmp/my-repo" "my-skill" "test-run"
    [ "$status" -eq 0 ]
    assert_contains "current/" "$output"
    assert_contains "test-run" "$output"
    # Lock file exists in current/
    assert_file_exists "$TEST_BASE/cache/skills/levonk/skills-releases/skills/ai/ai-upsert/locks/current/$(basename "$output")"
}

@test "acquire-lock: active lock blocks — exit 2 with LOCKED: prefix" {
    # First acquire
    local first_lock
    first_lock="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    # Second acquire with skip action (default)
    export AI_UPSERT_LOCK_ACTION="skip"
    run acquire_lock "/tmp/my-repo" "my-skill" "run-2"
    [ "$status" -eq 2 ]
    assert_contains "LOCKED:" "$output"
}

@test "acquire-lock: different skill does not collide" {
    local lock1 lock2
    lock1="$(acquire_lock "/tmp/my-repo" "skill-a" "run-1")"
    lock2="$(acquire_lock "/tmp/my-repo" "skill-b" "run-2")"
    # Both acquired — different keys
    [ "$lock1" != "$lock2" ]
    assert_file_exists "$TEST_BASE/cache/skills/levonk/skills-releases/skills/ai/ai-upsert/locks/current/$(basename "$lock1")"
    assert_file_exists "$TEST_BASE/cache/skills/levonk/skills-releases/skills/ai/ai-upsert/locks/current/$(basename "$lock2")"
}

@test "acquire-lock: different repo does not collide" {
    local lock1 lock2
    lock1="$(acquire_lock "/tmp/repo-a" "my-skill" "run-1")"
    lock2="$(acquire_lock "/tmp/repo-b" "my-skill" "run-2")"
    [ "$lock1" != "$lock2" ]
}

@test "check-lock: no active lock — prints nothing, exit 0" {
    run check_lock "/tmp/my-repo" "my-skill"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "check-lock: active lock — prints lock path, exit 0" {
    local first_lock
    first_lock="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    run check_lock "/tmp/my-repo" "my-skill"
    [ "$status" -eq 0 ]
    assert_contains "$(basename "$first_lock")" "$output"
}

@test "check-lock: stale lock self-archives" {
    # Acquire with a dead PID
    acquire_lock_pid "/tmp/my-repo" "my-skill" "dead-run" 999999 "Mon Aug 17 09:45:00 2026"
    local lock_dir="$TEST_BASE/cache/skills/levonk/skills-releases/skills/ai/ai-upsert/locks"
    local lock_file
    lock_file="$(ls "$lock_dir/current/"*-dead-run-*.sh 2>/dev/null | head -1)"
    [ -n "$lock_file" ]
    # check-lock should trigger self-archive (PID 999999 is dead)
    run check_lock "/tmp/my-repo" "my-skill"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # Lock file moved to archive
    assert_file_not_exists "$lock_file"
    local archive_file
    archive_file="$(find "$lock_dir/archive" -name "$(basename "$lock_file")" 2>/dev/null | head -1)"
    [ -n "$archive_file" ]
}

@test "release-lock: moves lock to archive" {
    local lock_file
    lock_file="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    assert_file_exists "$lock_file"
    run release_lock "$lock_file"
    [ "$status" -eq 0 ]
    assert_contains "archive/" "$output"
    assert_file_not_exists "$lock_file"
    assert_file_exists "$output"
}

@test "acquire-lock: force action ignores active lock" {
    local first_lock
    first_lock="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    export AI_UPSERT_LOCK_ACTION="force"
    run acquire_lock "/tmp/my-repo" "my-skill" "run-2"
    [ "$status" -eq 0 ]
    assert_contains "run-2" "$output"
}

@test "acquire-lock: cancel action exits 2 with CANCELLED: prefix" {
    local first_lock
    first_lock="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    export AI_UPSERT_LOCK_ACTION="cancel"
    run acquire_lock "/tmp/my-repo" "my-skill" "run-2"
    [ "$status" -eq 2 ]
    assert_contains "CANCELLED:" "$output"
}

@test "acquire-lock: JSON output format" {
    run acquire_lock "/tmp/my-repo" "my-skill" "json-run" --json
    [ "$status" -eq 0 ]
    assert_contains '"status":"acquired"' "$output"
    assert_contains '"action":"new"' "$output"
    assert_contains '"pid"' "$output"
}

@test "check-lock: JSON output format" {
    acquire_lock "/tmp/my-repo" "my-skill" "run-1"
    run check_lock "/tmp/my-repo" "my-skill" --json
    [ "$status" -eq 0 ]
    assert_contains '"status":"locked"' "$output"
    assert_contains '"active_locks"' "$output"
}

@test "lock file is executable and self-validating" {
    local lock_file
    lock_file="$(acquire_lock "/tmp/my-repo" "my-skill" "exec-run")"
    [ -x "$lock_file" ]
    # Running the lock file directly should report ACTIVE
    run bash "$lock_file"
    [ "$status" -eq 0 ]
    assert_contains "ACTIVE:" "$output"
}

@test "lock file self-archives when PID is dead" {
    # Acquire with a dead PID
    acquire_lock_pid "/tmp/my-repo" "my-skill" "dead-exec" 999998 "Mon Aug 17 09:45:00 2026"
    local lock_dir="$TEST_BASE/cache/skills/levonk/skills-releases/skills/ai/ai-upsert/locks"
    local lock_file
    lock_file="$(ls "$lock_dir/current/"*-dead-exec-*.sh 2>/dev/null | head -1)"
    [ -n "$lock_file" ]
    # Running the lock file should self-archive and exit 1
    run bash "$lock_file"
    [ "$status" -eq 1 ]
    assert_file_not_exists "$lock_file"
}

@test "lock key is deterministic for same repo+skill" {
    # Two acquisitions with the same repo+skill should produce lock files
    # with the same key suffix
    local lock1 lock2
    lock1="$(acquire_lock "/tmp/my-repo" "my-skill" "run-1")"
    # Release first to allow second
    release_lock "$lock1" >/dev/null
    lock2="$(acquire_lock "/tmp/my-repo" "my-skill" "run-2")"
    # Extract the key (last segment before .sh)
    local key1 key2
    key1="$(basename "$lock1" | sed 's/.*-\([a-f0-9]*\)\.sh/\1/')"
    key2="$(basename "$lock2" | sed 's/.*-\([a-f0-9]*\)\.sh/\1/')"
    assert_equals "$key1" "$key2"
}
