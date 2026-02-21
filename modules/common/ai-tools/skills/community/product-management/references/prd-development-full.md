# PRD Development — Full Framework

## Purpose

A PRD (Product Requirements Document) creates cross-functional alignment before
design or engineering begins. It defines the problem, the target user, the success
criteria, and the solution scope — in that order. The problem must precede the
solution. A solution described before a problem is a solution looking for a
justification.

## When to Use a PRD

Use a PRD when:
- The feature requires more than 2 weeks of engineering effort
- Cross-functional teams (design, engineering, data, legal) must align before work starts
- There are material unknowns about scope, dependencies, or success criteria
- The initiative represents a strategic bet, not a routine improvement

Do NOT write a PRD for:
- Bug fixes (write a bug report)
- Minor enhancements under 2 days (write a well-formed user story)
- Experimental spikes or PoL probes (write a hypothesis card)

## 8-Phase Process

### Phase 1: Problem Discovery
**Duration:** 2–5 days
**Activities:**
- Review discovery research, customer interviews, support data
- Write or validate the five-part problem statement
- Confirm the problem is worth solving (severity × frequency × strategic fit)

**Participants:** PM, UX Researcher
**Exit criterion:** Problem statement drafted with evidence sources cited

---

### Phase 2: Stakeholder Alignment on Problem
**Duration:** 1 day
**Activities:**
- Share problem statement with engineering lead, design lead, and business stakeholder
- Surface disagreements on problem framing before solution work begins
- Resolve priority conflicts: which customer segment and which problem come first

**Participants:** PM, Engineering Lead, Design Lead, Business Stakeholder
**Exit criterion:** Written confirmation (Slack, email, or meeting notes) that stakeholders
agree the problem is real and worth solving

---

### Phase 3: Success Metric Definition
**Duration:** 1 day
**Activities:**
- Define primary success metric (the number that tells you if you won)
- Define secondary metrics (leading indicators and guardrail metrics)
- Confirm metrics are measurable with existing instrumentation or note what must be added

**Participants:** PM, Data/Analytics, Engineering Lead
**Exit criterion:** Primary metric and measurement method approved

---

### Phase 4: Solution Exploration
**Duration:** 2–5 days
**Activities:**
- Facilitate or review design exploration (do not write solution before design exploration)
- Identify 2–3 solution options with distinct scope/risk tradeoffs
- Select preferred solution and document rationale

**Participants:** PM, UX Designer, Engineering Lead
**Exit criterion:** Preferred solution selected; alternatives documented with rejection rationale

---

### Phase 5: PRD Draft
**Duration:** 1–2 days
**Activities:**
- Write the PRD using the template below
- Include all required sections; mark unknowns explicitly rather than omitting them
- Link supporting artifacts (designs, research reports, technical spikes)

**Participants:** PM (primary author)
**Exit criterion:** All required sections complete; no TBDs left unresolved

---

### Phase 6: Engineering Review
**Duration:** 1 day (async review + 1 meeting)
**Activities:**
- Engineering lead reviews for technical feasibility and hidden dependencies
- Identify risks: API limitations, data model changes, third-party constraints
- Revise scope or add technical notes based on feedback

**Participants:** PM, Engineering Lead, relevant engineers
**Exit criterion:** Engineering lead signs off on feasibility; open items documented

---

### Phase 7: Design Review
**Duration:** 1 day (async review)
**Activities:**
- Design reviews for user experience consistency and edge case coverage
- Confirm acceptance criteria cover all designed states
- Update PRD with design decisions and links to final mocks

**Participants:** PM, UX Designer
**Exit criterion:** Designer confirms PRD accurately reflects design intent

---

### Phase 8: Final Approval and Handoff
**Duration:** Half day
**Activities:**
- PM presents PRD to business stakeholder for sign-off
- Confirm success metrics are agreed upon
- Move PRD to "approved" state; schedule sprint planning kickoff

**Participants:** PM, Business Stakeholder, Engineering Lead
**Exit criterion:** Written approval; PRD status set to Approved

---

## PRD Template

```markdown
# PRD: [Feature / Initiative Name]
**Status:** Draft | In Review | Approved
**Author:** [PM Name]
**Last Updated:** [Date]
**Target Launch:** [Quarter or date range]

---

## Executive Summary
[2–4 sentences. What is this? Why now? What does success look like?
Write this last — after all other sections are complete.]

---

## Problem Statement
[The five-part problem statement. Must come before the solution section.
Include evidence sources.]

I am [persona]
trying to [goal]
but [barrier]
because [root cause]
which makes me feel [emotional impact]

**Evidence:** [Links to interviews, support tickets, analytics]

---

## Target Users
[Named persona(s). Role, company size, behavioral context.
Link to full persona document if available.]

**Primary:** [Persona name and description]
**Secondary:** [Persona name — users who benefit but are not the primary target]

---

## Strategic Context
[How does this initiative support the current positioning statement or OKRs?
Link to the positioning statement document.]

---

## Success Metrics
**Primary metric:** [The one number that defines success]
**Target:** [Current baseline → goal within timeframe]
**Measurement:** [How it will be tracked; instrumentation required]

**Secondary metrics:**
- [Leading indicator metric]
- [Guardrail metric — what must not get worse]

**Anti-metrics (what we are NOT optimizing for):**
- [Metric we explicitly deprioritize to avoid scope creep]

---

## Solution Overview
[High-level description of the solution. 3–6 sentences.
Do NOT include implementation details here — those belong in engineering specs.]

[Link to design mocks / prototype]

---

## User Stories
[List of user stories for this initiative. Each links to its full story file
or is written inline using the standard template.]

- [Story 1: short title] — [link or inline]
- [Story 2: short title] — [link or inline]

---

## Out of Scope
[Explicit list of things that will NOT be included in this initiative.
This section prevents scope creep. If something is deferred, note where it is tracked.]

- [Item explicitly excluded] — [Reason / where it's tracked]

---

## Dependencies
[Systems, teams, or initiatives this PRD depends on.]

| Dependency          | Owner      | Status      | Risk if Delayed       |
|---------------------|------------|-------------|-----------------------|
| [Dependency name]   | [Team]     | [Status]    | [Impact]              |

---

## Open Questions
[Unresolved decisions that must be answered before or during development.
Each question should have an owner and a resolution deadline.]

| Question                          | Owner   | Due    | Status   |
|-----------------------------------|---------|--------|----------|
| [Question]                        | [Name]  | [Date] | [Open]   |

---

## Risks
[Known risks and mitigations.]

| Risk                              | Likelihood | Impact | Mitigation              |
|-----------------------------------|------------|--------|-------------------------|
| [Risk description]                | High/Med/Low | High/Med/Low | [Action]        |

---

## Appendix
[Links to supporting research, designs, technical investigations, competitive analysis]
```

## Quality Checklist

- [ ] Problem statement comes before solution overview
- [ ] Problem statement has evidence sources cited
- [ ] Primary metric is specific, measurable, and has a baseline and target
- [ ] Out of scope section is present and contains at least one item
- [ ] Open questions have owners and due dates
- [ ] Engineering lead has reviewed and approved feasibility
- [ ] All TBDs are resolved before PRD is marked Approved
- [ ] User stories are written or linked (not implied)
