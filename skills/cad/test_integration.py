#!/usr/bin/env python3
"""
Integration test script for CAD skills
Tests integration between build123d-tool, 3d-modeling, and room-planner skills
"""

import sys
import os
from pathlib import Path

# Add shared scripts to path
shared_path = Path(__file__).parent / "shared" / "scripts"
sys.path.insert(0, str(shared_path))

def test_build123d_tool():
    """Test build123d-tool skill functionality"""
    print("🔧 Testing build123d-tool skill...")
    
    try:
        from build123d import *
        from ocp_vscode import show_object
        
        # Test basic geometry creation
        box = Box(10, 10, 10)
        cylinder = Cylinder(5, 20)
        combined = box + cylinder
        
        print("✅ build123d-tool: Basic geometry creation successful")
        
        # Test transformations
        transformed = Rot(0, 0, 45) * combined
        translated = Pos(5, 5, 0) * transformed
        
        print("✅ build123d-tool: Transformations successful")
        
        # Test export capabilities
        test_file = Path("test_export.stl")
        combined.export_stl(str(test_file))
        test_file.unlink()  # Clean up
        
        print("✅ build123d-tool: Export functionality successful")
        return True
        
    except Exception as e:
        print(f"❌ build123d-tool test failed: {e}")
        return False

def test_3d_modeling():
    """Test 3d-modeling skill functionality"""
    print("\n🏠 Testing 3d-modeling skill...")
    
    try:
        from build123d import *
        
        # Test room creation
        def create_room(length, width, height, wall_thickness=100, floor_thickness=200):
            with BuildPart() as room:
                # Floor
                Box(length, width, floor_thickness)
                
                # Walls
                wall_height = height - floor_thickness
                with Locations([(0, 0, floor_thickness), (length - wall_thickness, 0, floor_thickness)]):
                    Box(wall_thickness, width, wall_height)
                with Locations([(0, 0, floor_thickness), (0, width - wall_thickness, floor_thickness)]):
                    Box(length, wall_thickness, wall_height)
            return room.part
        
        room = create_room(5000, 4000, 2400)
        print("✅ 3d-modeling: Room creation successful")
        
        # Test cabinet creation
        def create_base_cabinet(width, height=720, depth=600, material_thickness=18):
            with BuildPart() as cabinet:
                Box(width, depth, height)
                
                interior_width = width - 2 * material_thickness
                interior_depth = depth - 2 * material_thickness
                interior_height = height - material_thickness
                
                with Locations((material_thickness, material_thickness, material_thickness)):
                    Box(interior_width, interior_depth, interior_height, mode=Mode.SUBTRACT)
                
                with Locations((material_thickness, 0, material_thickness)):
                    Box(interior_width, material_thickness, interior_height, mode=Mode.SUBTRACT)
            return cabinet.part
        
        cabinet = create_base_cabinet(600, 720, 600)
        print("✅ 3d-modeling: Cabinet creation successful")
        
        # Test assembly
        with BuildPart() as kitchen:
            add(room)
            add(cabinet, location=Pos(500, 500, 200))
        
        print("✅ 3d-modeling: Assembly creation successful")
        return True
        
    except Exception as e:
        print(f"❌ 3d-modeling test failed: {e}")
        return False

def test_room_planner():
    """Test room-planner skill functionality"""
    print("\n🪑 Testing room-planner skill...")
    
    try:
        from build123d import *
        
        # Test furniture creation
        def create_sofa(length=2000, depth=900, height=850, seat_height=450):
            with BuildPart() as sofa:
                Box(length, depth, seat_height)
                
                with Locations((0, 0, seat_height)):
                    Box(length, depth - 100, height - seat_height)
                
                armrest_width = 150
                with Locations((0, 0, 0)):
                    Box(length, armrest_width, height)
                with Locations((0, depth - armrest_width, 0)):
                    Box(length, armrest_width, height)
            return sofa.part
        
        def create_dining_table(length=1600, width=900, height=750):
            with BuildPart() as table:
                Box(length, width, 30)
                
                leg_width = 80
                leg_height = height - 30
                leg_positions = [
                    (100, 100, 0),
                    (length - 100 - leg_width, 100, 0),
                    (100, width - 100 - leg_width, 0),
                    (length - 100 - leg_width, width - 100 - leg_width, 0)
                ]
                
                for pos in leg_positions:
                    with Locations(pos):
                        Box(leg_width, leg_width, leg_height)
            return table.part
        
        sofa = create_sofa()
        table = create_dining_table()
        print("✅ room-planner: Furniture creation successful")
        
        # Test layout creation
        def create_furniture_layout(room, furniture_items):
            with BuildPart() as layout:
                add(room)
                
                for item_type, dimensions, position in furniture_items:
                    if item_type == "sofa":
                        furniture = create_sofa(*dimensions)
                    elif item_type == "table":
                        furniture = create_dining_table(*dimensions)
                    else:
                        continue
                    
                    add(furniture, location=Pos(*position))
            
            return layout.part
        
        # Create a simple room for testing
        def create_simple_room(length, width, height):
            with BuildPart() as room:
                Box(length, width, height)
            return room.part
        
        room = create_simple_room(5000, 4000, 2400)
        furniture_items = [
            ("sofa", (2000, 900, 850), (500, 1000, 0)),
            ("table", (1600, 900, 750), (2500, 2000, 0))
        ]
        
        layout = create_furniture_layout(room, furniture_items)
        print("✅ room-planner: Layout creation successful")
        
        return True
        
    except Exception as e:
        print(f"❌ room-planner test failed: {e}")
        return False

def test_shared_utilities():
    """Test shared utility functions"""
    print("\n🔧 Testing shared utilities...")
    
    try:
        # Test geometry utilities
        from geometry_utils import create_standard_wall, check_collision
        
        wall = create_standard_wall(3000, 2400, 100)
        print("✅ Shared utilities: Geometry functions working")
        
        # Test material utilities
        from material_utils import get_material, calculate_material_requirements
        
        material = get_material("plywood_18mm")
        components = [{"width": 600, "height": 720}, {"width": 400, "height": 600}]
        requirements = calculate_material_requirements(components, "plywood_18mm")
        print("✅ Shared utilities: Material functions working")
        
        # Test layout utilities
        from layout_utils import create_standard_furniture, validate_layout
        
        furniture = create_standard_furniture("sofa")
        print("✅ Shared utilities: Layout functions working")
        
        return True
        
    except Exception as e:
        print(f"❌ Shared utilities test failed: {e}")
        return False

def test_complete_integration():
    """Test complete integration of all skills"""
    print("\n🔗 Testing complete integration...")
    
    try:
        from build123d import *
        from geometry_utils import create_room_layout_template
        from layout_utils import Room, FurnitureType, create_standard_furniture, recommend_optimal_layout
        
        # Create a complete room layout scenario
        room_template = create_room_layout_template(5000, 4000, 2400)
        
        # Create furniture using room-planner skill
        furniture_list = [
            create_standard_furniture(FurnitureType.SOFA),
            create_standard_furniture(FurnitureType.CHAIR),
            create_standard_furniture(FurnitureType.TABLE)
        ]
        
        # Create room using 3d-modeling skill
        def create_room_with_architecture(length, width, height, wall_thickness=100):
            with BuildPart() as room:
                # Floor
                Box(length, width, 200)
                
                # Walls
                wall_height = height - 200
                with Locations([(0, 0, 200), (length - wall_thickness, 0, 200)]):
                    Box(wall_thickness, width, wall_height)
                with Locations([(0, 0, 200), (0, width - wall_thickness, 200)]):
                    Box(length, wall_thickness, wall_height)
            return room.part
        
        room = create_room_with_architecture(5000, 4000, 2400)
        
        # Add furniture to room
        with BuildPart() as complete_layout:
            add(room)
            
            # Add sofa
            sofa = create_standard_furniture(FurnitureType.SOFA)
            add(sofa, location=Pos(500, 1000, 200))
            
            # Add table
            table = create_standard_furniture(FurnitureType.TABLE)
            add(table, location=Pos(2500, 2000, 200))
            
            # Add chair
            chair = create_standard_furniture(FurnitureType.CHAIR)
            add(chair, location=Pos(2000, 2500, 200))
        
        print("✅ Complete integration: Full room layout created successfully")
        
        # Test export using build123d-tool skill
        exports_dir = Path("test_exports")
        exports_dir.mkdir(exist_ok=True)
        
        complete_layout.part.export_stl(str(exports_dir / "complete_layout.stl"))
        complete_layout.part.export_step(str(exports_dir / "complete_layout.step"))
        
        print("✅ Complete integration: Export functionality working")
        
        # Clean up test files
        for file in exports_dir.glob("*"):
            file.unlink()
        exports_dir.rmdir()
        
        return True
        
    except Exception as e:
        print(f"❌ Complete integration test failed: {e}")
        return False

def run_all_tests():
    """Run all integration tests"""
    print("🚀 Starting CAD Skills Integration Tests\n")
    
    tests = [
        ("build123d-tool", test_build123d_tool),
        ("3d-modeling", test_3d_modeling),
        ("room-planner", test_room_planner),
        ("shared utilities", test_shared_utilities),
        ("complete integration", test_complete_integration)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"❌ {test_name} test crashed: {e}")
            results[test_name] = False
    
    # Summary
    print("\n" + "="*50)
    print("📊 TEST SUMMARY")
    print("="*50)
    
    passed = sum(results.values())
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:20} {status}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! CAD skills integration is working correctly.")
    else:
        print("⚠️  Some tests failed. Check the error messages above.")
    
    return passed == total

def create_demo_project():
    """Create a demo project showing all skills working together"""
    print("\n🏗️  Creating demo project...")
    
    try:
        from build123d import *
        from material_utils import create_material_schedule
        from layout_utils import Room, RoomType, FurnitureType, recommend_optimal_layout
        
        # Define a complete apartment scenario
        apartment_parts = []
        
        # Living room with furniture
        with BuildPart() as living_room:
            # Room structure
            Box(5000, 4000, 2400)
            
            # Kitchen cabinets along one wall
            for i in range(4):
                cabinet_width = 600
                with Locations((i * (cabinet_width + 50), 0, 720)):
                    Box(cabinet_width, 600, 720)
            
            # Living room furniture
            with Locations((500, 1000, 200)):
                Box(2000, 900, 850)  # Sofa
            
            with Locations((2500, 2000, 200)):
                Box(1600, 900, 750)  # Dining table
        
        apartment_parts.append(("living_room", living_room.part))
        
        # Bedroom with furniture
        with BuildPart() as bedroom:
            # Room structure
            Box(4500, 3500, 2400)
            
            # Bedroom furniture
            with Locations((1000, 1000, 200)):
                Box(2000, 1800, 400)  # Bed
            
            with Locations((500, 500, 200)):
                Box(1200, 600, 900)  # Dresser
            
            with Locations((3500, 1000, 200)):
                Box(500, 400, 600)  # Nightstand
        
        apartment_parts.append(("bedroom", bedroom.part))
        
        # Combine all parts
        with BuildPart() as apartment:
            add(living_room.part, location=Pos(0, 0, 0))
            add(bedroom.part, location=Pos(5000, 0, 0))
        
        # Export the complete apartment
        demo_dir = Path("demo_apartment")
        demo_dir.mkdir(exist_ok=True)
        
        apartment.part.export_stl(str(demo_dir / "apartment.stl"))
        apartment.part.export_step(str(demo_dir / "apartment.step"))
        
        print("✅ Demo project created successfully!")
        print(f"📁 Files saved to: {demo_dir.absolute()}")
        print("   - apartment.stl (for 3D printing)")
        print("   - apartment.step (for CAD software)")
        
        return True
        
    except Exception as e:
        print(f"❌ Demo project creation failed: {e}")
        return False

if __name__ == "__main__":
    # Run integration tests
    success = run_all_tests()
    
    if success:
        # Create demo project if tests pass
        create_demo_project()
    
    print(f"\n🏁 Integration testing completed. Success: {success}")
