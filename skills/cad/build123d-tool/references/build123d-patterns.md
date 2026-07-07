# Build123D Patterns Reference

Detailed code patterns for algebraic mode, builder mode, transformations, geometric primitives, boolean operations, fillets/chamfers, and project adopter integration configs.

## Algebraic Mode (Stateless)

Preferred for simple, explicit geometry construction:

```python
from build123d import *

# Create basic shapes
box = Box(10, 10, 10)
cylinder = Cylinder(5, 20)

# Combine with operators
combined = box + cylinder
result = combined - Pos(15, 0, 0) * Sphere(3)

# Apply transformations
rotated = Rot(0, 0, 45) * result
translated = Pos(5, 5, 0) * rotated
```

## Builder Mode (Stateful)

Preferred for complex, hierarchical constructions:

```python
from build123d import *

with BuildPart() as main_part:
    # Main structure
    Box(20, 20, 10)

    # Add features
    with BuildSketch(Plane.XY) as sketch:
        Circle(3)
    extrude(amount=5, mode=Mode.ADD)

    # Subtractive features
    with Locations((5, 5, 0)):
        Cylinder(2, 15, mode=Mode.SUBTRACT)

# Access the result
final_part = main_part.part
```

## Location and Transformation System

```python
# Positioning objects
location = Pos(10, 20, 30)  # X, Y, Z translation
rotation = Rot(0, 45, 90)   # Roll, Pitch, Yaw
combined = location * rotation

# Grid and array layouts
grid = GridLocations(5, 5, 3, 3)  # spacing_x, spacing_y, count_x, count_y
circular = PolarLocations(10, 8)  # radius, count

# Apply to shapes
with Locations(*grid):
    Box(2, 2, 2)
```

## Basic Geometric Primitives

```python
# 1D: Lines and curves
line = Line((0, 0), (10, 0))
arc = Arc((0, 0), (10, 0), (5, 5))

# 2D: Faces and sketches
rectangle = Rectangle(10, 5)
circle = Circle(3)
complex_sketch = Rectangle(10, 10) + Circle(2)

# 3D: Solids
box = Box(10, 10, 10)
cylinder = Cylinder(5, 20)
sphere = Sphere(5)
```

## Boolean Operations

```python
# Union (addition)
combined = Box(10, 10, 10) + Cylinder(5, 20)

# Difference (subtraction)
result = Box(20, 20, 10) - Cylinder(3, 15)

# Intersection
overlap = Box(10, 10, 10) & Box(5, 5, 15)
```

## Fillets and Chamfers

```python
part = Box(10, 10, 10)

# Fillet edges
filleted = fillet(part.edges(), radius=1)

# Chamfer edges
chamfered = chamfer(part.edges(), distance=0.5)

# Selective edge treatment
specific_edges = part.edges().filter_by(Axis.Z)
filleted_specific = fillet(specific_edges, radius=0.5)
```

## Example: Basic Room Layout

```python
from build123d import *

with BuildPart() as room:
    # Floor
    Box(5000, 4000, 200)

    # Walls
    with Locations([(0, 0, 200), (5000-100, 0, 200)]):
        Box(100, 4000, 2400)
    with Locations([(0, 0, 200), (0, 4000-100, 200)]):
        Box(5000, 100, 2400)

show_object(room.part)
```

## Example: Parametric Cabinet

```python
from build123d import *

def create_cabinet(width, height, depth, material_thickness=18):
    """Create parametric cabinet box"""
    with BuildPart() as cabinet:
        # Cabinet box
        Box(width, depth, height)

        # Interior cavity
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

    return cabinet.part

# Use the function
cabinet = create_cabinet(600, 720, 300)
show_object(cabinet, name="kitchen_cabinet")
```

## Project Adopter Integration Configs

### Python Packages for devbox.json

```json
{
  "packages": [
    "just",
    "python311",
    "python311Packages.pip"
  ],
  "shell": {
    "init_hook": ["just bootstrap-internal"]
  }
}
```

### Justfile Targets

The project-adopter skill includes these CAD-specific targets:

```just
# CAD-specific internal targets
bootstrap-internal:
    pip install build123d[all] ocp-vscode numpy trimesh meshio
    python scripts/setup_build123d.py

test-internal:
    python -c "import build123d; print('✅ build123d import successful')"
    python scripts/view_model.py --demo

dev-internal:
    python scripts/view_model.py --demo

view-model:
    python scripts/view_model.py

export-model:
    python scripts/export_model.py
```

### pyproject.toml Configuration

```toml
[project]
dependencies = [
    "build123d>=0.7.0",
    "ocp-vscode>=2.0.0",
    "numpy>=1.21.0"
]

[project.optional-dependencies]
export = [
    "trimesh>=3.15.0",
    "meshio>=5.0.0"
]
```

### Shared Utilities

The `scripts/` directory contains reusable utilities:

```python
# scripts/geometry_helpers.py
def create_standard_wall(thickness=100, height=2400):
    """Create standard wall section"""
    return Box(thickness, 1000, height)

def create_standard_floor(thickness=200):
    """Create standard floor section"""
    return Box(5000, 5000, thickness)
```
