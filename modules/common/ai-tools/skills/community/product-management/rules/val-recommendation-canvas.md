---
title: AI Recommendation Canvas
impact: HIGH
impactDescription: Undocumented AI recommendations become invisible technical debt and unauditable product decisions
tags: validation, ai-recommendations, canvas, evidence, risk, transparency
---

## AI Recommendation Canvas

**Impact: HIGH (Undocumented AI recommendations become invisible technical debt and unauditable product decisions)**

The AI Recommendation Canvas structures the documentation of any AI-powered recommendation feature — personalization, next-best-action, content ranking, or predictive nudging — across five fields: Context (what the system knows about the user and situation), Approach (the model or algorithm driving the recommendation), Evidence (the data and validation behind the approach), Risks (failure modes, bias vectors, and edge cases), and Next Steps (how the team will monitor and iterate). Use this canvas before shipping any AI-driven recommendation to ensure the logic is auditable and the failure modes are owned. Do not use it to document rule-based recommendations — it is designed for probabilistic systems where explainability is not automatic.

**Incorrect (AI feature shipped with no documentation of logic or risk):**

```markdown
Feature: "Recommended for you" section in dashboard.
Engineering: ML model trained on clickstream data.
Ship date: Next sprint.
```

**Correct (five-field canvas, risks and monitoring owned):**

```markdown
## AI Recommendation Canvas: "Next Action" Widget

**Context:**
User is a mid-market PM, 14 days post-activation, has created 2 projects but
has not invited teammates. Session frequency: 3x/week. Last action: viewed pricing page.

**Approach:**
Collaborative filtering model trained on behavioral sequences of users who
reached "activated" state (defined as 5+ team members, 3+ projects in 30 days).
Model outputs top-3 recommended next actions ranked by predicted activation probability.

**Evidence:**
- Trained on 90-day cohort of 4,200 users; held-out AUC: 0.74.
- Offline simulation: top-1 recommendation matched actual next action in 41% of cases.
- Qualitative: 8/10 users in usability test found recommendations "relevant or very relevant."

**Risks:**
- Cold start: model underperforms for users with < 5 sessions (affects ~30% of new signups).
  Mitigation: fall back to rule-based recommendations for cold-start users.
- Feedback loop: if users only click recommended actions, model may narrow over time.
  Mitigation: inject 10% diversity actions; monitor recommendation entropy monthly.
- Bias: free-tier users are underrepresented in training data (8% of cohort).
  Mitigation: stratified sampling in next training run; flag free-tier outputs for review.

**Next Steps:**
- Week 1–2: A/B test (50/50 split); primary metric = 30-day activation rate.
- Week 3: Review recommendation distribution for cold-start cohort.
- Month 2: Retrain model with expanded free-tier sample.
- Owner: [PM name] reviews recommendation quality dashboard weekly.
```

Reference: [Full framework](../references/recommendation-canvas-full.md)
