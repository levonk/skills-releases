#!/usr/bin/env python3
"""
Material and finish utilities for CAD skills
Standard materials, finishes, and material property calculations
"""

from dataclasses import dataclass
from typing import Dict, List, Tuple
from enum import Enum

class MaterialType(Enum):
    WOOD = "wood"
    PLYWOOD = "plywood"
    MDF = "mdf"
    PARTICLEBOARD = "particleboard"
    METAL = "metal"
    PLASTIC = "plastic"
    LAMINATE = "laminate"
    SOLID_SURFACE = "solid_surface"

class FinishType(Enum):
    NATURAL = "natural"
    PAINTED = "painted"
    STAINED = "stained"
    LAMINATED = "laminated"
    VENEERED = "veneered"
    POLISHED = "polished"
    MATTE = "matte"
    GLOSSY = "glossy"

@dataclass
class Material:
    """Material properties for CAD components"""
    name: str
    type: MaterialType
    thickness: float  # mm
    density: float   # kg/m³
    color: str
    cost_per_m2: float  # currency units
    workability: float  # 1-10 scale
    durability: float   # 1-10 scale
    
    def calculate_weight(self, area_m2: float) -> float:
        """Calculate weight for given area"""
        volume_m3 = area_m2 * (self.thickness / 1000)
        return volume_m3 * self.density
    
    def calculate_cost(self, area_m2: float) -> float:
        """Calculate cost for given area"""
        return area_m2 * self.cost_per_m2

@dataclass
class Finish:
    """Finish properties for materials"""
    name: str
    type: FinishType
    color: str
    texture: str
    durability: float  # 1-10 scale
    cost_per_m2: float
    application_method: str
    
    def apply_to_material(self, material: Material) -> Dict:
        """Apply finish to material and return combined properties"""
        return {
            "base_material": material.name,
            "finish": self.name,
            "combined_color": self.color,
            "combined_cost_per_m2": material.cost_per_m2 + self.cost_per_m2,
            "combined_durability": (material.durability + self.durability) / 2
        }

# Standard material library
STANDARD_MATERIALS = {
    "plywood_18mm": Material(
        name="Plywood 18mm",
        type=MaterialType.PLYWOOD,
        thickness=18,
        density=600,
        color="#DEB887",
        cost_per_m2=45,
        workability=8,
        durability=7
    ),
    "mdf_16mm": Material(
        name="MDF 16mm",
        type=MaterialType.MDF,
        thickness=16,
        density=750,
        color="#F5DEB3",
        cost_per_m2=35,
        workability=9,
        durability=6
    ),
    "particleboard_18mm": Material(
        name="Particleboard 18mm",
        type=MaterialType.PARTICLEBOARD,
        thickness=18,
        density=650,
        color="#CD853F",
        cost_per_m2=25,
        workability=6,
        durability=5
    ),
    "solid_oak_20mm": Material(
        name="Solid Oak 20mm",
        type=MaterialType.WOOD,
        thickness=20,
        density=750,
        color="#8B4513",
        cost_per_m2=120,
        workability=7,
        durability=9
    ),
    "steel_2mm": Material(
        name="Steel 2mm",
        type=MaterialType.METAL,
        thickness=2,
        density=7850,
        color="#C0C0C0",
        cost_per_m2=80,
        workability=4,
        durability=10
    ),
    "aluminum_3mm": Material(
        name="Aluminum 3mm",
        type=MaterialType.METAL,
        thickness=3,
        density=2700,
        color="#A8A8A8",
        cost_per_m2=95,
        workability=6,
        durability=8
    )
}

# Standard finish library
STANDARD_FinishES = {
    "natural_oak": Finish(
        name="Natural Oak",
        type=FinishType.NATURAL,
        color="#8B4513",
        texture="wood_grain",
        durability=7,
        cost_per_m2=15,
        application_method="oil"
    ),
    "white_paint": Finish(
        name="White Paint",
        type=FinishType.PAINTED,
        color="#FFFFFF",
        texture="smooth",
        durability=6,
        cost_per_m2=8,
        application_method="roller"
    ),
    "gray_laminate": Finish(
        name="Gray Laminate",
        type=FinishType.LAMINATED,
        color="#808080",
        texture="smooth",
        durability=8,
        cost_per_m2=25,
        application_method="adhesive"
    ),
    "walnut_stain": Finish(
        name="Walnut Stain",
        type=FinishType.STAINED,
        color="#5C4033",
        texture="wood_grain",
        durability=6,
        cost_per_m2=12,
        application_method="brush"
    ),
    "matte_black": Finish(
        name="Matte Black",
        type=FinishType.MATTE,
        color="#000000",
        texture="matte",
        durability=7,
        cost_per_m2=18,
        application_method="spray"
    )
}

def get_material(material_name: str) -> Material:
    """Get material from standard library"""
    return STANDARD_MATERIALS.get(material_name, STANDARD_MATERIALS["plywood_18mm"])

def get_finish(finish_name: str) -> Finish:
    """Get finish from standard library"""
    return STANDARD_FinishES.get(finish_name, STANDARD_FinishES["natural_oak"])

def calculate_material_requirements(components: List[Dict], 
                                   material_name: str) -> Dict:
    """Calculate material requirements for a list of components"""
    material = get_material(material_name)
    
    total_area = 0
    total_weight = 0
    total_cost = 0
    
    for component in components:
        # Each component should have width and height in mm
        width_m = component["width"] / 1000
        height_m = component["height"] / 1000
        area = width_m * height_m
        
        total_area += area
        total_weight += material.calculate_weight(area)
        total_cost += material.calculate_cost(area)
    
    return {
        "material": material.name,
        "thickness": material.thickness,
        "total_area_m2": total_area,
        "total_weight_kg": total_weight,
        "total_cost": total_cost,
        "component_count": len(components)
    }

def optimize_material_usage(components: List[Dict], 
                          sheet_size: Tuple[float, float] = (2440, 1220)) -> Dict:
    """Optimize material usage and calculate waste"""
    sheet_width, sheet_height = sheet_size
    sheet_area = (sheet_width / 1000) * (sheet_height / 1000)
    
    # Simple greedy algorithm for optimization
    # In practice, you'd use more sophisticated bin-packing algorithms
    sorted_components = sorted(components, key=lambda x: max(x["width"], x["height"]), reverse=True)
    
    sheets_needed = 1
    current_sheet_used_area = 0
    cutting_plan = []
    
    for component in sorted_components:
        component_area = (component["width"] / 1000) * (component["height"] / 1000)
        
        if current_sheet_used_area + component_area <= sheet_area:
            current_sheet_used_area += component_area
            cutting_plan.append({
                "component": component,
                "sheet": sheets_needed,
                "position": "calculated"  # Simplified
            })
        else:
            sheets_needed += 1
            current_sheet_used_area = component_area
            cutting_plan.append({
                "component": component,
                "sheet": sheets_needed,
                "position": "calculated"
            })
    
    total_used_area = sum((c["width"] / 1000) * (c["height"] / 1000) for c in components)
    total_sheet_area = sheets_needed * sheet_area
    waste_percentage = ((total_sheet_area - total_used_area) / total_sheet_area) * 100
    
    return {
        "sheets_needed": sheets_needed,
        "total_sheet_area_m2": total_sheet_area,
        "used_area_m2": total_used_area,
        "waste_percentage": waste_percentage,
        "cutting_plan": cutting_plan
    }

def create_material_schedule(furniture_items: List[Dict]) -> Dict:
    """Create a complete material schedule for furniture items"""
    material_schedule = {}
    
    for item in furniture_items:
        item_name = item["name"]
        components = item.get("components", [])
        material_name = item.get("material", "plywood_18mm")
        finish_name = item.get("finish", "natural_oak")
        
        # Calculate material requirements
        material_req = calculate_material_requirements(components, material_name)
        
        # Add finish costs
        finish = get_finish(finish_name)
        finish_cost = material_req["total_area_m2"] * finish.cost_per_m2
        
        material_schedule[item_name] = {
            "material_requirements": material_req,
            "finish": finish_name,
            "finish_cost": finish_cost,
            "total_cost": material_req["total_cost"] + finish_cost
        }
    
    # Calculate totals
    total_cost = sum(item["total_cost"] for item in material_schedule.values())
    total_weight = sum(item["material_requirements"]["total_weight_kg"] 
                     for item in material_schedule.values())
    
    return {
        "items": material_schedule,
        "total_cost": total_cost,
        "total_weight_kg": total_weight,
        "item_count": len(furniture_items)
    }

def generate_cutting_list(material_name: str, components: List[Dict]) -> List[Dict]:
    """Generate detailed cutting list for fabrication"""
    material = get_material(material_name)
    optimization = optimize_material_usage(components)
    
    cutting_list = []
    
    for sheet_num in range(1, optimization["sheets_needed"] + 1):
        sheet_components = [c for c in optimization["cutting_plan"] if c["sheet"] == sheet_num]
        
        cutting_list.append({
            "sheet_number": sheet_num,
            "material": material.name,
            "thickness": material.thickness,
            "sheet_size": "2440x1220mm",
            "components": [
                {
                    "name": comp["component"].get("name", f"Component {i+1}"),
                    "width": comp["component"]["width"],
                    "height": comp["component"]["height"],
                    "quantity": comp["component"].get("quantity", 1),
                    "edge_banding": comp["component"].get("edge_banding", "none")
                }
                for i, comp in enumerate(sheet_components)
            ]
        })
    
    return cutting_list

def estimate_fabrication_time(furniture_items: List[Dict]) -> Dict:
    """Estimate fabrication time based on complexity and materials"""
    # Time estimates in hours
    time_per_operation = {
        "cutting": 0.1,  # per cut
        "drilling": 0.05,  # per hole
        "assembly": 0.2,  # per joint
        "finishing": 0.3,  # per m²
        "hardware_installation": 0.1  # per hardware piece
    }
    
    total_time = 0
    breakdown = {}
    
    for item in furniture_items:
        item_time = 0
        components = item.get("components", [])
        
        # Estimate cutting time
        cuts_per_component = 4  # Average cuts per component
        cutting_time = len(components) * cuts_per_component * time_per_operation["cutting"]
        item_time += cutting_time
        
        # Estimate assembly time
        joints_per_component = 6  # Average joints per component
        assembly_time = len(components) * joints_per_component * time_per_operation["assembly"]
        item_time += assembly_time
        
        # Estimate finishing time
        total_area = sum((c["width"] / 1000) * (c["height"] / 1000) for c in components)
        finishing_time = total_area * time_per_operation["finishing"]
        item_time += finishing_time
        
        breakdown[item["name"]] = {
            "cutting": cutting_time,
            "assembly": assembly_time,
            "finishing": finishing_time,
            "total": item_time
        }
        
        total_time += item_time
    
    return {
        "total_hours": total_time,
        "breakdown": breakdown,
        "estimated_days": total_time / 8  # Assuming 8-hour workday
    }
