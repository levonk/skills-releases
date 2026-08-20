#!/usr/bin/env bats
# test_handoff_template.bats — structural validation for the handoff template
# Verifies the template includes all required sections, including the
# Skill Contract section added to prevent skill-contract loss across
# session handoffs.
#
# Run via: bats scripts/tests/test_handoff_template.bats

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../../references/handoff-template.md"
INSTRUCTIONS="$SCRIPT_DIR/../../INSTRUCTIONS.md"

@test "handoff template file exists" {
    [[ -f "$TEMPLATE" ]] || {
        echo "handoff-template.md not found at $TEMPLATE" >&3
        return 1
    }
}

@test "handoff template includes Required Reading section" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    grep -q '## Required Reading' "$TEMPLATE" || {
        echo "template missing ## Required Reading section" >&3
        return 1
    }
}

@test "handoff template includes Skill Contract section" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    grep -q '## Skill Contract' "$TEMPLATE" || {
        echo "template missing ## Skill Contract section" >&3
        return 1
    }
}

@test "handoff template Skill Contract appears after Required Reading" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    local rr_line sc_line
    rr_line=$(grep -n '## Required Reading' "$TEMPLATE" | head -1 | cut -d: -f1)
    sc_line=$(grep -n '## Skill Contract' "$TEMPLATE" | head -1 | cut -d: -f1)
    [[ -n "$rr_line" && -n "$sc_line" ]] || {
        echo "missing Required Reading (line $rr_line) or Skill Contract (line $sc_line)" >&3
        return 1
    }
    [[ "$sc_line" -gt "$rr_line" ]] || {
        echo "Skill Contract (line $sc_line) should come after Required Reading (line $rr_line)" >&3
        return 1
    }
}

@test "handoff template Skill Contract references INSTRUCTIONS.md" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    grep -q 'INSTRUCTIONS.md' "$TEMPLATE" || {
        echo "Skill Contract section should reference the skill's INSTRUCTIONS.md" >&3
        return 1
    }
}

@test "handoff template Skill Contract includes no-skill fallback" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    grep -q 'No skill contract' "$TEMPLATE" || {
        echo "Skill Contract section should include the no-skill fallback text" >&3
        return 1
    }
}

@test "handoff template includes Skill Contract in extended example" {
    [[ -f "$TEMPLATE" ]] || skip "template not found"
    # The extended example is the second occurrence of ## Skill Contract
    local count
    count=$(grep -c '## Skill Contract' "$TEMPLATE")
    [[ "$count" -ge 2 ]] || {
        echo "expected Skill Contract in both default and extended templates, found $count" >&3
        return 1
    }
}

@test "handoff INSTRUCTIONS includes Emit Skill Contract step" {
    [[ -f "$INSTRUCTIONS" ]] || skip "INSTRUCTIONS not found"
    grep -q 'Emit Skill Contract' "$INSTRUCTIONS" || {
        echo "INSTRUCTIONS missing the Emit Skill Contract Directive step" >&3
        return 1
    }
}

@test "handoff INSTRUCTIONS includes Read the Skill Contract step" {
    [[ -f "$INSTRUCTIONS" ]] || skip "INSTRUCTIONS not found"
    grep -q 'Read the Skill Contract' "$INSTRUCTIONS" || {
        echo "INSTRUCTIONS missing the Read the Skill Contract restoration step" >&3
        return 1
    }
}

@test "handoff INSTRUCTIONS Skill Contract overrides generic defaults" {
    [[ -f "$INSTRUCTIONS" ]] || skip "INSTRUCTIONS not found"
    grep -q 'overrides generic AI-assistant defaults' "$INSTRUCTIONS" || {
        echo "INSTRUCTIONS should state that the skill contract overrides generic defaults" >&3
        return 1
    }
}
