#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Conversation Context Capture Helper with tkr Integration

This script helps structure conversation context and optionally creates tkr tickets.
Run with --help for options.
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


import json
import os
import shutil
import subprocess
from pathlib import Path


def _walk_up_find(*patterns: str) -> Path | None:
    """Walk up from cwd looking for any of the given filenames. Return the dir containing the first match."""
    cwd = Path.cwd()
    for d in [cwd, *cwd.parents]:
        for p in patterns:
            if (d / p).is_file():
                return d
    return None


def _detect_wrapper() -> str | None:
    """Detect an environment wrapper for the current directory. Returns the wrapper prefix or None."""
    # Already inside devbox shell?
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return None

    # devbox
    if shutil.which("devbox") and _walk_up_find("devbox.json"):
        return "devbox run --"

    # mise
    if shutil.which("mise") and _walk_up_find(".mise.toml", ".mise/config.toml"):
        return "mise exec --"

    # flox
    if shutil.which("flox") and _walk_up_find("flox.nix"):
        return "flox activate --"

    # direnv
    if shutil.which("direnv") and _walk_up_find(".envrc"):
        return "direnv export &&"

    # nix
    if shutil.which("nix"):
        nix_root = _walk_up_find("flake.nix", "shell.nix")
        if nix_root:
            if (nix_root / "flake.nix").is_file():
                return "nix develop --command"
            return "nix-shell --run"

    return None


def _get_repo_root() -> Path | None:
    """Get git repo root if available."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, check=True,
        )
        return Path(result.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def _search_dirs() -> list[Path]:
    """Build the list of directories to search, tech-stack-aware."""
    home = Path.home()
    dirs: list[Path] = []

    # Universal user-local and system dirs
    xdg_bin = os.environ.get("XDG_BIN_HOME")
    if xdg_bin:
        dirs.append(Path(xdg_bin))
    dirs.extend([
        home / ".local/bin",
        home / ".nix-profile/bin",
        Path("/nix/var/nix/profiles/default/bin"),
        home / "bin",
        Path("/usr/local/bin"),
        Path("/usr/local/sbin"),
        Path("/usr/sbin"),
        Path("/usr/bin"),
        Path("/sbin"),
        Path("/bin"),
    ])
    # Homebrew: only check the prefix for the current arch.
    # A Time Machine restore across arches can leave a stale directory
    # with non-universal binaries that won't run.
    import platform
    arch = platform.machine()
    if arch == "arm64":
        dirs.extend([Path("/opt/homebrew/bin"), Path("/opt/homebrew/sbin")])
    elif arch in ("x86_64", "i386"):
        dirs.extend([Path("/usr/local/bin"), Path("/usr/local/sbin")])
    # MacPorts (both arches use /opt/local)
    dirs.append(Path("/opt/local/bin"))
    dirs.extend([Path("/snap/bin"), Path("/run/current-system/sw/bin")])

    # Language/runtime-specific dirs
    dirs.extend([
        home / ".cargo/bin",
        home / ".bun/bin",
        home / ".deno/bin",
        home / ".volta/bin",
        home / "go/bin",
        home / ".rbenv/shims",
        home / ".pyenv/shims",
        home / ".pixi/bin",
        home / ".krew/bin",
        home / ".foundry/bin",
    ])

    # nvm: all installed versions
    nvm_node = home / ".nvm/versions/node"
    if nvm_node.is_dir():
        for v in nvm_node.iterdir():
            b = v / "bin"
            if b.is_dir():
                dirs.append(b)

    # mise/rtx managed tool installs
    for base in [home / ".local/share/mise/installs", home / ".local/share/rtx/installs"]:
        if base.is_dir():
            for inst in base.iterdir():
                b = inst / "bin"
                if b.is_dir():
                    dirs.append(b)

    # Tech-stack-specific repo-local dirs
    repo = _get_repo_root()
    if repo:
        if (repo / "package.json").is_file():
            dirs.extend([repo / "node_modules/.bin", repo / ".bin"])
        if (repo / "Cargo.toml").is_file():
            dirs.extend([repo / "target/release", repo / "target/debug"])
        if (repo / "go.mod").is_file():
            dirs.extend([repo / "bin", repo / ".bin"])
        if (repo / "pyproject.toml").is_file() or (repo / "requirements.txt").is_file():
            dirs.extend([repo / ".venv/bin", repo / ".local/bin"])
        if (repo / "Gemfile").is_file():
            dirs.extend([repo / "bin", repo / ".bundle/bin"])
        if (repo / "composer.json").is_file():
            dirs.append(repo / "vendor/bin")
        dirs.extend([repo / "bin", repo / "scripts", repo / ".local/bin"])

    return dirs


def resolve_tool(tool: str) -> dict:
    """Resolve a CLI tool. Returns a dict with 'status' and 'path' or 'wrapper'.

    Return values:
        {"status": "found", "path": "/usr/local/bin/go"}
        {"status": "wrapper", "wrapper": "devbox run --"}
        {"status": "not_found"}
    """
    # 1. Already on PATH?
    path = shutil.which(tool)
    if path:
        return {"status": "found", "path": path}

    # 2. Environment wrapper
    wrapper = _detect_wrapper()
    if wrapper:
        return {"status": "wrapper", "wrapper": wrapper}

    # 3. Standard PATH locations
    for d in _search_dirs():
        candidate = d / tool
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return {"status": "found", "path": str(candidate)}

    # 4. Package manager lookup
    if shutil.which("brew"):
        try:
            subprocess.run(["brew", "list", tool], capture_output=True, check=True)
            prefix = subprocess.run(
                ["brew", "--prefix", tool], capture_output=True, text=True
            ).stdout.strip()
            if prefix:
                p = Path(prefix) / "bin" / tool
                if p.is_file() and os.access(p, os.X_OK):
                    return {"status": "found", "path": str(p)}
            brew_prefix = subprocess.run(
                ["brew", "--prefix"], capture_output=True, text=True
            ).stdout.strip()
            p = Path(brew_prefix) / "bin" / tool
            if p.is_file() and os.access(p, os.X_OK):
                return {"status": "found", "path": str(p)}
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass

    if shutil.which("mise"):
        try:
            result = subprocess.run(
                ["mise", "which", tool], capture_output=True, text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except FileNotFoundError:
            pass

    if shutil.which("asdf"):
        try:
            result = subprocess.run(
                ["asdf", "which", tool], capture_output=True, text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except FileNotFoundError:
            pass

    return {"status": "not_found"}


def run_tool(tool: str, args: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Resolve a tool and run it. If a wrapper is detected, runs through the wrapper.

    Uses subprocess.run (captures output only if kwargs request it).
    For exec (replace process), use run_tool_exec instead.
    """
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        return subprocess.run([result["path"], *args], **kwargs)
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            return subprocess.run(["devbox", "run", "--", tool, *args], **kwargs)
        elif wrapper == "mise exec --":
            return subprocess.run(["mise", "exec", "--", tool, *args], **kwargs)
        elif wrapper == "flox activate --":
            return subprocess.run(["flox", "activate", "--", tool, *args], **kwargs)
        elif wrapper == "direnv export &&":
            # direnv needs eval — fall back to running direnv export then the tool
            export = subprocess.run(
                ["direnv", "export", "bash"], capture_output=True, text=True
            )
            # Can't easily eval in Python; just run the tool and hope PATH is set
            return subprocess.run([tool, *args], **kwargs)
        elif wrapper == "nix develop --command":
            return subprocess.run(["nix", "develop", "--command", tool, *args], **kwargs)
        elif wrapper == "nix-shell --run":
            return subprocess.run(
                ["nix-shell", "--run", " ".join([tool, *args])], **kwargs
            )
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


def run_tool_exec(tool: str, args: list[str]) -> None:
    """Resolve a tool and exec it (replaces the current process). Never returns."""
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        os.execv(result["path"], [tool, *args])
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            os.execvp("devbox", ["devbox", "run", "--", tool, *args])
        elif wrapper == "mise exec --":
            os.execvp("mise", ["mise", "exec", "--", tool, *args])
        elif wrapper == "flox activate --":
            os.execvp("flox", ["flox", "activate", "--", tool, *args])
        elif wrapper == "direnv export &&":
            os.execvp(tool, [tool, *args])
        elif wrapper == "nix develop --command":
            os.execvp("nix", ["nix", "develop", "--command", tool, *args])
        elif wrapper == "nix-shell --run":
            os.execvp("nix-shell", ["nix-shell", "--run", " ".join([tool, *args])])
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


# --- Convenience wrappers (backward-compatible with old devbox_run/rtk_wrap) ---

def is_devbox_available() -> bool:
    """Backward compat: check if devbox wrapper would be used."""
    r = resolve_tool("devbox")
    # Actually check if devbox wrapper is active for this dir
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return _walk_up_find("devbox.json") is not None


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


def is_rtk_available() -> bool:
    """Backward compat: check if rtk is available."""
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through rtk if available, otherwise through devbox/direct."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)



def format_context(context):
    """Format the context dictionary into markdown"""
    md = "# Conversation Context Handoff\n\n"
    
    # Add tkr reference if present
    if context.get('tkr_ticket'):
        md += "## Ticket Reference\n"
        md += f"- **Ticket ID**: {context['tkr_ticket']}\n"
        if context.get('tkr_parent'):
            md += f"- **Parent Ticket**: {context['tkr_parent']}\n"
        md += "\n"
    
    # Metadata
    md += "## Metadata\n"
    md += f"- **Created**: {context['created']}\n"
    if context.get('session_duration'):
        md += f"- **Session Duration**: {context['session_duration']}\n"
    md += f"- **Primary Goal**: {context['primary_goal']}\n\n"
    
    # Project Overview
    md += "## Project Overview\n"
    md += "### Objective\n"
    md += f"{context['objective']}\n\n"
    md += "### Current Status\n"
    md += f"{context['current_status']}\n\n"
    
    # Key Decisions
    if context.get('key_decisions'):
        md += "## Key Decisions Made\n"
        for decision in context['key_decisions']:
            md += f"- {decision['decision']} - {decision['reason']}\n"
        md += "\n"
    
    # Technical Context
    if context.get('technical_stack') or context.get('important_files'):
        md += "## Technical Context\n"
        if context.get('technical_stack'):
            md += "### Stack/Tools\n"
            for tool in context['technical_stack']:
                md += f"- {tool}\n"
            md += "\n"
        if context.get('important_files'):
            md += "### Important Files\n"
            for file_info in context['important_files']:
                md += f"- `{file_info['path']}` - {file_info['purpose']}\n"
            md += "\n"
        if context.get('environment_notes'):
            md += "### Environment Notes\n"
            md += f"{context['environment_notes']}\n\n"
    
    # Next Steps
    if context.get('next_steps'):
        md += "## Next Steps (Priority Order)\n"
        for i, step in enumerate(context['next_steps'], 1):
            md += f"{i}. {step}\n"
        md += "\n"
    
    # Success Criteria
    if context.get('success_criteria'):
        md += "## Success Criteria\n"
        for criterion in context['success_criteria']:
            md += f"- {criterion['criterion']}: {criterion['verification']}\n"
        md += "\n"
    
    # Open Questions
    if context.get('open_questions'):
        md += "## Open Questions/Blockers\n"
        for question in context['open_questions']:
            md += f"- {question['question']} - {question['impact']}\n"
        md += "\n"
    
    # Important Context
    if context.get('important_context'):
        md += "## Important Context\n"
        md += f"{context['important_context']}\n\n"
    
    # Conversation Summary
    if context.get('conversation_summary'):
        md += "## Conversation Summary\n"
        md += f"{context['conversation_summary']}\n\n"
    
    # Do Not
    if context.get('do_not'):
        md += "## Do Not\n"
        for dont in context['do_not']:
            md += f"- {dont}\n"
        md += "\n"
    
    return md


def check_tkr_available():
    """Check if tkr is available and we're in a project with tickets"""
    # Check if .tickets directory exists
    if not os.path.exists('.tickets'):
        return False, "No .tickets directory found"

    # Check if tkr command is available via tool discovery
    result = resolve_tool("tkr")
    if result["status"] == "not_found":
        return False, "tkr command not found"

    return True, "tkr available"


def create_tkr_ticket(context, parent_ticket=None):
    """Create a tkr ticket for continuation"""
    try:
        # Prepare ticket title
        title = f"Continue work: {context['primary_goal']}"
        
        # Build tkr command
        cmd = ['tkr', 'create', title]
        
        # Add description
        if context.get('objective'):
            cmd.extend(['-d', context['objective'][:200] + '...' if len(context['objective']) > 200 else context['objective']])
        
        # Add parent if specified
        if parent_ticket:
            cmd.extend(['--parent', parent_ticket])
        
        # Set type to task
        cmd.extend(['-t', 'task'])
        
        # Execute command
        result = run_tool("tkr", cmd[1:], capture_output=True, text=True)
        
        if result.returncode == 0:
            ticket_id = result.stdout.strip()
            return ticket_id, None
        else:
            return None, result.stderr
            
    except Exception as e:
        return None, str(e)


def capture_interactive():
    """Interactive context capture"""
    print("=== Conversation Context Capture ===\n")
    
    # Check tkr availability
    tkr_available, tkr_status = check_tkr_available()
    if tkr_available:
        print("✓ tkr-enabled project detected")
        use_tkr = input("Create continuation ticket? (Y/n): ").lower() != 'n'
    else:
        print(f"ℹ {tkr_status}")
        use_tkr = False
    
    context = {
        'created': datetime.now().isoformat(),
        'primary_goal': input("Primary goal (one sentence): "),
        'objective': input("Detailed objective: "),
        'current_status': input("Current status/progress: "),
    }
    
    # Check for parent ticket if using tkr
    parent_ticket = None
    if use_tkr:
        parent = input("Parent ticket ID (optional): ").strip()
        if parent:
            parent_ticket = parent
            context['tkr_parent'] = parent
    
    # Optional session duration
    duration = input("Session duration (optional, e.g., '2 hours'): ")
    if duration:
        context['session_duration'] = duration
    
    # Key decisions
    print("\nKey decisions made (press Enter when done):")
    context['key_decisions'] = []
    while True:
        decision = input("Decision: ")
        if not decision:
            break
        reason = input("Reason/Brief context: ")
        context['key_decisions'].append({
            'decision': decision,
            'reason': reason
        })
    
    # Technical stack
    print("\nTechnical stack (press Enter when done):")
    context['technical_stack'] = []
    while True:
        tool = input("Tool/Technology: ")
        if not tool:
            break
        context['technical_stack'].append(tool)
    
    # Important files
    print("\nImportant files (press Enter when done):")
    context['important_files'] = []
    while True:
        path = input("File path: ")
        if not path:
            break
        purpose = input("Purpose: ")
        context['important_files'].append({
            'path': path,
            'purpose': purpose
        })
    
    # Environment notes
    env_notes = input("\nEnvironment notes (optional): ")
    if env_notes:
        context['environment_notes'] = env_notes
    
    # Next steps
    print("\nNext steps (press Enter when done):")
    context['next_steps'] = []
    while True:
        step = input("Next step: ")
        if not step:
            break
        context['next_steps'].append(step)
    
    # Success criteria
    print("\nSuccess criteria (press Enter when done):")
    context['success_criteria'] = []
    while True:
        criterion = input("Criteria: ")
        if not criterion:
            break
        verification = input("How to verify: ")
        context['success_criteria'].append({
            'criterion': criterion,
            'verification': verification
        })
    
    # Open questions
    print("\nOpen questions/blockers (press Enter when done):")
    context['open_questions'] = []
    while True:
        question = input("Question: ")
        if not question:
            break
        impact = input("Impact if unresolved: ")
        context['open_questions'].append({
            'question': question,
            'impact': impact
        })
    
    # Important context
    important = input("\nAny other important context? ")
    if important:
        context['important_context'] = important
    
    # Conversation summary
    summary = input("\nBrief conversation summary: ")
    if summary:
        context['conversation_summary'] = summary
    
    # Do not
    print("\nThings to avoid (press Enter when done):")
    context['do_not'] = []
    while True:
        dont = input("Don't: ")
        if not dont:
            break
        context['do_not'].append(dont)
    
    # Create tkr ticket if requested
    if use_tkr:
        ticket_id, error = create_tkr_ticket(context, parent_ticket)
        if ticket_id:
            context['tkr_ticket'] = ticket_id
            print(f"\n✅ Created continuation ticket: {ticket_id}")
        else:
            print(f"\n❌ Failed to create ticket: {error}")
    
    return context


def save_context(context, output_path=None):
    """Save context to file"""
    if not output_path:
        timestamp = datetime.now().strftime('%Y-%m-%d-%H%M')
        output_path = f"context-{timestamp}.md"
    
    # Ensure .md extension
    if not output_path.endswith('.md'):
        output_path += '.md'
    
    with open(output_path, 'w') as f:
        f.write(format_context(context))
    
    return output_path


def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help']:
        print("Usage: capture_context.py [options] [output_file]")
        print("Options:")
        print("  --no-tkr    Skip tkr ticket creation")
        print("  --parent ID Specify parent ticket ID")
        print("  output_file Optional path for the context file")
        return
    
    # Parse options
    no_tkr = '--no-tkr' in sys.argv
    parent_id = None
    output_path = None
    
    # Extract arguments
    args = [arg for arg in sys.argv[1:] if not arg.startswith('--')]
    if args:
        output_path = args[0]
    
    if '--parent' in sys.argv:
        idx = sys.argv.index('--parent')
        if idx + 1 < len(sys.argv):
            parent_id = sys.argv[idx + 1]
    
    try:
        context = capture_interactive()
        saved_path = save_context(context, output_path)
        print(f"\n✅ Context saved to: {saved_path}")
        
        if context.get('tkr_ticket'):
            print(f"🎫 Ticket: {context['tkr_ticket']}")
            print(f"   To continue work: tkr start {context['tkr_ticket']}")
            
    except KeyboardInterrupt:
        print("\n\n❌ Context capture cancelled")
    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == "__main__":
    main()
