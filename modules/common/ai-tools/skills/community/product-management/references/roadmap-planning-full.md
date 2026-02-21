# Roadmap Planning — Full Framework

## Purpose

A roadmap communicates strategic direction and rationale — it is not a commitment
list with fixed dates. The difference: a commitment list erodes trust when reality
diverges from dates. A direction document builds trust by explaining why things
are sequenced as they are.

Use Now/Next/Later horizons instead of date-based timelines. Dates belong only
on items being actively built (Now), and only at the quarter level.

## When to Use

- At the start of each quarter before sprint planning begins
- After a significant strategy shift that reorders priorities
- When stakeholders across functions need shared direction
- When the current roadmap is a date-ordered feature list

## 5-Phase Process

### Phase 1: Gather Inputs
**Duration:** 2–3 days
**Activities:**
1. Pull from four input sources:
   - **Strategy:** Current positioning statement and OKRs
   - **Validated problems:** Discovery research findings, severity × frequency matrix
   - **Stakeholder asks:** Sales blockers, customer success escalations, executive requests
   - **Engineering capacity:** Available eng-weeks this quarter (people × weeks × utilization)
2. Document each input source explicitly. An initiative without a source is an opinion.
3. Identify conflicts: where do stakeholder asks conflict with validated problems?
   Surface these before prioritization, not during.

**Output:** Inputs document with source attribution for every item

---

### Phase 2: Define Initiatives
**Duration:** 1–2 days
**Activities:**
1. Group related validated problems and stakeholder asks into initiatives.
2. Name each initiative as an **outcome**, not a feature:
   - Good: "Reduce navigation friction for power users"
   - Bad: "Sidebar redesign"
3. For each initiative, write:
   - The target outcome (metric + target)
   - The user persona who benefits
   - The rough scope (list of epics, not user stories)
   - The dependency on other initiatives or systems

**Output:** Initiative list with outcome framing and rough scope

---

### Phase 3: Score and Prioritize
**Duration:** 1 day
**Activities:**
1. Score each initiative on two dimensions:
   - **Strategic value:** Does it advance the positioning differentiator, open a new segment,
     or close a critical competitive gap? (1–3 scale)
   - **Expected impact:** Estimated metric movement × confidence (1–3 scale)
2. Size each initiative in engineering-weeks (rough order of magnitude: S/M/L/XL).
3. Apply simple priority score: (strategic value × expected impact) / size
4. Sort by score. Discuss top 5 with stakeholders before sequencing.

**Note:** Do not use RICE for roadmap-level initiatives — the data required for
accurate RICE scoring exists at the story level, not the initiative level.

---

### Phase 4: Sequence into Now/Next/Later
**Duration:** Half day
**Activities:**
1. Place initiatives into three horizons based on capacity and dependency order.
2. Apply hard rules:
   - **Now** must fit available capacity with at least 15% buffer for unplanned work
   - **Next** must have defined entry criteria (dependency cleared, discovery done)
   - **Later** communicates intent only — no scope or date commitments
3. For each Now initiative, assign an owner (single PM or EM accountable)
4. Explicitly document what is NOT on the roadmap and why

**Horizon definitions:**
- **Now:** This quarter. Committed. Scope locked at epic level. Owner named.
- **Next:** Next quarter, directional. Scope may shift. Entry criteria defined.
- **Later:** 6+ months or strategic intent. No commitment. May add Q-level estimate.

---

### Phase 5: Communicate and Maintain
**Duration:** Ongoing
**Activities:**
1. Share the roadmap with stakeholders in a live review, not asynchronously.
   Walk through the rationale for each Now item and for what was excluded.
2. Update the roadmap when: new high-severity validated problems emerge, strategy
   shifts, or a Now initiative is complete or blocked.
3. Version the document: date every update, preserve the previous version.
4. Date stamp the header with "Last updated:" so staleness is visible.

---

## Now/Next/Later Template

```markdown
# [Product Area] Roadmap — Last updated: [Date]

## Inputs
- **Strategy anchor:** [Link to positioning statement / OKRs]
- **Capacity this quarter:** [N engineers × N weeks = N eng-weeks available]
- **Key validated problems:** [1–3 bullet points from discovery]
- **Stakeholder inputs:** [Summary of sales/CS/exec asks]

---

## NOW — This quarter (committed)

### Initiative: [Outcome-framed name]
**Target outcome:** [Metric] from [baseline] → [goal] within [timeframe]
**Persona:** [Who benefits]
**Epics:** [List of epics, not user stories]
**Capacity:** [N eng-weeks] | **Owner:** [Name]
**Rationale:** [Why now — strategic fit, urgency, dependency order]

### Initiative: [Name]
[Same structure]

---

## NEXT — Next quarter (directional)

### Initiative: [Outcome-framed name]
**Target outcome:** [Metric] direction
**Entry criteria:** [What must be true before this can start]
**Why next:** [Dependency on NOW work, research required, etc.]

### Initiative: [Name]
[Same structure]

---

## LATER — 6+ months (intent only)

### Initiative: [Name]
**Intent:** [What problem this will eventually address]
**Why later:** [Missing validation, dependency, lower priority]
**Estimated timing:** [Q-level estimate if known; omit if not]

---

## What Is NOT on This Roadmap

| Item                  | Reason for Exclusion                        | Where Tracked           |
|-----------------------|---------------------------------------------|-------------------------|
| [Item]                | [No validated problem evidence]             | [Backlog / Future cycle] |
| [Item]                | [Conflicts with positioning]                | [Decision log]          |
```

## Worked Example (NOW section)

```markdown
## NOW — Q2 2026 (committed)

### Initiative: Reduce report navigation friction
**Target outcome:** Avg. navigation clicks per session from 8.2 → 4.0 within 60 days post-launch
**Persona:** Operations analyst, runs 3+ reports per day
**Epics:** Persistent sidebar, keyboard shortcuts, recently-viewed history
**Capacity:** 12 eng-weeks | **Owner:** Ana Reyes
**Rationale:** #1 support theme (180 tickets/month); directly supports "data-first
operations" positioning; no external dependencies

### Initiative: Unblock enterprise sales via SSO
**Target outcome:** 7 stalled enterprise deals unblocked; SSO as table-stakes feature
**Persona:** Enterprise IT administrator + sales champion
**Epics:** SAML 2.0 integration, admin provisioning flow, JIT user creation
**Capacity:** 8 eng-weeks | **Owner:** Ben Liu
**Rationale:** 7 deals explicitly blocked on SSO requirement per sales; Q2 close-date
pressure; engineering spike confirmed 3-week implementation feasible
```

## Quality Checklist

- [ ] All Now initiatives fit available capacity with buffer (do not overcommit)
- [ ] Every initiative named as an outcome, not a feature or technology
- [ ] Every initiative has a target metric with baseline and goal
- [ ] Every initiative has a single named owner
- [ ] Next items have defined entry criteria, not just "when we get to it"
- [ ] "What is NOT on this roadmap" section present with at least two items
- [ ] Roadmap has a last-updated date in the header
- [ ] No fixed delivery dates on Next or Later items
- [ ] Rationale for sequencing is documented, not just the sequence
