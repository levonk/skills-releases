#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Initialize a new skill with proper directory structure and template files.

Usage:
    uv run --script init_skill.py <skill-name> --path <output-directory>
    python init_skill.py <skill-name> --path <output-directory>

Examples:
    # Create in the skills-src repo (public profile)
    python init_skill.py pdf-rotator --path ~/p/gh/levonk/skills-src/src/current/skills/cad

    # Create in the skills-src repo (private profile)
    python init_skill.py internal-tool --path ~/p/gh/levonk/skills-src/src/private/skills/business

    # Create in the current project
    python init_skill.py project-skill --path ./.agents/skills/general

    # Create in the user directory
    python init_skill.py personal-skill --path ~/.agents/skills/general

The --path argument accepts nested paths; all parent directories are created
automatically. Tilde (~) is expanded to the user's home directory.
"""

import argparse
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


# ---------------------------------------------------------------------------
# Devbox detection — use `devbox run --` to execute commands when devbox
# is available and a devbox.json exists, unless already inside a devbox shell.
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    """Check if devbox is available and not already in a devbox shell."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK (Rust Token Killer) detection — use rtk as a proxy for git and other
# supported commands when available to reduce LLM token consumption by 60-90%.
# See: https://github.com/rtk-ai/rtk
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    """Check if rtk is available on the system."""
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Run a command through rtk if available, otherwise directly."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


def get_script_dir() -> Path:
    """Get the directory where this script is located."""
    return Path(__file__).parent.parent


def load_template(template_name: str) -> str:
    """Load a template file from the templates directory."""
    script_dir = get_script_dir()
    template_path = script_dir / "templates" / template_name

    if not template_path.exists():
        print(f"Error: Template file not found: {template_path}")
        sys.exit(1)

    with open(template_path, "r") as f:
        return f.read()


def create_skill_structure(skill_name: str, output_path: str) -> None:
    """Create the skill directory structure with template files.

    The output_path may be a nested path (e.g. a skills-src profile path like
    ``src/current/skills/<category>``). All parent directories are created
    automatically. Tilde (~) is expanded to the user's home directory.
    """
    # Expand ~ and resolve to an absolute path so nested skills-src paths work
    expanded_path = os.path.expanduser(output_path)
    output_dir = Path(expanded_path)
    skill_dir = output_dir / skill_name

    if skill_dir.exists():
        print(f"Error: Directory {skill_dir} already exists")
        sys.exit(1)

    # Create parent directories of the output path if they don't exist,
    # then the skill directory itself (parents=True handles both)
    os.makedirs(str(output_dir), exist_ok=True)
    skill_dir.mkdir(parents=True, exist_ok=True)
    (skill_dir / "scripts").mkdir(exist_ok=True)
    (skill_dir / "references").mkdir(exist_ok=True)
    (skill_dir / "assets").mkdir(exist_ok=True)
    (skill_dir / "evals").mkdir(exist_ok=True)

    # Load and render templates
    created_date = datetime.now().strftime('%Y-%m-%d')
    skill_title = skill_name.replace('-', ' ').title()

    # Create SKILL.md from template
    # Templates use Go text/template syntax: {{{ .variable | default "" }}}
    # We do simple string replacement since init_skill.py runs outside the render tool.
    skill_md_template = load_template("SKILL.md.template")
    skill_md_content = skill_md_template.replace("{{{ .skill_name | default \"\" }}}", skill_name)
    skill_md_content = skill_md_content.replace("{{{ .created_date | default \"\" }}}", created_date)
    skill_md_content = skill_md_content.replace("{{{ .skill_title | default \"\" }}}", skill_title)

    with open(skill_dir / "SKILL.md", "w") as f:
        f.write(skill_md_content)

    # Create example script from template
    example_script_template = load_template("example-script.py.template")
    with open(skill_dir / "scripts" / "example.py", "w") as f:
        f.write(example_script_template)

    # Create example reference from template
    example_reference_template = load_template("example-reference.md.template")
    with open(skill_dir / "references" / "example.md", "w") as f:
        f.write(example_reference_template)

    # Create evals template
    evals_template = load_template("evals.json.template")
    evals_content = evals_template.replace("{{{ .skill_name | default \"\" }}}", skill_name)
    with open(skill_dir / "evals" / "evals.json", "w") as f:
        f.write(evals_content)

    # Create .gitignore from template
    gitignore_template = load_template("gitignore.template")
    with open(skill_dir / ".gitignore", "w") as f:
        f.write(gitignore_template)

    print(f"✓ Skill created at: {skill_dir}")
    print(f"✓ Directory structure:")
    print(f"  - SKILL.md (main skill file)")
    print(f"  - scripts/ (executable code)")
    print(f"  - references/ (documentation)")
    print(f"  - assets/ (output resources)")
    print(f"  - evals/ (test cases)")
    print(f"\nNext steps:")
    print(f"1. Edit SKILL.md to add skill content")
    print(f"2. Add scripts/references/assets as needed")
    print(f"3. Delete example files you don't need")
    print(f"4. Test with evals/evals.json")
    print(f"5. Package with: devbox run -- python scripts/package_skill.py {skill_dir}")
    print(f"   (or: python scripts/package_skill.py {skill_dir} if devbox is unavailable)")


def main():
    parser = argparse.ArgumentParser(description="Initialize a new skill")
    parser.add_argument("skill_name", help="Name of the skill (use kebab-case)")
    parser.add_argument("--path", default=".", help="Output directory for the skill")

    args = parser.parse_args()

    # Validate skill name
    if not args.skill_name.replace("-", "").isalnum():
        print("Error: Skill name should use kebab-case (letters, numbers, hyphens only)")
        sys.exit(1)

    create_skill_structure(args.skill_name, args.path)


if __name__ == "__main__":
    main()
