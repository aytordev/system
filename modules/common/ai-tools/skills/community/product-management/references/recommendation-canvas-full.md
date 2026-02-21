# Recommendation Canvas — Full Framework

## Purpose

Build a structured, defensible recommendation for stakeholders when proposing a
new product solution — especially AI-powered features that carry higher
uncertainty and risk. The canvas synthesizes business outcomes, customer outcomes,
problem framing, solution hypotheses, positioning, risks, and value justification
into a single strategic document. Created for Productside's "AI Innovation for
Product Managers" course.

## When to Use

- Proposing a new AI-powered product or feature
- Pitching to executives or securing budget and sponsorship
- Evaluating whether a solution idea is worth pursuing
- Aligning cross-functional stakeholders (product, engineering, data science)
- After completing initial discovery (you need context to fill this canvas)

## When Not to Use

- Trivial features that do not warrant strategic framing
- Before any discovery work (the canvas synthesizes insights, it does not create them)
- As a replacement for experimentation (the canvas informs experiments)

## Ten-Section Framework

### Section 1: Business Outcome

What is in it for the business? Use the outcome formula:

```
[Direction] [Metric] [Outcome] [Context] [Acceptance Criteria]
```

Good: "Increase by 15% the monthly recurring revenue from enterprise customers
within 12 months"
Bad: "Increase revenue" (not measurable, not time-bound)

**Quality test:** Can you track this metric? Is there a timeframe? Is it
ambitious but realistic?

### Section 2: Product Outcome

What is in it for the customer? Same formula, from the user's perspective:

```
[Direction] [Metric] [Outcome] [Context from persona's POV] [Acceptance Criteria]
```

Good: "Reduce by 60% the time spent manually processing invoices for small
business owners"
Bad: "Improve UX" (not measurable, not customer-centric)

**Quality test:** Is it written from the user's perspective? Does it name an
outcome, not a feature?

### Section 3: Problem Statement

Frame the problem using a persona-centric narrative (2-3 sentences from the
user's point of view). Reference the Problem Statement framework.

```
Sarah is a freelance designer managing 10 clients. She spends 8 hours/month
manually tracking invoices and chasing late payments. By the time she follows
up, some clients have moved to other designers, costing her revenue.
```

**Quality test:** Does this sound like the user's voice? Is it specific and
grounded in research, not assumptions?

### Section 4: Solution Hypothesis

Use the If/Then hypothesis format:

```
If we [action or solution]
for [target persona]
Then we will [attain desirable outcome]
```

Example: "If we provide AI-powered invoice reminders that auto-send at optimal
times for freelance designers, then we will reduce time spent on payment
follow-ups by 70%."

#### Tiny Acts of Discovery

Define 2-3 lightweight experiments to validate the hypothesis before committing
engineering resources:

1. Prototype AI reminder system and test with 5 freelancers
2. A/B test manual vs. AI-timed reminders for 20 users
3. Survey users on perceived value after 2 weeks

**Quality test:** Are experiments fast (days/weeks)? Cheap (prototypes, not
full builds)? Falsifiable (could prove you wrong)?

#### Proof-of-Life

Define how you will know the hypothesis is valid:

```
We know our hypothesis is valid if within [timeframe] we observe:
- [Quantitative signal]: 80% of users send reminders via the AI system
- [Qualitative signal]: 8 out of 10 users report saving 5+ hours/month
```

### Section 5: Positioning Statement

Use the standard positioning format:

```
For [target customer]
that need [underserved need]
[product name]
is a [product category]
that [statement of benefit]

Unlike [primary competitor]
[product name]
provides [unique differentiation]
```

### Section 6: Assumptions and Unknowns

Make hidden assumptions visible and testable:

- **Assumption:** Users will trust AI-generated reminders
- **Assumption:** Payment timing optimization increases response rates
- **Unknown:** Do users prefer email or SMS reminders?
- **Unknown:** What is the price sensitivity threshold?

Each assumption should be testable via the Tiny Acts of Discovery.

### Section 7: PESTEL Risks

Categorize risks by Political, Economic, Social, Technological, Environmental,
and Legal dimensions. Separate into high-priority (investigate now) and
lower-priority (monitor over time).

**Risks to Investigate (High Priority):**

| Category       | Risk                                                      |
|----------------|-----------------------------------------------------------|
| Political      | Regulatory changes to AI-generated communications         |
| Economic       | Downturn reduces willingness to pay for premium features  |
| Social         | Users perceive AI reminders as impersonal or pushy        |
| Technological  | AI model accuracy degrades without retraining             |
| Environmental  | Energy costs of AI processing at scale                    |
| Legal          | GDPR compliance for storing customer email patterns       |

**Risks to Monitor (Lower Priority):**
List risks that do not require immediate action but should be watched.

**Quality test:** Are risks specific and actionable, not generic? "GDPR
compliance for storing client timing data" beats "regulations might change."

### Section 8: Value Justification

Convince C-level executives this is worth doing:

```
Is this valuable? [Absolutely yes / Yes with caveats / No / Absolutely not]

Justification:
1. Addresses the #1 pain point per user research (8/10 interviews cited this)
2. Differentiates from competitors who only offer manual reminders
3. Low technical risk — leverages existing AI infrastructure
4. 20% churn reduction = $500K ARR impact
```

**Quality test:** Would a skeptical CFO find this convincing? Use data, not
feelings.

### Section 9: Success Metrics

Define SMART metrics (Specific, Measurable, Attainable, Relevant, Time-Bound):

1. 80% of active users adopt AI reminders within 3 months
2. Average time on payment follow-ups decreases by 50% within 6 months
3. Net Promoter Score for invoicing feature increases from 6 to 8 within 6 months

### Section 10: Next Steps

Concrete, sequenced actions:

1. Run 2-week prototype test with 10 beta users
2. Conduct legal review of GDPR implications
3. Build lightweight AI model for reminder timing
4. Present findings to exec team for go/no-go decision
5. If validated, add to Q2 roadmap

## Output Template

```markdown
# Recommendation Canvas: [Product/Feature Name]

## Business Outcome
- [Direction] [Metric] [Outcome] [Context] [Timeframe]

## Product Outcome
- [Direction] [Metric] [Outcome] [User context] [Timeframe]

## Problem Statement
[2-3 sentence persona-centric narrative]

## Solution Hypothesis
**If we** [action] **for** [persona] **Then we will** [outcome]

### Tiny Acts of Discovery
1. [Experiment 1]
2. [Experiment 2]
3. [Experiment 3]

### Proof-of-Life
Within [timeframe] we observe:
- [Quantitative signal]
- [Qualitative signal]

## Positioning Statement
For [target] that need [need], [product] is a [category] that [benefit].
Unlike [competitor], [product] provides [differentiation].

## Assumptions & Unknowns
- [ASSUMPTION] [Description]
- [UNKNOWN] [Description]

## PESTEL Risks
### Investigate
- [Category]: [Specific risk]
### Monitor
- [Category]: [Specific risk]

## Value Justification
[Yes/No] — [3 numbered justifications with data]

## Success Metrics
1. [SMART metric 1]
2. [SMART metric 2]
3. [SMART metric 3]

## Next Steps
1. [Action with timeline]
2. [Action with timeline]
3. [Action with timeline]
```

## Common Failure Modes

| Failure Mode                     | Example                                      | Fix                                                         |
|----------------------------------|----------------------------------------------|-------------------------------------------------------------|
| Vague outcomes                   | "Increase revenue. Improve UX."              | Use outcome formula: Direction + Metric + Context + Time    |
| Solution-first thinking          | Problem statement is "We need AI-powered X"  | Frame problem from user perspective; let solution emerge    |
| Skipping Tiny Acts of Discovery  | Hypothesis goes straight to roadmap          | Define 2-3 lightweight experiments before committing        |
| Generic PESTEL risks             | "Regulations might change"                   | Be specific: "GDPR for storing email timing data"           |
| Weak value justification         | "Customers will like it"                     | Use data: "#1 pain point, $500K ARR impact, low tech risk"  |
| Missing proof-of-life criteria   | No way to know if hypothesis was validated   | Define quantitative + qualitative signals with timeframes   |

## Quality Checklist

- [ ] Business outcome is measurable with a specific metric and timeframe
- [ ] Product outcome is written from the user's perspective
- [ ] Problem statement is persona-centric and based on research
- [ ] Hypothesis uses If/Then format with a falsifiable prediction
- [ ] At least 2 Tiny Acts of Discovery defined (fast, cheap, falsifiable)
- [ ] Proof-of-life criteria include both quantitative and qualitative signals
- [ ] Positioning statement names the target, category, benefit, and differentiator
- [ ] Assumptions are explicit and each one is testable
- [ ] PESTEL risks are specific, not generic
- [ ] Value justification uses data and would convince a skeptical executive
- [ ] Success metrics are SMART
- [ ] Next steps are concrete, sequenced, and time-bound

## Relationship to Other Frameworks

1. Problem Statement — informs the problem narrative (Section 3)
2. Proto-Persona — defines the target persona referenced throughout
3. Epic Hypothesis — provides the If/Then hypothesis structure (Section 4)
4. Positioning Statement — provides the positioning format (Section 5)
5. PESTEL Analysis — provides the risk categorization model (Section 7)
6. Jobs-to-be-Done — informs customer outcomes (Section 2)
7. TAM/SAM/SOM — market sizing informs business outcome projections (Section 1)
