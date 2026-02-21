# Opportunity Solution Tree — Full Framework

## Purpose

The Opportunity Solution Tree (OST) is a visual discovery framework from Teresa
Torres' *Continuous Discovery Habits* that connects a desired outcome to customer
opportunities (problems, needs, desires), candidate solutions, and validation
experiments. It prevents "feature factory" syndrome by ensuring teams explore the
problem space before converging on solutions.

This is not a roadmap generator. It is a structured discovery process that
outputs validated opportunities with testable solution hypotheses.

## When to Use

- A stakeholder requests a feature or product initiative
- Starting discovery for a new product area
- Clarifying vague OKRs or strategic goals into actionable work
- Prioritizing which customer problems to solve first
- Aligning the team on what outcomes you are driving and why

## When Not to Use

- The problem is already validated — move to solution testing
- Tactical bug fixes or technical debt with no discovery needed
- Stakeholders demand a specific solution regardless — address alignment first

## Tree Structure

```
              Desired Outcome
                    |
       +------------+------------+
       |            |            |
  Opportunity   Opportunity   Opportunity
       |            |            |
    +--+--+      +--+--+      +--+--+
    |  |  |      |  |  |      |  |  |
   S1 S2 S3    S1 S2 S3    S1 S2 S3
    |                             |
  Experiment                  Experiment
```

Each level serves a distinct purpose:

1. **Desired Outcome** — the business or product metric you want to move
2. **Opportunities** — customer problems, needs, or desires that could drive that outcome
3. **Solutions** — ways to address each opportunity
4. **Experiments** — tests to validate whether solutions actually work

## Phase 1: Generate the Tree

### Step 1: Extract the Desired Outcome

The outcome is a specific, measurable business or product metric. Not a feature,
not a project name. Common categories:

| Category             | Example                                                  |
|----------------------|----------------------------------------------------------|
| Revenue growth       | Increase ARR by 15% within 12 months                    |
| Customer retention   | Reduce monthly churn from 5% to 3%                      |
| Customer acquisition | Increase trial-to-paid conversion from 15% to 25%       |
| Product efficiency   | Reduce average support ticket resolution from 4h to 1h  |

Bad outcome: "Improve user experience." (Not measurable.)
Good outcome: "Increase trial-to-paid conversion from 15% to 25%."

### Step 2: Identify Opportunities

Generate 3 opportunities — customer problems or needs that, if addressed, could
drive the desired outcome. Each opportunity must be:

- **A problem customers face**, not a solution disguised as a problem
- **Grounded in evidence** from research, support tickets, analytics, or interviews
- **Distinct** from the other opportunities (not overlapping)

Bad opportunity: "We need a mobile app." (That is a solution.)
Good opportunity: "Mobile-first users cannot access the product on the go."

Example set for "Increase trial-to-paid conversion from 15% to 25%":

1. **Users do not experience value during trial** — new users sign up but never
   reach the "aha moment," abandoning before seeing core value.
2. **Pricing is unclear or misaligned** — users are unsure what they get for the
   price; conversion funnel drops off at the pricing page.
3. **Free plan is good enough** — users stay on the free tier indefinitely because
   it meets their needs with no compelling upgrade trigger.

### Step 3: Map Solutions per Opportunity

For each selected opportunity, generate at least 3 candidate solutions. Each
solution should include:

- A brief description of what you would build or do
- A hypothesis stating what you believe will happen
- A suggested experiment type

Example solutions for "Users do not experience value during trial":

| Solution                     | Hypothesis                                         | Experiment                             |
|------------------------------|----------------------------------------------------|----------------------------------------|
| Guided onboarding checklist  | Structured guidance increases activation rate       | A/B test checklist vs. no checklist    |
| Time-to-value trigger nudges | Proactive prompts prevent drop-off                 | Track prompt engagement, measure lift  |
| Human-assisted onboarding    | Personal touch increases conversion for high-intent | Offer to 50 trial users, compare       |

## Phase 2: Select Proof of Concept

### Evaluation Criteria

Score each solution on three dimensions (1 = low, 5 = high):

| Dimension    | What It Measures                                          |
|--------------|-----------------------------------------------------------|
| Feasibility  | How quickly and cheaply can you build/test this?          |
| Impact       | How much could this move the desired outcome?             |
| Market Fit   | How well does this align with what customers want/expect? |

### Scoring Table Template

```
| Solution                     | Feasibility | Impact | Market Fit | Total | Rationale              |
|------------------------------|-------------|--------|------------|-------|------------------------|
| Guided onboarding checklist  | 4           | 4      | 5          | 13    | Proven pattern, fast   |
| Time-to-value triggers       | 3           | 3      | 4          | 10    | Needs analytics setup  |
| Human-assisted onboarding    | 5           | 5      | 3          | 13    | No dev work, unscalable|
```

Pick the highest-scoring solution as your POC. When scores tie, prefer the one
that generates the most learning with the least investment.

### Define the Experiment

Choose an experiment type matched to your confidence level:

| Experiment Type         | Best For                                    | Timeline  |
|-------------------------|---------------------------------------------|-----------|
| A/B test                | Quantitative validation, requires traffic   | 2-4 weeks |
| Prototype + usability   | Early-stage validation, low traffic          | 1-2 weeks |
| Manual concierge test   | Learning fast with no development work       | 1 week    |

Each experiment must specify:
- **Participants:** number and segment
- **Duration:** timeline
- **Success criteria:** what validates the hypothesis
- **Failure criteria:** what invalidates it

## Output Template

```markdown
# Opportunity Solution Tree

## Desired Outcome
Outcome: [Specific, measurable goal]
Target metric: [Current value -> Target value]
Why it matters: [Business rationale]

## Opportunities

### Opportunity 1: [Name]
Problem: [Description]
Evidence: [Source]
Solutions:
  1. [Solution A]
  2. [Solution B]
  3. [Solution C]

### Opportunity 2: [Name]
Problem: [Description]
Evidence: [Source]
Solutions:
  1. [Solution A]
  2. [Solution B]
  3. [Solution C]

### Opportunity 3: [Name]
Problem: [Description]
Evidence: [Source]
Solutions:
  1. [Solution A]
  2. [Solution B]
  3. [Solution C]

## Selected POC
Opportunity: [Selected]
Solution: [Selected]
Hypothesis: If we [solution], then [outcome metric] will [change] because [rationale].
Experiment type: [A/B test / Prototype / Concierge]
Participants: [Number, segment]
Duration: [Timeline]
Success criteria: [What validates]
Failure criteria: [What invalidates]

## Next Steps
1. Build experiment: [Specific action]
2. Run experiment: [Specific action]
3. Measure results: [Specific metric]
4. Decide: If successful, scale. If failed, try next solution.
```

## Common Pitfalls

| Pitfall                              | Consequence                               | Fix                                                    |
|--------------------------------------|-------------------------------------------|--------------------------------------------------------|
| Opportunities disguised as solutions | Premature convergence, no problem explored | Reframe as customer problems: "Users struggle with..." |
| Skipping divergence                  | Miss better alternatives, no learning      | Generate at least 3 solutions per opportunity          |
| Vague outcome                        | Cannot measure success or prioritize       | Make outcome measurable with current and target values |
| No experiments                       | High risk of building the wrong thing      | Every solution must map to an experiment               |
| Analysis paralysis                   | Team stuck in discovery, no progress       | Limit to 3 opportunities, 3 solutions each; pick, run  |

## Relationship to Other Frameworks

1. **Problem Statement** — frames opportunities as specific customer problems
2. **Jobs to Be Done** — identifies opportunities from JTBD research
3. **Epic Hypothesis** — turns validated solutions into testable epics
4. **User Story** — breaks experiments into deliverable stories
5. **Discovery Interview Prep** — validates opportunities through customer interviews
6. **PoL Probe** — designs lightweight validation experiments for solutions

## References

- Teresa Torres, *Continuous Discovery Habits* (2021) — origin of the OST framework
- Jeff Patton, *User Story Mapping* (2014) — outcome-driven product planning
- Ash Maurya, *Running Lean* (2012) — hypothesis-driven experimentation
- Source: `deanpeters/Product-Manager-Skills` — `skills/opportunity-solution-tree/SKILL.md`
