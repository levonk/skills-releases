#!/usr/bin/env bats
# test_check_npm_registry.bats — unit tests for check-npm-registry.sh
#
# Tests the local (no-network) detection paths: missing package.json,
# private packages, missing bin entries, missing name. Registry-dependent
# paths (is_published, tarball inspection) require network + npm and are
# covered by manual/integration testing, not these unit tests.
#
# Run via:
#   bats scripts/tests/test_check_npm_registry.bats
#
# Creates temp scenarios under /tmp/skill-test/nixify/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/../check-npm-registry.sh"
TEST_BASE="/tmp/skill-test/nixify"

# Create a scenario dir. Echoes the dir path.
setup_scenario() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    echo "$dir"
}

# Write a package.json with given content to a dir
write_pkgjson() {
    local dir="$1" content="$2"
    echo "$content" > "$dir/package.json"
}

# Run the script on a dir. Echoes JSON output; propagates the script's exit
# status so `[ "$status" -eq 0 ]` assertions are meaningful.
run_check() {
    local dir="$1"
    bash "$CHECK_SCRIPT" "$dir" 2>/dev/null
}

# --- not a Node project ---

@test "no package.json -> applicable=false" {
    local dir
    dir=$(setup_scenario no-package-json)
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r .applicable)" = "false" ]
}

# --- private package ---

@test "private package -> is_published=false, eligible=false" {
    local dir
    dir=$(setup_scenario private-pkg)
    write_pkgjson "$dir" '{"name":"internal-cli","private":true,"bin":{"internal-cli":"dist/cli.js"}}'
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r .applicable)" = "true" ]
    [ "$(echo "$output" | jq -r .is_published)" = "false" ]
    [ "$(echo "$output" | jq -r .npm_registry_tarball_eligible)" = "false" ]
    echo "$output" | jq -r .rationale | grep -q "private"
}

# --- library without bin ---

@test "no bin entries -> has_bin=false, eligible=false" {
    local dir
    dir=$(setup_scenario library-no-bin)
    write_pkgjson "$dir" '{"name":"some-lib","main":"index.js"}'
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r .has_bin)" = "false" ]
    [ "$(echo "$output" | jq -r .npm_registry_tarball_eligible)" = "false" ]
    echo "$output" | jq -r .rationale | grep -q "library"
}

# --- missing name ---

@test "no name field -> is_published=false, eligible=false" {
    local dir
    dir=$(setup_scenario no-name)
    write_pkgjson "$dir" '{"bin":{"cli":"dist/cli.js"}}'
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r .is_published)" = "false" ]
    [ "$(echo "$output" | jq -r .npm_registry_tarball_eligible)" = "false" ]
}

# --- native dep detection (local, no registry needed) ---

@test "better-sqlite3 dependency is reported in native_deps" {
    local dir
    dir=$(setup_scenario native-dep)
    write_pkgjson "$dir" '{"name":"x","private":true,"bin":{"x":"dist/x.js"},"dependencies":{"better-sqlite3":"^13.0.0"}}'
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r '.native_deps | contains(["better-sqlite3"])')" = "true" ]
}

@test "non-native dependencies produce empty native_deps" {
    local dir
    dir=$(setup_scenario no-native)
    write_pkgjson "$dir" '{"name":"x","private":true,"bin":{"x":"dist/x.js"},"dependencies":{"lodash":"^4.0.0"}}'
    run run_check "$dir"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r '.native_deps | length')" = "0" ]
}
