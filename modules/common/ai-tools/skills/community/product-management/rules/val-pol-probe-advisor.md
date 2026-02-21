---
title: PoL Probe Type Advisor
impact: HIGH
impactDescription: Choosing the wrong probe type produces invalid signal and wastes the experiment window
tags: validation, proof-of-learning, probe-advisor, concierge, wizard-of-oz, fake-door, facilitation
---

## PoL Probe Type Advisor

**Impact: HIGH (Choosing the wrong probe type produces invalid signal and wastes the experiment window)**

The PoL Probe Type Advisor is an interactive decision protocol that recommends one of five probe types based on three inputs: hypothesis type (problem vs. solution), risk level (high vs. low), and available resources (engineering access, customer access, data access). Run through the advisor before designing any experiment — mismatched probe types are the most common cause of inconclusive results. Do not use this as a checklist to justify a probe type already chosen; the point is to select the right instrument before committing to a design.

**Five probe types and their selection triggers:**

| Probe Type | Best When | Avoid When |
|---|---|---|
| Concierge | Testing whether humans value the outcome (do it manually first) | You need to test at scale |
| Wizard of Oz | Solution is complex to build; simulate the experience manually | The "magic" can't be simulated credibly |
| Landing Page | Testing demand signal before any build | You already have active users to observe |
| Fake Door | Testing engagement/intent inside an existing product | No existing product surface to embed the trigger |
| Data Analysis | Hypothesis can be tested with existing instrumentation | Data is sparse, lagged, or not yet collected |

**Incorrect (probe type chosen by familiarity, not fit):**

```markdown
Hypothesis: Enterprise users want an audit log feature.
Probe: We'll build a landing page and run Google Ads.

[Problem: existing users are already in-product;
a landing page tests acquisition intent, not feature demand from current users.]
```

**Correct (advisor applied: hypothesis type → risk → resources → probe type):**

```markdown
## Probe Type Advisor: Audit Log Feature

**Step 1 — Hypothesis type:** Solution hypothesis (we know the problem; testing whether
this specific solution is wanted).

**Step 2 — Risk level:** High. Engineering cost is 3 sprints; no comparable data exists.

**Step 3 — Available resources:** Existing product surface with enterprise users; no
engineering capacity for a prototype; PM can send targeted in-app messages.

**Advisor output: Fake Door**
Rationale: Solution hypothesis + high risk + existing product surface = fake door.
Place an "Audit Log" menu item in the admin panel. Clicking shows: "Audit log is
in development — notify me when it's ready." Measure click rate among admin users
over 2 weeks. Success bar: ≥ 15% of admin users engage.

**Ruled out:**
- Landing page: audience is existing users, not acquisition prospects.
- Concierge: PM can't manually produce audit logs at enterprise data volumes.
- Wizard of Oz: requires engineering to fake the log output — not available.
```

Reference: [Full framework](../references/pol-probe-full.md)
