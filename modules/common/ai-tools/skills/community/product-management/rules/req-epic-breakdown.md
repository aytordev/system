---
title: Epic Breakdown Advisor
impact: HIGH
impactDescription: Poorly split epics create stories too large to estimate, test, or ship independently
tags: epics, story splitting, richard lawrence, agile, backlog
---

## Epic Breakdown Advisor

**Impact: HIGH (Poorly split epics create stories too large to estimate, test, or ship independently)**

Use Richard Lawrence's 9 splitting patterns to decompose epics into independently deliverable stories. Apply when an epic takes more than one sprint or cannot be estimated with confidence. Do not use this to split by technical layer (front-end / back-end / DB) — that produces stories with no user value. The goal is vertical slices: each story must be deployable and valuable on its own.

**Incorrect (splitting by technical component, not user value):**

```markdown
Epic: User can pay for orders

Stories:
- Build payment database schema
- Build payment API endpoint
- Build payment UI form
- Wire up Stripe SDK
```

**Correct (splitting by workflow steps and happy/unhappy paths):**

```markdown
Epic: User can pay for orders

Stories:
- User pays with a saved credit card (happy path)
- User pays with a new credit card (data variation)
- User sees an error when payment is declined (unhappy path)
- User pays with PayPal (interface variation)
- Admin refunds an order (operation variation)
```

Reference: [Full framework](../references/epic-breakdown-advisor-full.md)
