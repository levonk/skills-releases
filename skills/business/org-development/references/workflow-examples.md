# Workflow Examples

Detailed bash workflow examples for common organizational development operations.

## 1. Adding New Roles

```bash
# Step 1: Choose unique ID
id="department-role-type"

# Step 2: Add to YAML structure
- id: "${id}"
  title: "Role Title"
  level: "specialist"
  department: "department-name"
  reports_to: "manager-role-id"
  synopsis: "Brief description"
  rationale: "Business justification"

# Step 3: Update references
# Search for old references and update to use new ID
grep -r "old-role-title" org-files/
```

## 2. Restructuring Departments

```bash
# Step 1: Plan changes
- Identify affected roles (by ID)
- Map new reporting relationships
- Document rationale for changes

# Step 2: Update YAML structure
- Move role IDs between departments
- Update reports_to relationships
- Add rationale for organizational changes

# Step 3: Regenerate views
./generate-org-diagrams.sh full
./generate-org-diagrams.sh departments
```

## 3. Conflict Resolution

```bash
# Step 1: Identify conflicts
- Duplicate role titles
- Conflicting reporting relationships
- Missing role references

# Step 2: Resolve by ID
- Keep stable IDs
- Update titles and relationships
- Maintain referential integrity

# Step 3: Validate structure
./scripts/validate-org-structure.sh
```

## Diagram Generation

### Available Views

```bash
# From the skill directory, run:
./scripts/generate-org-diagrams.sh full          # Full detailed view (all roles)
./scripts/generate-org-diagrams.sh departments   # High-level department view
./scripts/generate-org-diagrams.sh sales        # Specific department view
./scripts/generate-org-diagrams.sh marketing    # Specific department view
```

### Custom Views

```bash
# Executive view (directors and above)
./scripts/generate-org-diagrams.sh executive

# Management view (managers and above)
./scripts/generate-org-diagrams.sh management

# Cross-functional view
./scripts/generate-org-diagrams.sh cross-functional
```

### Script Location

The diagram generation script is located at:
`scripts/generate-org-diagrams.sh`

This script:

- Reads YAML structure from `references/organization-structure.yml`
- Generates Mermaid diagrams for different organizational views
- Outputs to the Agent Org directory for easy access
- Supports multiple view types (full, departments, role-specific)

## Troubleshooting

### Common Issues

1. **Duplicate IDs** - Use unique identifiers
2. **Broken references** - Validate all reports_to IDs exist
3. **Inconsistent levels** - Ensure level matches role scope
4. **Missing rationales** - Document why each role exists

### Validation Commands

```bash
# Check for duplicate IDs
./scripts/validate-duplicate-ids.sh

# Validate reporting relationships
./scripts/validate-reporting-structure.sh

# Check department consistency
./scripts/validate-department-structure.sh
```
