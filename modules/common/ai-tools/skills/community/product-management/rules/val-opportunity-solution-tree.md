---
title: Opportunity Solution Tree
impact: HIGH
impactDescription: Jumping from outcome directly to solutions skips the opportunity space and kills discovery
tags: validation, ost, teresa-torres, continuous-discovery, opportunities, solutions
---

## Opportunity Solution Tree

**Impact: HIGH (Jumping from outcome directly to solutions skips the opportunity space and kills discovery)**

Teresa Torres's Opportunity Solution Tree structures product thinking as a four-level hierarchy: Desired Outcome at the root, then Opportunities (unmet needs, pain points, desires surfaced from customers), then Solutions (specific approaches per opportunity), then Experiments (probes that test each solution). Always expand the Opportunity level fully before adding Solutions — PMs who jump from outcome to solution skip the discovery work that reveals which problem is actually worth solving. Do not use OST to document solutions already decided; it is a thinking and communication tool for teams actively doing discovery.

**Incorrect (outcome jumps directly to solutions, no opportunity mapping):**

```markdown
Outcome: Increase 30-day retention

Solutions:
- Build onboarding checklist
- Add email drip campaign
- Add progress badges
```

**Correct (four-level tree, opportunities surfaced before solutions):**

```markdown
Desired Outcome: Increase 30-day retention by 8 points

Opportunities (from 12 customer interviews):
├── O1: Users don't understand what "done" looks like in week 1
│   ├── Solution A: Onboarding checklist with explicit success milestones
│   │   └── Experiment: Fake-door test — show checklist to 50% of new signups; measure completion rate
│   └── Solution B: Welcome call for high-intent signups
│       └── Experiment: Concierge — manually call 10 users; track 7-day activation
├── O2: Users lose context after returning from multi-day absence
│   └── Solution A: "Pick up where you left off" re-engagement screen
│       └── Experiment: Wizard of Oz — manually send personalized re-entry emails; measure return rate
└── O3: Power features discovered too late to influence habit formation
    └── Solution A: Contextual feature tips triggered at day 3 and day 7
        └── Experiment: A/B test tip timing; measure feature adoption rate

Next: Run experiments for O1 in parallel — highest churn signal.
```

Reference: [Full framework](../references/opportunity-solution-tree-full.md)
