#!/usr/bin/env tsx
/**
 * Build FPDS.gov contract detail URLs from PIID (Procurement Instrument Identifier).
 *
 * Usage:
 *   tsx build-fpds-url.ts --piid W91CRB18C0012
 *
 * The script outputs the FPDS contract detail URL. Use agent-browser to pull the page.
 */

interface FpdsParams {
  piid: string;
  modNumber?: string;
}

/**
 * Build FPDS contract detail URL.
 * FPDS uses a servlet-based URL structure for contract details.
 */
function buildFpdsUrl(params: FpdsParams): string {
  const base = "https://www.fpds.gov/ezsearch/fpdsportal";

  // FPDS search by PIID
  const searchUrl = new URL(base);
  searchUrl.searchParams.set("q", `PIID:"${params.piid}"`);
  searchUrl.searchParams.set("s", "FPDS.GOV");
  searchUrl.searchParams.set("templateName", "1.5");
  searchUrl.searchParams.set("indexName", "awardfull");

  return searchUrl.toString();
}

/**
 * Build FPDS direct document URL if the document number is known.
 * This is useful for direct access when the FPDS internal doc ID is known.
 */
function buildFpdsDirectUrl(piid: string, modNumber?: string): string {
  const base = "https://www.fpds.gov/ezsearch/fpdsportal";
  const url = new URL(base);
  url.searchParams.set("q", `PIID:"${piid}"`);
  url.searchParams.set("s", "FPDS.GOV");

  if (modNumber) {
    url.searchParams.set("q", `PIID:"${piid}" AND "MOD NUMBER":"${modNumber}"`);
  }

  return url.toString();
}

function printUsage(): void {
  console.error(`
Usage: tsx build-fpds-url.ts --piid <piid> [--mod <modNumber>]

Options:
  --piid <id>     Procurement Instrument Identifier (required)
  --mod <num>     Modification number (optional)
  --help          Show this help

Example:
  tsx build-fpds-url.ts --piid W91CRB18C0012
  tsx build-fpds-url.ts --piid W91CRB18C0012 --mod P00001
`);
}

function parseArgs(args: string[]): FpdsParams {
  const params: Partial<FpdsParams> = {};
  let i = 0;

  while (i < args.length) {
    const arg = args[i];
    switch (arg) {
      case "--piid":
        params.piid = args[++i];
        break;
      case "--mod":
        params.modNumber = args[++i];
        break;
      case "--help":
        printUsage();
        process.exit(0);
        break;
      default:
        console.error(`Unknown argument: ${arg}`);
        printUsage();
        process.exit(1);
    }
    i++;
  }

  if (!params.piid) {
    console.error("Error: --piid is required.");
    printUsage();
    process.exit(1);
  }

  return params as FpdsParams;
}

if (require.main === module) {
  const params = parseArgs(process.argv.slice(2));
  const url = buildFpdsUrl(params);
  console.log(url);
}

export { buildFpdsUrl, buildFpdsDirectUrl, FpdsParams };
