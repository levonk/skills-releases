# CAD Skills System

A comprehensive 3D modeling and space planning system using build123d for architectural modeling, furniture planning, and move logistics.

## Overview

This system provides three integrated skills for 3D CAD work:

1. **build123d-tool** - Core CAD functionality and Python environment setup
2. **3d-modeling** - Architectural modeling (rooms, cabinets, closets, building elements)
3. **room-planner** - Furniture layout, space planning, and move logistics

## Quick Start

### Environment Setup

```bash
# Install build123d and dependencies
python scripts/setup_build123d.py

# Test the installation
python scripts/view_model.py --demo
```

### Basic Usage

```python
from build123d import *
from ocp_vscode import show_object

# Create a room
room = create_room(5000, 4000, 2400)

# Add furniture
furniture = create_sofa(2000, 900, 850)
layout = room + Pos(500, 1000, 0) * furniture

# View and export
show_object(layout)
layout.export_stl("room_layout.stl")
```

## Skills

### build123d-tool

**Purpose**: Core CAD functionality and Python environment setup

**Features**:
- Python environment configuration
- build123d installation and validation
- Visualization setup with OCP VSCode
- Export utilities (STL, STEP, 3MF, BREP)
- Performance optimization patterns

**Key Functions**:
- `setup_build123d.py` - Environment setup
- `view_model.py` - Interactive 3D viewing
- `export_model.py` - Multi-format export

**When to use**: Setting up 3D CAD capabilities, viewing models, exporting for manufacturing

### 3d-modeling

**Purpose**: Architectural modeling and building components

**Features**:
- Room and space modeling
- Kitchen and bathroom cabinets
- Closet systems
- Door and window systems
- Material and finish applications
- Standard architectural dimensions

**Key Components**:
- `create_room()` - Basic room structure
- `create_base_cabinet()` - Kitchen cabinets
- `create_wall_cabinet()` - Wall-mounted cabinets
- `create_reach_in_closet()` - Standard closets
- `create_walk_in_closet()` - Large closets

**When to use**: Modeling architectural elements, planning renovations, creating building components

### room-planner

**Purpose**: Furniture layout and move planning

**Features**:
- Furniture library (sofa, tables, beds, storage)
- Layout optimization algorithms
- Space planning with clearances
- Move logistics and inventory
- Traffic flow analysis

**Key Components**:
- Furniture creation functions
- Layout validation
- Clearance zone calculations
- Move planning tools
- Traffic flow analysis

**When to use**: Planning furniture placement, room layouts, moving logistics

## Shared Utilities

The `shared/scripts/` directory contains reusable utilities:

### geometry_utils.py
- Standard geometric functions
- Collision detection
- Clearance validation
- Bounding box calculations

### material_utils.py
- Material library and properties
- Cost calculations
- Cutting optimization
- Fabrication time estimates

### layout_utils.py
- Furniture placement algorithms
- Layout optimization
- Traffic flow analysis
- Space planning utilities

## Integration

### Skill Dependencies

```
room-planner → 3d-modeling → build123d-tool
     ↓              ↓              ↓
   Layout      Architecture    Core CAD
```

### Complete Workflow

1. **Setup Environment**: Use build123d-tool skill
2. **Create Architecture**: Use 3d-modeling skill for rooms/cabinets
3. **Add Furniture**: Use room-planner skill for layout
4. **Export Results**: Use build123d-tool export utilities

### Example: Complete Apartment

```python
# 1. Create room structure (3d-modeling skill)
living_room = create_room(5000, 4000, 2400)
kitchen_cabinets = create_kitchen_cabinet_run(3000, 600, 720)

# 2. Add furniture (room-planner skill)
sofa = create_sofa(2000, 900, 850)
dining_table = create_dining_table(1600, 900, 750)

# 3. Combine in layout
with BuildPart() as apartment:
    add(living_room)
    add(kitchen_cabinets, location=Pos(0, 0, 0))
    add(sofa, location=Pos(500, 1000, 0))
    add(dining_table, location=Pos(2500, 2000, 0))

# 4. Export (build123d-tool skill)
apartment.part.export_stl("apartment.stl")
```

## Testing

Run the integration test suite:

```bash
python test_integration.py
```

This tests:
- Individual skill functionality
- Cross-skill integration
- Export capabilities
- Complete workflow scenarios

## Standard Dimensions

### Architectural Standards
- Room height: 2400mm (8ft)
- Wall thickness: 100mm (4in)
- Floor thickness: 200mm (8in)
- Door height: 2100mm (7ft)
- Standard door width: 900mm (36in)

### Furniture Standards
- Sofa: 2000×900×850mm
- Dining table: 1600×900×750mm
- Bed: 2000×1800×400mm
- Desk: 1600×800×750mm
- Kitchen counter height: 910mm

### Clearances
- Traffic paths: 700mm minimum
- Sofa front clearance: 800mm
- Bed side clearance: 600mm
- Chair pull-out space: 800mm

## File Structure

```
cad/
├── build123d-tool/
│   └── SKILL.md
├── 3d-modeling/
│   └── SKILL.md
├── room-planner/
│   └── SKILL.md
├── shared/
│   └── scripts/
│       ├── geometry_utils.py
│       ├── material_utils.py
│       └── layout_utils.py
└── test_integration.py
```

## Use Cases

### 1. Move Planning
```python
# Create inventory
furniture_list = [
    {"type": "bed", "dimensions": (2000, 1800, 900)},
    {"type": "sofa", "dimensions": (2000, 900, 850)}
]

# Plan move
inventory = create_furniture_inventory(furniture_list)
move_plan = plan_move_sequence(inventory)
```

### 2. Kitchen Renovation
```python
# Design kitchen layout
room = create_room(4000, 3000, 2400)
cabinets = create_kitchen_cabinet_run(3000, [600, 800, 600])
appliances = create_appliance_cutouts()

# Generate cutting list
cutting_list = generate_cutting_list("plywood_18mm", cabinet_components)
```

### 3. Furniture Arrangement
```python
# Optimize room layout
room = Room("living_room", RoomType.LIVING_ROOM, 5000, 4000, 2400)
furniture = [create_standard_furniture(t) for t in [SOFA, CHAIR, TABLE]]

recommendation = recommend_optimal_layout(room, furniture)
```

## Export Formats

- **STL**: 3D printing and basic manufacturing
- **STEP**: CAD software interchange
- **3MF**: Microsoft 3D format
- **BREP**: OpenCascade native format

## Performance Tips

1. **Use Builder Mode** for complex assemblies
2. **Batch operations** when possible
3. **Minimize boolean operations**
4. **Use efficient geometry creation patterns**
5. **Export only necessary components**

## Troubleshooting

### Common Issues

1. **build123d import error**: Run `python scripts/setup_build123d.py`
2. **Visualization not working**: Install OCP VSCode extension
3. **Export fails**: Check file permissions and disk space
4. **Performance issues**: Simplify geometry or use Builder Mode

### Getting Help

- Check individual skill documentation
- Run integration tests for diagnostics
- Review build123d documentation at https://build123d.readthedocs.io/

## Contributing

When adding new features:

1. Follow the skill structure pattern
2. Add to shared utilities if reusable
3. Update integration tests
4. Document standard dimensions
5. Include export examples

## License

Internal use only - proprietary skill system.
