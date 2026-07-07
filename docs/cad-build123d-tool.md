<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Build123D Tool

> Category: **cad** · Status: ready · Version: 1.0.0

Core build123d CAD tool setup and Python environment for 3D modeling. Provides the foundation for architectural modeling and furniture planning. Use when setting up 3D CAD capabilities, configuring build123d environments, writing build123d Python code (algebraic or builder mode), exporting models to STL/STEP/3MF/BREP, visualizing parts with OCP VSCode, handling geometry validation errors, optimizing boolean operation performance, or when other skills need build123d functionality — even if the user only mentions "CAD setup" or "build123d environment.

## Metadata

| Field | Value |
|-------|-------|
| Name | `build123d-tool` |
| Category | `cad` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `computer-aided-design`
- `3d-modeling`
- `cad`
- `python`
- `build123d`

## Quick Start

Setting up build123d for 3D modeling:

```python
# Basic usage example
from build123d import *
from ocp_vscode import show_object

# Create a simple box
with BuildPart() as part:
    Box(10, 10, 10)

# Export for visualization
show_object(part.part)
```

## Examples

### Basic Room Layout and Parametric Cabinet

→ See [references/build123d-patterns.md](references/build123d-patterns.md) — Example: Basic Room Layout and Example: Parametric Cabinet for complete working examples.

## References

- [Project Adopter Skill](../software-dev/project-adopter/SKILL.md) - Standard developer UX workflow
- [build123d Documentation](https://build123d.readthedocs.io/) - Core CAD functionality
- [Open Cascade Technology](https://dev.opencascade.org/) - Geometric kernel
- [OCP VSCode Viewer](https://github.com/bernhard-42/ocp_vscode) - 3D visualization
- [Standard Developer UX Flow ADR](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md)

## Related Skills
- **3d-modeling** (skill, dependent) — Architectural 3D modeling skill that depends on this skill for core CAD functionality
- **room-planner** (skill, dependent) — Furniture layout and move planning skill that depends on this skill for core CAD functionality
- **project-adopter** (skill, integration) — Standard developer UX workflow integration for devbox/justfile/direnv setup
- **base-ai-guidance** (skill, base-framework) — Base AI guidance and content principles for all AI skills

---

- **Full skill**: [`skills/cad/build123d-tool/SKILL.md`](skills/cad/build123d-tool/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-07T22:59:26Z
