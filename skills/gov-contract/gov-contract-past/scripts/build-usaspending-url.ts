#!/usr/bin/env tsx
/**
 * Build USAspending.gov search URLs for past award research.
 *
 * Usage:
 *   tsx build-usaspending-url.ts --psc S203 --naics 722310 --place "Some City, ST" --agency "DEPT OF DEFENSE"
 *
 * The script outputs the search URL to stdout. Use agent-browser to pull the page.
 */

interface UsaSpendingParams {
  psc?: string;
  naics?: string;
  place?: string;
  state?: string;
  zip?: string;
  agency?: string;
  dateRange?: string; // e.g., "2015-01-01|2026-01-01"
}

function buildUsaSpendingUrl(params: UsaSpendingParams): string {
  const base = "https://www.usaspending.gov/search/?hash=";

  const filters: Record<string, unknown> = {
    time_period: params.dateRange
      ? [{ start_date: params.dateRange.split("|")[0], end_date: params.dateRange.split("|")[1] }]
      : [{ start_date: "2015-01-01", end_date: "2026-01-01" }],
  };

  if (params.psc) {
    filters.product_or_service_code = [params.psc];
  }

  if (params.naics) {
    filters.naics = [params.naics];
  }

  if (params.place || params.state || params.zip) {
    const placeParts: string[] = [];
    if (params.place) placeParts.push(params.place);
    if (params.state) placeParts.push(params.state);
    if (params.zip) placeParts.push(params.zip);
    filters.place_of_performance_locations = placeParts;
  }

  if (params.agency) {
    filters.agencies = [{ name: params.agency, tier: "toptier", type: "awarding" }];
  }

  // Award type: contracts only (IDV + Awards)
  filters.award_type = ["A", "B", "C", "D"];

  const hashPayload = JSON.stringify({ filters });
  // Note: USAspending uses a hashed representation. In practice, users should
  // navigate to the site and apply filters manually, or use the API.
  // This function returns the API endpoint for programmatic access.

  return buildApiUrl(params);
}

function buildApiUrl(params: UsaSpendingParams): string {
  // USAspending API v2 endpoint for awards search
  const baseUrl = new URL("https://api.usaspending.gov/api/v2/search/spending_by_award/");

  const body: Record<string, unknown> = {
    filters: {
      award_type_codes: ["A", "B", "C", "D"],
      time_period: [
        {
          start_date: params.dateRange?.split("|")[0] ?? "2015-01-01",
          end_date: params.dateRange?.split("|")[1] ?? "2026-01-01",
        },
      ],
    },
    fields: [
      "Award ID",
      "Recipient Name",
      "Start Date",
      "End Date",
      "Award Amount",
      "Awarding Agency",
      "Awarding Sub Agency",
      "Contract Award Type",
      "Award Type",
      "Funding Agency",
      "Funding Sub Agency",
      "Place of Performance City Code",
      "Place of Performance State Code",
      "Place of Performance Country Code",
      "Base Obligation Date",
      "generated_internal_id",
    ],
    page: 1,
    limit: 100,
    sort: "Award Amount",
    order: "desc",
  };

  if (params.psc) {
    (body.filters as Record<string, unknown>).product_or_service_code = [params.psc];
  }

  if (params.naics) {
    (body.filters as Record<string, unknown>).naics_codes = [params.naics];
  }

  if (params.place || params.state) {
    const loc: Record<string, string> = {};
    if (params.state) loc.state = params.state;
    if (params.place) loc.city = params.place;
    (body.filters as Record<string, unknown>).place_of_performance_locations = [loc];
  }

  if (params.agency) {
    (body.filters as Record<string, unknown>).agencies = [
      { name: params.agency, tier: "toptier", type: "awarding" },
    ];
  }

  return `${baseUrl.toString()}?${encodeURIComponent(JSON.stringify(body))}`;
}

function printUsage(): void {
  console.error(`
Usage: tsx build-usaspending-url.ts [options]

Options:
  --psc <code>        Product/Service Code (e.g., S203)
  --naics <code>      NAICS code (e.g., 722310)
  --place <city>      Place of performance city
  --state <st>        Place of performance state (2-letter)
  --zip <zip>         Place of performance ZIP
  --agency <name>     Awarding agency name
  --range <start|end> Date range (e.g., "2015-01-01|2026-01-01")
  --help              Show this help

Example:
  tsx build-usaspending-url.ts --psc S203 --naics 722310 --state TX --agency "DEPT OF DEFENSE"
`);
}

function parseArgs(args: string[]): UsaSpendingParams {
  const params: UsaSpendingParams = {};
  let i = 0;

  while (i < args.length) {
    const arg = args[i];
    switch (arg) {
      case "--psc":
        params.psc = args[++i];
        break;
      case "--naics":
        params.naics = args[++i];
        break;
      case "--place":
        params.place = args[++i];
        break;
      case "--state":
        params.state = args[++i];
        break;
      case "--zip":
        params.zip = args[++i];
        break;
      case "--agency":
        params.agency = args[++i];
        break;
      case "--range":
        params.dateRange = args[++i];
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

  return params;
}

if (require.main === module) {
  const params = parseArgs(process.argv.slice(2));

  if (!params.psc && !params.naics) {
    console.error("Error: At least one of --psc or --naics is required.");
    printUsage();
    process.exit(1);
  }

  const apiUrl = buildApiUrl(params);
  console.log(apiUrl);
}

export { buildUsaSpendingUrl, buildApiUrl, UsaSpendingParams };
