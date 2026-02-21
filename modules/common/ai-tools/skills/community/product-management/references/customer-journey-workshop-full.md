# Customer Journey Workshop — Full Framework

## Purpose

Guide product managers through creating a customer journey map by asking adaptive
questions about the actor (persona), scenario/goal, journey phases, actions and
emotions, and opportunities for improvement. Use this to visualize the end-to-end
customer experience, identify pain points, and create a shared mental model across
teams — avoiding surface-level feature lists and ensuring discovery focuses on
real customer problems.

This is a discovery and alignment tool, not a feature roadmap.

## When to Use

- Starting customer discovery (understanding current experience)
- Identifying pain points for retention or engagement initiatives
- Aligning cross-functional teams on customer perspective
- Prioritizing which problems to solve first

## When NOT to Use

- When you already understand the customer journey deeply
- For technical refactoring with no customer-facing journey
- As a substitute for user research (maps require research input)

## Five Key Components (NNGroup Framework)

1. **Actor** — a specific persona whose perspective anchors the map
2. **Scenario + Expectations** — the situational context and associated goals
3. **Journey Phases** — high-level stages (e.g., discover, try, buy, use, support)
4. **Actions, Mindsets, and Emotions** — behaviors, thoughts, and emotional responses
5. **Opportunities** — insights identifying where the experience can improve

## Journey Map Structure

```
Actor: [Persona Name]
Scenario: [Goal/Context]

Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
   |          |          |          |          |
 Actions    Actions    Actions    Actions    Actions
 Thoughts   Thoughts   Thoughts   Thoughts   Thoughts
 Emotions   Emotions   Emotions   Emotions   Emotions
   |          |          |          |          |
 Opportunities  ...      ...       ...       ...
```

## What This Is NOT

- **Not a service blueprint** — journey maps focus on customer perspective, not internal operations
- **Not a user story map** — journey maps support discovery, not implementation planning
- **Not an experience map** — journey maps target specific users and products, not broad human behaviors

## Interactive Workshop Flow (5 Steps)

### Step 0: Gather Context

Before the workshop, collect:
- User interviews, discovery notes, support tickets
- Churn reasons, exit surveys, NPS feedback
- Analytics data (drop-off points, feature usage)
- Personas or proto-personas
- Website copy, product descriptions, positioning
- Competitor reviews (G2, Capterra)

### Step 1: Identify the Actor

Choose which persona anchors this map:

1. **Primary persona** — main target customer (most common starting point)
2. **Secondary persona** — a different user segment with distinct needs
3. **High-churn persona** — segment with highest churn rate (good for retention)
4. **Newly discovered persona** — emerging segment from recent research

Rule: one map per persona. If multiple personas matter, create separate maps.

### Step 2: Define Scenario and Goal

What is the actor trying to accomplish?

1. **First-time use** — onboarding, from discovery to activation
2. **Core workflow** — recurring task (e.g., "create invoice," "run report")
3. **Problem resolution** — user encounters issue and seeks help
4. **Upgrade/expansion** — free user considering paid, or expanding usage

Extract and record: actor, scenario, and goal.

### Step 3: Identify Journey Phases

Break the journey into 4-6 high-level phases from start to end.

Example phases for "First-time use":
```
Discover → Evaluate → Try → Activate → Use → Expand
```

Validate with the team: do these phases capture the full journey? Add, remove,
or rename as needed.

### Step 4: Map Actions, Thoughts, and Emotions per Phase

For each phase, document 3-5 items in each category:

```
Phase 3: Try (Onboarding)

Actions:
- Signs up with email
- Receives welcome email
- Logs in, sees empty dashboard
- Searches for "getting started" guide

Thoughts:
- "This looks promising, but I'm not sure where to start"
- "What's the first step?"

Emotions:
- Curious but uncertain
- Slightly frustrated (no clear next step)

Pain Points:
- No onboarding checklist or guided tour
- Empty state doesn't suggest next action
```

Repeat for all phases. Include emotional highs AND lows — not just positive states.

### Step 5: Identify and Prioritize Opportunities

Generate 5-7 opportunities from pain points with highest emotional intensity
or drop-off rates. Rank each by impact (HIGH / MEDIUM / LOW).

```
Opportunity 1: Onboarding lacks guided first steps (Phase: Try)
  Pain Point: Users see empty dashboard, don't know what to do
  Evidence: 60% of signups don't complete first action in 24 hours
  Proposed Solution: Add interactive onboarding checklist
  Impact: HIGH — directly affects activation rate

Opportunity 2: Pricing page is confusing (Phase: Evaluate)
  Pain Point: Users don't understand which plan fits
  Evidence: 70% bounce rate on pricing page
  Proposed Solution: Add plan comparison tool
  Impact: HIGH — directly affects trial conversion
```

## Output Template

```markdown
# Customer Journey Map: [Scenario]

**Actor:** [Persona]
**Scenario:** [Context]
**Goal:** [What actor is trying to accomplish]
**Date:** [Today's date]

## Journey Phases
[Phase 1] → [Phase 2] → [Phase 3] → [Phase 4] → [Phase 5]

## Phase Details

### Phase 1: [Name]
**Actions:** [list]
**Thoughts:** [quotes]
**Emotions:** [states with intensity]
**Pain Points:** [observed problems]

[...repeat for all phases...]

## Opportunities (Prioritized)

### 1. [Name] — HIGH IMPACT
Phase: [which phase]
Pain Point: [description]
Evidence: [data/research]
Proposed Solution: [how to address]

[...continue for all opportunities...]

## Next Steps
1. Validate with discovery interviews
2. Prioritize fixes with team
3. Create problem statements for top opportunities
4. Design experiments for solutions
```

## Worked Example (SaaS Onboarding)

**Actor:** Primary persona — small business owner
**Scenario:** First-time use — new user onboarding to activation
**Phases:** Discover, Evaluate, Try, Activate, Use, Expand

Phase 3 (Try) mapped:
```
Actions: Signs up via Google SSO, receives welcome email, logs in to
  empty dashboard, clicks Help, watches 5-min tutorial, attempts first
  project but gets stuck on form.

Thoughts: "This looks easy enough" ... "Wait, what's a workspace vs
  a project?" ... "Do I need to fill out all these fields?"

Emotions: Excited initially, confused by terminology, frustrated by
  unclear form.

Pain Points: No guided checklist, unexplained terminology, too many
  required fields upfront.
```

Top opportunities identified:
1. Add onboarding checklist — HIGH (affects activation)
2. Simplify terminology — MEDIUM (affects understanding)
3. Reduce required form fields — MEDIUM (affects completion rate)

## Common Failure Modes

| Failure Mode                       | Example                                            | Fix                                               |
|------------------------------------|----------------------------------------------------|----------------------------------------------------|
| Mapping internal process           | Phases are "Lead generated → Qualified → Closed"   | Map from customer POV, not sales funnel            |
| No emotions or pain points         | Journey lists actions only                         | Add customer quotes and emotional states           |
| Too many personas in one map       | Trying to map "all users" at once                  | One map per persona; create separate maps          |
| Opportunities not prioritized      | List of 20 items with no ranking                   | Rank by impact (HIGH/MEDIUM/LOW) with evidence     |
| Map created in isolation           | PM builds it alone without team input              | Facilitate as cross-functional workshop            |

## Relationship to Other Frameworks

- **Customer Journey Map** — the component template this workshop produces
- **Proto-Persona** — defines the actor for journey mapping
- **Problem Statement** — converts journey opportunities into problem statements
- **Discovery Interview Prep** — gathers research input for the mapping session
- **Opportunity Solution Tree** — designs solutions for journey opportunities
