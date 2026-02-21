# Problem Framing Canvas — Full Framework

## Purpose

The problem framing canvas is a structured process based on the MITRE Innovation
Toolkit (v3) that ensures teams solve the right problem before jumping to solutions.
It works through three phases — Look Inward, Look Outward, and Reframe — to broaden
perspective, challenge assumptions, surface overlooked stakeholders, and produce a
clear, bias-resistant problem statement with an actionable "How Might We" question.

This is not a solution brainstorm. It is a problem framing tool that produces the
foundation for everything that follows: discovery interviews, opportunity trees,
PRDs, and roadmaps.

## When to Use

- Starting discovery for a new initiative or product area
- Reframing an existing problem (suspicion you are solving the wrong thing)
- Challenging assumptions before committing to a solution direction
- Aligning a cross-functional team on shared problem definition
- When existing problem statements feel too vague or too narrow

## When NOT to Use

- When the problem is already well-understood and validated with customers
- For tactical bug fixes or technical debt (no deep framing needed)
- When stakeholders have already committed to a solution (address alignment first)

## Canvas Structure

```
+------------------------------------------------------------------+
| LOOK INWARD                                                       |
| - What is the problem? (symptoms)                                 |
| - Why haven't we solved it? (barriers)                            |
| - How are we part of the problem? (assumptions, biases)           |
+------------------------------------------------------------------+

+------------------------------------------------------------------+
| LOOK OUTWARD                                                      |
| - Who experiences the problem? When/where/consequences?           |
| - Who else has it? Who doesn't?                                   |
| - Who has been left out? Who benefits from the status quo?        |
+------------------------------------------------------------------+

+------------------------------------------------------------------+
| REFRAME                                                           |
| - Stated another way, the problem is: [refined restatement]      |
| - How might we [action] as we aim to [objective]?                |
+------------------------------------------------------------------+
```

## Phase 1: Look Inward

Goal: examine your own assumptions, biases, and complicity in the problem.

### Question 1 — What is the problem? (Describe symptoms)

Capture the problem as currently understood. Do not solve — just describe symptoms:

1. Customer pain point ("customers struggle with [specific task]")
2. Business metric problem ("churn increased 15% last quarter")
3. Stakeholder request ("sales team says we need better reporting")
4. Observed behavior ("users abandon onboarding at step 3")

### Question 2 — Why haven't we solved it?

Surface the barriers. Allow multiple selections:

1. It is new (recently emerged)
2. It is hard (technically complex or resource-intensive)
3. It is low priority (other initiatives took precedence)
4. Lack of resources (budget, people, time)
5. Lack of authority (cannot get buy-in or make the decision)
6. Systemic inequity (disproportionately affects marginalized groups, overlooked)

### Question 3 — How are we part of the problem?

Force explicit examination of team assumptions and biases:

1. Assuming we know what customers want (confirmation bias)
2. Optimizing for ourselves, not users (internal bias)
3. Overlooking specific user segments (survivorship bias)
4. Solution-first thinking — jumped to "we need feature X" (premature convergence)

## Phase 2: Look Outward

Goal: understand who experiences the problem, who benefits from it, and who has
been left out.

### Question 4 — Who experiences the problem?

Capture specifics along four dimensions:

- **Who:** Specific personas, user segments, or roles
- **When:** Triggering events or contexts ("during onboarding", "at month-end close")
- **Where:** Physical or digital locations ("mobile app", "enterprise deployments")
- **Consequences:** Impact ("waste 2 hours/week", "miss deadlines", "churn")

### Question 5 — Who else has this problem? Who doesn't?

- **Who else:** Other companies, industries, or domains with similar problems
- **How they cope:** Workarounds, alternative solutions, or adaptations
- **Who doesn't:** Users or companies that avoid the problem — what is different?

The counter-examples are especially valuable: understanding who does NOT have the
problem reveals what conditions create or prevent it.

### Question 6 — Who has been left out? Who benefits?

This is the equity-driven question that distinguishes MITRE's canvas:

- **Left out:** Marginalized voices, edge cases, overlooked stakeholders
- **Benefits from status quo:** Who gains when the problem persists?
- **Benefits from resolution:** Who loses if the problem is solved?

Example: "Who benefits when onboarding is broken?" Sales team avoids supporting
complex workflows. Engineering avoids building guided flows. Non-technical and
international users (English-only onboarding) are left out.

## Phase 3: Reframe

Goal: synthesize all insights into a clear, actionable problem statement.

### Question 7 — Restate the Problem

Use this template:

```
The problem is: [Who] struggles to [accomplish what] because [root cause],
which leads to [consequence]. This affects [specific segments] and has been
overlooked because [bias/assumption from Phase 1].
```

**Example:**
"The problem is: non-technical small business owners struggle to activate our
product during onboarding because we use jargon-heavy UI and lack guided workflows,
which leads to 60% abandonment within 24 hours. This disproportionately affects
solopreneurs without technical support and has been overlooked because our team
optimizes for enterprise users with IT departments."

### Question 8 — Create "How Might We" Statement

Template:

```
How might we [action that addresses the problem]
as we aim to [objective / desired condition]?
```

**Example:**
"How might we guide non-technical users through onboarding with plain-language
prompts as we aim to increase activation from 40% to 70%?"

**Quality check:** The HMW must be broad enough to admit multiple solutions but
specific enough to exclude irrelevant ones. "How might we add a mobile app?" is too
narrow. "How might we improve UX?" is too broad.

## Output Template

```markdown
# Problem Framing Canvas: [Problem Name]

## Phase 1: Look Inward
### Symptoms
[From Q1]

### Barriers to Solving
- [From Q2]

### Our Assumptions and Biases
- [From Q3]
- Which of these might be redesigned, reframed, or removed?

## Phase 2: Look Outward
### Who Experiences the Problem
- Who: [From Q4]
- When/Where: [Context]
- Consequences: [Impact]

### Who Else Has It / Who Doesn't
- [From Q5]

### Left Out / Who Benefits
- Left out: [From Q6]
- Benefits from status quo: [From Q6]

## Phase 3: Reframe
### Restated Problem
[From Q7]

### How Might We
How might we [action] as we aim to [objective]?
```

## Common Pitfalls

| Pitfall                        | Symptom                                           | Fix                                                   |
|--------------------------------|---------------------------------------------------|-------------------------------------------------------|
| Skipping "Look Inward"        | Jump to Look Outward without examining biases     | Force explicit discussion of assumptions (Q2-Q3)      |
| Ignoring "Who Benefits"       | Canvas done without exploring status quo winners   | Always ask "who loses if this is solved?" (Q6)        |
| Generic problem statement     | Reframe is vague ("improve user experience")      | Make it specific: who, what, when, consequence, cause |
| HMW too narrow                | "How might we add a mobile app?"                  | Broaden: "enable mobile-first users to access core workflows" |
| Solo exercise                 | PM fills out canvas alone                         | Facilitate with cross-functional team + customer input |
| Treating it as one-and-done   | Canvas completed, never revisited                 | Revisit when new data arrives or assumptions change   |

## Facilitation Tips

- Run the canvas with 4-8 participants from different functions (PM, design,
  engineering, customer success, sales) for maximum perspective diversity.
- Timebox: 120 minutes total (30 min Look Inward, 45 min Look Outward, 45 min Reframe).
- The "who has been left out?" question often produces the most valuable insights.
  Do not rush it.
- If the team cannot agree on the restated problem (Q7), that disagreement is the
  most important output. Do not paper over it.

## Related Frameworks

- **Problem Statement** (`problem-statement-full.md`) — converts the reframed problem into a formal statement
- **Opportunity Solution Tree** — uses the HMW statement to explore solution space
- **Discovery Process** (`discovery-process-full.md`) — validates the reframed problem with customers
- **Customer Journey Map** (`customer-journey-map-full.md`) — maps pain points across the full experience

## References

- MITRE Innovation Toolkit, "Problem Framing Canvas v3" (2021) — origin of the canvas
- Stanford d.school, "How Might We" statements — actionable problem framing technique
- Source: `deanpeters/Product-Manager-Skills` — problem-framing-canvas skill
