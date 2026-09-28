#!/usr/bin/env bash
# install-hooks.sh — install Devin CLI hooks for execute-upsert enforcement
#
# Writes the hooks config (.devin/hooks.v1.json) and hook scripts
# (.devin/scripts/*.sh) into the consumer project's .devin/ directory.
# Called by refresh.sh after the skill update completes.
#
# This is the deterministic hook distribution mechanism — no agent judgment
# needed. The hooks are project-level (.devin/hooks.v1.json), not skill-level,
# so the skill needs this setup script to install them.
#
# Idempotent: safe to re-run. Overwrites the hook scripts and merges the hooks
# config (preserving any existing hooks the consumer may have).
#
# Usage:
#   bash scripts/install-hooks.sh [--project-dir <path>]
#
# Exit codes:
#   0 = hooks installed (or already up to date)
#   1 = usage error or missing skill scripts
set -euo pipefail

# --- Resolve project directory ---
PROJECT_DIR="${DEVIN_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
if [[ "${1:-}" == "--project-dir" ]]; then
  PROJECT_DIR="$2"
  shift 2
fi

# --- Resolve skill directory (where this script lives) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DEVIN_DIR="$PROJECT_DIR/.devin"
DEVIN_SCRIPTS_DIR="$DEVIN_DIR/scripts"

# --- Hook scripts to install (source filenames in skill scripts/ dir) ---
HOOK_SCRIPTS=(
  "check-subagent-gate.sh"
  "inject-binding-contract.sh"
  "check-uncommitted-stop.sh"
  "execution-gate.sh"
)

# --- Create .devin/ and .devin/scripts/ if they don't exist ---
mkdir -p "$DEVIN_SCRIPTS_DIR"

# --- Install hook scripts ---
for script in "${HOOK_SCRIPTS[@]}"; do
  SRC="$SCRIPT_DIR/$script"
  DST="$DEVIN_SCRIPTS_DIR/$script"
  if [[ ! -f "$SRC" ]]; then
    echo "install-hooks.sh: WARNING — $script not found at $SRC, skipping" >&2
    continue
  fi
  cp "$SRC" "$DST"
  chmod +x "$DST"
done

# --- Install hooks config ---
# Merge with any existing hooks.v1.json to preserve consumer hooks.
# If no existing config, write a fresh one.
HOOKS_FILE="$DEVIN_DIR/hooks.v1.json"

# The execute-upsert hooks block — always written fresh (idempotent).
write_hooks_config() {
  cat > "$HOOKS_FILE" <<'HOOKS_JSON'
{
  "PreToolUse": [
    {
      "matcher": "run_subagent",
      "hooks": [
        {
          "type": "command",
          "command": "bash .devin/scripts/check-subagent-gate.sh",
          "timeout": 5
        }
      ]
    }
  ],
  "UserPromptSubmit": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "bash .devin/scripts/inject-binding-contract.sh",
          "timeout": 5
        }
      ]
    }
  ],
  "Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "bash .devin/scripts/check-uncommitted-stop.sh",
          "timeout": 5
        }
      ]
    }
  ]
}
HOOKS_JSON
}

if [[ ! -f "$HOOKS_FILE" ]]; then
  write_hooks_config
elif command -v jq >/dev/null 2>&1; then
  # Merge: update the execute-upsert hook entries without clobbering others.
  # We use jq to ensure the three hook events exist with our entries.
  # For simplicity and idempotency, if the file already has our commands,
  # we leave it; otherwise we add/overwrite our entries.
  if ! grep -q "check-subagent-gate.sh" "$HOOKS_FILE" 2>/dev/null; then
    # File exists but doesn't have our hooks — merge them in.
    # Safe merge: add our hooks to existing arrays.
    TMP_FILE="$(mktemp)"
    jq '
      .PreToolUse = ((.PreToolUse // []) + [{
        "matcher": "run_subagent",
        "hooks": [{"type": "command", "command": "bash .devin/scripts/check-subagent-gate.sh", "timeout": 5}]
      }]) |
      .UserPromptSubmit = ((.UserPromptSubmit // []) + [{
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash .devin/scripts/inject-binding-contract.sh", "timeout": 5}]
      }]) |
      .Stop = ((.Stop // []) + [{
        "matcher": "",
        "hooks": [{"type": "command", "command": "bash .devin/scripts/check-uncommitted-stop.sh", "timeout": 5}]
      }])
    ' "$HOOKS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$HOOKS_FILE"
  fi
else
  # No jq and file exists — overwrite with our config (consumer hooks lost).
  # This is a fallback; jq is available in the devbox environment.
  echo "install-hooks.sh: WARNING — jq not found, overwriting existing hooks.v1.json" >&2
  write_hooks_config
fi

echo "install-hooks.sh: execute-upsert enforcement hooks installed to $DEVIN_DIR" >&2
