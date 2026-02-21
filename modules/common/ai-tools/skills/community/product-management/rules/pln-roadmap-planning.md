---
title: Roadmap Planning
impact: MEDIUM
impactDescription: A feature-list timeline masquerading as a roadmap erodes trust when reality diverges from dates
tags: planning, roadmap, now-next-later, initiatives, sequencing, communication
---

## Roadmap Planning

**Impact: MEDIUM (A feature-list timeline masquerading as a roadmap erodes trust when reality diverges from dates)**

Roadmap planning is a 1–2 week process with four sequential phases: gather inputs (strategy, validated problems, stakeholder asks, engineering capacity), define initiatives and epics (outcome-framed, not feature-named), prioritize using a scoring framework, and sequence into Now/Next/Later horizons. The output is a living document that communicates direction and rationale — not a commitment list with fixed dates. Use this at the start of each quarter or after a significant strategy shift. Do not use this process to produce a Gantt chart; if stakeholders need dates, add estimated quarters to Later items only, never to Now.

**Incorrect (feature list with fixed dates, no strategic link):**

```markdown
## 2026 Product Roadmap

January: Dark mode
February: Mobile app redesign
March: Zapier integration
April: Advanced search filters
May: Team permissions v2
June: API v3

Note: dates are committed to sales team and on website.
```

**Correct (initiative-level, outcome-framed, Now/Next/Later with rationale):**

```markdown
## Q2 2026 Roadmap — Last updated: Feb 21

### Inputs gathered
- Strategy: "data-first operations" positioning (see Positioning Statement v3)
- Validated problems: report navigation friction (#1 support theme, 180 tickets/mo)
- Capacity: 3 engineers × 10 weeks = 30 eng-weeks available
- Stakeholder asks: Sales requests SSO (7 enterprise deals blocked)

### Initiatives

**NOW (this quarter, committed)**
- Initiative: Reduce report navigation friction
  Outcome: avg. navigation clicks per session from 8.2 → 4.0
  Epics: persistent sidebar, keyboard shortcuts, recent history
  Capacity: 12 eng-weeks | Owner: Ana

- Initiative: Unblock enterprise sales via SSO
  Outcome: 7 stalled enterprise deals unblocked, SSO as table-stakes feature
  Epics: SAML 2.0, admin provisioning flow
  Capacity: 8 eng-weeks | Owner: Ben

**NEXT (next quarter, directional)**
- Initiative: Self-serve analytics exports
  Outcome: reduce custom export support tickets by 60%
  Why next: depends on NOW sidebar work; data model changes required first

**LATER (6+ months, intent only)**
- Initiative: Mobile companion app (Q4 estimate)
  Why later: no validated mobile use case yet; discovery planned for Q3

### What is NOT on this roadmap
- Dark mode: low strategic value, no customer problem evidence
- Zapier integration: under evaluation; channel ROI analysis pending
```

Reference: [Full framework](../references/roadmap-planning-full.md)
