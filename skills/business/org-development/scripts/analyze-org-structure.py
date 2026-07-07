#!/usr/bin/env python3
"""
Organization Structure Analyzer

Analyzes the organization structure for various metrics and insights.

Usage:
    python analyze-org-structure.py --stats
    python analyze-org-structure.py --hierarchy
    python analyze-org-structure.py --departments
"""

import yaml
import argparse
import sys
from collections import defaultdict, Counter
from pathlib import Path

def load_yaml(yaml_file):
    """Load and parse YAML file"""
    try:
        with open(yaml_file, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading YAML file: {e}")
        sys.exit(1)

def analyze_stats(org_data):
    """Generate organization statistics"""
    stats = {
        'total_roles': 0,
        'departments': 0,
        'levels': Counter(),
        'unique_ids': set()
    }
    
    def count_roles(section):
        if isinstance(section, dict):
            if 'roles' in section:
                stats['departments'] += 1
                for role in section['roles']:
                    stats['total_roles'] += 1
                    stats['levels'][role.get('level', 'unknown')] += 1
                    role_id = role.get('id')
                    if role_id:
                        stats['unique_ids'].add(role_id)
            
            # Recursively check other sections
            for key, value in section.items():
                if key != 'roles':
                    count_roles(value)
        elif isinstance(section, list):
            for item in section:
                count_roles(item)
    
    # Count all roles in the organization
    for key, value in org_data.items():
        if key not in ['principal', 'chief_of_staff']:  # Skip top-level entries
            count_roles(value)
    
    return stats

def analyze_hierarchy(org_data):
    """Analyze reporting hierarchy"""
    hierarchy = {}
    role_map = {}
    
    def build_role_map(section, path=""):
        if isinstance(section, dict):
            if 'roles' in section:
                for role in section['roles']:
                    role_id = role.get('id')
                    if role_id:
                        role_map[role_id] = {
                            'title': role.get('title'),
                            'level': role.get('level'),
                            'reports_to': role.get('reports_to'),
                            'manages': role.get('manages', []),
                            'department': path
                        }
            
            # Recursively build map
            for key, value in section.items():
                if key != 'roles':
                    new_path = f"{path}/{key}" if path else key
                    build_role_map(value, new_path)
        elif isinstance(section, list):
            for item in section:
                build_role_map(item, path)
    
    # Build the role map
    for key, value in org_data.items():
        if key not in ['principal', 'chief_of_staff']:
            build_role_map(value, key)
    
    # Analyze hierarchy
    issues = []
    for role_id, role_info in role_map.items():
        reports_to = role_info.get('reports_to')
        if reports_to and reports_to not in role_map:
            issues.append(f"Role {role_id} reports to non-existent role: {reports_to}")
        
        manages = role_info.get('manages', [])
        for managed_role in manages:
            if managed_role not in role_map:
                issues.append(f"Role {role_id} manages non-existent role: {managed_role}")
    
    return role_map, issues

def analyze_departments(org_data):
    """Analyze department structure"""
    departments = {}
    
    def extract_departments(section, name=""):
        if isinstance(section, dict):
            if 'roles' in section:
                dept_info = {
                    'title': section.get('title', name),
                    'role_count': len(section['roles']),
                    'levels': Counter(),
                    'roles': []
                }
                
                for role in section['roles']:
                    dept_info['levels'][role.get('level', 'unknown')] += 1
                    dept_info['roles'].append({
                        'id': role.get('id'),
                        'title': role.get('title'),
                        'level': role.get('level')
                    })
                
                departments[name] = dept_info
            
            # Recursively extract departments
            for key, value in section.items():
                if key != 'roles':
                    extract_departments(value, key)
    
    # Extract all departments
    for key, value in org_data.items():
        if key not in ['principal', 'chief_of_staff']:
            extract_departments(value, key)
    
    return departments

def main():
    parser = argparse.ArgumentParser(description='Analyze organization structure')
    parser.add_argument('yaml_file', help='YAML file to analyze')
    parser.add_argument('--stats', action='store_true', help='Show organization statistics')
    parser.add_argument('--hierarchy', action='store_true', help='Analyze reporting hierarchy')
    parser.add_argument('--departments', action='store_true', help='Analyze department structure')
    parser.add_argument('--all', action='store_true', help='Show all analyses')
    
    args = parser.parse_args()
    
    if not any([args.stats, args.hierarchy, args.departments, args.all]):
        parser.error("Must specify at least one analysis type (--stats, --hierarchy, --departments, or --all)")
    
    # Load organization data
    org_data = load_yaml(args.yaml_file)
    
    if args.stats or args.all:
        print("=== ORGANIZATION STATISTICS ===")
        stats = analyze_stats(org_data)
        print(f"Total Roles: {stats['total_roles']}")
        print(f"Departments: {stats['departments']}")
        print(f"Unique Role IDs: {len(stats['unique_ids'])}")
        print("\nRole Levels:")
        for level, count in stats['levels'].most_common():
            print(f"  {level}: {count}")
        print()
    
    if args.hierarchy or args.all:
        print("=== HIERARCHY ANALYSIS ===")
        role_map, issues = analyze_hierarchy(org_data)
        print(f"Total Roles in Hierarchy: {len(role_map)}")
        
        if issues:
            print("\nHierarchy Issues:")
            for issue in issues:
                print(f"  ⚠️  {issue}")
        else:
            print("✅ No hierarchy issues found")
        print()
    
    if args.departments or args.all:
        print("=== DEPARTMENT ANALYSIS ===")
        departments = analyze_departments(org_data)
        print(f"Total Departments: {len(departments)}")
        print("\nDepartment Details:")
        for name, dept in departments.items():
            print(f"  {dept['title']} ({name})")
            print(f"    Roles: {dept['role_count']}")
            print(f"    Levels: {dict(dept['levels'])}")
        print()

if __name__ == "__main__":
    main()
