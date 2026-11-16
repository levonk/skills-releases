#!/usr/bin/env bats
# test_onboarding_report.bats — unit tests for onboarding-report.py
#
# Covers: init skeleton, render ID assignment (letter = cluster,
# number = per-cluster sequence), pre-assigned ID preservation
# (no renumbering), select parsing (single, all-, all-+, !, none-,
# revert), and unknown-cluster letter assignment.
#
# Run via: bats scripts/tests/test_onboarding_report.bats

SCRIPT="${BATS_TEST_DIRNAME}/../onboarding-report.py"
TEST_BASE="/tmp/skill-test/onboarding-report"

setup() {
    mkdir -p "$TEST_BASE"
    cat > "$TEST_BASE/findings.json" <<'EOF'
{
  "project": "demo",
  "date": "2026-11-16",
  "findings": [
    {"cluster": "docs", "title": "Dead link", "files": ["README.md"], "tier": "applied", "fix": "relinked"},
    {"cluster": "docs", "title": "Missing Testing section", "files": ["README.md"], "tier": "proposed"},
    {"cluster": "build-tooling", "title": "Stale lint target", "files": ["Justfile"], "tier": "proposed"},
    {"cluster": "security", "title": "Committed .env", "files": [".env"], "tier": "proposed"},
    {"cluster": "model-prompting", "title": "Prompt exceeds budget", "files": ["a.md"], "tier": "optional"},
    {"cluster": "weird-custom", "title": "Custom thing", "tier": "proposed"}
  ]
}
EOF
}

run_report() {
    uv run --script "$SCRIPT" "$@"
}

@test "init emits a valid findings skeleton" {
    run run_report init
    [ "$status" -eq 0 ]
    echo "$output" | grep -q '"findings"'
}

@test "render assigns letter+number IDs per cluster" {
    run run_report render "$TEST_BASE/findings.json"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q '\[D1\] applied'
    echo "$output" | grep -q '\[D2\] proposed'
    echo "$output" | grep -q '\[B1\] proposed'
    echo "$output" | grep -q '\[S1\] proposed'
    echo "$output" | grep -q '\[M1\] optional'
}

@test "render groups unknown clusters under a free letter" {
    run run_report render "$TEST_BASE/findings.json"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q '\[C1\] proposed — Custom thing'
    echo "$output" | grep -q '## C — Weird Custom'
}

@test "render preserves pre-assigned IDs and continues numbering" {
    cat > "$TEST_BASE/stable.json" <<'EOF'
{
  "project": "demo",
  "date": "2026-11-16",
  "findings": [
    {"id": "D7", "cluster": "docs", "title": "kept", "tier": "proposed"},
    {"cluster": "docs", "title": "new finding", "tier": "proposed"}
  ]
}
EOF
    run run_report render "$TEST_BASE/stable.json"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q '\[D7\] proposed — kept'
    echo "$output" | grep -q '\[D8\] proposed — new finding'
}

@test "select resolves singles, all-, !skip, and none-" {
    run run_report select "$TEST_BASE/findings.json" "D2 all-S !S9 none-M"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q '"D2"'
    echo "$output" | grep -q '"S1"'
    echo "$output" | grep -q '"M1"'
}

@test "select all-+ includes optional tier" {
    run run_report select "$TEST_BASE/findings.json" "all-M+"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.apply | index("M1")' >/dev/null
}

@test "select all- excludes optional tier" {
    run run_report select "$TEST_BASE/findings.json" "all-M"
    [ "$status" -eq 0 ]
    ! echo "$output" | jq -e '.apply | index("M1")' >/dev/null
    echo "$output" | jq -e '.skip | index("M1")' >/dev/null
}

@test "select revert removes from applied_unchanged" {
    run run_report select "$TEST_BASE/findings.json" "revert D1"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.revert | index("D1")' >/dev/null
    ! echo "$output" | jq -e '.applied_unchanged | index("D1")' >/dev/null
}

@test "select defaults unmentioned pending items to skip" {
    run run_report select "$TEST_BASE/findings.json" "D2"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.skip | index("B1")' >/dev/null
    echo "$output" | jq -e '.skip | index("S1")' >/dev/null
}
