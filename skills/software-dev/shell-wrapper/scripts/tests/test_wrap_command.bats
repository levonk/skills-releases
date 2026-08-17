#!/usr/bin/env bats
# test_wrap_command.bats — unit tests for wrap_command.sh
# Tests wrapper detection (devbox, mise, nix, etc.) and rtk wrapping logic.
#
# Run via:
#   bats scripts/tests/test_wrap_command.bats
#
# Creates temp scenarios under /tmp/skill-test/shell-wrapper/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
WRAP_CMD="$SCRIPT_DIR/../wrap_command.sh"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/../cli-tool-discovery.sh"
TEST_BASE="/tmp/skill-test/shell-wrapper"

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

# Create a scenario dir with specific files. Echoes the dir path.
# Usage: setup_scenario scenario_name file1 file2 ...
# Config files that require valid content for wrapper detection (devbox.json,
# flake.nix, shell.nix, etc.) are written with minimal valid content instead
# of empty `touch`. Build-system files (package.json, Cargo.toml, etc.) are
# still `touch`ed — detection only checks file existence for those.
setup_scenario() {
    local scenario="$1"; shift
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        case "$f" in
        devbox.json)
            printf '{"packages":[]}\n' > "$dir/$f"
            ;;
        flake.nix|shell.nix|flox.nix)
            printf '{ description = "test"; }\n' > "$dir/$f"
            ;;
        .envrc)
            printf 'export PATH=$PATH:$PWD/bin\n' > "$dir/$f"
            ;;
        mise.toml|.mise.toml|.mise/config.toml)
            printf '[tools]\n' > "$dir/$f"
            ;;
        *)
            touch "$dir/$f"
            ;;
        esac
    done
    echo "$dir"
}

# Run wrap_command.sh in resolve mode from a given dir.
# Echoes the wrapped command string.
# Unsets DEVBOX_SHELL_ENABLED and IN_NIX_SHELL so cli-tool-discovery.sh
# doesn't short-circuit on "already inside devbox/nix" when bats itself
# runs via `devbox run --`.
run_resolve() {
    local dir="$1"; shift
    (cd "$dir" && env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL bash "$WRAP_CMD" "$@") 2>/dev/null || true
}

# --- tests ---

# Helper: check if devbox is functional (returns 0=yes, 1=no). No skip —
# callers decide whether to skip or branch on the result.
# Reuses cli-tool-discovery.sh's --detect-wrapper mode, which probes devbox
# with `devbox run -- true` (hang-safe via devbox_run_timed). No duplicated
# probe logic here — the include's hardened timeout/kill path is the single
# source of truth for devbox functionality checks.
devbox_is_functional() {
    command -v devbox >/dev/null 2>&1 || return 1
    local probe_dir; probe_dir="$(mktemp -d)"
    printf '{"packages":[]}\n' > "$probe_dir/devbox.json"
    local result
    result="$(cd "$probe_dir" && env -u DEVBOX_SHELL -u IN_DEVBOX_SHELL \
        DEVBOX_PROBE_TIMEOUT_SECS=5 bash "$CLI_TOOL_DISCOVERY" --detect-wrapper 2>/dev/null)" || true
    rm -rf "$probe_dir"
    [[ "$result" == "WRAPPER: devbox run --" ]]
}

# Helper: skip if devbox is not functional. Wraps devbox_is_functional with
# a skip call for tests that require devbox to work.
skip_unless_devbox_functional() {
    devbox_is_functional || skip "devbox not functional on this platform"
}

@test "devbox+rtk git status" {
    skip_unless_devbox_functional
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario devbox-rtk devbox.json)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "devbox run -- rtk git status" "$out"
}

@test "devbox only: vim (rtk excluded)" {
    skip_unless_devbox_functional
    local dir
    dir="$(setup_scenario devbox-vim devbox.json)"
    local out
    out="$(run_resolve "$dir" vim file.txt)"
    assert_equals "devbox run -- vim file.txt" "$out"
}

@test "devbox only: just build (rtk unsupported)" {
    skip_unless_devbox_functional
    local dir
    dir="$(setup_scenario devbox-unsupported devbox.json)"
    local out
    out="$(run_resolve "$dir" just build)"
    assert_equals "just build" "$out"
}

@test "--raw: git status (no rtk)" {
    skip_unless_devbox_functional
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario raw-flag devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git status)"
    assert_equals "devbox run -- git status" "$out"
}

@test "chained commands" {
    skip_unless_devbox_functional
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario chained devbox.json)"
    local out
    out="$(run_resolve "$dir" git fetch '&&' git status)"
    # Output uses %q quoting (backslash-escaped spaces): rtk\ git\ fetch
    assert_contains "rtk\ git\ fetch" "$out"
    assert_contains "rtk\ git\ status" "$out"
    assert_contains "bash -c" "$out"
}

@test "--raw chained" {
    skip_unless_devbox_functional
    local dir
    dir="$(setup_scenario raw-chained devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git fetch '&&' git status)"
    assert_not_contains "rtk" "$out"
    assert_contains "bash -c" "$out"
}

@test "no wrapper: rtk git status" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario no-wrapper)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "rtk git status" "$out"
}

@test "no wrapper: echo hello (no rtk)" {
    local dir
    dir="$(setup_scenario no-wrapper-no-rtk)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    # echo is not rtk-supported, no devbox → just echo hello
    assert_equals "echo hello" "$out"
}

@test "inside devbox: rtk git status (no devbox prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-devbox devbox.json)"
    local out
    out="$(DEVBOX_SHELL=1 run_resolve "$dir" git status)"
    # Already inside devbox → no devbox prefix, just rtk
    assert_equals "rtk git status" "$out"
}

@test "inside mise: rtk git status (no mise prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-mise mise.toml)"
    local out
    out="$(MISE_SHELL=1 run_resolve "$dir" git status)"
    assert_equals "rtk git status" "$out"
}

@test "mise detection" {
    command -v mise >/dev/null 2>&1 || skip "mise not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario mise-present mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise exec --" "$out"
    assert_contains "rtk git status" "$out"
}

@test "mise: detects .mise.toml" {
    command -v mise >/dev/null 2>&1 || skip "mise not installed"
    local dir
    dir="$(setup_scenario mise-dot .mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise exec --" "$out"
}

@test "nix flake detection" {
    command -v nix >/dev/null 2>&1 || skip "nix not installed"
    nix --version >/dev/null 2>&1 || skip "nix not functional on this platform"
    local dir
    dir="$(setup_scenario nix-flake flake.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix develop --command" "$out"
}

@test "nix shell.nix detection" {
    command -v nix >/dev/null 2>&1 || skip "nix not installed"
    nix --version >/dev/null 2>&1 || skip "nix not functional on this platform"
    local dir
    dir="$(setup_scenario nix-shell shell.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix-shell --run" "$out"
}

@test "inside nix: rtk git status (no nix prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-nix flake.nix)"
    local out
    # Call wrap_command.sh directly with IN_NIX_SHELL=1 to simulate
    # being inside a nix shell (run_resolve unsets IN_NIX_SHELL).
    out="$(cd "$dir" && IN_NIX_SHELL=1 env -u DEVBOX_SHELL_ENABLED bash "$WRAP_CMD" git status 2>/dev/null)" || true
    assert_equals "rtk git status" "$out"
}

@test "flox detection" {
    command -v flox >/dev/null 2>&1 || skip "flox not installed"
    local dir
    dir="$(setup_scenario flox-present flox.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "flox activate --" "$out"
}

@test "direnv detection" {
    command -v direnv >/dev/null 2>&1 || skip "direnv not installed"
    direnv version >/dev/null 2>&1 || skip "direnv not functional on this platform"
    local dir
    dir="$(setup_scenario direnv-present .envrc)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    # direnv is NOT a wrapper prefix — it uses eval-based activation.
    # wrap_command.sh should fall through to direct execution when only
    # .envrc is present (no devbox.json, flake.nix, etc.).
    assert_equals "echo hello" "$out"
}

@test "pipe command" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario pipe-cmd devbox.json)"
    local out
    out="$(run_resolve "$dir" git log '|' head -5)"
    # Output uses %q quoting: rtk\ git\ log
    assert_contains "rtk\ git\ log" "$out"
    assert_contains "bash -c" "$out"
}
