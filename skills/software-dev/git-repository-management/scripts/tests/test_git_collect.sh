#!/usr/bin/env bash
# test_git_collect.sh — unit tests for git-collect.sh
# Tests repository data collection, tool detection, and quality checks.
#
# Run directly:
#   bash scripts/tests/test_git_collect.sh
#
# Creates temp git repos under /tmp/skill-test/git-collect/{scenario}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_COLLECT="$SCRIPT_DIR/../git-collect.sh"
TEST_BASE="/tmp/skill-test/git-collect"

FAILED=0
PASSED=0
SKIPPED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }
skip() { echo "  SKIP: $1 (tool not installed)"; SKIPPED=$((SKIPPED + 1)); }

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — expected '$needle' in output"
    fi
}
assert_not_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — did not expect '$needle' in output"
    fi
}

# Create a temp git repo with specific files. Echoes the dir path.
# Usage: setup_repo scenario_name file1 file2 ...
setup_repo() {
    local scenario="$1"; shift
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        echo "content" > "$dir/$f"
    done
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial" 2>/dev/null || true
    echo "$dir"
}

# Run git-collect.sh on a repo. Echoes the full output.
run_collect() {
    local dir="$1"
    bash "$GIT_COLLECT" "$dir" 2>&1 || true
}

# --- basic collection tests ---

test_collection_start_end() {
    local dir; dir="$(setup_repo basic README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "basic: COLLECTION_START marker" "=== COLLECTION_START ===" "$out"
    assert_contains "basic: COLLECTION_END marker" "=== COLLECTION_END ===" "$out"
}

test_repo_root() {
    local dir; dir="$(setup_repo repo-root src/main.py)"
    local out; out="$(run_collect "$dir")"
    # git rev-parse may resolve symlinks (/tmp → /private/tmp on macOS)
    assert_contains "basic: REPO_ROOT" "REPO_ROOT:" "$out"
    assert_contains "basic: REPO_ROOT path" "repo-root" "$out"
}

test_branch_detected() {
    local dir; dir="$(setup_repo branch-detected src/index.ts)"
    local out; out="$(run_collect "$dir")"
    assert_contains "basic: BRANCH line" "BRANCH:" "$out"
}

test_staged_changes() {
    local dir; dir="$(setup_repo staged src/app.py)"
    echo "modified" > "$dir/src/app.py"
    git -C "$dir" add -A
    local out; out="$(run_collect "$dir")"
    assert_contains "staged: STAGED section" "STAGED:" "$out"
}

test_unstaged_changes() {
    local dir; dir="$(setup_repo unstaged src/lib.rs)"
    echo "modified" > "$dir/src/lib.rs"
    local out; out="$(run_collect "$dir")"
    assert_contains "unstaged: UNSTAGED section" "UNSTAGED:" "$out"
}

test_untracked_files() {
    local dir; dir="$(setup_repo untracked src/main.go)"
    echo "new" > "$dir/new-file.txt"
    local out; out="$(run_collect "$dir")"
    assert_contains "untracked: UNTRACKED section" "UNTRACKED:" "$out"
}

# --- tool detection tests ---

test_rtk_detection() {
    command -v rtk >/dev/null 2>&1 || { skip "RTK detection"; return; }
    local dir; dir="$(setup_repo rtk-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "RTK: available flag" "RTK:1" "$out"
}

test_rtk_not_available() {
    # This test only works if rtk is NOT installed — skip if it is
    command -v rtk >/dev/null 2>&1 && { skip "RTK not available (rtk is installed)"; return; }
    local dir; dir="$(setup_repo no-rtk README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "no RTK: unavailable flag" "RTK:0" "$out"
}

test_devbox_detection() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox detection"; return; }
    local dir; dir="$(setup_repo devbox-detect devbox.json README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "devbox: available flag" "DEVBOX:1" "$out"
}

test_devbox_not_available() {
    command -v devbox >/dev/null 2>&1 && { skip "devbox not available (devbox is installed)"; return; }
    local dir; dir="$(setup_repo no-devbox README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "no devbox: unavailable flag" "DEVBOX:0" "$out"
}

test_jj_detection() {
    command -v jj >/dev/null 2>&1 || { skip "jj detection"; return; }
    local dir; dir="$(setup_repo jj-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "jj: available flag" "JJ:1" "$out"
}

# --- quality check tests ---

test_quality_checks_section() {
    local dir; dir="$(setup_repo quality-checks package.json)"
    local out; out="$(run_collect "$dir")"
    assert_contains "quality: QUALITY_CHECKS section" "QUALITY_CHECKS:" "$out"
}

test_npm_test_detected() {
    local dir
    dir="$TEST_BASE/npm-test"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    cat > "$dir/package.json" <<'EOF'
{
  "name": "test-project",
  "scripts": {
    "test": "echo 'tests pass'"
  }
}
EOF
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    assert_contains "npm test: NPM_TEST section" "NPM_TEST:" "$out"
}

test_cargo_test_detected() {
    local dir
    dir="$TEST_BASE/cargo-test"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    cat > "$dir/Cargo.toml" <<'EOF'
[package]
name = "test-project"
version = "0.1.0"
EOF
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    assert_contains "cargo test: CARGO_TEST section" "CARGO_TEST:" "$out"
}

test_no_test_configured() {
    local dir; dir="$(setup_repo no-test README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "no tests: NOT_CONFIGURED" "TESTS:NOT_CONFIGURED" "$out"
}

# --- diff stats ---

test_diff_stats() {
    local dir; dir="$(setup_repo diff-stats src/a.py src/b.py)"
    echo "changed" > "$dir/src/a.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "diff: DIFF_STATS section" "DIFF_STATS:" "$out"
}

test_full_diff() {
    local dir; dir="$(setup_repo full-diff src/main.py)"
    echo "changed content" > "$dir/src/main.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "diff: FULL_DIFF section" "FULL_DIFF:" "$out"
}

# --- not a git repo ---

test_not_a_git_repo() {
    local dir="$TEST_BASE/not-a-repo"
    rm -rf "$dir"; mkdir -p "$dir"
    local out
    out="$(bash "$GIT_COLLECT" "$dir" 2>&1)" || true
    assert_contains "not a repo: error message" "ERROR" "$out"
}

# --- main ---

main() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"

    echo "=== git-repository-management: git-collect.sh tests ==="
    echo ""

    echo "--- basic collection ---"
    test_collection_start_end
    test_repo_root
    test_branch_detected
    test_staged_changes
    test_unstaged_changes
    test_untracked_files

    echo ""
    echo "--- tool detection ---"
    test_rtk_detection
    test_rtk_not_available
    test_devbox_detection
    test_devbox_not_available
    test_jj_detection

    echo ""
    echo "--- quality checks ---"
    test_quality_checks_section
    test_npm_test_detected
    test_cargo_test_detected
    test_no_test_configured

    echo ""
    echo "--- diff output ---"
    test_diff_stats
    test_full_diff

    echo ""
    echo "--- edge cases ---"
    test_not_a_git_repo

    echo ""
    echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

    rm -rf "$TEST_BASE"
    exit "$FAILED"
}

main "$@"
