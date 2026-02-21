---
title: TAM SAM SOM Calculator
impact: CRITICAL
impactDescription: Unsourced market size numbers destroy investor and executive credibility
tags: strategy, market-sizing, tam, sam, som, financial
---

## TAM SAM SOM Calculator

**Impact: CRITICAL (Unsourced market size numbers destroy investor and executive credibility)**

Calculate market opportunity in three nested layers: Total Addressable Market (the full global demand if you served everyone), Serviceable Addressable Market (the segment you can realistically reach with your current model), and Serviceable Obtainable Market (your realistic capture in years 1–3 given competition and go-to-market constraints). Every figure must cite a real source — analyst reports, census data, or bottom-up calculations from known unit counts. Do not use top-down TAM figures as your SOM; the gap between TAM and SOM is where strategy lives.

**Incorrect (top-down, uncited, no methodology):**

```markdown
Market Sizing:
- TAM: $50B (the global HR software market)
- SAM: $10B (mid-market segment, roughly 20%)
- SOM: $500M (we'll capture 5% in year 3)

Source: "industry reports"
```

**Correct (bottom-up, cited, with methodology):**

```markdown
TAM — Bottom-up calculation:
- 180,000 mid-market SaaS companies in the US (source: Crunchbase 2025, companies
  with $10M–$500M ARR)
- Average spend on financial close software: $28,000/yr (source: Gartner MQ 2024)
- TAM = 180,000 × $28,000 = $5.04B

SAM — Segment filter:
- Target: Series B–D SaaS, finance team 3–15 people, using Salesforce CRM
- Estimated count: 22,000 companies (source: LinkedIn Sales Navigator export, Feb 2025)
- SAM = 22,000 × $28,000 = $616M

SOM — Realistic capture:
- Year 1 target: 80 customers (based on current sales capacity of 4 AEs × 20 deals)
- Year 3 target: 600 customers (with planned team expansion)
- SOM = 600 × $24,000 ACV = $14.4M ARR by end of year 3
```

Reference: [Full framework](../references/tam-sam-som-calculator-full.md)
