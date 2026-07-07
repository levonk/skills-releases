<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# 3D Modeling

> Category: **cad** · Status: ready · Version: 1.0.0

Architectural 3D modeling skill for rooms, cabinets, closets, and building elements using build123d. Creates parametric architectural components for move planning and space design. Use when modeling rooms, designing kitchen cabinet runs, building closet storage systems, creating door/window openings, generating multi-room apartment layouts, or producing parametric architectural components for move planning and space design — even if the user only mentions "model a room" or "design cabinets.

## Metadata

| Field | Value |
|-------|-------|
| Name | `3d-modeling` |
| Category | `cad` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `computer-aided-design`
- `3d-modeling`
- `architectural-design`
- `build123d`
- `furniture-design`

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

## References

- [build123d-tool Skill](../build123d-tool/SKILL.md) - Core CAD functionality
- [Architectural Standards](https://www.nkba.org/guidelines) - Kitchen and bath standards
- [Building Codes](https://www.iccsafe.org/) - Standard building requirements
- [Cabinet Manufacturing Standards](https://www.awic.org/) - Industry specifications

## Related Skills
- **build123d-tool** (skill, dependency) — Core build123d CAD tool setup and Python environment — provides the foundation this skill builds on
- **room-planner** (skill, dependent) — Furniture layout and move planning skill that consumes architectural components produced here
- **base-ai-guidance** (skill, base-framework) — Base AI guidance and content principles for all AI skills

---

- **Full skill**: [`skills/cad/3d-modeling/SKILL.md`](skills/cad/3d-modeling/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-07T22:59:26Z
