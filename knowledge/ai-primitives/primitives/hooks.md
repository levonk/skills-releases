---
type: Primitive Definition
title: Hooks
description: Event-driven scripts that fire at specific points in the AI agent lifecycle (pre/post read/write/run), receiving JSON via stdin and returning exit codes.
resource: src/current/hooks/
tags: [ai-primitives, hooks, event-driven, guardrails, validation, security]
timestamp: 2026-07-11T10:30:00Z
---

# Hooks

## Definition

Hooks are event-driven scripts that fire at specific points in the AI agent
lifecycle. They receive JSON via stdin, execute logic, and return an exit
code: 0 = allow the action, 1 = block it. Hooks provide guardrails and
validation around tool calls.

## Primary Role

**Guardrail** — a hook intercepts an action (file read, file write, command
execution) and either allows or blocks it based on security/validation
logic.

## Scope

Narrow, event-specific. A hook fires on one event type and checks one
concern.

## Frontmatter

Hooks typically have **no frontmatter**. They are standalone Python scripts
that read JSON from stdin and exit with a status code.

## Body Structure

Hooks are Python scripts (not markdown):

```python
#!/usr/bin/env python3
import sys
import json
import re

def main():
    input_data = sys.stdin.read()
    data = json.loads(input_data)

    if data.get("agent_action_name") == "pre_write_code":
        # Check for secrets in proposed edits
        findings = scan_text(new_string)
        if findings:
            print(f"SECURITY BLOCK: Found potential secrets...", file=sys.stderr)
            sys.exit(1)  # Block the write
    sys.exit(0)  # Allow

main()
```

## Hook Input Format

Hooks receive JSON via stdin:

```json
{
  "agent_action_name": "pre_write_code",
  "tool_info": {
    "edits": [
      {
        "new_string": "code to check"
      }
    ]
  }
}
```

## Hook Events

| Event | When it fires | Use case |
|-------|--------------|----------|
| `pre_read_code` | Before reading files | Block sensitive files |
| `pre_write_code` | Before writing files | Scan for secrets, check extensions |
| `post_write_code` | After writing files | Lint check, quality lint |
| `pre_run_command` | Before executing commands | Block dangerous commands |
| `preflight` | Before feature activation | Feature validation |
| `global` | Always active | Cascade logging |

## Loading Behavior

Event-driven. Loaded only when the corresponding event fires.

## Reusability

Hooks are reusable across projects — the same secret scanner can protect
any codebase.

## Autonomy Level Changes

No — hooks are guards, not autonomous agents.

## Personality/Behavior

No — hooks are scripts, no personality.

## Planning and Reasoning

No — hooks execute deterministic checks. No planning.

## File Location

`src/current/hooks/<event-type>/<hook-name>.py`

## Hook Subdirectories

```
src/current/hooks/
├── features/domain-primitives-branded-types@v1/preflight.md
├── global/cascade_logger.py
├── linters/linters-todo.md
├── post_write_code/
│   ├── lint_check.py
│   └── quality_lint.py
├── pre_read_code/
│   └── block_sensitive_files.py
├── pre_run_command/
│   └── block_dangerous.py
└── pre_write_code/
    ├── check_ts_extensions.py
    └── scan_secrets.py
```

## Key Difference from Skills

| Aspect | Hooks | Skills |
|--------|-------|--------|
| Trigger | Event-driven (file ops, commands) | Description-based trigger |
| Input | JSON via stdin | Natural language request |
| Output | Exit code (0=allow, 1=block) | Generated content |
| Purpose | Guardrails, validation | Task execution |
| Format | Python scripts | Markdown + scripts |

## Examples

- `hooks/pre_write_code/scan_secrets.py` — Blocks writes containing secrets
- `hooks/pre_write_code/check_ts_extensions.py` — Validates TypeScript file extensions
- `hooks/pre_run_command/block_dangerous.py` — Blocks dangerous shell commands
- `hooks/pre_read_code/block_sensitive_files.py` — Blocks reading sensitive files
- `hooks/post_write_code/lint_check.py` — Lints code after writing
- `hooks/global/cascade_logger.py` — Logs all actions

## Producer Skill

No dedicated `hook-upsert` skill. Hooks are authored by hand following the
pattern of existing hook files. Use `ai-guidance-improver` to audit them.

# Citations

[1] [Hooks directory](src/current/hooks/)
