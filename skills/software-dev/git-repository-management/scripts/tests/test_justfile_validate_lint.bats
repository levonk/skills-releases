#!/usr/bin/env bats
# test_justfile_validate_lint.bats — structural validation for the
# validate-lint recipe in the Justfile.
# Verifies the bats stage uses a temp file (not a pipe to tail) and a
# 300-second timeout. The pipe-to-tail approach caused false timeouts
# because subprocesses inherited the pipe FD and kept it open after bats
# exited, making tail wait until the timeout killed the pipeline.
#
# Run via: bats scripts/tests/test_justfile_validate_lint.bats

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
# Find the Justfile by walking up from the test directory until we find it.
# This handles both the source tree (src/current/skills/.../tests/) and
# the build tree (build/current/skills/.../tests/ and the deeper included/ copy).
JUSTFILE=""
_JUSTFILE_SEARCH_DIR="$SCRIPT_DIR"
while [[ "$_JUSTFILE_SEARCH_DIR" != "/" ]]; do
    if [[ -f "$_JUSTFILE_SEARCH_DIR/Justfile" ]]; then
        JUSTFILE="$_JUSTFILE_SEARCH_DIR/Justfile"
        break
    fi
    _JUSTFILE_SEARCH_DIR=$(dirname "$_JUSTFILE_SEARCH_DIR")
done

@test "Justfile exists" {
    [[ -f "$JUSTFILE" ]] || {
        echo "Justfile not found at $JUSTFILE" >&3
        return 1
    }
}

@test "validate-lint bats stage uses mktemp for output capture" {
    [[ -f "$JUSTFILE" ]] || skip "Justfile not found"
    # The fix changed from `timeout 120 bats "$f" 2>&1 | tail -3` to
    # `BATS_OUT=$(mktemp); timeout 300 bats "$f" >"$BATS_OUT" 2>&1; tail -3 "$BATS_OUT"`
    grep -q 'BATS_OUT=$(mktemp)' "$JUSTFILE" || {
        echo "validate-lint should use mktemp for bats output capture" >&3
        echo "the pipe-to-tail approach causes false timeouts from FD inheritance" >&3
        return 1
    }
}

@test "validate-lint bats stage uses 300-second timeout" {
    [[ -f "$JUSTFILE" ]] || skip "Justfile not found"
    grep -q 'timeout 300 bats' "$JUSTFILE" || {
        echo "validate-lint should use 'timeout 300 bats' (300s per file)" >&3
        echo "the old 120s timeout was too short for test_git_collect.bats (~178s)" >&3
        return 1
    }
}

@test "validate-lint does not pipe bats output directly to tail" {
    [[ -f "$JUSTFILE" ]] || skip "Justfile not found"
    # The old approach: timeout 120 bats "$f" 2>&1 | tail -3
    # This caused false timeouts because subprocesses inherited the pipe FD.
    # The fix captures to a temp file and tails the file after bats exits.
    if grep -q 'timeout.*bats.*|.*tail' "$JUSTFILE"; then
        echo "validate-lint should NOT pipe bats output directly to tail" >&3
        echo "the pipe causes subprocesses to inherit the FD and hang tail" >&3
        return 1
    fi
}

@test "validate-lint cleans up the temp file after each bats run" {
    [[ -f "$JUSTFILE" ]] || skip "Justfile not found"
    grep -q 'rm -f "$BATS_OUT"' "$JUSTFILE" || {
        echo "validate-lint should clean up BATS_OUT after each bats run" >&3
        return 1
    }
}
