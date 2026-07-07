# Script Execution Standards

All scripts created by or bundled with a skill must follow these execution standards. These patterns ensure scripts run in the correct environment (devbox) and optimize token usage automatically (rtk).

## Table of Contents

1. [Devbox Environment Detection](#devbox-environment-detection)
2. [RTK (Rust Token Killer) Usage](#rtk-rust-token-killer-usage)
3. [Applying These Standards](#applying-these-standards)

## Devbox Environment Detection

Before executing any bundled script, check whether `devbox` is available and a `devbox.json` exists in the project root. If so, execute scripts via `devbox run --` unless already inside a `devbox shell`.

**Detection pattern (bash):**
```bash
if command -v devbox >/dev/null 2>&1 && [[ -f "devbox.json" ]]; then
    DEVBOX_AVAILABLE=1
else
    DEVBOX_AVAILABLE=0
fi

# Check if already inside a devbox shell
if [[ -n "${DEVBOX_SHELL:-}" ]] || [[ -n "${IN_DEVBOX_SHELL:-}" ]]; then
    DEVBOX_AVAILABLE=0
fi

devbox_run() {
    if [[ "$DEVBOX_AVAILABLE" -eq 1 ]]; then
        devbox run -- "$@"
    else
        "$@"
    fi
}
```

**Detection pattern (python):**
```python
import os
import shutil
import subprocess

def is_devbox_available() -> bool:
    """Check if devbox is available and not already in a devbox shell."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")

def devbox_run(cmd: list[str]) -> subprocess.CompletedProcess:
    """Run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], check=True)
    return subprocess.run(cmd, check=True)
```

## RTK (Rust Token Killer) Usage

Within scripts, use `rtk` as a proxy for `git` and other supported commands when available. RTK reduces LLM token consumption by 60-90% by filtering and compressing command outputs.

- **Detection**: Check with `command -v rtk` (bash) or `shutil.which("rtk")` (python)
- **Git commands**: Use `rtk git <args>` instead of `git <args>`
- **Quality checks**: Use `rtk <tool> <args>` for supported tools (eslint, prettier, npm, cargo, pytest, etc.)
- **Fallback**: If `rtk` is not available, use the raw command directly
- **No user permission needed**: This is automatic — do not ask the user whether to use rtk

**Bash wrapper pattern:**
```bash
if command -v rtk >/dev/null 2>&1; then
    RTK_AVAILABLE=1
else
    RTK_AVAILABLE=0
fi

rtk_wrap() {
    local tool="$1"
    shift
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        devbox_run rtk "$tool" "$@"
    else
        devbox_run "$tool" "$@"
    fi
}
```

**Python wrapper pattern:**
```python
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None

def rtk_wrap(tool: str, *args: str) -> subprocess.CompletedProcess:
    """Run a command through rtk if available, otherwise directly."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args])
    return devbox_run([tool, *args])
```

See: <https://github.com/rtk-ai/rtk> for full command coverage.

## Applying These Standards

- When the AI agent runs bundled scripts directly (outside of scripts), it should also prefer `devbox run --` and `rtk` when available
- The `init_skill.py` and `package_skill.py` scripts in this skill already include these detection patterns
- The `example-script.py.template` template includes these patterns so new skills inherit them automatically
- When converting workflows to skills, extract deterministic phases into scripts that include these detection patterns at the top
