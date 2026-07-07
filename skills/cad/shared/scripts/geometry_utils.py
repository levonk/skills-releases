#!/usr/bin/env python3
"""
Shared geometry utilities for build123d CAD skills
Common functions used across architectural modeling and furniture planning
"""

from build123d import *
import math
from typing import Tuple, List, Optional

def create_standard_wall(length: float, height: float, thickness: float = 100) -> Solid:
    """Create a standard wall section"""
    return Box(length, thickness, height)

def create_standard_floor(length: float, width: float, thickness: float = 200) -> Solid:
    """Create a standard floor section"""
    return Box(length, width, thickness)

def create_standard_ceiling(length: float, width: float, thickness: float = 150) -> Solid:
    """Create a standard ceiling section"""
    return Box(length, width, thickness)

def add_door_opening(wall: Solid, width: float = 900, height: float = 2100, 
                    position: Tuple[float, float, float] = (0, 0, 0)) -> Solid:
    """Add a door opening to a wall"""
    with BuildPart() as wall_with_opening:
        add(wall)
        with Locations(position):
            Box(width, wall.bounding_box().size.Y, height, mode=Mode.SUBTRACT)
    return wall_with_opening.part

def add_window_opening(wall: Solid, width: float = 1200, height: float = 1000,
                      sill_height: float = 1000, 
                      position: Tuple[float, float, float] = (0, 0, 0)) -> Solid:
    """Add a window opening to a wall"""
    with BuildPart() as wall_with_opening:
        add(wall)
        window_position = (position[0], position[1], position[2] + sill_height)
        with Locations(window_position):
            Box(width, wall.bounding_box().size.Y, height, mode=Mode.SUBTRACT)
    return wall_with_opening.part

def create_fillet_edges(shape: Solid, radius: float, edge_filter=None) -> Solid:
    """Apply fillets to edges with optional filtering"""
    if edge_filter:
        edges = shape.edges().filter_by(edge_filter)
    else:
        edges = shape.edges()
    return fillet(edges, radius)

def create_chamfer_edges(shape: Solid, distance: float, edge_filter=None) -> Solid:
    """Apply chamfers to edges with optional filtering"""
    if edge_filter:
        edges = shape.edges().filter_by(edge_filter)
    else:
        edges = shape.edges()
    return chamfer(edges, distance)

def create_grid_of_objects(object_creator, spacing_x: float, spacing_y: float, 
                          count_x: int, count_y: int) -> List[Solid]:
    """Create a grid of objects using the provided creator function"""
    objects = []
    for i in range(count_x):
        for j in range(count_y):
            x_pos = i * spacing_x
            y_pos = j * spacing_y
            obj = object_creator()
            objects.append(Pos(x_pos, y_pos, 0) * obj)
    return objects

def calculate_bounding_box_union(objects: List[Solid]) -> BoundingBox:
    """Calculate the union bounding box of multiple objects"""
    if not objects:
        return None
    
    min_coords = objects[0].bounding_box().min
    max_coords = objects[0].bounding_box().max
    
    for obj in objects[1:]:
        bbox = obj.bounding_box()
        min_coords = Vector(
            min(min_coords.X, bbox.min.X),
            min(min_coords.Y, bbox.min.Y),
            min(min_coords.Z, bbox.min.Z)
        )
        max_coords = Vector(
            max(max_coords.X, bbox.max.X),
            max(max_coords.Y, bbox.max.Y),
            max(max_coords.Z, bbox.max.Z)
        )
    
    return BoundingBox(min_coords, max_coords)

def check_collision(obj1: Solid, obj2: Solid) -> bool:
    """Check if two objects collide/overlap"""
    # Simple bounding box check first
    bbox1 = obj1.bounding_box()
    bbox2 = obj2.bounding_box()
    
    if (bbox1.max.X < bbox2.min.X or bbox2.max.X < bbox1.min.X or
        bbox1.max.Y < bbox2.min.Y or bbox2.max.Y < bbox1.min.Y or
        bbox1.max.Z < bbox2.min.Z or bbox2.max.Z < bbox1.min.Z):
        return False
    
    # More precise check would require boolean intersection
    # For now, bounding box check is sufficient
    return True

def create_material_thickness_standard(thickness: float = 18) -> float:
    """Get standard material thickness"""
    standard_thicknesses = [12, 16, 18, 20, 25]
    return min(standard_thicknesses, key=lambda x: abs(x - thickness))

def calculate_panel_cut_list(dimensions: List[Tuple[float, float]], 
                            sheet_size: Tuple[float, float] = (2440, 1220)) -> List:
    """Calculate optimal cutting layout for panels from sheet stock"""
    # Simplified cutting list calculator
    # In practice, you'd use more sophisticated optimization algorithms
    cut_list = []
    remaining_area = sheet_size[0] * sheet_size[1]
    
    for width, height in dimensions:
        area = width * height
        if area <= remaining_area:
            cut_list.append({"width": width, "height": height, "sheet": 1})
            remaining_area -= area
        else:
            cut_list.append({"width": width, "height": height, "sheet": 2})
    
    return cut_list

def export_to_multiple_formats(shape: Solid, base_name: str, 
                             output_dir: str = "exports") -> List[str]:
    """Export shape to multiple CAD formats"""
    from pathlib import Path
    
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    
    formats = [
        ("stl", shape.export_stl),
        ("step", shape.export_step),
        ("3mf", shape.export_3mf)
    ]
    
    exported_files = []
    for format_name, export_func in formats:
        file_path = output_path / f"{base_name}.{format_name}"
        export_func(str(file_path))
        exported_files.append(str(file_path))
    
    return exported_files

def create_standard_clearance_zones(furniture: Solid, clearance_distances: dict) -> dict:
    """Create clearance zones around furniture for layout planning"""
    bbox = furniture.bounding_box()
    zones = {}
    
    for direction, distance in clearance_distances.items():
        if direction == "front":
            zones["front"] = Box(
                bbox.size.X + 2 * distance,
                distance,
                bbox.size.Z
            )
        elif direction == "back":
            zones["back"] = Box(
                bbox.size.X + 2 * distance,
                distance,
                bbox.size.Z
            )
        elif direction == "left":
            zones["left"] = Box(
                distance,
                bbox.size.Y + 2 * distance,
                bbox.size.Z
            )
        elif direction == "right":
            zones["right"] = Box(
                distance,
                bbox.size.Y + 2 * distance,
                bbox.size.Z
            )
    
    return zones

def validate_furniture_clearance(furniture_items: List[Tuple[Solid, Tuple[float, float, float]]],
                               min_clearance: float = 500) -> List[str]:
    """Validate that furniture items maintain minimum clearance"""
    issues = []
    
    for i, (furniture1, pos1) in enumerate(furniture_items):
        for j, (furniture2, pos2) in enumerate(furniture_items[i+1:], i+1):
            # Move furniture to positions for checking
            placed_furniture1 = Pos(*pos1) * furniture1
            placed_furniture2 = Pos(*pos2) * furniture2
            
            # Check clearance
            bbox1 = placed_furniture1.bounding_box()
            bbox2 = placed_furniture2.bounding_box()
            
            # Calculate minimum distance between bounding boxes
            min_distance = min(
                abs(bbox1.max.X - bbox2.min.X),
                abs(bbox2.max.X - bbox1.min.X),
                abs(bbox1.max.Y - bbox2.min.Y),
                abs(bbox2.max.Y - bbox1.min.Y)
            )
            
            if min_distance < min_clearance:
                issues.append(f"Insufficient clearance between item {i+1} and {j+1}: {min_distance}mm")
    
    return issues

def create_room_layout_template(room_length: float, room_width: float, 
                               room_height: float = 2400) -> dict:
    """Create a template for room layout planning"""
    return {
        "room_dimensions": (room_length, room_width, room_height),
        "wall_thickness": 100,
        "floor_thickness": 200,
        "ceiling_thickness": 150,
        "standard_clearances": {
            "sofa": 800,
            "bed": 600,
            "desk": 800,
            "dining_table": 900,
            "traffic_path": 700
        },
        "standard_heights": {
            "countertop": 910,
            "desk": 750,
            "dining_table": 750,
            "coffee_table": 450,
            "bed": 400
        }
    }
