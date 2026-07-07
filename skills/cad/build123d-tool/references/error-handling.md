# Error Handling and Performance Reference

Detailed code patterns for validating geometry, handling errors, and optimizing build123d performance.

## Common Error Patterns

```python
from build123d import *

try:
    # This might fail if geometry is invalid
    result = Box(10, 10, 10) - Cylinder(15, 20)  # Cylinder larger than box
except Exception as e:
    print(f"Geometry error: {e}")
    # Fallback to safer operation
    result = Box(10, 10, 10) - Cylinder(3, 5)

# Validate geometry before operations
def validate_geometry(shape):
    """Check if shape is valid for operations"""
    if shape.is_null():
        raise ValueError("Shape is null")
    if not shape.is_valid():
        raise ValueError("Shape is invalid")
    return True

# Use validation
box = Box(10, 10, 10)
if validate_geometry(box):
    result = box + Cylinder(5, 10)
```

## Performance Optimization

```python
# Use Builder mode for complex scenes
with BuildPart() as assembly:
    # Efficient batch operations
    with GridLocations(2, 2, 5, 5):
        Box(1, 1, 1)

    # Group similar operations
    with BuildSketch(Plane.XY) as holes:
        with Locations([(1, 1), (3, 3), (5, 5)]):
            Circle(0.3)
    extrude(amount=2, mode=Mode.SUBTRACT)

# Minimize expensive operations
# Bad: Multiple boolean operations
result = Box(10, 10, 10)
for pos in [(1,1), (2,2), (3,3)]:
    result -= Pos(*pos) * Cylinder(0.5, 5)

# Good: Single compound operation
with BuildPart() as result:
    Box(10, 10, 10)
    with Locations([(1,1), (2,2), (3,3)]):
        Cylinder(0.5, 5, mode=Mode.SUBTRACT)
```
