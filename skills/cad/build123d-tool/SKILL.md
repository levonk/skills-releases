---
name: build123d-tool
description: Core build123d CAD tool setup and Python environment for 3D modeling. Provides the foundation for architectural modeling and furniture planning. Use when setting up 3D CAD capabilities, configuring build123d environments, writing build123d Python code (algebraic or builder mode), exporting models to STL/STEP/3MF/BREP, visualizing parts with OCP VSCode, handling geometry validation errors, optimizing boolean operation performance, or when other skills need build123d functionality — even if the user only mentions "CAD setup" or "build123d environment."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-02-02"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "computer-aided-design", "3d-modeling", "cad", "python", "build123d"]
dependencies:
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
  - type: python
    name: build123d
    url: https://github.com/gumyr/build123d
  - type: python
    name: ocp_vscode
    url: https://github.com/gumyr/ocp_vscode
  - type: python
    name: numpy
    url: https://numpy.org/
  - type: url
    name: Build123D Documentation
    url: https://build123d.readthedocs.io/
see-also:
  - skill: 3d-modeling
    relationship: dependent
    description: "Architectural 3D modeling skill that depends on this skill for core CAD functionality"
  - skill: room-planner
    relationship: dependent
    description: "Furniture layout and move planning skill that depends on this skill for core CAD functionality"
  - skill: project-adopter
    relationship: integration
    description: "Standard developer UX workflow integration for devbox/justfile/direnv setup"
  - skill: base-ai-guidance
    relationship: base-framework
    description: "Base AI guidance and content principles for all AI skills"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Build123D Tool

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

## Instructions

## Integration with Project Adopter

This skill integrates with the **project-adopter** skill for standard development workflow:

### Detection and Setup

The project-adopter skill will:

1. **Detect Python/CAD project type** automatically
2. **Configure devbox.json** with build123d packages
3. **Create justfile** with CAD-specific targets
4. **Set up .envrc** for direnv integration

### Usage with Project Adopter

```bash
# 1. Initialize project with project-adopter skill
# (This detects Python/CAD and sets up standard UX)

# 2. Bootstrap environment
just bootstrap

# 3. Start development
just dev

# 4. View models
just view-model

# 5. Export models
just export-model
```

### Project Adopter Integration Points

This skill provides specific configurations for project-adopter, including devbox.json packages, justfile targets, and pyproject.toml dependencies.

→ See [references/build123d-patterns.md](references/build123d-patterns.md) — Project Adopter Integration Configs for the full JSON, justfile, and TOML configuration snippets, plus shared geometry utility scripts.

### Core build123d Patterns

#### 1. Algebraic Mode (Stateless)

Preferred for simple, explicit geometry construction using operators (`+`, `-`, `*`) to combine and transform shapes.

#### 2. Builder Mode (Stateful)

Preferred for complex, hierarchical constructions using `BuildPart` context managers with `Mode.ADD` and `Mode.SUBTRACT`.

#### 3. Location and Transformation System

Positioning objects with `Pos`, `Rot`, `GridLocations`, and `PolarLocations` for array layouts.

→ See [references/build123d-patterns.md](references/build123d-patterns.md) for full implementations of algebraic mode, builder mode, location/transformation system, basic geometric primitives, boolean operations, fillets/chamfers, and example layouts.

### Visualization and Export

#### Interactive Viewing with OCP VSCode

Display parts in VSCode with `show_object` and `show`, including configurable display options (alpha, color).

#### Export Formats

Export models to STL (3D printing), STEP (CAD interchange), 3MF (Microsoft 3D), and BREP (OpenCascade native).

→ See [references/visualization-export.md](references/visualization-export.md) for full visualization and export code patterns.

### Common Modeling Operations

Basic geometric primitives (1D lines/curves, 2D faces/sketches, 3D solids), boolean operations (union, difference, intersection), and fillets/chamfers with selective edge treatment.

→ See [references/build123d-patterns.md](references/build123d-patterns.md) for full implementations of geometric primitives, boolean operations, and fillets/chamfers.

### Error Handling and Validation

#### Common Error Patterns

Geometry validation with `is_null()` and `is_valid()` checks, plus try/except fallback patterns for invalid geometry.

#### Performance Optimization

Batch operations with `GridLocations`, grouping similar operations, and avoiding multiple sequential boolean operations in favor of single compound operations.

→ See [references/error-handling.md](references/error-handling.md) for full error handling, geometry validation, and performance optimization code patterns.

### Integration with Other Skills

This skill provides the foundation for:

- **3d-modeling skill**: Architectural elements (rooms, cabinets, closets)
- **room-planner skill**: Furniture layout and move planning
- **Custom manufacturing**: 3D printing and CNC preparation

## Examples

### Basic Room Layout and Parametric Cabinet

→ See [references/build123d-patterns.md](references/build123d-patterns.md) — Example: Basic Room Layout and Example: Parametric Cabinet for complete working examples.

## Quality Checklist

- [ ] Python environment configured with build123d
- [ ] OCP VSCode viewer working
- [ ] Export formats tested (STL, STEP, 3MF)
- [ ] Basic geometric primitives functional
- [ ] Boolean operations tested
- [ ] Transformation system understood
- [ ] Error handling implemented
- [ ] Performance patterns applied
- [ ] Integration scripts created
- [ ] Documentation examples verified

## References

- [Project Adopter Skill](../software-dev/project-adopter/SKILL.md) - Standard developer UX workflow
- [build123d Documentation](https://build123d.readthedocs.io/) - Core CAD functionality
- [Open Cascade Technology](https://dev.opencascade.org/) - Geometric kernel
- [OCP VSCode Viewer](https://github.com/bernhard-42/ocp_vscode) - 3D visualization
- [Standard Developer UX Flow ADR](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md)

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/cad/build123d-tool/SKILL.md`
- References: `config/ai/skills/cad/build123d-tool/references/`
  - `references/build123d-patterns.md` — Algebraic/builder modes, transformations, primitives, booleans, fillets, examples, project adopter configs
  - `references/visualization-export.md` — OCP VSCode viewing and STL/STEP/3MF/BREP export
  - `references/error-handling.md` — Geometry validation, error patterns, performance optimization
- Scripts: `scripts/export_model.py`, `scripts/setup_build123d.py`, `scripts/view_model.py`
- Includes: `config/ai/skills/includes/`

### Related Skills
- `3d-modeling` (dependent) — Architectural 3D modeling that depends on this skill
- `room-planner` (dependent) — Furniture layout and move planning that depends on this skill
- `project-adopter` (integration) — Standard developer UX workflow integration
- `base-ai-guidance` (base-framework) — Base AI guidance and content principles

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
