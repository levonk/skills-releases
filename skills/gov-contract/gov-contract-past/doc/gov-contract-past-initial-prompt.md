- Use the skill ~/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/ai/ai-skill-upsert
- create a new skill in ~/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/gov-contract/gov-contract-past
- create typescript code when the process is deterministic and agent-browser tool to pull web pages instead of doing image recogntion or HTML parsing
- to turn this flow into a skill 
``
You *can* get exactly what you’re asking for — **past vendors, past pricing, past contract structures, and how the government paid for the same service at the same location** — but SAM.gov alone won’t show it.  
The trick is knowing **which system shows which part of the history**.

Below is the exact workflow procurement analysts use to answer your scenario:

> “Government wants 3 meals/day for 500 people at Location Y.  
> What meal contracts were active at Location Y, by which vendor, and how much did they charge?”

---

# ✅ The short answer
Yes — you can see:

- **All past vendors** who provided that service  
- **How much they were paid**  
- **How they priced it** (per meal, per head, per day, fixed price, cost‑plus, etc.)  
- **Whether the contract was renewed, extended, or rebid**  
- **Why a new solicitation exists** (options expired, scope changed, bridge contract, etc.)

But you must use **three systems together**, not just SAM.gov.

---

# 🧭 The exact workflow to find past vendors & pricing for a service at a location

## 1️⃣ Step 1 — Start with the *current* solicitation on SAM.gov  
This gives you:

- Solicitation number  
- NAICS code  
- PSC code (Product/Service Code)  
- Place of performance (Location Y)  
- Description (“food services”, “meal preparation”, “catering”, etc.)

The key fields you need to extract are:

- **PSC code** (e.g., S203 – Food Services)  
- **NAICS code** (e.g., 722310 – Food Service Contractors)  
- **Place of performance ZIP or city**  
- **Agency**

These four fields let you find the past contracts.

Use: **SAM.gov Contract Awards**

---

## 2️⃣ Step 2 — Use USAspending.gov to find *all past awards* for that service at that location  
This is where you get the “who did it before and for how much” part.

Search using:

- **PSC code**  
- **NAICS code**  
- **Place of performance (city, county, ZIP)**  
- **Agency**

USAspending lets you filter by:

- Vendor  
- Award amount  
- Period of performance  
- Type of contract (fixed price, cost-plus, IDIQ, etc.)  
- Competition type (full & open, small business set‑aside, sole source)

This will show:

- Every vendor who provided meals at that location  
- How much they were paid  
- How many years they held the contract  
- Whether they won multiple times  
- Whether the contract was extended or modified

Use: **USAspending.gov**

---

## 3️⃣ Step 3 — Use FPDS.gov to see *how* they charged  
USAspending shows totals.  
FPDS shows **pricing structure**.

FPDS reveals:

- Unit prices (e.g., “$8.92 per meal”)  
- Quantity (e.g., “547,500 meals”)  
- Contract type (FFP, T&M, cost-plus)  
- All modifications (options exercised, funding increases, extensions)  
- Whether the contract ended normally or was bridged  
- Whether the incumbent bid again

This is where you see the *real* details.

Use: **FPDS.gov**

---

# 🧩 Putting it together for your example
> “3 meals/day for 500 people at Location Y”

### You will be able to see:

- Vendor A provided meals from 2019–2022  
- Vendor B took over in 2023  
- Vendor A charged \$X per meal  
- Vendor B charged \$Y per meal  
- Vendor A’s contract ended because the option years ran out  
- Vendor B’s contract is now expiring, so the agency is recompeting  
- A bridge contract was issued for 6 months  
- The new solicitation is the recompete

This is all visible through:

- **SAM.gov** → new solicitation  
- **USAspending** → past vendors + amounts  
- **FPDS** → pricing + contract structure + modifications  

---

# 🧨 Important: SAM.gov *does not* show past pricing  
SAM.gov only shows:

- The new solicitation  
- The award notice  
- Basic award amount (sometimes)

It does **not** show:

- Unit pricing  
- Past vendors  
- Past contract history  
- Modifications  
- Option-year renewals  
- Bridge contracts  

That’s why you need USAspending + FPDS.

---

# 🏁 Final answer
Yes — you can absolutely see:

- Past vendors  
- Past pricing  
- Past contract structure  
- Why the government is rebidding  
- Whether the contract was renewed or extended  
- How much was paid and how it was calculated  

You just need to use the right systems in the right order.

```