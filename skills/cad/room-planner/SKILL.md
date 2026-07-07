---
name: room-planner
description: Furniture layout and move planning skill using build123d. Optimizes room arrangements, creates furniture libraries, and generates move plans. Use when planning furniture placement, designing room layouts, optimizing furniture arrangements, generating move plans, creating furniture inventories, estimating furniture weights, planning move logistics, generating move checklists, or arranging living room/bedroom/office furniture — even if the user only mentions "plan a room" or "organize a move."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-02-02"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "computer-aided-design", "furniture-design", "layout", "move-planning", "build123d", "room-design"]
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
  - type: skill
    name: build123d-tool
  - type: skill
    name: 3d-modeling
  - type: url
    name: Furniture Standards
    url: https://www.ikea.com/
see-also:
  - skill: build123d-tool
    relationship: dependency
    description: "Core build123d CAD tool setup and Python environment — provides the foundation this skill builds on"
  - skill: 3d-modeling
    relationship: dependency
    description: "Architectural 3D modeling skill that provides room structures and architectural components used here"
  - skill: base-ai-guidance
    relationship: base-framework
    description: "Base AI guidance and content principles for all AI skills"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Room Planner

## Quick Start

Planning furniture layouts:

```python
from build123d import *

# Create a room layout
room = create_room(5000, 4000, 2400)

# Add furniture
layout = create_furniture_layout(room, [
    ("sofa", (1000, 2000), (500, 1000)),
    ("dining_table", (1600, 900), (2500, 2000)),
    ("bed", (2000, 1800), (1000, 3000))
])
```

## Instructions

### Dependencies

This skill requires:

- **build123d-tool** skill for core CAD functionality
- **3d-modeling** skill for architectural components

```python
from build123d import *
from ocp_vscode import show_object
```

### Furniture Library

#### Living Room and Office Furniture

Create sofas, armchairs, coffee tables, dining tables, office desks, and ergonomic office chairs. All furniture is parametric with configurable dimensions and style variants (straight legs, tapered legs, pedestal bases).

→ See [references/living-room-furniture.md](references/living-room-furniture.md) for `create_sofa`, `create_armchair`, `create_coffee_table`, `create_dining_table`, `create_desk`, and `create_office_chair` implementations.

#### Bedroom Furniture

Create beds with mattresses and headboards, nightstands with drawers, dressers with multiple drawers and pulls, and wardrobes with configurable compartments (hanging space, shelves, or mixed).

→ See [references/bedroom-furniture.md](references/bedroom-furniture.md) for `create_bed`, `create_nightstand`, `create_dresser`, and `create_wardrobe` implementations.

### Layout Planning System

#### Room Layout Generator

Place furniture items in a room with clearance checking. The `create_furniture_layout` function handles placement, and `create_furniture_item` is a factory that routes to the appropriate furniture creator.

#### Space Planning Algorithms

Optimize furniture placement using heuristic scoring (traffic flow, functional zones, aesthetics) with boundary and overlap validation.

→ See [references/layout-optimization.md](references/layout-optimization.md) for `create_furniture_layout`, `create_furniture_item`, `optimize_furniture_layout`, `is_valid_layout`, and `evaluate_layout` implementations.

### Move Planning System

#### Inventory Management

Create furniture inventories with weight estimation, fragility assessment, and disassembly requirements. Weight is estimated from volume and furniture-type-specific factors.

#### Move Logistics

Plan optimal move sequences (large/heavy items first, fragile items last) and generate comprehensive move checklists (disassembly, packing, protection, tools).

→ See [references/layout-optimization.md](references/layout-optimization.md) for `create_furniture_inventory`, `estimate_weight`, `assess_fragility`, `plan_move_sequence`, and `generate_move_checklist` implementations.

## Examples

### Living Room Layout

A complete living room with sofa, coffee table, armchair, TV stand, and bookshelf.

→ See [references/layout-optimization.md](references/layout-optimization.md) — Example: Living Room Layout for the `create_living_room_layout` implementation.

### Bedroom Move Plan

A complete move plan for a bedroom including inventory, move sequence, and checklist.

→ See [references/layout-optimization.md](references/layout-optimization.md) — Example: Bedroom Move Plan for the `plan_bedroom_move` implementation.

## Quality Checklist

- [ ] Furniture dimensions are realistic
- [ ] Standard clearances are maintained
- [ ] Layout optimization functions work
- [ ] Move planning algorithms are logical
- [ ] Inventory system is comprehensive
- [ ] Integration with CAD skills confirmed
- [ ] Examples tested and verified
- [ ] Material properties considered
- [ ] Ergonomic factors included
- [ ] Move logistics are practical

## References

- [build123d-tool Skill](../build123d-tool/SKILL.md) - Core CAD functionality
- [3d-modeling Skill](../3d-modeling/SKILL.md) - Architectural components
- [Ergonomic Standards](https://www.osha.gov/) - Workplace design guidelines
- [Moving Industry Standards](https://www.amsa.org/) - Professional moving guidelines

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/cad/room-planner/SKILL.md`
- References: `config/ai/skills/cad/room-planner/references/`
  - `references/living-room-furniture.md` — Sofas, armchairs, tables, desks, office chairs
  - `references/bedroom-furniture.md` — Beds, nightstands, dressers, wardrobes
  - `references/layout-optimization.md` — Layout generation, space planning, move planning, examples
- Includes: `config/ai/skills/includes/`

### Related Skills
- `build123d-tool` (dependency) — Core CAD environment and build123d setup
- `3d-modeling` (dependency) — Architectural room structures and components
- `base-ai-guidance` (base-framework) — Base AI guidance and content principles

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
