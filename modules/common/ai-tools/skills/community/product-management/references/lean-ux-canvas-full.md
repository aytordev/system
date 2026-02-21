# Lean UX Canvas (v2) — Full Framework

## Purpose

The Lean UX Canvas is a one-page facilitation tool created by Jeff Gothelf that
frames product work around a business problem, not a solution to implement. It
aligns cross-functional teams on core assumptions, crafts testable hypotheses,
and ensures learning happens every sprint by exposing gaps in understanding
around problem, users, value, and solution viability.

Think of it as an insurance policy: it turns assumptions into experiments before
committing to full development. The canvas shifts conversations from outputs to
outcomes and prevents teams from building the wrong thing efficiently.

## When to Use

- Starting a new product initiative or feature
- Reframing an existing project when you suspect the team is building the wrong thing
- Aligning cross-functional teams on assumptions and experiments
- Planning discovery sprints or MVPs
- Stakeholders are solution-driven ("we need to build X") and you need to surface assumptions

## When Not to Use

- Problem and solution are already validated — move to execution
- Tactical bug fixes or technical debt with no learning needed
- Stakeholders have committed to a solution regardless of evidence — address alignment first

## Canvas Structure (8 Boxes)

The canvas is a 3-column, 3-row grid filled in a specific order:

```
+---------------------+--------------+-----------------------+
| 1. Business Problem |              | 2. Business Outcomes  |
|                     |              |                       |
+---------------------+ 5. Solutions +-----------------------+
| 3. Users            |  (spans      | 4. User Outcomes      |
|                     |   rows 1-2)  |    & Benefits         |
+---------------------+--------------+-----------------------+
| 6. Hypotheses       | 7. Learn     | 8. Least Work /       |
|                     |    First     |    Experiments         |
+---------------------+--------------+-----------------------+
```

## Box-by-Box Guidance

### Box 1: Business Problem

What changed in the world that created a problem worth solving?

Describe the current state, what shifted (market, competitor, customer behavior),
and why the current situation no longer meets expectations.

Good: "Our checkout conversion rate dropped 15% after mobile traffic surpassed
desktop. Our checkout flow was not designed for mobile, and competitors have
one-tap checkout."

Bad: "We need to increase revenue." (No context on what changed.)

### Box 2: Business Outcomes

How will you know you solved the problem? What measurable behavior change
indicates success?

This box holds metrics and leading indicators, not emotions or empathy.

Examples:
- Increase mobile checkout conversion from 45% to 60%
- Reduce enterprise onboarding time from 3 weeks to 3 days
- Reduce customer support tickets by 30%

### Box 3: Users

Which persona(s) should you focus on first? Consider who buys, who uses,
who configures, and who administers.

Be specific enough to imagine a real person. "All users" is not a persona.

Good: "SMB owners (1-10 employees) in professional services."
Bad: "Everyone."

### Box 4: User Outcomes and Benefits

Why would users seek out your product? What benefit do they gain? This is the
empathy box — goals, emotions, motivations. Not metrics (those go in Box 2).

Good: "Save 10 hours per week on manual data entry (spend more time with family)."
Bad: "Increase engagement by 20%." (That is a business metric.)

### Box 5: Solutions

What features, initiatives, policies, or business model shifts might solve the
problem and meet user needs simultaneously? List at least 3 candidate solutions.
These are hypotheses, not commitments.

Include innovative, small, "weird," and non-technical ideas alongside the obvious ones.

### Box 6: Hypotheses

Combine assumptions from Boxes 2 through 5 using this template:

```
We believe that [business outcome from Box 2]
will be achieved if [user from Box 3]
attains [benefit from Box 4]
with [solution from Box 5].
```

Each hypothesis focuses on one solution. Write one per solution from Box 5.

Example: "We believe that increasing mobile checkout conversion from 45% to 60%
will be achieved if mobile-first millennials (25-35) attain faster, friction-free
checkout with one-tap Apple Pay integration."

### Box 7: What Is Most Important to Learn First?

Identify the riskiest assumption across your hypotheses. Categorize by risk type:

- **Value risk:** Will users actually want this?
- **Usability risk:** Can users figure out how to use it?
- **Feasibility risk:** Can we technically build this?
- **Viability risk:** Will this achieve the business outcome?

Early on, focus on value risk. Do not build something technically feasible that
nobody wants.

### Box 8: What Is the Least Work to Learn Next?

Design the smallest experiment to validate or invalidate the riskiest assumption.

Experiment types:
- **Customer interviews** (5-10 interviews to test value hypothesis)
- **Landing page / fake door test** (measure interest without building)
- **Concierge / manual prototype** (high-touch manual version)
- **Wizard-of-Oz** (pretend the feature exists, humans behind the scenes)
- **Smoke test** (announce the feature, measure signups)

If the experiment takes more than 2 weeks, it is too big. Break it down.

## Key Distinction: Box 2 vs Box 4

This is the most common source of confusion.

| Box 2: Business Outcomes         | Box 4: User Outcomes & Benefits         |
|----------------------------------|-----------------------------------------|
| Measurable behavior change       | Goals, benefits, emotions, empathy      |
| Retention rate, conversion rate  | Save time, feel confident, get promoted |
| What the dashboard shows         | What the person experiences              |

Box 2 is metrics. Box 4 is human.

## Hypothesis Template

```
We believe that [business outcome]
will be achieved if [user persona]
attains [user benefit]
with [solution].

We will test this by [experiment from Box 8].
We know our hypothesis is valid if [success criteria].
```

## Completed Canvas Example

```
Initiative: Mobile Checkout Optimization
Date: 2025-03-15 | Iteration: 1

Box 1: Mobile checkout conversion is 15% lower than desktop. Mobile traffic
       surpassed desktop 6 months ago, but checkout was never redesigned.

Box 2: Increase mobile conversion from 45% to 60% within 3 months.

Box 3: Mobile-first millennials (25-35) who order takeout 3+ times per week.

Box 4: Complete purchases without friction or embarrassment when ordering
       with friends. Feel confident the order is correct before paying.

Box 5: (a) One-tap Apple Pay/Google Pay
       (b) Persistent cart with push reminder
       (c) Streamlined 2-step checkout (vs current 5-step)

Box 6: We believe increasing mobile conversion from 45% to 60% will be
       achieved if mobile-first millennials attain friction-free checkout
       with one-tap Apple Pay integration.

Box 7: Value risk — will users trust one-tap checkout without seeing an
       itemized charge summary?

Box 8: Wizard-of-Oz test: 50 users shown a prototype with one-tap checkout.
       Measure completion rate and post-task trust survey. Timeline: 5 days.
```

## Iteration Process

The canvas is not a one-time exercise. After each experiment:

1. Run the experiment (Box 8) with a fixed timeline (e.g., 2 weeks)
2. Document learnings — was the assumption validated or invalidated?
3. Update the canvas — revise hypotheses, pick next riskiest assumption
4. Repeat Box 7 to Box 8 until confidence is high enough to commit resources

## Common Pitfalls

| Pitfall                          | Consequence                                       | Fix                                                     |
|----------------------------------|---------------------------------------------------|---------------------------------------------------------|
| Starting with solutions          | Build what someone decided, skip problem validation | Ask: "What changed? Why is this a problem now?"         |
| Vague business outcomes          | Cannot measure success or evaluate experiments     | Define measurable behavior change with specific targets |
| Too-broad user segments          | Cannot design targeted experiments                 | Pick one persona to start; expand later                 |
| Confusing Box 2 and Box 4        | Misaligned hypotheses and unclear success criteria | Box 2 = metrics; Box 4 = empathy                       |
| Only one solution in Box 5       | No exploration of alternatives                     | Force at least 3 solutions; ask "what else?"            |
| Skipping experiments (Box 8)     | Weeks wasted building the wrong thing              | Always design smallest experiment first                 |

## Relationship to Other Frameworks

1. **Problem Statement** — define the problem before filling Box 1
2. **Proto-Persona** — create personas for Box 3
3. **Jobs to Be Done** — identify user benefits for Box 4
4. **Epic Hypothesis** — formalize testable hypotheses for Box 6
5. **PoL Probe** — design lightweight validation experiments for Box 8
6. **Discovery Interview Prep** — design customer interviews for Box 8 experiments

## References

- Jeff Gothelf, *Lean UX: Designing Great Products with Agile Teams* (O'Reilly, 2013; 2nd ed. 2016)
- Jeff Gothelf, "Lean UX Canvas v2" (jeffgothelf.com)
- Source: `deanpeters/Product-Manager-Skills` — `skills/lean-ux-canvas/SKILL.md`
