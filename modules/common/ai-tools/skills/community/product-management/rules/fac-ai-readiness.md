---
title: Organizational AI Readiness Assessment
impact: MEDIUM
impactDescription: Deploying AI into organizations with immature foundations wastes budget and erodes trust
tags: facilitation, ai-readiness, maturity-model, data-infrastructure, change-management
---

## Organizational AI Readiness Assessment

**Impact: MEDIUM (Deploying AI into organizations with immature foundations wastes budget and erodes trust)**

Assess AI readiness across five competencies — data infrastructure, model literacy, workflow integration, governance, and change management — and assign a maturity level (1 Nascent through 4 Leading) to each before recommending AI initiatives. Use this before scoping an AI product feature, advising a client on AI adoption, or evaluating whether an organization can absorb a given AI investment. Do not assess readiness as a single yes/no — a company can have elite data infrastructure and zero governance, creating liability even with strong technical capability.

**Incorrect (binary readiness verdict):**

```markdown
## AI Readiness Check

- Has data team: Yes
- Uses some ML tools: Yes
- Leadership is interested in AI: Yes

Verdict: Ready for AI. Proceed with implementation.
```

**Correct (five-competency maturity grid with gaps and sequencing):**

```markdown
## AI Readiness Assessment — Acme Corp

| Competency | Level | Evidence | Gap |
|---|---|---|---|
| Data Infrastructure | 3 — Defined | Centralized data warehouse, 80% structured | No real-time pipelines; batch only |
| Model Literacy | 1 — Nascent | Leadership aware of AI; IC teams have no ML exposure | Training needed before deployment |
| Workflow Integration | 2 — Emerging | 2 pilot automations in ops; no PM ownership | No process for AI feature lifecycle |
| Governance | 1 — Nascent | No AI policy; no bias review process | Blocker for any customer-facing AI |
| Change Management | 2 — Emerging | Change comms in place for IT projects | AI-specific change plan absent |

**Overall Maturity: Level 1–2 (Emerging)**

**Blockers Before AI Product Investment:**
1. Governance: Draft AI use policy and bias review checklist (4 weeks)
2. Model Literacy: Run 2-day ML fundamentals workshop for PMs and Eng leads
3. Workflow Integration: Assign AI feature owner before scoping any initiative

**Recommended Entry Point:** Internal productivity AI (low customer risk) while governance matures.
Do not launch customer-facing AI features until governance reaches Level 3.
```

Reference: [Full framework](../references/ai-readiness-full.md)
