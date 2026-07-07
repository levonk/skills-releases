---
name: 3d-modeling
description: Architectural 3D modeling skill for rooms, cabinets, closets, and building elements using build123d. Creates parametric architectural components for move planning and space design. Use when modeling rooms, designing kitchen cabinet runs, building closet storage systems, creating door/window openings, generating multi-room apartment layouts, or producing parametric architectural components for move planning and space design — even if the user only mentions "model a room" or "design cabinets."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-02-02"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "computer-aided-design", "3d-modeling", "architectural-design", "build123d", "furniture-design"]
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
  - type: skill
    name: build123d-tool
  - type: url
    name: OpenCascade Technology
    url: https://www.opencascade.com/
see-also:
  - skill: build123d-tool
    relationship: dependency
    description: "Core build123d CAD tool setup and Python environment — provides the foundation this skill builds on"
  - skill: room-planner
    relationship: dependent
    description: "Furniture layout and move planning skill that consumes architectural components produced here"
  - skill: base-ai-guidance
    relationship: base-framework
    description: "Base AI guidance and content principles for all AI skills"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# 3D Modeling

## Quick Start

Creating architectural models:

```python
from build123d import *

# Create a room with standard dimensions
room = create_room(length=5000, width=4000, height=2400, wall_thickness=100)

# Add kitchen cabinets
cabinets = create_kitchen_cabinets(length=2400, depth=600, height=720)

# Combine in assembly
with BuildPart() as layout:
    add(room)
    add(cabinets, location=Pos(0, 0, 0))
```

## Instructions

### Dependencies

This skill requires the **build123d-tool** skill for core CAD functionality:

```python
# Ensure build123d environment is loaded
from build123d import *
from ocp_vscode import show_object
```

### Core Architectural Components

#### 1. Room and Space Modeling

Create basic room structures with floors, walls, door openings, and window openings. Supports single rooms, rooms with openings, and multi-room apartment layouts.

→ See [references/room-modeling.md](references/room-modeling.md) for `create_room`, `create_room_with_opening`, `create_apartment_layout`, `create_interior_door`, and `create_window` implementations.

#### 2. Kitchen Cabinet Systems

Create standard base cabinets, wall cabinets, drawer cabinets, and full cabinet runs with countertops. All cabinets are parametric with configurable width, height, depth, and material thickness.

→ See [references/cabinet-systems.md](references/cabinet-systems.md) for `create_base_cabinet`, `create_base_cabinet_with_drawers`, `create_wall_cabinet`, `create_upper_cabinet_with_shelves`, and `create_kitchen_cabinet_run` implementations.

#### 3. Closet and Storage Systems

Create reach-in closets with shelving and hanging rods, and walk-in closets with perimeter shelving systems.

→ See [references/cabinet-systems.md](references/cabinet-systems.md) for `create_reach_in_closet` and `create_walk_in_closet` implementations.

#### 4. Door and Window Systems

Create standard interior doors with panel details and double-hung windows with frames and meeting rails.

→ See [references/room-modeling.md](references/room-modeling.md) for `create_interior_door` and `create_window` implementations.

#### 5. Material and Finish Systems

Define material properties (plywood, MDF, particleboard, solid oak) and apply finish types (laminate, wood grain, painted) to architectural components.

→ See [references/furniture-components.md](references/furniture-components.md) for the `Material` class, standard material definitions, and `apply_cabinet_finish` implementation.

#### 6. Standard Dimensions and Templates

Reference dictionaries for kitchen and closet standard dimensions (cabinet heights, depths, countertop thicknesses, toe kick sizes, hanging rod heights, etc.).

→ See [references/cabinet-systems.md](references/cabinet-systems.md) for `KITCHEN_STANDARDS` and `CLOSET_STANDARDS` dictionaries.

## Examples

### Complete Kitchen Layout

A full kitchen with room structure, cabinet runs, refrigerator space, and wall cabinets.

→ See [references/furniture-components.md](references/furniture-components.md) — Example: Complete Kitchen Layout for the `create_complete_kitchen` implementation.

### Master Bedroom Suite

A bedroom with attached walk-in closet and furniture placeholders.

→ See [references/furniture-components.md](references/furniture-components.md) — Example: Master Bedroom Suite for the `create_master_bedroom_suite` implementation.

## Quality Checklist

- [ ] Room dimensions follow architectural standards
- [ ] Cabinet systems use standard dimensions
- [ ] Material thicknesses are realistic
- [ ] Components are properly parametric
- [ ] Boolean operations are efficient
- [ ] Models are watertight for manufacturing
- [ ] Standard templates are documented
- [ ] Integration with build123d-tool confirmed
- [ ] Examples tested and verified
- [ ] Material properties defined

## References

- [build123d-tool Skill](../build123d-tool/SKILL.md) - Core CAD functionality
- [Architectural Standards](https://www.nkba.org/guidelines) - Kitchen and bath standards
- [Building Codes](https://www.iccsafe.org/) - Standard building requirements
- [Cabinet Manufacturing Standards](https://www.awic.org/) - Industry specifications

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/cad/3d-modeling/SKILL.md`
- References: `config/ai/skills/cad/3d-modeling/references/`
  - `references/room-modeling.md` — Room structures, multi-room layouts, doors, windows
  - `references/cabinet-systems.md` — Kitchen cabinets, closet systems, standard dimensions
  - `references/furniture-components.md` — Materials, finishes, complete layout examples
- Includes: `config/ai/skills/includes/`

### Related Skills
- `build123d-tool` (dependency) — Core CAD environment and build123d setup
- `room-planner` (dependent) — Furniture layout and move planning that consumes architectural components
- `base-ai-guidance` (base-framework) — Base AI guidance and content principles

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
