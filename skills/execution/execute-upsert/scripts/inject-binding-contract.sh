#!/usr/bin/env bash
# inject-binding-contract.sh — UserPromptSubmit hook
#
# Reads the user's prompt from stdin. If it mentions execute-upsert, execution,
# "run the workflow", or similar execution triggers, injects the binding contract
# as additionalContext. This keeps the non-negotiable rules in active attention
# at the start of every execution session.
#
# The contract is intentionally SHORT (~30 lines) so it stays in context.
set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt','').lower())" 2>/dev/null || echo "")

# Check if this prompt is about execution
KEYWORDS="execute-upsert|execute.upsert|run.*workflow|implement.*feature|drive.*to.completion|run.*prd|execute.*story|dispatch.*subagent"
if ! echo "$PROMPT" | grep -qE "$KEYWORDS"; then
  exit 0
fi

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "=== EXECUTE-UPSERT BINDING CONTRACT (NON-NEGOTIABLE) ===\n\nThese rules are MACHINE-ENFORCED via .devin/hooks.v1.json. Violating them triggers hard blocks.\n\n1. EVERY subagent dispatch MUST go through `bash .devin/scripts/execution-gate.sh <story-slug> [base-sha] [--story-type <trivial|standard|research>]` FIRST. This creates a per-story git worktree at /tmp/<project>-worktrees/<story-slug>. The PreToolUse hook on run_subagent BLOCKS dispatch if no gate-pass file exists. The --story-type flag is a forward-compatible metadata tag (currently unused behaviorally — all types get the same discipline).\n2. The subagent MUST work ONLY in the worktree path returned by the gate script. Pass the worktree path in the dispatch prompt.\n3. BEFORE dispatching: create a checkpoint commit on the current branch. Record the SHA for rollback.\n4. AFTER each story completes: commit the story's work on the story branch, merge back with --no-ff, remove the worktree.\n5. NEVER commit directly on main/master with uncommitted changes from a prior session. The Stop hook blocks stopping with a dirty main.\n6. NEVER work on stories directly in the main checkout. Every story gets its own worktree — sequential AND parallel.\n7. Max 5 simultaneous subagents (API rate-limit safety).\n8. If a subagent fails, roll back to the checkpoint: `git -C <worktree> reset --hard <checkpoint-sha>`.\n\nThe full INSTRUCTIONS.md is reference material. THIS CONTRACT is the active law.\n=== END BINDING CONTRACT ==="
  }
}
JSON
