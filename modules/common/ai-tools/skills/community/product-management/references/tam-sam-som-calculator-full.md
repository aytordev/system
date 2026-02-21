# TAM/SAM/SOM Calculator — Full Framework

## Purpose

Guide product managers through calculating Total Addressable Market (TAM),
Serviceable Available Market (SAM), and Serviceable Obtainable Market (SOM) for
a product idea. The output is a citation-backed market sizing analysis that
withstands investor and executive scrutiny — not a back-of-napkin guess.

## When to Use

- Pitching to investors or executives (market size for a deck)
- Validating whether a product idea has a large enough market
- Prioritizing product lines by market opportunity
- Setting realistic growth targets grounded in data

## When Not to Use

- Internal tools with captive users (no external market to size)
- Before defining the problem space (sizing requires a clear problem)
- As the sole validation method (pair with customer research)

## The Three-Tier Model

| Tier | Definition                                               | Question It Answers                     |
|------|----------------------------------------------------------|-----------------------------------------|
| TAM  | Total market demand — no constraints, 100% capture       | "How big is the entire opportunity?"    |
| SAM  | Segment you can realistically target (geo, product fit)  | "Who can we actually reach?"            |
| SOM  | Portion of SAM you can capture in 1-3 years              | "What can we realistically win?"        |

Each tier narrows the previous one. TAM without SAM/SOM is a fantasy number.
SOM without TAM/SAM lacks context for growth potential.

## Four-Question Adaptive Process

### Question 1: Problem Space

Define what problem space you are sizing. The answer drives all subsequent
questions.

Options to consider:
- B2B SaaS productivity (workflow automation, project management)
- Consumer fintech (budgeting, payments, investing)
- Healthcare / telehealth (mental health, clinical tools)
- E-commerce enablement (payments, logistics, storefronts)
- Custom problem space based on your product

### Question 2: Geographic Region

Where you are targeting determines data sources and market constraints.

| Region         | Key Data Sources                                  | Notes                                   |
|----------------|---------------------------------------------------|-----------------------------------------|
| United States  | US Census Bureau, BLS, IBISWorld, Statista         | Most granular data available            |
| European Union | Eurostat, local statistical agencies               | Factor in GDPR/compliance costs         |
| Global         | World Bank, IMF, Gartner, Forrester                | Broader but less granular               |
| Specific       | Country-level statistical agencies                 | Narrow but defensible                   |

### Question 3: Industry / Market Segments

Identify the specific industry or segment that intersects with your problem
space. Use industry reports with real numbers.

Example (B2B SaaS targeting US):
- SMB services sector: 5.4M businesses, $1.2T revenue (US Census, 2023)
- Professional services: 1.1M firms, $850B revenue (IBISWorld, 2023)
- Healthcare providers: 900K practices, $4T industry (BLS, 2023)

### Question 4: Customer Demographics / Firmographics

Narrow to the specific customer segment affected by the problem.

Example (SMB services sector):
- SMBs with 10-50 employees: 1.2M businesses, $400B revenue
- SMBs with 50-250 employees: 600K businesses, $800B revenue
- Solo entrepreneurs/freelancers: 3.5M self-employed, $200B revenue

## Calculation Method

### TAM Calculation

```
TAM = Total population in problem space x Average Revenue Per Account (ARPA)
```

Always cite the data source for population and ARPA. Show the math explicitly.

Example:
```
Population: 5.4M SMBs (US Census Bureau, 2023)
ARPA: $2,000/year (based on competitor pricing analysis)
TAM = 5.4M x $2,000 = $10.8B
```

### SAM Calculation

```
SAM = TAM population filtered by geographic, product, and segment constraints x ARPA
```

Example:
```
Segment: SMBs with 10-50 employees in services sector
Population: 1.2M businesses (US Census Bureau, 2023)
SAM = 1.2M x $2,000 = $2.4B
```

Document every filter applied and why.

### SOM Calculation

```
SOM = SAM x Realistic market share % (accounting for competition and GTM capacity)
```

SOM should be 1-20% of SAM for Year 1-3. Anything higher requires justification.

Example:
```
Year 1: 5% of SAM = 60K customers = $120M
Year 2: 10% of SAM = 120K customers = $240M
Year 3: 15% of SAM = 180K customers = $360M
```

Ground SOM in GTM constraints: sales capacity, marketing budget, conversion rates.

## Output Template

```markdown
# TAM/SAM/SOM Analysis

**Problem Space:** [From Q1]
**Region:** [From Q2]
**Industry Segment:** [From Q3]
**Target Customers:** [From Q4]

## Total Addressable Market (TAM)
- **Population:** [N] ([Source, Year])
- **ARPA:** $[X] ([Basis])
- **TAM:** $[X]B
- **Calculation:** [Show math]

## Serviceable Available Market (SAM)
- **Segment:** [Narrowed population]
- **Population:** [N] ([Source, Year])
- **SAM:** $[X]B
- **Assumptions:** [List filtering assumptions]

## Serviceable Obtainable Market (SOM)
- **Market Share Assumption:** [X]% Year 1, [Y]% Year 2, [Z]% Year 3
- **Year 1:** [N] customers, $[X]M revenue
- **Year 2:** [N] customers, $[X]M revenue
- **Year 3:** [N] customers, $[X]M revenue
- **Basis:** [Competition, GTM capacity, conversion rates]

## Data Sources
- [Source 1: Name, Year, URL]
- [Source 2: Name, Year, URL]
- [Source 3: Name, Year, URL]

## Validation Questions
1. Does TAM align with third-party industry reports?
2. Is SAM realistically serviceable given our GTM motion?
3. Is SOM achievable given competitive landscape?
```

## Worked Example (Mini)

```
Problem Space: B2B workflow automation for SMBs
Region: United States
Segment: SMBs with 10-50 employees in services sector

TAM: 5.4M SMBs x $2,000 ARPA = $10.8B
SAM: 1.2M SMBs (10-50 employees) x $2,000 = $2.4B
SOM: 5% of SAM (Year 1) = 60K customers = $120M

Sources: US Census Bureau (2023), IBISWorld (2023), Statista (2023)
```

## Common Failure Modes

| Failure Mode               | Example                                      | Fix                                                         |
|----------------------------|----------------------------------------------|-------------------------------------------------------------|
| TAM without citations      | "The market is $50B" (no source)             | Cite industry reports with URLs                             |
| SOM equals SAM             | "SAM is $5B, SOM is $5B"                     | SOM should be 1-20% of SAM; account for competition        |
| No population estimates    | Only dollar amounts, no customer counts      | Always include customer population alongside revenue        |
| Static assumptions         | Calculated once, never updated               | Reassess annually as markets and competition shift          |
| Ignoring GTM constraints   | "SOM is 50% of SAM in Year 1"               | Ground SOM in sales capacity, budget, conversion rates      |
| Mixing B2B and B2C metrics | Using consumer population for B2B ARPA       | Match population type to revenue model                      |

## Quality Checklist

- [ ] TAM, SAM, and SOM each have explicit population counts and dollar values
- [ ] Every number has a cited source (name, year, URL where possible)
- [ ] Math is shown, not just final numbers
- [ ] SAM filters are documented and justified
- [ ] SOM is grounded in GTM capacity, not wishful thinking
- [ ] Year 1-3 projections included for SOM
- [ ] Competition acknowledged in SOM assumptions
- [ ] Validation questions answered or flagged for follow-up

## Optional Helper Script

If you have population and ARPU numbers already, use the deterministic calculator:

```bash
python3 scripts/market-sizing.py --population 5400000 --arpu 1000 --sam-share 30% --som-share 10%
```

This computes the math and generates a Markdown table. It does not fetch data.

## Relationship to Other Frameworks

1. Problem Statement — defines the problem space that scopes the market
2. TAM/SAM/SOM (this document) — sizes the market opportunity
3. Positioning Statement — the "For [target]" segment comes from SAM
4. Recommendation Canvas — market sizing informs business outcome projections
5. Roadmap Planning — SOM growth targets feed into quarterly objectives
