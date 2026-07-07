#!/usr/bin/env python3
"""
Build123D Model Viewer
Interactive visualization for build123d models using OCP VSCode
"""

import sys
import os
import argparse
from pathlib import Path

def check_dev_environment():
    """Check if running in proper devbox environment"""
    if not os.getenv("DEVBOX_SHELL_ENABLED"):
        print("⚠️  Not running in devbox shell")
        print("💡 Run 'direnv allow' then 'devbox shell' for proper environment")
        return False
    return True

def load_model(model_path):
    """Load a model from various file formats"""
    try:
        from build123d import import_stl, import_step, import_brep
        
        path = Path(model_path)
        if not path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        suffix = path.suffix.lower()
        
        if suffix == '.stl':
            return import_stl(str(path))
        elif suffix in ['.step', '.stp']:
            return import_step(str(path))
        elif suffix == '.brep':
            return import_brep(str(path))
        else:
            raise ValueError(f"Unsupported file format: {suffix}")
            
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return None

def create_demo_models():
    """Create demonstration models for testing"""
    try:
        from build123d import *
        from ocp_vscode import show_object
        
        models = {}
        
        # Basic geometric primitives
        models['box'] = Box(10, 10, 10)
        models['cylinder'] = Cylinder(5, 20)
        models['sphere'] = Sphere(5)
        
        # Combined geometry
        models['combined'] = Box(15, 15, 10) + Cylinder(3, 15)
        
        # Complex assembly
        with BuildPart() as assembly:
            Box(20, 20, 5)
            with BuildSketch(Plane.XY) as sketch:
                with Locations([(5, 5), (15, 15)]):
                    Circle(2)
            extrude(amount=10, mode=Mode.ADD)
        models['assembly'] = assembly.part
        
        return models
        
    except Exception as e:
        print(f"❌ Error creating demo models: {e}")
        return {}

def view_models(models, show_names=True):
    """Display models using OCP VSCode viewer"""
    try:
        from ocp_vscode import show_object, show, configure
        
        # Configure viewer
        configure(axes=True, axes0=True, grid=True, transparent=False)
        
        print("👀 Opening 3D viewer...")
        print("💡 Use mouse to rotate, scroll to zoom")
        
        for name, model in models.items():
            if show_names:
                show_object(model, name=name)
            else:
                show_object(model)
        
        # Show all objects
        show()
        
        print(f"✅ Displayed {len(models)} model(s)")
        
    except ImportError:
        print("❌ OCP VSCode not available. Install with: pip install ocp-vscode")
        return False
    except Exception as e:
        print(f"❌ Error displaying models: {e}")
        return False
    
    return True

def export_demo_models():
    """Export demo models in various formats"""
    try:
        models = create_demo_models()
        
        if not models:
            return False
        
        # Create exports directory
        exports_dir = Path("exports")
        exports_dir.mkdir(exist_ok=True)
        
        # Export each model
        for name, model in models.items():
            # STL format
            stl_path = exports_dir / f"{name}.stl"
            model.export_stl(str(stl_path))
            print(f"📄 Exported: {stl_path}")
            
            # STEP format
            step_path = exports_dir / f"{name}.step"
            model.export_step(str(step_path))
            print(f"📄 Exported: {step_path}")
        
        print(f"✅ Exported {len(models)} models to {exports_dir}")
        return True
        
    except Exception as e:
        print(f"❌ Error exporting models: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Build123D Model Viewer")
    parser.add_argument("model", nargs="?", help="Path to model file (.stl, .step, .brep)")
    parser.add_argument("--demo", action="store_true", help="Show demonstration models")
    parser.add_argument("--export", action="store_true", help="Export demo models")
    parser.add_argument("--no-names", action="store_true", help="Don't show model names")
    
    args = parser.parse_args()

    if not check_dev_environment():
        sys.exit(1)

    if args.export:
        export_demo_models()
        return
    
    if args.demo:
        models = create_demo_models()
        if models:
            view_models(models, show_names=not args.no_names)
    elif args.model:
        model = load_model(args.model)
        if model:
            view_models({"loaded": model}, show_names=not args.no_names)
    else:
        print("🔧 Build123D Model Viewer")
        print("Usage:")
        print("  python view_model.py --demo          # Show demo models")
        print("  python view_model.py model.stl       # Load specific model")
        print("  python view_model.py --export         # Export demo models")
        print("\n💡 Try --demo to see example models")

if __name__ == "__main__":
    main()
