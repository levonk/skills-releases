#!/usr/bin/env python3
"""
Build123D Model Export Utility
Export build123d models to various formats for manufacturing and visualization
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

def export_model(model, output_path, format_type):
    """Export a build123d model to specified format"""
    try:
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        if format_type.lower() == 'stl':
            model.export_stl(str(output_path))
        elif format_type.lower() in ['step', 'stp']:
            model.export_step(str(output_path))
        elif format_type.lower() == '3mf':
            model.export_3mf(str(output_path))
        elif format_type.lower() == 'brep':
            model.export_brep(str(output_path))
        else:
            raise ValueError(f"Unsupported format: {format_type}")
        
        print(f"✅ Exported: {output_path}")
        return True
        
    except Exception as e:
        print(f"❌ Export error: {e}")
        return False

def create_test_model():
    """Create a test model for export testing"""
    try:
        from build123d import *
        
        with BuildPart() as test_part:
            # Main body
            Box(50, 30, 20)
            
            # Add some features
            with BuildSketch(Plane.XY) as sketch:
                with Locations([(10, 10), (40, 20)]):
                    Circle(3)
            extrude(amount=25, mode=Mode.ADD)
            
            # Add some holes
            with Locations([(25, 15, 0)]):
                Cylinder(5, 30, mode=Mode.SUBTRACT)
            
            # Add fillets
            fillet(edges().filter_by_length(20), radius=2)
        
        return test_part.part
        
    except Exception as e:
        print(f"❌ Error creating test model: {e}")
        return None

def export_all_formats(model, base_name, output_dir="exports"):
    """Export model to all supported formats"""
    formats = ['stl', 'step', '3mf', 'brep']
    success_count = 0
    
    output_dir = Path(output_dir)
    output_dir.mkdir(exist_ok=True)
    
    for format_type in formats:
        output_path = output_dir / f"{base_name}.{format_type}"
        if export_model(model, output_path, format_type):
            success_count += 1
    
    print(f"📊 Exported {success_count}/{len(formats)} formats")
    return success_count == len(formats)

def batch_export_directory(input_dir, output_dir, format_type='stl'):
    """Export all build123d Python files in a directory"""
    try:
        input_dir = Path(input_dir)
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        python_files = list(input_dir.glob("*.py"))
        
        if not python_files:
            print(f"❌ No Python files found in {input_dir}")
            return False
        
        success_count = 0
        
        for py_file in python_files:
            try:
                # Execute the Python file to get the model
                # Note: This assumes the file defines a 'model' variable
                spec = __import__(py_file.stem)
                if hasattr(spec, 'model'):
                    base_name = py_file.stem
                    output_path = output_dir / f"{base_name}.{format_type}"
                    
                    if export_model(spec.model, output_path, format_type):
                        success_count += 1
                else:
                    print(f"⚠️  No 'model' variable found in {py_file}")
                    
            except Exception as e:
                print(f"❌ Error processing {py_file}: {e}")
        
        print(f"📊 Batch export complete: {success_count}/{len(python_files)} files")
        return success_count > 0
        
    except Exception as e:
        print(f"❌ Batch export error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Build123D Model Export Utility")
    parser.add_argument("--test", action="store_true", help="Export test model to all formats")
    parser.add_argument("--input", help="Input Python file with build123d model")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--format", choices=['stl', 'step', 'stp', '3mf', 'brep'], 
                       default='stl', help="Export format")
    parser.add_argument("--batch", help="Batch export directory")
    parser.add_argument("--batch-output", help="Batch output directory")
    parser.add_argument("--name", help="Base name for exports")
    
    args = parser.parse_args()

    if not check_dev_environment():
        sys.exit(1)

    if args.test:
        print("🔧 Creating and exporting test model...")
        model = create_test_model()
        if model:
            export_all_formats(model, "test_model")
        return
    
    if args.batch:
        if not args.batch_output:
            args.batch_output = "exports"
        batch_export_directory(args.batch, args.batch_output, args.format)
        return
    
    if args.input:
        try:
            # Load the model from Python file
            spec = __import__(Path(args.input).stem)
            if not hasattr(spec, 'model'):
                print("❌ No 'model' variable found in input file")
                sys.exit(1)
            
            model = spec.model
            
            if args.output:
                export_model(model, args.output, args.format)
            else:
                # Default output path
                input_path = Path(args.input)
                output_path = input_path.with_suffix(f".{args.format}")
                export_model(model, output_path, args.format)
                
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            sys.exit(1)
    else:
        print("🔧 Build123D Model Export Utility")
        print("Usage:")
        print("  python export_model.py --test                    # Export test model")
        print("  python export_model.py --input model.py          # Export specific model")
        print("  python export_model.py --input model.py --output out.stl  # Custom output")
        print("  python export_model.py --batch models/ --output exports/   # Batch export")
        print("\nSupported formats: stl, step, stp, 3mf, brep")

if __name__ == "__main__":
    main()
