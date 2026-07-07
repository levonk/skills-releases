#!/usr/bin/env python3
"""
Layout and space planning utilities
Common functions for furniture placement, clearance validation, and optimization
"""

import math
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from enum import Enum

class RoomType(Enum):
    LIVING_ROOM = "living_room"
    BEDROOM = "bedroom"
    KITCHEN = "kitchen"
    DINING_ROOM = "dining_room"
    OFFICE = "office"
    BATHROOM = "bathroom"
    CLOSET = "closet"

class FurnitureType(Enum):
    SOFA = "sofa"
    CHAIR = "chair"
    TABLE = "table"
    BED = "bed"
    DESK = "desk"
    DRESSER = "dresser"
    WARDROBE = "wardrobe"
    NIGHTSTAND = "nightstand"
    BOOKSHELF = "bookshelf"
    TV_STAND = "tv_stand"

@dataclass
class Room:
    """Room definition with dimensions and properties"""
    name: str
    room_type: RoomType
    length: float  # mm
    width: float   # mm
    height: float  # mm
    has_windows: bool = True
    has_doors: bool = True
    wall_thickness: float = 100

@dataclass
class Furniture:
    """Furniture item definition"""
    name: str
    furniture_type: FurnitureType
    length: float  # mm
    width: float   # mm
    height: float  # mm
    weight: float  # kg
    can_rotate: bool = True
    requires_clearance: bool = True
    fragile: bool = False

@dataclass
class Placement:
    """Furniture placement with position and rotation"""
    furniture: Furniture
    x: float  # mm from room origin
    y: float  # mm from room origin
    rotation: float  # degrees
    room: Room

# Standard clearances (in mm)
STANDARD_CLEARANCES = {
    FurnitureType.SOFA: {
        "front": 800,    # Space in front for walking
        "sides": 300,     # Space on sides
        "back": 100       # Space behind (against wall)
    },
    FurnitureType.CHAIR: {
        "front": 600,
        "sides": 300,
        "back": 100
    },
    FurnitureType.TABLE: {
        "all_sides": 700  # Space around all sides for chairs
    },
    FurnitureType.BED: {
        "sides": 600,
        "front": 800,
        "back": 300
    },
    FurnitureType.DESK: {
        "front": 800,     # Chair space
        "sides": 500,
        "back": 100
    },
    FurnitureType.DRESSER: {
        "front": 800,     # Drawer opening space
        "sides": 300,
        "back": 50
    },
    FurnitureType.WARDROBE: {
        "front": 900,     # Door opening space
        "sides": 300,
        "back": 50
    }
}

# Standard furniture dimensions (in mm)
STANDARD_DIMENSIONS = {
    FurnitureType.SOFA: {"length": 2000, "width": 900, "height": 850},
    FurnitureType.CHAIR: {"length": 650, "width": 650, "height": 900},
    FurnitureType.TABLE: {"length": 1600, "width": 900, "height": 750},
    FurnitureType.BED: {"length": 2000, "width": 1800, "height": 400},
    FurnitureType.DESK: {"length": 1600, "width": 800, "height": 750},
    FurnitureType.DRESSER: {"length": 1200, "width": 600, "height": 900},
    FurnitureType.WARDROBE: {"length": 2000, "width": 650, "height": 2400},
    FurnitureType.NIGHTSTAND: {"length": 500, "width": 400, "height": 600},
    FurnitureType.BOOKSHELF: {"length": 800, "width": 300, "height": 1800},
    FurnitureType.TV_STAND: {"length": 1500, "width": 400, "height": 600}
}

def create_standard_furniture(furniture_type: FurnitureType, 
                              custom_dimensions: Optional[Tuple[float, float, float]] = None) -> Furniture:
    """Create standard furniture with optional custom dimensions"""
    if custom_dimensions:
        length, width, height = custom_dimensions
    else:
        dims = STANDARD_DIMENSIONS[furniture_type]
        length, width, height = dims["length"], dims["width"], dims["height"]
    
    # Estimate weight based on volume and material
    volume_m3 = (length * width * height) / 1_000_000_000  # Convert mm³ to m³
    weight = max(10, volume_m3 * 500)  # Minimum 10kg, density ~500 kg/m³
    
    return Furniture(
        name=f"{furniture_type.value.replace('_', ' ').title()}",
        furniture_type=furniture_type,
        length=length,
        width=width,
        height=height,
        weight=weight
    )

def calculate_clearance_zone(furniture: Furniture, placement: Placement) -> Dict[str, Tuple[float, float, float, float]]:
    """Calculate clearance zones around furniture"""
    clearances = STANDARD_CLEARANCES.get(furniture.furniture_type, {"all_sides": 500})
    
    zones = {}
    
    if "all_sides" in clearances:
        clearance = clearances["all_sides"]
        zones["all"] = (
            placement.x - clearance,
            placement.y - clearance,
            placement.x + furniture.length + clearance,
            placement.y + furniture.width + clearance
        )
    else:
        # Individual side clearances
        front_clearance = clearances.get("front", 500)
        back_clearance = clearances.get("back", 100)
        side_clearance = clearances.get("sides", 300)
        
        zones["front"] = (
            placement.x,
            placement.y + furniture.width,
            placement.x + furniture.length,
            placement.y + furniture.width + front_clearance
        )
        
        zones["back"] = (
            placement.x,
            placement.y - back_clearance,
            placement.x + furniture.length,
            placement.y
        )
        
        zones["left"] = (
            placement.x - side_clearance,
            placement.y,
            placement.x,
            placement.y + furniture.width
        )
        
        zones["right"] = (
            placement.x + furniture.length,
            placement.y,
            placement.x + furniture.length + side_clearance,
            placement.y + furniture.width
        )
    
    return zones

def check_room_boundaries(furniture: Furniture, placement: Placement) -> List[str]:
    """Check if furniture placement stays within room boundaries"""
    issues = []
    
    # Check if furniture is within room
    if placement.x < 0:
        issues.append(f"Furniture extends beyond left wall by {abs(placement.x)}mm")
    if placement.y < 0:
        issues.append(f"Furniture extends beyond front wall by {abs(placement.y)}mm")
    
    if placement.x + furniture.length > placement.room.length:
        overhang = placement.x + furniture.length - placement.room.length
        issues.append(f"Furniture extends beyond right wall by {overhang}mm")
    
    if placement.y + furniture.width > placement.room.width:
        overhang = placement.y + furniture.width - placement.room.width
        issues.append(f"Furniture extends beyond back wall by {overhang}mm")
    
    return issues

def check_furniture_collision(placement1: Placement, placement2: Placement) -> bool:
    """Check if two furniture items collide"""
    f1 = placement1.furniture
    f2 = placement2.furniture
    
    # Get bounding boxes
    box1 = (placement1.x, placement1.y, 
            placement1.x + f1.length, placement1.y + f1.width)
    box2 = (placement2.x, placement2.y, 
            placement2.x + f2.length, placement2.y + f2.width)
    
    # Check if boxes overlap
    return not (box1[2] <= box2[0] or box2[2] <= box1[0] or
                box1[3] <= box2[1] or box2[3] <= box1[1])

def check_clearance_violations(placement1: Placement, placement2: Placement) -> List[str]:
    """Check if furniture items violate each other's clearance requirements"""
    violations = []
    
    # Get clearance zones
    zones1 = calculate_clearance_zone(placement1.furniture, placement1)
    zones2 = calculate_clearance_zone(placement2.furniture, placement2)
    
    # Check zone overlaps
    for zone_name1, zone1 in zones1.items():
        for zone_name2, zone2 in zones2.items():
            if boxes_overlap(zone1, zone2):
                violations.append(
                    f"Clearance violation: {placement1.furniture.name} {zone_name1} zone "
                    f"overlaps with {placement2.furniture.name} {zone_name2} zone"
                )
    
    return violations

def boxes_overlap(box1: Tuple[float, float, float, float], 
                 box2: Tuple[float, float, float, float]) -> bool:
    """Check if two rectangular boxes overlap"""
    return not (box1[2] <= box2[0] or box2[2] <= box1[0] or
                box1[3] <= box2[1] or box2[3] <= box1[1])

def validate_layout(placements: List[Placement]) -> Dict:
    """Validate complete furniture layout"""
    validation_results = {
        "boundary_issues": [],
        "collisions": [],
        "clearance_violations": [],
        "is_valid": True
    }
    
    # Check each placement against room boundaries
    for placement in placements:
        issues = check_room_boundaries(placement.furniture, placement)
        validation_results["boundary_issues"].extend(issues)
    
    # Check furniture collisions and clearance violations
    for i, placement1 in enumerate(placements):
        for placement2 in placements[i+1:]:
            if check_furniture_collision(placement1, placement2):
                validation_results["collisions"].append(
                    f"Collision between {placement1.furniture.name} and {placement2.furniture.name}"
                )
            
            violations = check_clearance_violations(placement1, placement2)
            validation_results["clearance_violations"].extend(violations)
    
    # Determine if layout is valid
    total_issues = (len(validation_results["boundary_issues"]) + 
                   len(validation_results["collisions"]) + 
                   len(validation_results["clearance_violations"]))
    
    validation_results["is_valid"] = total_issues == 0
    validation_results["total_issues"] = total_issues
    
    return validation_results

def calculate_traffic_flow(placements: List[Placement], room: Room) -> Dict:
    """Calculate and analyze traffic flow in room layout"""
    # Simplified traffic flow analysis
    # Identify main paths and potential bottlenecks
    
    # Define main traffic areas (simplified)
    main_paths = [
        {"name": "entry_to_room", "start": (0, room.width/2), "end": (room.length/2, room.width/2)},
        {"name": "room_circulation", "start": (room.length/2, room.width/2), "end": (room.length, room.width/2)}
    ]
    
    traffic_analysis = {
        "paths": [],
        "bottlenecks": [],
        "clear_areas": []
    }
    
    for path in main_paths:
        # Check if path is blocked by furniture
        blocked_sections = []
        
        for placement in placements:
            if furniture_blocks_path(placement, path["start"], path["end"]):
                blocked_sections.append(placement.furniture.name)
        
        traffic_analysis["paths"].append({
            "name": path["name"],
            "blocked_by": blocked_sections,
            "is_clear": len(blocked_sections) == 0
        })
        
        if blocked_sections:
            traffic_analysis["bottlenecks"].append({
                "path": path["name"],
                "blocking_furniture": blocked_sections
            })
    
    return traffic_analysis

def furniture_blocks_path(placement: Placement, path_start: Tuple[float, float], 
                         path_end: Tuple[float, float]) -> bool:
    """Check if furniture blocks a straight-line path"""
    # Simplified check - see if furniture bounding box intersects path rectangle
    f = placement.furniture
    
    # Create path rectangle (simplified as straight line with width)
    path_width = 700  # Standard corridor width
    
    # Path bounding box
    path_min_x = min(path_start[0], path_end[0])
    path_max_x = max(path_start[0], path_end[0])
    path_min_y = min(path_start[1], path_end[1]) - path_width/2
    path_max_y = max(path_start[1], path_end[1]) + path_width/2
    
    # Furniture bounding box
    furniture_box = (
        placement.x,
        placement.y,
        placement.x + f.length,
        placement.y + f.width
    )
    
    # Check intersection
    return boxes_overlap((path_min_x, path_min_y, path_max_x, path_max_y), furniture_box)

def generate_layout_alternatives(room: Room, furniture_list: List[Furniture]) -> List[Dict]:
    """Generate multiple layout alternatives for a room"""
    alternatives = []
    
    # Alternative 1: Against walls layout
    wall_layout = generate_wall_layout(room, furniture_list)
    alternatives.append({
        "name": "Against Walls",
        "description": "All furniture placed against walls for maximum floor space",
        "placements": wall_layout
    })
    
    # Alternative 2: Centered layout
    centered_layout = generate_centered_layout(room, furniture_list)
    alternatives.append({
        "name": "Centered",
        "description": "Key furniture pieces centered for balanced look",
        "placements": centered_layout
    })
    
    # Alternative 3: Functional zones layout
    zoned_layout = generate_zoned_layout(room, furniture_list)
    alternatives.append({
        "name": "Functional Zones",
        "description": "Furniture arranged in functional zones",
        "placements": zoned_layout
    })
    
    return alternatives

def generate_wall_layout(room: Room, furniture_list: List[Furniture]) -> List[Placement]:
    """Generate layout with furniture against walls"""
    placements = []
    current_x = 100  # Start 100mm from wall
    current_y = 100
    
    for furniture in furniture_list:
        # Try to place furniture along walls
        if current_x + furniture.length <= room.length - 100:
            placement = Placement(
                furniture=furniture,
                x=current_x,
                y=current_y,
                rotation=0,
                room=room
            )
            placements.append(placement)
            current_x += furniture.length + 100  # Add spacing
        else:
            # Move to next wall
            current_x = 100
            current_y += 1000  # Move deeper into room
            if current_y + furniture.width <= room.width - 100:
                placement = Placement(
                    furniture=furniture,
                    x=current_x,
                    y=current_y,
                    rotation=0,
                    room=room
                )
                placements.append(placement)
                current_x += furniture.length + 100
    
    return placements

def generate_centered_layout(room: Room, furniture_list: List[Furniture]) -> List[Placement]:
    """Generate layout with centered furniture arrangement"""
    placements = []
    center_x = room.length / 2
    center_y = room.width / 2
    
    # Place largest furniture first (usually sofa or bed)
    sorted_furniture = sorted(furniture_list, key=lambda f: f.length * f.width, reverse=True)
    
    for i, furniture in enumerate(sorted_furniture):
        # Arrange furniture around center point
        angle = (i * 2 * math.pi) / len(furniture_list)
        radius = min(room.length, room.width) / 4
        
        x = center_x + radius * math.cos(angle) - furniture.length / 2
        y = center_y + radius * math.sin(angle) - furniture.width / 2
        
        placement = Placement(
            furniture=furniture,
            x=x,
            y=y,
            rotation=math.degrees(angle),
            room=room
        )
        placements.append(placement)
    
    return placements

def generate_zoned_layout(room: Room, furniture_list: List[Furniture]) -> List[Placement]:
    """Generate layout based on functional zones"""
    placements = []
    
    # Define zones based on room type
    if room.room_type == RoomType.LIVING_ROOM:
        # Create seating zone and media zone
        seating_furniture = [f for f in furniture_list if f.furniture_type in [FurnitureType.SOFA, FurnitureType.CHAIR]]
        media_furniture = [f for f in furniture_list if f.furniture_type in [FurnitureType.TV_STAND, FurnitureType.TABLE]]
        
        # Place seating zone
        seating_x = 200
        seating_y = room.width / 2
        for i, furniture in enumerate(seating_furniture):
            placement = Placement(
                furniture=furniture,
                x=seating_x + i * 100,
                y=seating_y,
                rotation=0,
                room=room
            )
            placements.append(placement)
        
        # Place media zone
        media_x = room.length - 1000
        media_y = 200
        for i, furniture in enumerate(media_furniture):
            placement = Placement(
                furniture=furniture,
                x=media_x,
                y=media_y + i * 500,
                rotation=0,
                room=room
            )
            placements.append(placement)
    
    else:
        # Default to wall layout for other room types
        return generate_wall_layout(room, furniture_list)
    
    return placements

def score_layout(placements: List[Placement]) -> float:
    """Score a layout based on design principles"""
    score = 0.0
    
    # Traffic flow score (40% weight)
    validation = validate_layout(placements)
    if validation["is_valid"]:
        score += 40
    else:
        # Deduct points for issues
        score -= validation["total_issues"] * 2
    
    # Space utilization score (30% weight)
    room = placements[0].room if placements else None
    if room:
        total_furniture_area = sum(p.furniture.length * p.furniture.width for p in placements)
        room_area = room.length * room.width
        utilization = (total_furniture_area / room_area) * 100
        
        # Optimal utilization is 40-60%
        if 40 <= utilization <= 60:
            score += 30
        elif 30 <= utilization <= 70:
            score += 20
        else:
            score += 10
    
    # Functional arrangement score (30% weight)
    # This would be more sophisticated in practice
    score += 20  # Base score for having furniture arranged
    
    return max(0, score)

def recommend_optimal_layout(room: Room, furniture_list: List[Furniture]) -> Dict:
    """Recommend the best layout from generated alternatives"""
    alternatives = generate_layout_alternatives(room, furniture_list)
    
    scored_alternatives = []
    for alt in alternatives:
        validation = validate_layout(alt["placements"])
        score = score_layout(alt["placements"])
        
        scored_alternatives.append({
            **alt,
            "score": score,
            "validation": validation
        })
    
    # Sort by score
    scored_alternatives.sort(key=lambda x: x["score"], reverse=True)
    
    return {
        "recommended": scored_alternatives[0] if scored_alternatives else None,
        "alternatives": scored_alternatives,
        "room": room,
        "furniture_count": len(furniture_list)
    }
