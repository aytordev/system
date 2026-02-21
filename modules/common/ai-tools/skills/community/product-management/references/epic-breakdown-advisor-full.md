# Epic Breakdown Advisor — Full Framework

## Purpose

Systematically decompose large epics into small, independently deliverable user stories
using Richard Lawrence's Humanizing Work methodology. The approach applies 9 splitting
patterns in a defined sequence, guided by a three-step process: validate, split, evaluate.
Every resulting story must be a vertical slice (end-to-end user value across architectural
layers), never a horizontal slice (single technical layer).

## When to Use

- An epic is too large to fit in a single sprint.
- Acceptance criteria contain multiple Given/When/Then scenarios bundled together.
- The team cannot estimate the epic with confidence.
- You need to expose low-value work that can be deprioritized or eliminated.
- You want repeatable, non-arbitrary story decomposition.

## When NOT to Use

- The story is already small and passes INVEST criteria including "Small."
- The work is a pure technical task with no user-facing outcome (reframe first).
- The epic sits in a chaotic domain where priorities shift daily (stabilize first).

## The Three-Step Process

### Step 1 — Pre-Split Validation (INVEST Check)

Before any splitting, verify the epic satisfies all INVEST criteria except "Small."

| Criterion   | Question                                                        | If Fails                          |
|-------------|-----------------------------------------------------------------|-----------------------------------|
| Independent | Can it be prioritized without hard dependencies on other work?  | Flag the dependency               |
| Negotiable  | Does it leave room for collaborative implementation discovery?  | Reframe; it is too prescriptive   |
| Valuable    | Does it deliver observable value to a user?                     | STOP. Combine with related work   |
| Estimable   | Can the team size it even roughly?                              | May need a spike first            |
| Testable    | Are there concrete pass/fail acceptance criteria?               | Refine before splitting           |

If the story fails the **Valuable** check, do not split it. Merge it with related
work until it delivers a meaningful user increment.

### Step 2 — Apply the 9 Splitting Patterns (In Order)

Work through the patterns sequentially. Stop at the first one that fits.

#### Pattern 1: Workflow Steps

Split into thin end-to-end slices, not step-by-step phases.

- Wrong: Story 1 = Editorial review, Story 2 = Legal approval, Story 3 = Publish.
- Right: Story 1 = Publish (simple path, no reviews), Story 2 = Add editorial review,
  Story 3 = Add legal approval. Each story delivers the full workflow at increasing
  sophistication.

#### Pattern 2: Operations (CRUD)

The word "manage" signals bundled operations. Split into Create, Read, Update, Delete.

- Original: "Manage user accounts."
- Split: Create account / View account / Edit account / Delete account.

#### Pattern 3: Business Rule Variations

Different rules for different scenarios become separate stories.

- Original: "Flight search with flexible dates."
- Split: Search by date range / Search by specific weekends / Search by date offsets.

#### Pattern 4: Data Variations

Different data types or structures each become their own story, delivered just-in-time.

- Original: "Geographic search (counties, cities, custom areas)."
- Split: Search by county / Add city search / Add custom area search.

#### Pattern 5: Data Entry Methods

Build the simplest interface first, then add sophisticated UI as follow-ups.

- Original: "Search with calendar date picker."
- Split: Search by date (basic text input) / Add visual calendar picker.

#### Pattern 6: Major Effort

When the first implementation carries most complexity and additions are trivial.

- Original: "Accept credit card payments (Visa, MC, Amex, Discover)."
- Split: Accept Visa (build payment infrastructure) / Add MC, Amex, Discover.

#### Pattern 7: Simple/Complex

Find the simplest version that still delivers value. Extract variations.

- Original: "Flight search with max stops, nearby airports, flexible dates."
- Split: Basic search (origin, destination, date) / Add max stops / Add nearby airports
  / Add flexible dates.

#### Pattern 8: Defer Performance

Deliver functional value first. Optimize later.

- Original: "Real-time search with <100ms response time."
- Split: Search works (no performance guarantee) / Optimize to <100ms.

#### Pattern 9: Break Out a Spike

Last resort when uncertainty prevents splitting. Time-box an investigation to answer
specific questions, then return and split with better understanding.

Spikes produce learning, not shippable code. After the spike, restart at Pattern 1.

### Step 3 — Evaluate Split Quality

After splitting, validate against two criteria:

1. **Does the split reveal low-value work you can deprioritize or eliminate?**
   Good splits expose the 80/20 principle: most value concentrates in a small portion
   of functionality.

2. **Does the split produce roughly equal-sized stories?**
   Equal-sized stories give product owners greater prioritization flexibility.

If neither criterion is met, try a different pattern.

## The Meta-Pattern

Across all 9 patterns, follow this sequence:

1. Identify the core complexity.
2. List all variations.
3. Reduce to one complete slice (simplest variation delivering end-to-end value).
4. Make remaining variations separate stories.

## Cynefin Domain Considerations

| Domain                      | Strategy                                                          |
|-----------------------------|-------------------------------------------------------------------|
| Low uncertainty (Obvious)   | Find all stories, prioritize by value/risk                        |
| High uncertainty (Complex)  | Identify 1-2 learning stories; avoid exhaustive enumeration       |
| Chaos                       | Defer splitting until stability emerges; focus on stabilization   |

## Output Template

```markdown
# Epic Breakdown Plan

**Epic:** [Title]
**Pre-Split Validation:** Passes INVEST (except Small)
**Splitting Pattern Applied:** [Pattern name]
**Rationale:** [Why this pattern fits]

## Story Breakdown

### Story 1: [Title] (Simplest Complete Slice)

**As a** [persona]
**I want to** [action]
**So that** [outcome]

**Acceptance Criteria:**
Given [precondition]
When  [action]
Then  [outcome]

**Why first:** [Delivers core value; simpler variations follow]
**Estimated effort:** [Days/points]

### Story 2: [Title] (First Variation)
[Repeat structure]

## Split Evaluation

- Does this split reveal low-value work? [Analysis]
- Does this split produce equal-sized stories? [Analysis]

## INVEST Validation (Each Story)

- Independent: Stories can be developed in any order
- Negotiable: Implementation details discoverable collaboratively
- Valuable: Each delivers observable user value
- Estimable: Team can size each story
- Small: Each fits in 1-5 days
- Testable: Clear acceptance criteria
```

## Worked Example — Iterative Splitting

**Epic:** "Checkout flow with discounts (member, VIP, first-time) and payment
(Visa, Mastercard, Amex)."

**First pass — Pattern 1 (Workflow Steps):**
1. Add items to cart
2. Apply discount
3. Complete payment

**Story 2 still 4 days — re-split with Pattern 3 (Business Rules):**
- 2a: Apply member discount (10%)
- 2b: Apply VIP discount (20%)
- 2c: Apply first-time discount (5%)

**Story 3 still 5 days — re-split with Pattern 6 (Major Effort):**
- 3a: Accept Visa (build payment infrastructure)
- 3b: Add Mastercard, Amex support

**Final result:** 6 stories, all 1-2 days each.

## Common Pitfalls

| Pitfall                         | Symptom                                      | Fix                                                              |
|---------------------------------|----------------------------------------------|------------------------------------------------------------------|
| Skipping pre-split validation   | Jump straight to splitting                   | Always run INVEST check first                                    |
| Step-by-step workflow splitting | Story 1 = review, Story 2 = approve         | Each story must cover the full workflow (thin end-to-end slice)  |
| Horizontal slicing              | Story 1 = API, Story 2 = UI                 | Every story includes front-end + back-end for observable value   |
| Forcing a pattern               | Applying workflow split when there is none   | If the pattern does not apply, move to the next one              |
| Not re-splitting large stories  | 3 stories, each 5+ days                     | Restart at Pattern 1 for each large story                        |
| Ignoring split evaluation       | Split but never ask about low-value work     | After every split, check for work you can eliminate              |

## Practice Guidance

Teams reach fluency in 2.5-3 hours across multiple practice sessions (per Humanizing
Work). The recommended approach:

1. Analyze recently completed features with hindsight.
2. Walk completed work through the pattern flowchart.
3. Find multiple split approaches for each feature.
4. Build shared vocabulary with domain-specific pattern examples.

## References

- Richard Lawrence and Peter Green, *The Humanizing Work Guide to Splitting User Stories*
- Bill Wake, *INVEST in Good Stories* (2003)
- Source: https://www.humanizingwork.com/the-humanizing-work-guide-to-splitting-user-stories/
- Source skill: `deanpeters/Product-Manager-Skills` — `skills/epic-breakdown-advisor/SKILL.md`
