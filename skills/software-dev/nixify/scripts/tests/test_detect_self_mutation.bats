#!/usr/bin/env bats
# test_detect_self_mutation.bats — unit tests for detect-self-mutation.sh
#
# Tests the deterministic detection of in-place self-mutation signals in a
# project's source tree: self-updaters, rollback paths, self-repair, delta
# patchers, and auto-update frameworks (Sparkle/Squirrel/electron-updater).
# These fail at runtime when a flake wraps the binary because /nix/store is
# read-only.
#
# Run via:
#   bats scripts/tests/test_detect_self_mutation.bats
#
# Creates temp scenarios under /tmp/skill-test/nixify-selfmut/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/../detect-self-mutation.sh"
TEST_BASE="/tmp/skill-test/nixify-selfmut"

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

setup_scenario() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    echo "$dir"
}

@test "detects Swift updater + rollback + bundle-write signals" {
    dir=$(setup_scenario swift-updater)
    cat > "$dir/app.swift" <<'EOF'
final class SimpleUpdater {
    func startUpdateCheck() { }
    func rollbackToLatestBackup() { performSwapAndRelaunch() }
    func performSwapAndRelaunch() {
        let bundle = Bundle.main.bundleURL
    }
}
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_hits":true' "$output"
    assert_contains 'updater' "$output"
    assert_contains 'rollback' "$output"
    assert_contains 'swap-relaunch' "$output"
    assert_contains 'bundle-mutation' "$output"
}

@test "detects Sparkle, Squirrel, and electron-updater frameworks" {
    dir=$(setup_scenario frameworks)
    cat > "$dir/main.ts" <<'EOF'
import { autoUpdater } from "electron-updater";
// Sparkle appcast feed: SUUpdater / SPUUpdater
// SquirrelAware Update.exe handling
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_hits":true' "$output"
    assert_contains 'electron-updater' "$output"
    assert_contains 'sparkle' "$output"
    assert_contains 'squirrel' "$output"
}

@test "detects delta patchers and self-repair" {
    dir=$(setup_scenario repair)
    cat > "$dir/install.c" <<'EOF'
// apply delta patch via bspatch, then self-repair install
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains 'delta-patch' "$output"
    assert_contains 'self-repair' "$output"
}

@test "reports no hits for a clean CLI project" {
    dir=$(setup_scenario clean)
    cat > "$dir/main.go" <<'EOF'
package main
func main() { println("hello") }
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_hits":false' "$output"
    assert_contains '"hit_count":0' "$output"
}

@test "skips node_modules and lockfiles" {
    dir=$(setup_scenario exclusions)
    mkdir -p "$dir/node_modules/pkg"
    cat > "$dir/node_modules/pkg/updater.js" <<'EOF'
const updater = require("sparkle-updater");
EOF
    cat > "$dir/package-lock.json" <<'EOF'
{"name":"x","dependencies":{"updater":"1.0.0","rollback-lib":"2.0.0"}}
EOF
    cat > "$dir/src.js" <<'EOF'
console.log("no signals here");
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_hits":false' "$output"
}

@test "fails on missing directory" {
    run bash "$DETECT_SCRIPT" /tmp/skill-test/nonexistent-dir-xyz
    [ "$status" -eq 1 ]
    assert_contains 'not found' "$output"
}
