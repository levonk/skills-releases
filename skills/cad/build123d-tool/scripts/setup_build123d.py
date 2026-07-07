#!/usr/bin/env python3
"""
Build123D Validation Script
Validates build123d installation and basic functionality
This script is called by the justfile bootstrap-internal target
"""

import sys
import os
from pathlib import Path

def validate_build123d():
    """Test build123d installation and basic functionality"""
    try:
        import build123d
        from build123d import Box, Cylinder, Pos
        from ocp_vscode import show_object

        # Test basic geometry creation
        box = Box(10, 10, 10)
        cylinder = Cylinder(5, 10)
        combined = box + cylinder

        print("✅ build123d basic functionality verified")
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("💡 Run 'just bootstrap' to install dependencies")
        return False
    except Exception as e:
        print(f"❌ Functionality error: {e}")
        return False

def create_project_structure():
    """Create standard project directories"""
    directories = [
        "models",
        "exports",
        "scripts",
        "tests"
    ]

    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
        print(f"📁 Created directory: {directory}")

def check_dev_environment():
    """Check if running in proper devbox environment"""
    if not os.getenv("DEVBOX_SHELL_ENABLED"):
        print("⚠️  Not running in devbox shell")
        print("💡 Run 'direnv allow' then 'devbox shell' for proper environment")
        return False
    return True

def main():
    """Main validation function"""
    print("🔧 Validating Build123D environment...")

    # Check dev environment
    if not check_dev_environment():
        return False

    # Validate build123d installation
    if not validate_build123d():
        return False

    # Create project structure
    create_project_structure()

    print("\n🚀 Build123D environment is ready!")
    print("💡 Try running: just dev")
    print("💡 Or view models: just view-model")
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
