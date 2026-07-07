#!/usr/bin/env python3
"""
Package a skill into a distributable .skill file (zip archive).

Usage:
    python package_skill.py <path/to/skill-folder>
    python package_skill.py <path/to/skill-folder> ./dist

Example:
    python package_skill.py ./skills/pdf-rotator
    python package_skill.py ./skills/pdf-rotator ./dist
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import zipfile
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


def validate_skill(skill_path: Path) -> list[str]:
    """Validate the skill structure and return list of errors."""
    errors = []

    # Check if skill directory exists
    if not skill_path.exists():
        errors.append(f"Skill directory does not exist: {skill_path}")
        return errors

    # Check for SKILL.md
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        errors.append("SKILL.md is required")
        return errors

    # Validate SKILL.md frontmatter
    try:
        with open(skill_md, "r") as f:
            content = f.read()

        # Check for YAML frontmatter
        if not content.startswith("---"):
            errors.append("SKILL.md must start with YAML frontmatter (---)")
            return errors

        # Extract frontmatter
        frontmatter_end = content.find("---", 3)
        if frontmatter_end == -1:
            errors.append("SKILL.md frontmatter must be closed with ---")
            return errors

        frontmatter = content[3:frontmatter_end]

        # Try to parse as YAML (basic check)
        try:
            import yaml
            metadata = yaml.safe_load(frontmatter)
        except ImportError:
            # If yaml not available, do basic checks
            if "name:" not in frontmatter:
                errors.append("SKILL.md frontmatter must contain 'name' field")
            if "description:" not in frontmatter:
                errors.append("SKILL.md frontmatter must contain 'description' field")
        else:
            if "name" not in metadata:
                errors.append("SKILL.md frontmatter must contain 'name' field")
            if "description" not in metadata:
                errors.append("SKILL.md frontmatter must contain 'description' field")
            if not metadata.get("description"):
                errors.append("SKILL.md description cannot be empty")

            # Check description quality
            description = metadata.get("description", "")
            if len(description) < 50:
                errors.append("SKILL.md description should be more descriptive (at least 50 characters)")

            # Check for date fields
            if "date" in metadata:
                date = metadata["date"]
                if "created" not in date:
                    errors.append("SKILL.md date.created field is required")
                if "last-used" not in date:
                    errors.append("SKILL.md date.last-used field is required")
    except Exception as e:
        errors.append(f"Error reading SKILL.md: {e}")
        return errors

    # Check for forbidden files
    forbidden_files = ["README.md", "INSTALLATION_GUIDE.md", "QUICK_REFERENCE.md", "CHANGELOG.md"]
    for forbidden in forbidden_files:
        if (skill_path / forbidden).exists():
            errors.append(f"Forbidden file found: {forbidden}. Skills should not include extraneous documentation.")

    # Check for proper directories
    for dir_name in ["scripts", "references", "assets", "evals"]:
        dir_path = skill_path / dir_name
        if dir_path.exists() and not dir_path.is_dir():
            errors.append(f"{dir_name} exists but is not a directory")

    return errors


def package_skill(skill_path: Path, output_dir: Path) -> str:
    """Package the skill into a .skill file."""
    skill_name = skill_path.name

    # Validate first
    errors = validate_skill(skill_path)
    if errors:
        print("Validation failed:")
        for error in errors:
            print(f"  ✗ {error}")
        sys.exit(1)

    print("✓ Validation passed")

    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)

    # Create zip file
    output_file = output_dir / f"{skill_name}.skill"

    with zipfile.ZipFile(output_file, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(skill_path):
            # Skip __pycache__ and .git
            dirs[:] = [d for d in dirs if d not in ["__pycache__", ".git", "*-workspace"]]

            for file in files:
                file_path = Path(root) / file
                # Skip workspace and skill files
                if "*-workspace" in str(file_path) or file.endswith(".skill"):
                    continue

                arcname = file_path.relative_to(skill_path.parent)
                zipf.write(file_path, arcname)

    file_size = output_file.stat().st_size
    print(f"✓ Skill packaged: {output_file}")
    print(f"  Size: {file_size:,} bytes")

    return str(output_file)


def main():
    parser = argparse.ArgumentParser(description="Package a skill into a distributable .skill file")
    parser.add_argument("skill_path", help="Path to the skill directory")
    parser.add_argument("output_dir", nargs="?", default=".", help="Output directory for the .skill file (default: current directory)")

    args = parser.parse_args()

    skill_path = Path(args.skill_path).resolve()
    output_dir = Path(args.output_dir).resolve()

    package_skill(skill_path, output_dir)


if __name__ == "__main__":
    main()
