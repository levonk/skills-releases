#!/usr/bin/env bash
# check-subagent-gate.sh — PreToolUse hook for run_subagent
#
# Reads stdin (hook event JSON), checks if a gate-pass file exists.
# If it does, approves. If not, blocks with a message telling the agent
# to run execution-gate.sh first.
#
# This enforces: NO subagent dispatch without a worktree + checkpoint.
#
# Exit code 2 = block. Exit code 0 = allow.
set -euo pipefail

GATE_DIR="/tmp/devin-execution-gates"
GATE_PASS="$GATE_DIR/current-gate-pass"

# Read hook event from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only enforce for run_subagent
if [[ "$TOOL_NAME" != "run_subagent" ]]; then
  exit 0
fi

# Check for gate pass
if [[ -f "$GATE_PASS" ]]; then
  WORKTREE_PATH=$(cat "$GATE_PASS")
  # Verify the worktree still exists
  if [[ -d "$WORKTREE_PATH" ]]; then
    exit 0
  else
    echo "{\"decision\": \"block\", \"reason\": \"Execution gate: worktree at $WORKTREE_PATH no longer exists. Run execution-gate.sh again before dispatching.\"}"
    exit 2
  fi
fi

# No gate pass — block
cat <<'JSON'
{"decision": "block", "reason": "EXECUTION GATE: You are about to dispatch a subagent WITHOUT a worktree. This violates the execute-upsert binding contract. Run: bash .devin/scripts/execution-gate.sh <story-id-slug> [base-sha] — this creates a per-story git worktree + checkpoint commit. The subagent MUST work in that worktree, not in the main checkout. After the gate passes, re-dispatch. This hook will block every run_subagent call until the gate is satisfied."}
JSON
exit 2
