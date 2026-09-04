#!/usr/bin/env bash
# nixify-push-guard.sh — PreToolUse hook for `git push` commands.
#
# This is the deterministic guard that catches the agent trying to push a
# nixify PR without running validate-pre-push.sh (Step 22b). It fires on
# every `git push` command and checks:
#
#   1. Is this a nixify project? (flake.nix exists in the project dir)
#   2. Was validate-pre-push.sh run? (marker file exists)
#
# If both conditions are true (nixify project + no marker), it BLOCKS the
# push with a reminder to run validate-pre-push.sh first.
#
# The marker file is created by validate-pre-push.sh itself when it passes.
# It's scoped to the project directory + branch so it doesn't leak across
# projects or branches.
#
# Install: add to ~/.config/devin/hooks.v1.json (user-level, applies to all
# projects) or .devin/hooks.v1.json (project-level):
#
#   {
#     "PreToolUse": [
#       {
#         "matcher": "exec",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "bash ~/.config/devin/hooks/nixify-push-guard.sh",
#             "timeout": 5
#           }
#         ]
#       }
#     ]
#   }
#
# Or use the install script: scripts/install-push-guard.sh

set -euo pipefail

# Read the PreToolUse stdin payload
INPUT=$(cat || echo "")
if [ -z "$INPUT" ]; then
	exit 0
fi

# Parse the tool name and command from stdin JSON
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_name', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

if [ "$TOOL_NAME" != "exec" ]; then
	exit 0
fi

COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# Only intercept git push commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+push\b'; then
	exit 0
fi

# Determine the project directory
PROJECT_DIR="${DEVIN_PROJECT_DIR:-$(pwd)}"

# Check if this is a nixify project (flake.nix exists)
if [ ! -f "$PROJECT_DIR/flake.nix" ]; then
	exit 0
fi

# Check if validate-pre-push.sh was run (marker file)
# The marker is scoped to the current branch + project to avoid stale markers
BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
PROJECT_HASH=$(echo "$PROJECT_DIR" | shasum -a 256 | cut -c1-16)
MARKER_DIR="/tmp/devin-nixify-guards"
MARKER_FILE="$MARKER_DIR/${PROJECT_HASH}-${BRANCH}-validated"

if [ -f "$MARKER_FILE" ]; then
	# validate-pre-push.sh ran and passed — allow the push
	exit 0
fi

# Block the push — validate-pre-push.sh hasn't run for this project+branch
cat <<'JSON'
{"decision": "block", "reason": "NIXIFY PUSH GUARD: You are about to push a nixify PR (flake.nix detected) but validate-pre-push.sh (Step 22b) has NOT been run for this branch. This is the deterministic gate that catches: (1) fetchPnpmDeps/fetchNpmDeps hash mismatches, (2) magic-nix-cache-action prohibition, (3) missing timeout-minutes, (4) stale branch. Run: bash scripts/validate-pre-push.sh <owner>/<repo> . --base-ref origin/main --verbose — then push. If validate-pre-push.sh is not available (not a nixify-managed project), delete flake.nix or set NIXIFY_SKIP_GUARD=1 in the environment."}
JSON
exit 2
