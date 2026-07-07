# Role ID System

## Purpose
The Role ID system provides stable, unique identifiers for organizational roles that survive renames, reorganizations, and structural changes.

## ID Format
```
[department]-[role-type]-[specialization]
```

### Components
- **department**: Parent department (kebab-case)
- **role-type**: Functional role type (director, manager, specialist, etc.)
- **specialization**: Specific area of expertise (optional)

## Examples

### Executive Level
- `chief-of-staff` - Chief of Staff
- `shared-services-director` - Director of Shared Services

### Department Directors
- `executive-operations-director`
- `brand-communications-director`
- `sales-director`
- `marketing-director`
- `customer-service-director`
- `security-director`
- `finance-director`
- `legal-director` (General Counsel)
- `data-research-director`
- `technology-engineering-director`
- `people-workplace-director`
- `strategy-governance-director`

### Managers
- `sales-operations-manager`
- `marketing-operations-manager`
- `customer-service-manager`
- `security-digital-manager`
- `finance-tax-manager`
- `finance-wealth-manager`
- `legal-contracts-manager`

### Specialists
- `sales-lead-generation-specialist`
- `marketing-content-specialist`
- `security-ai-engineer`
- `finance-cloud-gcp-specialist`
- `technology-frontend-typescript-specialist`
- `people-recruiting-specialist`

## ID Generation Rules

### 1. Uniqueness
- Each ID must be unique across the entire organization
- No duplicates allowed, even across different departments

### 2. Stability
- IDs should not change when roles are renamed
- IDs should not change when roles move between departments
- Only create new IDs when creating genuinely new roles

### 3. Descriptive
- IDs should be human-readable and descriptive
- Avoid cryptic abbreviations
- Include sufficient context to understand the role

### 4. Consistency
- Use kebab-case for all components
- Follow established naming patterns
- Maintain consistency across similar roles

## Reference Usage

### In Instructions
Always reference roles by ID, not title:
```yaml
# Correct
reports_to: "sales-director"
manages: ["sales-lead-generation-specialist", "sales-account-executive"]

# Incorrect
reports_to: "Sales Director"
manages: ["Lead Generation Specialist", "Account Executive"]
```

### In Documentation
Include both ID and title for clarity:
```markdown
## Sales Director (ID: sales-director)
Overall sales strategy and team leadership.
```

### In Code
Use IDs for programmatic references:
```python
def get_role_hierarchy(role_id):
    # Look up role by stable ID
    return org_structure[role_id]
```

## Migration Strategy

### Existing Roles
1. Assign IDs to all existing roles
2. Update documentation to include IDs
3. Gradually transition references to use IDs
4. Maintain title-to-ID mapping for backward compatibility

### New Roles
1. Generate appropriate ID during role creation
2. Document ID in role definition
3. Use ID consistently from the start

## Validation

Use the provided validation scripts to ensure role ID integrity:

### Duplicate Check
```bash
./scripts/validate-role-ids.sh
```

### Reference Validation
The validator automatically checks that all `reports_to` references exist as valid role IDs.

### Format Validation
The validator ensures all IDs follow the required format (lowercase letters, numbers, hyphens only).

## Best Practices

### DO
- Use descriptive, meaningful IDs
- Maintain consistent naming patterns
- Document ID assignments
- Validate ID uniqueness and references
- Use IDs consistently across all documentation

### DON'T
- Change IDs when renaming roles
- Use cryptic abbreviations
- Create duplicate IDs
- Mix ID formats
- Reference roles by title in technical contexts

## Tools and Scripts

### ID Generator
**Script**: `scripts/generate-role-id.py`

Generates consistent role IDs following the format `[department]-[role-type]-[specialization]`.

**Usage**:
```bash
# Basic role ID
python scripts/generate-role-id.py sales director
# Output: sales-director

# With specialization
python scripts/generate-role-id.py security engineer ai
# Output: security-ai-engineer
```

### Reference Updater
**Script**: `scripts/update-role-references.py`

Updates all role references from titles to IDs in organization files.

**Usage**:
```bash
# Update single file
python scripts/update-role-references.py "Sales Director" "sales-director" references/organization-structure.yml

# Update multiple files
python scripts/update-role-references.py "Sales Director" "sales-director" references/organization-structure.yml docs/*.md
```

**Features**:
- Creates backup files before updating
- Handles multiple reference formats (quotes, no quotes, etc.)
- Reports success/failure for each file

### Role ID Validator
**Script**: `scripts/validate-role-ids.sh`

Validates role ID uniqueness, format compliance, and reference integrity.

**Usage**:
```bash
./scripts/validate-role-ids.sh
```

**Validations**:
- Duplicate role ID detection
- Reference validity (all reports_to references exist)
- ID format compliance (lowercase letters, numbers, hyphens only)

### Organization Structure Analyzer
**Script**: `scripts/analyze-org-structure.py`

Provides comprehensive analysis of the organization structure.

**Usage**:
```bash
# Show statistics
python scripts/analyze-org-structure.py references/organization-structure.yml --stats

# Analyze hierarchy
python scripts/analyze-org-structure.py references/organization-structure.yml --hierarchy

# Analyze departments
python scripts/analyze-org-structure.py references/organization-structure.yml --departments

# Show all analyses
python scripts/analyze-org-structure.py references/organization-structure.yml --all
```

**Analyses**:
- Organization statistics (role counts, levels, departments)
- Hierarchy validation (reporting relationships)
- Department breakdown (roles per department, level distribution)

---

*This reference document provides comprehensive guidance for the Role ID system used in organizational development.*
