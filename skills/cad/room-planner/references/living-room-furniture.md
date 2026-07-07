# Living Room and Office Furniture Reference

Detailed code patterns for creating living room seating, tables, and office furniture with build123d.

## Sofa and Seating

```python
def create_sofa(length=2000, depth=900, height=850, seat_height=450):
    """Create a standard sofa with cushions"""
    with BuildPart() as sofa:
        # Base frame
        Box(length, depth, seat_height)

        # Backrest
        with Locations((0, 0, seat_height)):
            Box(length, depth - 100, height - seat_height)

        # Armrests
        armrest_height = height
        armrest_width = 150
        with Locations((0, 0, 0)):
            Box(length, armrest_width, armrest_height)
        with Locations((0, depth - armrest_width, 0)):
            Box(length, armrest_width, armrest_height)

        # Seat cushions (visual representation)
        cushion_count = 3
        cushion_length = (length - 40) / cushion_count
        cushion_depth = depth - 200

        for i in range(cushion_count):
            cushion_x = 20 + i * (cushion_length + 10)
            with Locations((cushion_x, 100, seat_height)):
                Box(cushion_length, cushion_depth, 100, mode=Mode.ADD)

        # Back cushions
        for i in range(cushion_count):
            cushion_x = 20 + i * (cushion_length + 10)
            with Locations((cushion_x, 50, seat_height + 200)):
                Box(cushion_length, 50, 150, mode=Mode.ADD)

    return sofa.part

def create_armchair(width=800, depth=850, height=900, seat_height=450):
    """Create an armchair"""
    with BuildPart() as chair:
        # Base
        Box(width, depth, seat_height)

        # Backrest
        with Locations((0, 0, seat_height)):
            Box(width, depth - 150, height - seat_height)

        # Armrests
        armrest_width = 150
        with Locations((0, 0, seat_height)):
            Box(width, armrest_width, height - seat_height)
        with Locations((0, depth - armrest_width, seat_height)):
            Box(width, armrest_width, height - seat_height)

        # Seat cushion
        with Locations((50, 75, seat_height)):
            Box(width - 100, depth - 150, 80, mode=Mode.ADD)

    return chair.part
```

## Tables

```python
def create_coffee_table(length=1200, width=600, height=450, leg_style="straight"):
    """Create a coffee table"""
    with BuildPart() as table:
        # Tabletop
        Box(length, width, 40)

        # Legs
        leg_width = 60
        leg_positions = [
            (50, 50, 0),
            (length - 50 - leg_width, 50, 0),
            (50, width - 50 - leg_width, 0),
            (length - 50 - leg_width, width - 50 - leg_width, 0)
        ]

        for pos in leg_positions:
            if leg_style == "tapered":
                # Tapered legs
                with BuildPart() as leg:
                    with Locations(pos):
                        Box(leg_width, leg_width, height - 40)
                    # Taper effect (simplified)
                    with Locations((pos[0] + 10, pos[1] + 10, height - 80)):
                        Box(leg_width - 20, leg_width - 20, 40, mode=Mode.ADD)
                add(leg.part)
            else:
                # Straight legs
                with Locations(pos):
                    Box(leg_width, leg_width, height - 40)

        # Bottom shelf (optional)
        if leg_style == "tapered":
            shelf_height = 150
            with Locations((50, 50, shelf_height)):
                Box(length - 100, width - 100, 20, mode=Mode.ADD)

    return table.part

def create_dining_table(length=1600, width=900, height=750, leg_style="four_post"):
    """Create a dining table"""
    with BuildPart() as table:
        # Tabletop
        tabletop_thickness = 30
        Box(length, width, tabletop_thickness)

        if leg_style == "four_post":
            # Four post legs
            leg_width = 80
            leg_height = height - tabletop_thickness
            leg_positions = [
                (100, 100, 0),
                (length - 100 - leg_width, 100, 0),
                (100, width - 100 - leg_width, 0),
                (length - 100 - leg_width, width - 100 - leg_width, 0)
            ]

            for pos in leg_positions:
                with Locations(pos):
                    Box(leg_width, leg_width, leg_height)

        elif leg_style == "pedestal":
            # Central pedestal
            pedestal_width = 200
            pedestal_length = 300
            with Locations((length/2 - pedestal_length/2, width/2 - pedestal_width/2, 0)):
                Box(pedestal_length, pedestal_width, height - tabletop_thickness)

    return table.part
```

## Desk Systems

```python
def create_desk(length=1600, width=800, height=750, style="straight"):
    """Create an office desk"""
    with BuildPart() as desk:
        # Desktop
        desktop_thickness = 25
        Box(length, width, desktop_thickness)

        if style == "straight":
            # Four straight legs
            leg_width = 60
            leg_height = height - desktop_thickness
            leg_positions = [
                (50, 50, 0),
                (length - 50 - leg_width, 50, 0),
                (50, width - 50 - leg_width, 0),
                (length - 50 - leg_width, width - 50 - leg_width, 0)
            ]

            for pos in leg_positions:
                with Locations(pos):
                    Box(leg_width, leg_width, leg_height)

        elif style == "pedestal":
            # Two pedestal bases
            pedestal_width = 400
            pedestal_depth = 600
            pedestal_height = height - desktop_thickness

            # Left pedestal
            with Locations((100, (width - pedestal_depth)/2, 0)):
                Box(pedestal_width, pedestal_depth, pedestal_height)

            # Right pedestal
            with Locations((length - 500, (width - pedestal_depth)/2, 0)):
                Box(pedestal_width, pedestal_depth, pedestal_height)

        # Keyboard tray (optional)
        if style == "pedestal":
            tray_width = 800
            tray_depth = 300
            tray_height = 25
            tray_position = ((length - tray_width)/2, (width - tray_depth)/2, height - 150)
            with Locations(tray_position):
                Box(tray_width, tray_depth, tray_height, mode=Mode.ADD)

    return desk.part

def create_office_chair(width=650, depth=650, height=1200, seat_height=450):
    """Create an ergonomic office chair"""
    with BuildPart() as chair:
        # Base pedestal
        pedestal_width = 300
        pedestal_height = seat_height
        with Locations((width/2 - pedestal_width/2, depth/2 - pedestal_width/2, 0)):
            Box(pedestal_width, pedestal_width, pedestal_height)

        # Seat
        seat_thickness = 80
        with Locations((50, 50, pedestal_height)):
            Box(width - 100, depth - 100, seat_thickness, mode=Mode.ADD)

        # Backrest
        backrest_height = height - seat_height - seat_thickness
        backrest_width = width - 200
        with Locations((100, 50, pedestal_height + seat_thickness)):
            Box(backrest_width, 50, backrest_height, mode=Mode.ADD)

        # Armrests
        armrest_height = seat_height + 200
        armrest_width = 150
        armrest_depth = 50

        with Locations((50, depth/2 - armrest_depth/2, seat_height)):
            Box(armrest_width, armrest_depth, armrest_height - seat_height, mode=Mode.ADD)
        with Locations((width - 200, depth/2 - armrest_depth/2, seat_height)):
            Box(armrest_width, armrest_depth, armrest_height - seat_height, mode=Mode.ADD)

        # Base (five-point star simplified)
        base_radius = 250
        with Locations((width/2, depth/2, 0)):
            Cylinder(base_radius, 50, align=(Align.CENTER, Align.CENTER, Align.MIN))

    return chair.part
```
