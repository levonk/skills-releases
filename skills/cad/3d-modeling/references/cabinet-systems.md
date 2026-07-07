# Cabinet and Storage Systems Reference

Detailed code patterns for creating kitchen cabinets, closet systems, and standard architectural dimensions with build123d.

## Base Cabinet

```python
def create_base_cabinet(width, height=720, depth=600, material_thickness=18):
    """Create a standard base kitchen cabinet"""
    with BuildPart() as cabinet:
        # Cabinet box
        Box(width, depth, height)

        # Interior cavity
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Door opening (front face removed)
        with Locations((material_thickness, 0, material_thickness)):
            Box(interior_width, material_thickness, interior_height, mode=Mode.SUBTRACT)

        # Toe kick space at bottom
        toe_kick_height = 100
        toe_kick_depth = 50
        with Locations((material_thickness, depth - toe_kick_depth, material_thickness)):
            Box(interior_width, toe_kick_depth, toe_kick_height, mode=Mode.SUBTRACT)

    return cabinet.part

def create_base_cabinet_with_drawers(width, height=720, depth=600,
                                   drawer_heights=[180, 180, 180], material_thickness=18):
    """Create base cabinet with drawers"""
    cabinet = create_base_cabinet(width, height, depth, material_thickness)

    # Add drawer dividers
    current_height = material_thickness
    for drawer_height in drawer_heights:
        divider_pos = (material_thickness, material_thickness,
                      current_height + drawer_height)
        divider_width = width - 2 * material_thickness
        divider_depth = depth - 2 * material_thickness

        with Locations(divider_pos):
            Box(divider_width, divider_depth, material_thickness, mode=Mode.ADD)

        current_height += drawer_height + material_thickness

    return cabinet
```

## Wall Cabinet

```python
def create_wall_cabinet(width, height=700, depth=300, material_thickness=18):
    """Create a standard wall kitchen cabinet"""
    with BuildPart() as cabinet:
        # Cabinet box
        Box(width, depth, height)

        # Interior cavity
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Door opening
        with Locations((material_thickness, 0, material_thickness)):
            Box(interior_width, material_thickness, interior_height, mode=Mode.SUBTRACT)

    return cabinet.part

def create_upper_cabinet_with_shelves(width, height=700, depth=300,
                                     shelf_count=2, material_thickness=18):
    """Create wall cabinet with adjustable shelves"""
    cabinet = create_wall_cabinet(width, height, depth, material_thickness)

    # Add shelf support holes (simplified as pegs)
    peg_diameter = 5
    peg_depth = 10
    spacing = 32  # Standard shelf pin spacing

    interior_width = width - 2 * material_thickness
    interior_depth = depth - 2 * material_thickness

    # Create peg holes on side walls
    for y_offset in range(50, int(height - 50), spacing):
        for x_offset in [material_thickness, width - material_thickness - peg_depth]:
            for z_offset in [material_thickness, depth - material_thickness - peg_depth]:
                peg_pos = (x_offset, y_offset, z_offset)
                with Locations(peg_pos):
                    Cylinder(peg_diameter/2, peg_depth, mode=Mode.SUBTRACT)

    return cabinet
```

## Cabinet Assembly

```python
def create_kitchen_cabinet_run(total_length, cabinet_widths=[600, 800, 600, 500],
                              height=720, depth=600):
    """Create a run of kitchen cabinets"""
    with BuildPart() as cabinet_run:
        current_x = 0

        for i, width in enumerate(cabinet_widths):
            cabinet_type = "base" if i % 2 == 0 else "drawer_base"

            if cabinet_type == "base":
                cabinet = create_base_cabinet(width, height, depth)
            else:
                cabinet = create_base_cabinet_with_drawers(width, height, depth)

            add(cabinet, location=Pos(current_x, 0, 0))
            current_x += width

        # Add countertop
        countertop_thickness = 40
        with Locations((0, -20, height)):  # Overhang of 20mm
            Box(total_length, depth + 40, countertop_thickness)

    return cabinet_run.part
```

## Reach-In Closet

```python
def create_reach_in_closet(width, depth=600, height=2400, material_thickness=18):
    """Create a standard reach-in closet with shelving"""
    with BuildPart() as closet:
        # Closet box
        Box(width, depth, height)

        # Interior cavity
        interior_width = width - 2 * material_thickness
        interior_depth = depth - 2 * material_thickness
        interior_height = height - material_thickness

        with Locations((material_thickness, material_thickness, material_thickness)):
            Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)

        # Door opening
        with Locations((material_thickness, 0, material_thickness)):
            Box(interior_width, material_thickness, interior_height, mode=Mode.SUBTRACT)

        # Add shelves
        shelf_thickness = material_thickness
        shelf_heights = [400, 1000, 1600]  # Heights from bottom

        for shelf_height in shelf_heights:
            shelf_pos = (material_thickness, material_thickness,
                        material_thickness + shelf_height)
            with Locations(shelf_pos):
                Box(interior_width, interior_depth, shelf_thickness, mode=Mode.ADD)

        # Add hanging rod
        rod_height = 1600  # Standard hanging height
        rod_diameter = 25
        rod_pos = (width/2, material_thickness + 50, material_thickness + rod_height)
        with Locations(rod_pos):
            Cylinder(rod_diameter/2, interior_width - 100, align=(Align.CENTER, Align.MIN, Align.MIN))

    return closet.part
```

## Walk-In Closet

```python
def create_walk_in_closet(length, width, height=2400, material_thickness=18):
    """Create a walk-in closet with perimeter shelving"""
    with BuildPart() as closet:
        # Basic room structure
        room = create_room(length, width, height, material_thickness)
        add(room)

        # Perimeter shelving system
        shelf_depth = 400
        shelf_height = 400
        shelf_thickness = material_thickness

        # Long wall shelves
        long_shelf_length = length - 2 * material_thickness
        shelf_pos_y1 = (material_thickness, material_thickness, shelf_height)
        shelf_pos_y2 = (material_thickness, width - material_thickness - shelf_depth, shelf_height)

        with Locations(shelf_pos_y1):
            Box(long_shelf_length, shelf_depth, shelf_thickness, mode=Mode.ADD)
        with Locations(shelf_pos_y2):
            Box(long_shelf_length, shelf_depth, shelf_thickness, mode=Mode.ADD)

        # Short wall shelves
        short_shelf_length = width - 2 * material_thickness - 2 * shelf_depth
        shelf_pos_x1 = (material_thickness, material_thickness + shelf_depth, shelf_height)
        shelf_pos_x2 = (length - material_thickness - short_shelf_length,
                       material_thickness + shelf_depth, shelf_height)

        with Locations(shelf_pos_x1):
            Box(short_shelf_length, shelf_depth, shelf_thickness, mode=Mode.ADD)
        with Locations(shelf_pos_x2):
            Box(short_shelf_length, shelf_depth, shelf_thickness, mode=Mode.ADD)

    return closet.part
```

## Kitchen Standards

```python
# Standard kitchen dimensions (in millimeters)
KITCHEN_STANDARDS = {
    "base_cabinet_height": 720,
    "base_cabinet_depth": 600,
    "wall_cabinet_height": 700,
    "wall_cabinet_depth": 300,
    "countertop_thickness": 40,
    "countertop_overhang": 20,
    "toe_kick_height": 100,
    "toe_kick_depth": 50,
    "standard_widths": [300, 450, 600, 800, 900, 1000, 1200],
    "work_surface_height": 910  # Including countertop
}
```

## Closet Standards

```python
CLOSET_STANDARDS = {
    "reach_in_depth": 600,
    "walk_in_depth": 1200,
    "minimum_width": 600,
    "standard_height": 2400,
    "shelf_depth": 400,
    "shelf_thickness": 18,
    "hanging_rod_height": 1600,
    "rod_diameter": 25
}
```
