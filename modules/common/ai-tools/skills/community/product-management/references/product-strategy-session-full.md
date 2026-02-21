# Product Strategy Session — Full Framework

## Purpose

The product strategy session is a multi-phase workflow that takes a product from
strategic ambiguity to validated direction with concrete, executable plans. It
orchestrates positioning, problem framing, customer discovery, solution exploration,
prioritization, and roadmap planning into a cohesive end-to-end process spanning
2-4 weeks. Use it to establish or refresh product strategy, ensuring alignment
across stakeholders before committing engineering resources to execution.

This is not a one-time workshop. It is a repeatable strategic process with built-in
decision points that adapt the workflow based on what you learn at each phase.

## When to Use

- Launching a new product or major initiative
- Annual or quarterly strategic planning cycles
- Repositioning an existing product after a pivot or market shift
- Onboarding new product leaders who need to align on strategy
- When the team disagrees on direction and needs structured alignment

## When NOT to Use

- When strategy is already clear, validated, and aligned
- For tactical feature additions that do not require strategic re-evaluation
- When executive sponsorship is absent (strategy without authority will not stick)

## Six-Phase Process

### Phase 1: Positioning and Market Context (Week 1, Days 1-2)

**Goal:** Define target customer, problem space, and differentiation.

**Activities:**

1. **Positioning Workshop** (90 min)
   Run the full positioning workshop to produce a draft Geoffrey Moore positioning
   statement. Participants: PM, product leadership, marketing, sales.

2. **Proto-Persona Definition** (60 min)
   Create 1-3 hypothesis-driven proto-personas based on available customer data.
   Participants: PM, design, customer-facing teams.

3. **Jobs-to-be-Done Mapping** (60 min)
   Write JTBD statements for each persona to ground the problem space.
   Participants: PM, design.

**Decision Point 1:** Do we have enough customer context to proceed?
- If YES: move to Phase 2.
- If NO: run 5-10 discovery interviews first. Add 1 week.

### Phase 2: Problem Framing and Validation (Week 1, Days 3-5)

**Goal:** Frame the core customer problem and validate it is worth solving.

**Activities:**

1. **Problem Framing Canvas** (120 min)
   MITRE canvas process: Look Inward, Look Outward, Reframe. Output: refined
   problem statement and "How Might We" question. Participants: PM, design,
   engineering lead, customer success.

2. **Formal Problem Statement** (30 min)
   Convert the canvas output into a structured problem statement for PRD/roadmap.

3. **Customer Journey Map** (90 min, optional)
   Use when the problem spans multiple touchpoints or lifecycle phases.

**Decision Point 2:** Is the problem validated with customers?
- If YES: move to Phase 3.
- If NO: run 5-10 customer discovery interviews. Add 1 week.

### Phase 3: Solution Exploration (Week 2, Days 1-3)

**Goal:** Generate solution options, evaluate feasibility and impact, select what to build.

**Activities:**

1. **Opportunity Solution Tree** (90 min)
   Map 3 opportunities with 3 solutions each. Select POC recommendation.
   Alternative: use Lean UX Canvas for hypothesis-driven approach.

2. **Epic Hypotheses** (60 min per epic)
   Write hypothesis statements for the top 3-5 initiatives.

3. **User Story Map** (120 min, optional)
   For complex features that need release planning with backbone and slices.

**Decision Point 3:** Do we need to test solutions before committing?
- If high uncertainty: design and run POC experiments with 10-20 customers. Add 1-2 weeks.
- If low uncertainty: proceed directly to Phase 4.

### Phase 4: Prioritization and Roadmap (Week 2, Days 4-5)

**Goal:** Prioritize initiatives and sequence them into an executable roadmap.

**Activities:**

1. **Choose Prioritization Framework** (30 min)
   Use the prioritization advisor to select RICE, ICE, Value/Effort, or another
   framework appropriate to your context.

2. **Score and Prioritize Epics** (90 min)
   Apply the chosen framework with PM, engineering lead, and product leadership.
   Output: ranked backlog of epics.

3. **Sequence Roadmap** (60 min)
   Organize epics into quarters or releases (Q1: Epics A, B; Q2: Epics C, D, E).

4. **TAM/SAM/SOM Analysis** (60 min, optional)
   For executive presentations, fundraising, or market sizing validation.

### Phase 5: Stakeholder Alignment (Week 3)

**Goal:** Present strategy, gather feedback, refine.

**Activities:**

1. **Press Release Draft** (60 min, optional)
   Amazon Working Backwards-style press release for major launches or exec buy-in.

2. **Strategy Presentation** (60 min)
   Cover: positioning statement (Phase 1), problem statement (Phase 2), solution
   options and prioritization (Phase 3-4), roadmap (Phase 4).
   Participants: executives, product leadership, key stakeholders.

3. **Refine Based on Feedback** (1-2 days)
   Incorporate feedback into strategy artifacts.

### Phase 6: Execution Planning (Week 4)

**Goal:** Break strategy into executable work.

**Activities:**

1. **Epic Breakdown** (90 min)
   Use Richard Lawrence's 9 splitting patterns to decompose the top epic into
   user stories. Participants: PM, design, engineering.

2. **Write User Stories** (30 min per story)
   Each story includes acceptance criteria and is testable independently.

3. **Plan First Sprint/Release** (60 min)
   Create sprint backlog or release plan from prioritized stories.

## Timeline Summary

```
Week 1: Positioning + Problem Framing
  Days 1-2: Positioning workshop, proto-personas, JTBD mapping
  Days 3-5: Problem framing canvas, problem statement, journey map
  Decision: problem validated? If no, +1 week discovery

Week 2: Solution Exploration + Prioritization
  Days 1-3: Opportunity solution tree, epic hypotheses, story map
  Decision: test solutions? If yes, +1-2 weeks experiments
  Days 4-5: Prioritization framework, scoring, roadmap sequencing

Week 3: Stakeholder Alignment
  Press release (optional), strategy presentation, refinement

Week 4: Execution Planning
  Epic breakdown, user stories, first sprint planning
```

**Total time:** 2 weeks minimum, 3 weeks typical, 4-6 weeks maximum (with discovery
and experiments).

## Key Decision Points

The decision points are what prevent this from becoming waterfall planning. They
inject feedback loops:

| After Phase | Question                            | If NO                                 |
|-------------|-------------------------------------|---------------------------------------|
| Phase 1     | Enough customer context?            | Run 5-10 discovery interviews (+1 wk) |
| Phase 2     | Problem validated with customers?   | Run 5-10 discovery interviews (+1 wk) |
| Phase 3     | Solutions tested enough to commit?  | Run POC experiments (+1-2 wks)        |

Skip unnecessary phases when uncertainty is low. Extend when uncertainty is high.
The workflow adapts to what you learn.

## Common Pitfalls

| Pitfall                          | Symptom                                               | Fix                                                       |
|----------------------------------|-------------------------------------------------------|-----------------------------------------------------------|
| Skipping problem validation      | Jump from positioning to solutions                    | Force Decision Point 2 — validate problem before solutions |
| Solo PM exercise                 | PM runs session alone, presents finished strategy     | Include cross-functional participants in every workshop    |
| No executive sponsorship         | Execs do not attend Phase 5 alignment                 | Secure exec commitment and schedule Phase 5 before starting |
| Ignoring decision points         | Run all 6 phases regardless of certainty              | Use decision points to skip or extend based on uncertainty |
| Analysis paralysis               | Team spends 6+ weeks in strategy mode, never executes | Time-box to 2-4 weeks; after Phase 6, move to execution   |
| Strategy without constraints     | Roadmap has 20 epics, no sequencing                   | Force stack-rank; roadmap must answer "what comes first?"  |

## Participant Guide

| Phase   | Required Participants                          | Optional Participants     |
|---------|------------------------------------------------|---------------------------|
| Phase 1 | PM, product leadership, marketing, sales       | Design                    |
| Phase 2 | PM, design, engineering lead, customer success  | Sales, support            |
| Phase 3 | PM, design, engineering lead                   | Data science              |
| Phase 4 | PM, engineering lead, product leadership       | Business ops, finance     |
| Phase 5 | Executives, product leadership, stakeholders   | Full product team         |
| Phase 6 | PM, design, engineering                        | QA                        |

## Related Frameworks

This workflow orchestrates the following skills:

- **Positioning Workshop** (`positioning-workshop-full.md`) — Phase 1
- **Problem Framing Canvas** (`problem-framing-canvas-full.md`) — Phase 2
- **Problem Statement** (`problem-statement-full.md`) — Phase 2
- **Customer Journey Map** (`customer-journey-map-full.md`) — Phase 2 (optional)
- **Discovery Process** (`discovery-process-full.md`) — Phases 1-2 (if validation needed)
- **Prioritization Advisor** (`prioritization-advisor-full.md`) — Phase 4
- **TAM/SAM/SOM Calculator** (`tam-sam-som-calculator-full.md`) — Phase 4 (optional)
- **Press Release** (`press-release-full.md`) — Phase 5 (optional)
- **PRD Development** (`prd-development-full.md`) — Phase 6
- **User Story** (`user-story-full.md`) — Phase 6
- **Roadmap Planning** (`roadmap-planning-full.md`) — Phase 4

## References

- Teresa Torres, *Continuous Discovery Habits* (2021) — opportunity solution tree
- Jeff Gothelf, *Lean UX* (2016) — hypothesis-driven product development
- Marty Cagan, *Inspired* (2017) — product discovery process
- Source: `deanpeters/Product-Manager-Skills` — product-strategy-session skill
