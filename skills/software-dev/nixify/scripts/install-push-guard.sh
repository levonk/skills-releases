#!/usr/bin/env bash
# install-push-guard.sh — install the nixify push guard as a user-level hook.
#
# Installs nixify-push-guard.sh into ~/.config/devin/hooks/ and wires it into
# ~/.config/devin/hooks.v1.json as a PreToolUse hook on `exec` commands.
# The guard intercepts `git push` commands in projects that have a flake.nix
# and blocks them if validate-pre-push.sh hasn't been run.
#
# Usage: install-push-guard.sh [--uninstall]
#
# The hook is user-level (applies to all projects). It only fires when:
#   1. The command is `git push`
#   2. flake.nix exists in the project directory
#   3. validate-pre-push.sh hasn't been run (no marker file)
#
# To bypass for a specific push (not a nixify project): set NIXIFY_SKIP_GUARD=1
# or delete flake.nix if it's not a nixify-managed project.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/../hooks/nixify-push-guard.sh"
HOOK_DEST_DIR="$HOME/.config/devin/hooks"
HOOK_DEST="$HOOK_DEST_DIR/nixify-push-guard.sh"
HOOKS_FILE="$HOME/.config/devin/hooks.v1.json"

ACTION="${1:-install}"

if [ "$ACTION" = "--uninstall" ]; then
	echo "Uninstalling nixify push guard..."
	rm -f "$HOOK_DEST" 2>/dev/null || true
	# Remove from hooks.v1.json (merge the existing hooks minus our entry)
	if [ -f "$HOOKS_FILE" ]; then
		python3 -c "
import json, sys
with open('$HOOKS_FILE') as f:
    hooks = json.load(f)
pre = hooks.get('PreToolUse', [])
filtered = []
for entry in pre:
    hook_cmds = [h for h in entry.get('hooks', []) if 'nixify-push-guard' not in h.get('command', '')]
    if hook_cmds:
        entry['hooks'] = hook_cmds
        filtered.append(entry)
hooks['PreToolUse'] = filtered
with open('$HOOKS_FILE', 'w') as f:
    json.dump(hooks, f, indent=2)
print('Removed nixify-push-guard from $HOOKS_FILE')
" 2>/dev/null || echo "Could not update $HOOKS_FILE — remove the nixify-push-guard entry manually."
	fi
	echo "Done."
	exit 0
fi

echo "Installing nixify push guard..."

# 1. Copy the hook script to ~/.config/devin/hooks/
mkdir -p "$HOOK_DEST_DIR"
cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"
echo "  Installed hook script: $HOOK_DEST"

# 2. Wire into hooks.v1.json
if [ ! -f "$HOOKS_FILE" ]; then
	# Create new hooks file
	cat > "$HOOKS_FILE" <<EOF
{
  "PreToolUse": [
    {
      "matcher": "exec",
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOOK_DEST",
          "timeout": 5
        }
      ]
    }
  ]
}
EOF
	echo "  Created $HOOKS_FILE with nixify push guard."
else
	# Merge into existing hooks file
	python3 -c "
import json

hooks_file = '$HOOKS_FILE'
hook_cmd = 'bash $HOOK_DEST'

with open(hooks_file) as f:
    hooks = json.load(f)

pre = hooks.get('PreToolUse', [])

# Check if already installed
already = any(
    'nixify-push-guard' in h.get('command', '')
    for entry in pre
    for h in entry.get('hooks', [])
)

if already:
    print('  nixify-push-guard already in $HOOKS_FILE — skipping.')
else:
    # Find an existing exec matcher or create one
    found = False
    for entry in pre:
        if entry.get('matcher') == 'exec':
            entry['hooks'].append({
                'type': 'command',
                'command': hook_cmd,
                'timeout': 5
            })
            found = True
            break
    if not found:
        pre.append({
            'matcher': 'exec',
            'hooks': [{
                'type': 'command',
                'command': hook_cmd,
                'timeout': 5
            }]
        })
    hooks['PreToolUse'] = pre
    with open(hooks_file, 'w') as f:
        json.dump(hooks, f, indent=2)
    print('  Added nixify-push-guard to $HOOKS_FILE.')
" 2>/dev/null || {
		echo "  WARNING: Could not update $HOOKS_FILE automatically." >&2
		echo "  Add this entry manually to the PreToolUse array:" >&2
		echo "    {\"matcher\": \"exec\", \"hooks\": [{\"type\": \"command\", \"command\": \"bash $HOOK_DEST\", \"timeout\": 5}]}" >&2
	}
fi

echo ""
echo "Done. The nixify push guard is now active for all projects."
echo "It will block 'git push' in projects with flake.nix unless"
echo "validate-pre-push.sh has been run and passed."
echo ""
echo "To uninstall: bash $SCRIPT_DIR/install-push-guard.sh --uninstall"
