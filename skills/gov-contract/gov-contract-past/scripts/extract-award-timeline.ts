#!/usr/bin/env tsx
/**
 * Synthesize a contract award timeline from USAspending and FPDS data.
 *
 * Usage:
 *   tsx extract-award-timeline.ts --input <json-file>
 *
 * Input: JSON file with arrays of usaspending_awards and fpds_contracts
 * Output: Markdown timeline to stdout
 */

interface UsaSpendingAward {
  award_id?: string;
  piid?: string;
  recipient_name?: string;
  start_date?: string;
  end_date?: string;
  award_amount?: number;
  awarding_agency?: string;
  awarding_sub_agency?: string;
  contract_award_type?: string;
  award_type?: string;
  place_of_performance_state_code?: string;
  place_of_performance_city_code?: string;
  base_obligation_date?: string;
  generated_internal_id?: string;
}

interface FpdsContract {
  piid?: string;
  modification_number?: string;
  obligated_amount?: number;
  pricing_type?: string;
  contract_type?: string;
  action_type?: string;
  description_of_requirement?: string;
  signed_date?: string;
  effective_date?: string;
  completion_date?: string;
  number_of_offers_received?: number;
  extent_competed?: string;
  statutory_exception?: string;
  vendor_name?: string;
  unit_price?: number;
  quantity?: number;
  unit_of_measure?: string;
}

interface TimelineEntry {
  vendor: string;
  piid: string;
  periodStart: string;
  periodEnd: string;
  totalValue: number;
  contractType: string;
  competition: string;
  modifications: FpdsContract[];
  unitPrice?: number;
  quantity?: number;
  unitOfMeasure?: string;
}

function parseDate(dateStr?: string): Date | null {
  if (!dateStr) return null;
  const d = new Date(dateStr);
  return isNaN(d.getTime()) ? null : d;
}

function formatCurrency(amount?: number): string {
  if (amount === undefined || amount === null) return "N/A";
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0,
  }).format(amount);
}

function formatDate(date?: Date | null): string {
  if (!date) return "N/A";
  return date.toISOString().split("T")[0];
}

function buildTimeline(
  usaspendingAwards: UsaSpendingAward[],
  fpdsContracts: FpdsContract[]
): TimelineEntry[] {
  // Group FPDS records by PIID
  const fpdsByPiid = new Map<string, FpdsContract[]>();
  for (const contract of fpdsContracts) {
    const piid = contract.piid ?? "UNKNOWN";
    if (!fpdsByPiid.has(piid)) {
      fpdsByPiid.set(piid, []);
    }
    fpdsByPiid.get(piid)!.push(contract);
  }

  const timeline: TimelineEntry[] = [];

  for (const award of usaspendingAwards) {
    const piid = award.piid ?? award.generated_internal_id ?? "UNKNOWN";
    const fpdsRecords = fpdsByPiid.get(piid) ?? [];

    // Sort FPDS records by signed date
    fpdsRecords.sort((a, b) => {
      const da = parseDate(a.signed_date)?.getTime() ?? 0;
      const db = parseDate(b.signed_date)?.getTime() ?? 0;
      return da - db;
    });

    // Find base award (usually mod 0 or earliest)
    const baseAward =
      fpdsRecords.find((r) => r.modification_number === "0" || r.modification_number === undefined) ??
      fpdsRecords[0];

    // Find latest pricing info
    const latestPricing = [...fpdsRecords]
      .reverse()
      .find((r) => r.unit_price !== undefined && r.unit_price !== null);

    timeline.push({
      vendor: award.recipient_name ?? baseAward?.vendor_name ?? "Unknown",
      piid,
      periodStart: award.start_date ?? baseAward?.effective_date ?? "N/A",
      periodEnd: award.end_date ?? baseAward?.completion_date ?? "N/A",
      totalValue: award.award_amount ?? 0,
      contractType: baseAward?.contract_type ?? award.contract_award_type ?? "Unknown",
      competition: baseAward?.extent_competed ?? "Unknown",
      modifications: fpdsRecords.filter((r) => r.modification_number && r.modification_number !== "0"),
      unitPrice: latestPricing?.unit_price,
      quantity: latestPricing?.quantity,
      unitOfMeasure: latestPricing?.unit_of_measure,
    });
  }

  // Sort by start date descending (most recent first)
  timeline.sort((a, b) => {
    const da = parseDate(a.periodStart)?.getTime() ?? 0;
    const db = parseDate(b.periodStart)?.getTime() ?? 0;
    return db - da;
  });

  return timeline;
}

function generateMarkdown(timeline: TimelineEntry[]): string {
  const lines: string[] = [];
  lines.push("## Contract Award Timeline\n");

  if (timeline.length === 0) {
    lines.push("_No contract awards found for the given criteria._\n");
    return lines.join("\n");
  }

  for (const entry of timeline) {
    lines.push(`### ${entry.vendor} (${entry.periodStart} – ${entry.periodEnd})`);
    lines.push(`- **PIID:** ${entry.piid}`);
    lines.push(`- **Total Value:** ${formatCurrency(entry.totalValue)}`);

    if (entry.unitPrice !== undefined) {
      lines.push(`- **Unit Price:** ${formatCurrency(entry.unitPrice)} per ${entry.unitOfMeasure ?? "unit"}`);
    }

    if (entry.quantity !== undefined) {
      lines.push(`- **Quantity:** ${entry.quantity.toLocaleString()} ${entry.unitOfMeasure ?? "units"}`);
    }

    lines.push(`- **Contract Type:** ${entry.contractType}`);
    lines.push(`- **Competition:** ${entry.competition}`);

    if (entry.modifications.length > 0) {
      lines.push(`- **Modifications (${entry.modifications.length}):**`);
      for (const mod of entry.modifications.slice(0, 5)) {
        const modDate = formatDate(parseDate(mod.signed_date));
        const modDesc = mod.description_of_requirement ?? "No description";
        lines.push(`  - Mod ${mod.modification_number} (${modDate}): ${modDesc}`);
      }
      if (entry.modifications.length > 5) {
        lines.push(`  - ... and ${entry.modifications.length - 5} more`);
      }
    }

    lines.push("");
  }

  return lines.join("\n");
}

function printUsage(): void {
  console.error(`
Usage: tsx extract-award-timeline.ts --input <json-file>

Input JSON format:
{
  "usaspending_awards": [...],
  "fpds_contracts": [...]
}

Options:
  --input <file>    JSON input file (required, or read from stdin)
  --help            Show this help
`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  let inputFile: string | undefined;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--input" && args[i + 1]) {
      inputFile = args[++i];
    } else if (args[i] === "--help") {
      printUsage();
      process.exit(0);
    }
  }

  let inputData: string;

  if (inputFile) {
    const fs = await import("fs/promises");
    inputData = await fs.readFile(inputFile, "utf-8");
  } else {
    const chunks: Buffer[] = [];
    for await (const chunk of process.stdin) {
      chunks.push(chunk);
    }
    inputData = Buffer.concat(chunks).toString("utf-8");
  }

  const data = JSON.parse(inputData) as {
    usaspending_awards?: UsaSpendingAward[];
    fpds_contracts?: FpdsContract[];
  };

  const awards = data.usaspending_awards ?? [];
  const contracts = data.fpds_contracts ?? [];

  const timeline = buildTimeline(awards, contracts);
  const markdown = generateMarkdown(timeline);

  console.log(markdown);
}

if (require.main === module) {
  main().catch((err) => {
    console.error("Error:", err.message);
    process.exit(1);
  });
}

export { buildTimeline, generateMarkdown, TimelineEntry, UsaSpendingAward, FpdsContract };
