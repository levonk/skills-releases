#!/usr/bin/env python3
"""
Role ID Generator

Generates consistent role IDs following the format:
[department]-[role-type]-[specialization]

Usage:
    python generate-role-id.py sales director
    python generate-role-id.py security engineer ai
"""

import re
import sys

def generate_role_id(department, role_type, specialization=None):
    """Generate a consistent role ID"""
    components = [department.lower(), role_type.lower()]
    if specialization:
        components.append(specialization.lower())
    
    # Convert to kebab-case and remove special characters
    role_id = "-".join(components)
    role_id = re.sub(r'[^a-z0-9-]', '', role_id)
    role_id = re.sub(r'-+', '-', role_id).strip('-')
    
    return role_id

def main():
    if len(sys.argv) < 3:
        print("Usage: python generate-role-id.py <department> <role_type> [specialization]")
        print("Example: python generate-role-id.py sales director")
        print("Example: python generate-role-id.py security engineer ai")
        sys.exit(1)
    
    department = sys.argv[1]
    role_type = sys.argv[2]
    specialization = sys.argv[3] if len(sys.argv) > 3 else None
    
    role_id = generate_role_id(department, role_type, specialization)
    print(role_id)

if __name__ == "__main__":
    main()
