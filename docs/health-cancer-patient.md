<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **health** · Status:  · Version: 1.0.0

Patient-side navigation guide for a new or advancing cancer diagnosis — what to do next at each stage. Triages where the patient is (newly diagnosed, in treatment, standard of care exhausted, or planning for end of life), then drives the right playbook: scheduling persistence, second opinions at major cancer centers, self-reading the NCCN standard of care, pushing for molecular/genetic testing, treatment decision discipline, clinical trials, record keeping, insurance and financial navigation, advocacy organizations, palliative care and hospice — plus the non-medical readiness layer: wills, living trusts, powers of attorney, advance directives and resuscitation wishes, and body disposition services (direct cremation providers like Neptune Society, burial, body donation). Materializes the cancer-patient-practices and estate-planning-practices knowledge bundles for offline use. Use when the user says they or a loved one was diagnosed with cancer, asks what to do after a cancer diagnosis, needs a second opinion, is weighing surgery or treatment, is looking for clinical trials, is overwhelmed by insurance or bills, asks about hospice or palliative care, needs estate documents in the face of serious illness, wants to document resuscitation/DNR wishes, or asks about cremation, burial, or body-disposition services. Make sure to use this skill whenever the user mentions a new cancer diagnosis, cancer treatment decisions, oncology navigation, end-of-life planning, advance directives, living wills, powers of attorney in a health context, or body disposition arrangements, even if they don't explicitly ask for guidance. Do NOT trigger on general medical questions unrelated to serious illness, fitness/diet advice, mental-health support, veterinary questions, or estate planning with no illness context (that work can still use the estate-planning-practices knowledge bundle directly).

## Metadata

| Field | Value |
|-------|-------|
| Name | `cancer-patient` |
| Category | `health` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- [`references/included/knowledge/cancer-patient-practices/overview.md`](references/included/knowledge/cancer-patient-practices/overview.md) — the medical navigation bundle (materialized at build time)
- [`references/included/knowledge/estate-planning-practices/overview.md`](references/included/knowledge/estate-planning-practices/overview.md) — the estate, directives, and disposition bundle (materialized at build time)

---

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **trigger-guard** (template, over-triggering-guard) — Shared over-triggering guard protocol
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Patient-side practices for navigating a cancer diagnosis — first steps, scheduling persistence, second opinions and cancer centers, NCCN standard of care, genetic/biomarker testing, treatment decisions, clinical trials, record keeping, insurance and financial toxicity, advocacy organizations, palliative care and hospice. Materialized at references/included/knowledge/cancer-patient-practices/ at build time.
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. The non-medical readiness layer — core estate documents (will, living trust), powers of attorney, advance directives and resuscitation wishes, body disposition (cremation, burial, donation, Neptune Society and alternatives), digital estate and beneficiaries, letter of instruction, after-death checklist. Materialized at references/included/knowledge/estate-planning-practices/ at build time.

---

- **Full skill**: [`skills/health/cancer-patient/SKILL.md`](skills/health/cancer-patient/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-10-16T05:04:49Z
