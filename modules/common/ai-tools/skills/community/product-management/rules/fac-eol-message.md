---
title: End-of-Life & Deprecation Communication
impact: MEDIUM
impactDescription: Vague or abrupt deprecation announcements damage trust and drive emergency churn
tags: facilitation, deprecation, end-of-life, product-communication, customer-success
---

## End-of-Life & Deprecation Communication

**Impact: MEDIUM (Vague or abrupt deprecation announcements damage trust and drive emergency churn)**

Communicate product or feature deprecation by covering five mandatory elements: what is changing, why the decision was made, the timeline with hard dates, the migration path with concrete steps, and the support commitment during transition. Use this for sunsetting features, retiring API versions, or discontinuing a product line. Do not announce EOL without a migration path ready — sending customers into a dead end is worse than delaying the announcement. Lead with customer impact, not internal rationale.

**Incorrect (internal-focused, no migration path):**

```markdown
## Deprecation Notice: Legacy Reports Module

We are deprecating the Legacy Reports module on March 1st.
This is part of our platform modernization initiative to reduce technical debt
and align with our new architecture strategy.

Please update your workflows accordingly.
```

**Correct (customer-centered with timeline, migration, and support):**

```markdown
## What's Changing: Legacy Reports Module Retirement

**What is changing:** The Legacy Reports module will be retired on June 30, 2026.
After this date, the module will no longer be accessible and saved report configurations
will not transfer automatically.

**Why:** The new Analytics Hub (launched Q1 2025) delivers the same reporting capabilities
with real-time data refresh, custom dimensions, and CSV/API export — features Legacy Reports
cannot support. Maintaining both systems prevents us from improving either.

**Timeline:**
- Now → March 31: Both systems available. New features added to Analytics Hub only.
- April 1 → June 29: Legacy Reports read-only. No new reports can be created.
- June 30: Legacy Reports retired. Data remains accessible via API export for 90 days.

**Migration Path (3 steps, ~30 minutes):**
1. Export your saved Legacy report list: Settings → Reports → Export Config (JSON)
2. Import into Analytics Hub: Analytics Hub → Import Legacy Config → follow wizard
3. Validate outputs match: use our side-by-side comparison guide [link]

**Support Commitment:**
- Dedicated migration office hours: Tuesdays 2–4pm ET through June (sign up [link])
- Migration guide with video walkthrough: [link]
- If you cannot migrate by June 30, contact support for a 60-day extension.

Questions? Reply to this email or open a ticket tagged "legacy-reports-migration".
```

Reference: [Full framework](../references/eol-message-full.md)
