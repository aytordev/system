# Proto-Persona — Full Framework

## Purpose

A proto-persona is a hypothesis-driven persona created from available research,
market data, and stakeholder knowledge — not from validated user research. Use it
to align teams early in product development, guide initial design decisions, and
surface the gaps that need real research to fill. It is a structured placeholder
that prevents design-by-committee while making assumptions explicit.

## When to Use

- Early-stage product development before formal user research
- Kicking off a new feature or pivot
- Aligning stakeholders on who the target user is
- Identifying research gaps (who should we interview next?)

## When Not to Use

- After extensive user research (create a validated persona instead)
- For mature products with known, validated user segments
- As a substitute for quantitative data or customer interviews

## Proto vs. Validated Persona

| Proto-Persona               | Validated Persona                |
|-----------------------------|----------------------------------|
| Created in hours/days       | Created over weeks/months        |
| Based on assumptions + data | Based on extensive user research |
| Used to align teams early   | Used to guide detailed design    |
| Evolves rapidly             | Stable over longer periods       |
| Good enough to start        | High confidence                  |

## Six-Step Process

### Step 1: Gather Available Context

Collect everything you have before writing anything:

- **User research:** Interview notes, survey results, support tickets
- **Analytics:** Usage data, demographics, behavioral patterns
- **Market data:** Industry reports, competitor user bases
- **Stakeholder insights:** Sales, support, CS teams who talk to users
- **Product context:** The problem being solved (links to problem statement)

If context is missing, note the gap. Do not fabricate.

### Step 2: Name the Persona

Use an alliterative, memorable name. This makes team conversations easier.

Good: "Manager Mike," "Startup Sarah," "Enterprise Emma"
Bad: "User 1," "Persona A," "Target Customer"

### Step 3: Bio and Demographics

Describe who this person is. Include only demographics that influence product
decisions — this is behavioral context, not a census record.

```
- Age range, geographic location
- Career status (title, industry, seniority)
- Online presence and community behaviors
- Family and lifestyle context (if product-relevant)
```

Good: "35-45, Director-level at mid-market tech, active in Slack communities,
juggles 3 direct reports and 2 side projects"
Bad: "30-40 years old, lives in a city"

### Step 4: Capture Their Voice (Quotes)

Use real or representative quotes that expose mindset, not just facts.

Strong: "I'm drowning in manual work and can't focus on strategy."
Weak: "I need better tools."

Source quotes from interviews, support tickets, or sales calls. If you have
no quotes, note "[PLACEHOLDER — NEEDS RESEARCH]" explicitly.

### Step 5: Document Pains, Behaviors, and Goals

**Pains** — specific, not vague:

Good: "Spends 3 hours/week manually copying data between tools"
Bad: "Frustrated with tools"

**Behaviors** — observable actions and outcomes:

Good: "Delivers projects 2 weeks ahead of schedule to build trust"
Bad: "Wants to get promoted"

**Goals** — include both tactical and aspirational:

- Short-term: "Ship the Q2 feature on time"
- Long-term: "Become VP within 3 years"
- Personal: "Spend more time with family" (if product-relevant)

### Step 6: Map Attitudes and Influences

**Decision-making authority:** Can they buy your product or do they need
approval? Note budget thresholds (e.g., "up to $10k without exec sign-off").

**Decision influencers:** Peers, industry analysts, community channels,
conferences, specific publications.

**Beliefs and attitudes:** Focus on beliefs that affect product adoption.
Example: "Skeptical of tools that require training," "Values data-driven
decision making over intuition."

## Template

```markdown
## Proto-Persona: [Alliterative Name]

### Bio & Demographics
- [Age range, location, career context]
- [Online behavior, community involvement]
- [Lifestyle context relevant to product]

### Quotes
- "[Authentic quote revealing mindset]"
- "[Quote exposing frustration or motivation]"
- "[Quote showing attitude or belief]"

### Pains
- [Specific pain point with quantification if possible]
- [Second pain point]

### What They Are Trying to Accomplish
- [Observable behavior or outcome they pursue]

### Goals
- [Tactical goal]
- [Aspirational goal]

### Attitudes & Influences
- **Decision Authority:** [Yes/No + budget context]
- **Influencers:** [Who shapes their decisions]
- **Beliefs:** [Product-relevant attitudes]

### Assumptions to Validate
- [ASSUMPTION] [Specific claim that needs research]
- [ASSUMPTION] [Another unverified belief]
```

## Worked Example

```markdown
## Proto-Persona: Manager Mike

### Bio & Demographics
- 35-45, urban (NYC/SF/Austin), Director at mid-market tech (50-500 employees)
- Active on LinkedIn and Twitter, attends 2-3 conferences/year
- Married with young kids, values work-life balance, listens to business podcasts

### Quotes
- "I spend 10 hours a week in status meetings that could be emails."
- "I'm tired of tools that promise automation but need a developer to set up."
- "My team expects answers immediately, but I'm always hunting for data."

### Pains
- 10+ hours/week in status meetings with no decisions made
- Manual data aggregation across 4 tools to build a single report
- Cannot demonstrate team impact to leadership without 3 days of prep

### What They Are Trying to Accomplish
- Deliver projects on time while shielding the team from organizational chaos
- Make data-driven decisions without depending on an analyst

### Goals
- Ship the Q2 roadmap without scope creep
- Get promoted to VP within 2 years
- Leave work by 6pm at least 3 days a week

### Attitudes & Influences
- **Decision Authority:** Budget up to $10k; needs exec approval above that
- **Influencers:** Peer recommendations in Slack groups, Gartner reports
- **Beliefs:** "If it takes more than 30 minutes to set up, I won't use it"

### Assumptions to Validate
- [ASSUMPTION] Majority of time waste is meetings, not email
- [ASSUMPTION] Would pay $50-100/month for automation that saves 5+ hrs/week
- [ASSUMPTION] Prefers self-serve setup over white-glove onboarding
```

## Validation and Iteration

After creating the proto-persona:

1. **Share with the team:** Does this person feel real? Do they recognize this user?
2. **Tag assumptions:** Mark uncertain items with `[ASSUMPTION — VALIDATE]`
3. **Plan research:** Use the persona to decide who to interview next
4. **Evolve it:** Update as you learn; graduate to validated persona when confidence is high

## Common Failure Modes

| Failure Mode                | Example                                      | Fix                                                          |
|-----------------------------|----------------------------------------------|--------------------------------------------------------------|
| Demographics without behavior | "28, lives in NYC, has a dog"              | Add: "Works remotely, active in 5 Slack communities"         |
| Treating it as fact         | "Mike would never use feature X"             | Tag as assumption; plan interview to validate                |
| Too many personas           | 10 proto-personas created day one            | Start with 1-2 (primary + secondary); expand after validation|
| Fabricated quotes           | "I love products that delight me!"           | Use real quotes from support tickets, interviews, sales calls|
| Never validating            | Same persona unchanged after 6 months        | Schedule research sprints; update as evidence comes in       |
| Missing "so what"           | Persona exists but informs no decisions      | Every design/priority decision should reference the persona  |

## Quality Checklist

- [ ] Name is alliterative and memorable (team can recall it easily)
- [ ] Demographics include behavioral context, not just census data
- [ ] Quotes sound like a real person, not marketing copy
- [ ] Pains are specific and quantified where possible
- [ ] Goals include both short-term tactical and long-term aspirational
- [ ] Decision authority and influencers documented
- [ ] Every uncertain claim tagged as `[ASSUMPTION — VALIDATE]`
- [ ] No solution language present in the persona
- [ ] Stakeholders reviewed and recognize this person

## Relationship to Other Frameworks

1. Proto-Persona (this document) — defines who has the problem
2. Problem Statement — frames the problem using the persona ("I am...")
3. Positioning Statement — positions the solution ("For [persona]...")
4. User Stories — each story's role references the persona ("As a [persona]...")
5. Jobs-to-be-Done — informs the persona's pains and goals
