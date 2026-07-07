# Room and Space Modeling Reference

Detailed code patterns for creating architectural room structures, multi-room layouts, and door/window systems with build123d.

## Basic Room Structure

```python
def create_room(length, width, height, wall_thickness=100, floor_thickness=200):
    """Create a basic room structure with floor and walls"""
    with BuildPart() as room:
        # Floor
        Box(length, width, floor_thickness)

        # Walls - positioned on floor edges
        wall_height = height - floor_thickness

        # Long walls
        with Locations([(0, 0, floor_thickness), (length - wall_thickness, 0, floor_thickness)]):
            Box(wall_thickness, width, wall_height)

        # Short walls
        with Locations([(0, 0, floor_thickness), (0, width - wall_thickness, floor_thickness)]):
            Box(length, wall_thickness, wall_height)

    return room.part

def create_room_with_opening(length, width, height, wall_thickness=100,
                           door_width=900, door_height=2100, window_width=1200, window_height=1000):
    """Create room with door and window openings"""
    with BuildPart() as room:
        # Basic room structure
        basic_room = create_room(length, width, height, wall_thickness)
        add(basic_room)

        # Door opening (in one long wall)
        door_pos = (length/2 - door_width/2, 0, 0)
        with Locations(door_pos):
            Box(door_width, wall_thickness, door_height, mode=Mode.SUBTRACT)

        # Window opening (in opposite wall)
        window_height_from_floor = 1000  # Standard window height
        window_pos = (length/2 - window_width/2, width - wall_thickness,
                     window_height_from_floor)
        with Locations(window_pos):
            Box(window_width, wall_thickness, window_height, mode=Mode.SUBTRACT)

    return room.part
```

## Multi-Room Layouts

```python
def create_apartment_layout():
    """Create a simple apartment with multiple rooms"""
    with BuildPart() as apartment:
        # Living room
        living_room = create_room(5000, 4000, 2400)
        add(living_room, location=Pos(0, 0, 0))

        # Kitchen
        kitchen = create_room(3000, 2500, 2400)
        add(kitchen, location=Pos(5000, 0, 0))

        # Bedroom
        bedroom = create_room(4000, 3500, 2400)
        add(bedroom, location=Pos(0, 4000, 0))

        # Bathroom
        bathroom = create_room(2500, 2000, 2400)
        add(bathroom, location=Pos(5000, 4000, 0))

    return apartment.part
```

## Interior Door

```python
def create_interior_door(width=900, height=2100, thickness=40):
    """Create a standard interior door"""
    with BuildPart() as door:
        # Door slab
        Box(width, height, thickness)

        # Add panel details (simplified)
        panel_border = 100
        panel_depth = 5

        # Top panel
        with Locations((panel_border, panel_border, 0)):
            Box(width - 2*panel_border, height/3 - panel_border, panel_depth,
                mode=Mode.SUBTRACT)

        # Bottom panels
        panel_width = (width - 3*panel_border) / 2
        with Locations((panel_border, height/3 + panel_border, 0)):
            Box(panel_width, height*2/3 - 2*panel_border, panel_depth,
                mode=Mode.SUBTRACT)
        with Locations((width - panel_border - panel_width, height/3 + panel_border, 0)):
            Box(panel_width, height*2/3 - 2*panel_border, panel_depth,
                mode=Mode.SUBTRACT)

    return door.part
```

## Window

```python
def create_window(width=1200, height=1000, frame_thickness=50):
    """Create a standard double-hung window"""
    with BuildPart() as window:
        # Window frame
        Box(width, height, frame_thickness)

        # Glass opening
        glass_border = 30
        interior_width = width - 2 * glass_border
        interior_height = height - 2 * glass_border

        with Locations((glass_border, glass_border, 0)):
            Box(interior_width, interior_height, frame_thickness, mode=Mode.SUBTRACT)

        # Center divider (meeting rail)
        divider_thickness = 20
        with Locations((glass_border, height/2 - divider_thickness/2, 0)):
            Box(interior_width, divider_thickness, frame_thickness, mode=Mode.ADD)

    return window.part
```
