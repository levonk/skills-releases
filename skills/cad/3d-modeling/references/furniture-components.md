# Furniture Components and Materials Reference

Detailed code patterns for material properties, finish applications, and complete layout examples with build123d.

## Material Properties

```python
class Material:
    """Material properties for architectural components"""
    def __init__(self, name, thickness, density, color):
        self.name = name
        self.thickness = thickness
        self.density = density
        self.color = color

# Standard materials
PLYWOOD_18MM = Material("Plywood", 18, 600, "#8B4513")
MDF_16MM = Material("MDF", 16, 750, "#DEB887")
PARTICLEBOARD_18MM = Material("Particleboard", 18, 650, "#CD853F")
SOLID_OAK_20MM = Material("Solid Oak", 20, 750, "#8B4513")
```

## Finish Applications

```python
def apply_cabinet_finish(cabinet, finish_type="laminate"):
    """Apply finish properties to cabinet (visual representation)"""
    # This would be used with rendering engines
    # For now, it's a placeholder for material assignment
    finish_properties = {
        "laminate": {"color": "#FFFFFF", "texture": "smooth"},
        "wood_grain": {"color": "#8B4513", "texture": "wood_grain"},
        "painted": {"color": "#F5F5DC", "texture": "matte"}
    }

    return finish_properties.get(finish_type, finish_properties["painted"])
```

## Example: Complete Kitchen Layout

```python
def create_complete_kitchen(room_length=5000, room_width=3000):
    """Create a complete kitchen with cabinets and appliances"""
    with BuildPart() as kitchen:
        # Room structure
        room = create_room(room_length, room_width, 2400)
        add(room)

        # Cabinet run along one wall
        cabinets = create_kitchen_cabinet_run(
            total_length=room_length - 1000,  # Leave space for fridge
            cabinet_widths=[600, 800, 600, 500]
        )
        add(cabinets, location=Pos(500, 0, 0))

        # Refrigerator space
        fridge_space = Box(700, 700, 1800)
        add(fridge_space, location=Pos(room_length - 800, 100, 0))

        # Wall cabinets
        wall_cabinets = create_kitchen_cabinet_run(
            total_length=room_length - 1000,
            cabinet_widths=[600, 800, 600, 500],
            height=700,
            depth=300
        )
        add(wall_cabinets, location=Pos(500, 0, 2400 - 700))

    return kitchen.part
```

## Example: Master Bedroom Suite

```python
def create_master_bedroom_suite():
    """Create bedroom with walk-in closet"""
    with BuildPart() as suite:
        # Main bedroom
        bedroom = create_room(4500, 4000, 2400)
        add(bedroom, location=Pos(0, 0, 0))

        # Walk-in closet
        closet = create_walk_in_closet(2500, 2000, 2400)
        add(closet, location=Pos(4500, 0, 0))

        # Add some bedroom furniture placeholders
        bed_platform = Box(2000, 1800, 300)
        add(bed_platform, location=Pos(1000, 1000, 0))

        nightstand = Box(500, 400, 600)
        add(nightstand, location=Pos(700, 1000, 0))
        add(nightstand, location=Pos(3200, 1000, 0))

    return suite.part
```
