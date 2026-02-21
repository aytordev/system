# Positioning Workshop — Full Framework

## Purpose

The positioning workshop is a structured interactive discovery process that guides
product managers through articulating product positioning using Geoffrey Moore's
framework. It is not a brainstorming session or tagline generator — it is a
facilitated conversation that forces explicit, evidence-based choices about target
customers, unmet needs, product category, key benefits, and competitive
differentiation. Run it before writing PRDs, launch plans, or marketing materials
to ensure every downstream artifact is anchored in deliberate strategic positioning.

Based on April Dunford's methodology (*Obviously Awesome*) and Geoffrey Moore's
positioning statement format (*Crossing the Chasm*).

## When to Use

- Defining positioning for a new product launch
- Repositioning an existing product after a pivot or market shift
- Aligning stakeholders on product strategy before execution
- Preparing for launch, major release, or go-to-market planning
- Before writing positioning-dependent artifacts (PRD, press release, sales deck)

## When NOT to Use

- Before customer research exists (positioning requires validated insights)
- For internal tools with captive users (no market positioning needed)
- When positioning is already clear, validated, and aligned across stakeholders

## Workshop Process

### Step 0: Gather Context

Before asking positioning questions, collect grounding materials:

**For your own product:**
- Current website copy, homepage, product pages, value proposition
- Existing positioning statements or messaging documents
- Customer testimonials, case studies, support tickets
- Sales objections, win/loss analysis, competitive intelligence
- Product descriptions or feature lists

**For repositioning:**
- Current positioning (what you say today)
- Customer feedback revealing gaps between positioning and reality
- Competitive intel (how competitors position themselves)

**For a new or hypothetical product:**
- Find 2-3 competitor or analog products
- Copy their homepage, positioning statements, or value propositions
- Use these as reference points for the discovery process

### Step 1: Target Customer Segment

Ask: "Who is the primary customer segment you serve?"

Offer adapted options based on context. Examples:

1. B2B: SMB decision-makers (10-50 employees managing operations)
2. B2B: Enterprise buyers (IT/Product leaders at 500+ companies)
3. B2C: Mass market consumers (demographic + behavior)
4. B2C: Niche enthusiasts (specific interest or activity)

The user selects or provides a custom segment with specifics: demographics, role,
company size, and behaviors.

### Step 2: Underserved Need (Jobs-to-be-Done)

Ask: "What underserved need or pain point does your target customer have?"

Adapt options based on the customer segment selected. Examples for B2B SMB:

1. Time-consuming manual work (10+ hours/week on automatable tasks)
2. Lack of visibility or control (no real-time status, missed deadlines)
3. Compliance or risk burden (fear of penalties due to manual errors)
4. Costly inefficiency (revenue loss from slow processes or friction)

Use language from customer testimonials and case studies when available.

### Step 3: Product Category

Ask: "What product category does your solution fit into?"

The category anchors how buyers evaluate you. Adapt based on previous answers:

1. Workflow automation platform
2. Business management software (all-in-one)
3. Vertical SaaS (purpose-built for a specific industry)
4. AI-powered assistant

Creating a new category is risky. Default to an existing one buyers understand
unless there is strong strategic rationale for category creation.

### Step 4: Key Benefit (Outcome, Not Feature)

Ask: "What is the primary benefit or outcome your product delivers?"

Focus on what the customer gets, not what the product has:

1. Time savings ("reduces manual work from 10 hours/week to 1 hour")
2. Error reduction ("eliminates 95% of manual data entry errors")
3. Cost savings ("saves $500/month in labor costs")

Quality check: reject features ("has AI", "includes dashboards"). Accept only
measurable outcomes ("makes decisions 3x faster", "prevents compliance violations").

### Step 5: Competitive Differentiation

Ask: "What is your primary competitor or competitive alternative, and how do you differ?"

1. Incumbent SaaS leader ("unlike Zapier, we offer no-code workflows")
2. Manual processes / spreadsheets ("unlike Excel, we provide real-time sync")
3. Vertical competitor ("unlike generic tools, we are pre-built for [industry]")
4. Enterprise-only solutions ("unlike enterprise tools, we are built for SMBs")

Use competitive intel from win/loss analysis and sales objections.

## Output: Positioning Statement

After all five questions, generate the statement using Geoffrey Moore's template:

```
For [target customer from Step 1]
who [underserved need from Step 2],
[Product Name]
is a [product category from Step 3]
that [key benefit from Step 4].
Unlike [primary competitor from Step 5],
[Product Name] [unique differentiation from Step 5].
```

**One-sentence version:**
[Product] is a [category] for [target] that [benefit], unlike [competitor] which
[limitation].

## Worked Example

**Context:** Acme Workflows, B2B SaaS automation for SMBs.

```
For small business owners (10-50 employees) managing daily operations
who spend 10+ hours/week on manual tasks like invoice processing and reporting,
Acme Workflows
is a no-code workflow automation platform
that reduces manual work from 10 hours/week to 1 hour.
Unlike Zapier, which requires technical setup and coding knowledge,
Acme Workflows provides visual, no-code workflows that non-technical
business owners can set up in 10 minutes.
```

**Why this works:**
- Target is specific (SMB owners, 10-50 employees, operations focus)
- Need is measurable (10+ hours/week on manual tasks)
- Category is clear (workflow automation)
- Benefit is outcome-focused (10 hours to 1 hour)
- Differentiation is defensible (no-code vs. technical setup)

## Anti-Example

```
For businesses
who need better tools,
ProductX
is a software
that improves productivity.
Unlike competitors,
ProductX provides better features.
```

Every field fails: target too broad, need vague, category meaningless, benefit
unmeasurable, differentiation empty.

## Common Pitfalls

| Pitfall                      | Symptom                                                | Fix                                                        |
|------------------------------|--------------------------------------------------------|------------------------------------------------------------|
| "For everyone"               | Target is "all businesses" or "anyone"                 | Narrow ruthlessly; pick the first beachhead segment        |
| Need is a feature request    | "Need better dashboards"                               | Ask "why?" until you reach the root pain                   |
| Category confusion           | "Next-generation platform for digital transformation"  | Pick a category buyers already understand                  |
| Differentiation is a feature | "Unlike competitors, we have AI"                       | Focus on outcomes: "reduces setup from 2 hours to 10 min"  |
| No customer validation       | Positioning created in a vacuum                        | Read it to 5 target customers; if they don't self-identify, revise |

## Post-Workshop Validation

After generating the positioning statement:

1. **Read it aloud to 5 target customers.** They should recognize themselves in
   the "For [target] who [need]" clause. If they shrug, revise.
2. **Share with stakeholders (product, marketing, sales).** Disagreement means
   the strategic decision has not been made yet.
3. **Test differentiation durability.** Can competitors copy this in 6 months?
   If yes, it is not real differentiation.
4. **Apply to downstream artifacts.** Update website, sales deck, PRD, and press
   release. If the positioning cannot drive these, it is too vague.

## Related Frameworks

- **Positioning Statement** (`positioning-statement-full.md`) — the output template
- **Proto-Persona** — defines the "For [target]" segment
- **Jobs-to-be-Done** — informs the "who [need]" clause
- **Problem Statement** — problem framing supports positioning
- **Press Release** — positioning informs press release messaging

## References

- Geoffrey Moore, *Crossing the Chasm* (1991) — origin of positioning statement format
- April Dunford, *Obviously Awesome* (2019) — modern positioning methodology
- Source: `deanpeters/Product-Manager-Skills` — positioning-workshop skill
