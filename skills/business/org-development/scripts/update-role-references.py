#!/usr/bin/env python3
"""
Reference Updater

Updates all role references from titles to IDs in organization files.

Usage:
    python update-role-references.py "Old Role Title" "new-role-id" file1.yaml file2.md
"""

import re
import sys
import os

def update_role_references(old_title, new_id, file_path):
    """Update all references from title to ID"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Create backup
        backup_path = f"{file_path}.backup"
        with open(backup_path, 'w') as f:
            f.write(content)
        
        # Replace title references with ID references
        pattern = f'"{old_title}"'
        replacement = f'"{new_id}"'
        updated_content = re.sub(pattern, replacement, content)
        
        # Also handle variations
        variations = [
            f"'{old_title}'",
            f'{old_title}',
            f': {old_title}',
            f'- {old_title}',
        ]
        
        for variation in variations:
            if "'" in variation:
                replacement_var = f"'{new_id}'"
            else:
                replacement_var = new_id
            updated_content = re.sub(re.escape(variation), replacement_var, updated_content)
        
        with open(file_path, 'w') as f:
            f.write(updated_content)
        
        print(f"Updated {file_path}")
        print(f"  Backup saved to: {backup_path}")
        
        return True
    except Exception as e:
        print(f"Error updating {file_path}: {e}")
        return False

def main():
    if len(sys.argv) < 4:
        print("Usage: python update-role-references.py <old_title> <new_id> <file1> [file2 ...]")
        print("Example: python update-role-references.py \"Sales Director\" \"sales-director\" org-structure.yaml")
        sys.exit(1)
    
    old_title = sys.argv[1]
    new_id = sys.argv[2]
    files = sys.argv[3:]
    
    print(f"Updating references from '{old_title}' to '{new_id}'")
    
    success_count = 0
    for file_path in files:
        if os.path.exists(file_path):
            if update_role_references(old_title, new_id, file_path):
                success_count += 1
        else:
            print(f"File not found: {file_path}")
    
    print(f"\nCompleted: {success_count}/{len(files)} files updated successfully")

if __name__ == "__main__":
    main()
