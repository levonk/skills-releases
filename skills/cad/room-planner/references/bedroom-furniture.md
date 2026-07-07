# Bedroom Furniture Reference

Detailed code patterns for creating beds, nightstands, dressers, and wardrobes with build123d.

## Bed Systems

```python
def create_bed(length=2000, width=1800, height=400, mattress_thickness=250):
    """Create a bed frame with mattress"""
    with BuildPart() as bed:
        # Bed frame/base
        frame_height = height - mattress_thickness
        Box(length, width, frame_height)

        # Headboard
        headboard_height = 900
        headboard_width = 100
        with Locations((0, 0, frame_height)):
            Box(length, headboard_width, headboard_height - frame_height)

        # Footboard (optional, smaller)
        footboard_height = 400
        with Locations((0, width - 50, frame_height)):
            Box(length, 50, footboard_height - frame_height)

        # Side rails (visual representation)
        rail_height = 200
        rail_width = 30
        with Locations((0, rail_width, frame_height)):
            Box(length, rail_width, rail_height, mode=Mode.ADD)
        with Locations((0, width - rail_width - rail_width, frame_height)):
            Box(length, rail_width, rail_height, mode=Mode.ADD)

        # Mattress
        with Locations((50, 50, frame_height)):
            Box(length - 100, width - 100, mattress_thickness, mode=Mode.ADD)

    return bed.part

def create_nightstand(width=500, depth=400, height=600, drawer_count=2):
    """Create a nightstand with drawers"""
    with BuildPart() as nightstand:
        # Main cabinet box
        Box(width, depth, height)

        # Interior cavity
        material_thickness = 18
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Drawer openings
        drawer_height = (interior_height - (drawer_count + 1) * material_thickness) / drawer_count

        for i in range(drawer_count):
            drawer_y = material_thickness + i * (drawer_height + material_thickness)
            with Locations((material_thickness, 0, drawer_y)):
                Box(interior_width, material_thickness, drawer_height, mode=Mode.SUBTRACT)

        # Top surface (solid)
        with Locations((material_thickness, material_thickness, height - material_thickness)):
            Box(interior_width, interior_depth, material_thickness, mode=Mode.ADD)

    return nightstand.part
```

## Storage Systems

```python
def create_dresser(width=1200, depth=600, height=900, drawer_count=6):
    """Create a dresser with multiple drawers"""
    with BuildPart() as dresser:
        # Main cabinet box
        Box(width, depth, height)

        # Interior cavity
        material_thickness = 18
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Drawer openings
        drawer_height = (interior_height - (drawer_count + 1) * material_thickness) / drawer_count

        for i in range(drawer_count):
            drawer_y = material_thickness + i * (drawer_height + material_thickness)
            with Locations((material_thickness, 0, drawer_y)):
                Box(interior_width, material_thickness, drawer_height, mode=Mode.SUBTRACT)

        # Top surface
        with Locations((material_thickness, material_thickness, height - material_thickness)):
            Box(interior_width, interior_depth, material_thickness, mode=Mode.ADD)

        # Drawer pulls (visual representation)
        pull_count = drawer_count
        for i in range(pull_count):
            pull_y = material_thickness + i * (drawer_height + material_thickness) + drawer_height/2
            with Locations((width/2 - 50, depth/2, pull_y)):
                Box(100, 20, 10, mode=Mode.ADD)

    return dresser.part

def create_wardrobe(width=2000, depth=650, height=2400, compartment_config="hanging_shelves"):
    """Create a wardrobe with configurable compartments"""
    with BuildPart() as wardrobe:
        # Main cabinet box
        Box(width, depth, height)

        # Interior cavity
        material_thickness = 18
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Door openings (double doors)
        with Locations((material_thickness, 0, material_thickness)):
            Box(interior_width/2 - 5, material_thickness, interior_height, mode=Mode.SUBTRACT)
        with Locations((material_thickness + interior_width/2 + 5, 0, material_thickness)):
            Box(interior_width/2 - 5, material_thickness, interior_height, mode=Mode.SUBTRACT)

        # Interior compartments
        if compartment_config == "hanging_shelves":
            # Left side: hanging space
            hanging_rod_height = 1600
            rod_diameter = 25
            with Locations((material_thickness + 50, material_thickness + 50,
                          material_thickness + hanging_rod_height)):
                Cylinder(rod_diameter/2, interior_width/2 - 100,
                        align=(Align.CENTER, Align.MIN, Align.MIN))

            # Right side: shelves
            shelf_count = 5
            shelf_spacing = (interior_height - 200) / shelf_count

            for i in range(shelf_count):
                shelf_height = 200 + i * shelf_spacing
                with Locations((material_thickness + interior_width/2 + 50,
                             material_thickness, material_thickness + shelf_height)):
                    Box(interior_width/2 - 100, interior_depth, material_thickness,
                        mode=Mode.ADD)

    return wardrobe.part
```
