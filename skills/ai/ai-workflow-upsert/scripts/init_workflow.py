#!/usr/bin/env python3
"""
Initialize a new workflow with the Template/Wrapper file pair.

Creates:
  1. <output-dir>/<category>/<name>.md.tmpl          # wrapper: frontmatter + includeTemplate
  2. <templates-root>/<category>/<name>-template.md  # content template (no frontmatter)

Usage:
    python init_workflow.py <workflow-name> --path <output-directory> [--category <category>] [--templates-root <dir>]

Example:
    python init_workflow.py ai-agent-create --path ./config/ai/workflows --category ai --templates-root ./config/ai/templates
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
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK (Rust Token Killer) detection — use rtk as a proxy for git and other
# supported commands when available to reduce LLM token consumption by 60-90%.
# See: https://github.com/rtk-ai/rtk
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


def create_workflow_structure(
    workflow_name: str,
    output_path: str,
    category: str,
    templates_root: str,
) -> None:
    """Create the workflow wrapper + content template with TODO placeholders."""
    created_date = datetime.now().strftime("%Y-%m-%d")
    workflow_title = workflow_name.replace("-", " ").title()
    slug = workflow_name

    # 1. Wrapper file: <output>/<category>/<name>.md.tmpl
    wrapper_dir = Path(output_path) / category
    wrapper_dir.mkdir(parents=True, exist_ok=True)
    wrapper_path = wrapper_dir / f"{workflow_name}.md.tmpl"

    if wrapper_path.exists():
        print(f"Error: Wrapper already exists: {wrapper_path}")
        sys.exit(1)

    # Build the includeTemplate line separately.  Chezmoi processes this .py
    # file as a template (it lives in .chezmoitemplates/), so double-braces
    # must be escaped via the {{{ "{{" }}} and {{{ "}}" }}} patterns to produce
    # literal braces in the output Python source.  See init_skill.py in
    # ai-skill-upsert for the same pattern.  The {category} substitution is
    # done with string concatenation rather than an f-string so the chezmoi
    # escapes survive intact.
    include_line = (
        '{{{ "{{" }}} include "workflows/'
        + category
        + '/includes/base-workflow-guidance.md" . {{{ "}}" }}}'
    )

    wrapper_content = f"""---
workflow: "{workflow_title}"
slug: "{slug}"
description: "[TODO: What this workflow does]"
use: "[TODO: When to invoke this workflow]"
date:
  created: "{created_date}"
  updated: "{created_date}"
  last-used: "{created_date}"
tags:
  - "ai/workflow/{category}/{slug}"
see-also:
  - template: "base-workflow-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
---

---

{include_line}

# {workflow_title}

[TODO: One-line description of the workflow.]

## Operation

1. **Initialize**: [TODO: Define purpose and scope]
2. **Plan**: [TODO: Map steps and dependencies]
3. **Apply**: [TODO: Implement the steps]
4. **Verify**: [TODO: Validate step sequencing]
5. **Deliver**: [TODO: Save to internal-docs/workflows/]

---
## Context Declaration

### File Paths
- Main workflow: `config/ai/workflows/{category}/{workflow_name}.md.tmpl`
- Content template: `config/ai/templates/{category}/{workflow_name}-template.md`
- Output directory: `internal-docs/workflows/`

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
"""
    wrapper_path.write_text(wrapper_content)

    # 2. Content template: <templates-root>/<category>/<name>-template.md
    template_dir = Path(templates_root) / category
    template_dir.mkdir(parents=True, exist_ok=True)
    template_path = template_dir / f"{workflow_name}-template.md"

    if template_path.exists():
        print(f"Warning: Content template already exists: {template_path} (leaving as-is)")
    else:
        template_content = f"""# {workflow_title} — Content Template

[TODO: Workflow content goes here. This template is included by the wrapper via includeTemplate.]

## Steps

[TODO: Define the workflow steps.]
"""
        template_path.write_text(template_content)

    print(f"✓ Workflow wrapper created: {wrapper_path}")
    if not template_path.exists():
        print(f"✓ Content template exists (left as-is): {template_path}")
    else:
        print(f"✓ Content template created: {template_path}")
    print(f"\nNext steps:")
    print(f"1. Edit the wrapper frontmatter (description, use, tags)")
    print(f"2. Edit the content template with the workflow steps")
    print(f"3. Validate: chezmoi execute-template < {wrapper_path}")
    print(f"4. Update date.last-used on each use (YYYY-MM-DD)")


def main():
    parser = argparse.ArgumentParser(description="Initialize a new workflow (Template/Wrapper pattern)")
    parser.add_argument("workflow_name", help="Name of the workflow (kebab-case)")
    parser.add_argument("--path", default="config/ai/workflows", help="Output directory for workflow wrappers")
    parser.add_argument("--category", default="ai", help="Category subdirectory (e.g., ai, business, cad)")
    parser.add_argument("--templates-root", default="config/ai/templates", help="Root directory for content templates")

    args = parser.parse_args()

    if not args.workflow_name.replace("-", "").isalnum():
        print("Error: Workflow name should use kebab-case (letters, numbers, hyphens only)")
        sys.exit(1)

    create_workflow_structure(args.workflow_name, args.path, args.category, args.templates_root)


if __name__ == "__main__":
    main()
