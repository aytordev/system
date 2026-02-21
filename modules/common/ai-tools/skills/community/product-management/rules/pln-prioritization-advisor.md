---
title: Prioritization Framework Advisor
impact: MEDIUM
impactDescription: Applying the wrong prioritization framework generates false confidence in ranking decisions
tags: planning, prioritization, rice, ice, kano, moscow, frameworks, advisor
---

## Prioritization Framework Advisor

**Impact: MEDIUM (Applying the wrong prioritization framework generates false confidence in ranking decisions)**

Select a prioritization framework based on three contextual factors: product stage (pre-PMF vs. scaling), data maturity (qualitative signals vs. quantitative metrics), and decision-making context (internal alignment vs. external stakeholder communication). RICE and ICE require reasonably reliable effort and reach estimates — use them at scaling stage with instrumented products. Kano is suited for feature discovery sessions where you need to separate delighters from basics. MoSCoW is a communication tool for scope alignment, not a ranking algorithm. Do not mix frameworks in one backlog; pick one per planning cycle and apply it consistently.

**Incorrect (framework mismatch, mixed signals, no selection rationale):**

```markdown
## Q2 Prioritization

We used RICE to score the backlog but estimates were rough guesses.
Also added MoSCoW labels and sorted by Kano category.

Top items:
1. Feature A — RICE: 2,400 (must-have, delighter)
2. Feature B — RICE: 1,800 (should-have, performance)
3. Feature C — RICE: 1,200 (could-have, basic)

Used confidence: 100% for all items.
```

**Correct (framework selected based on context, applied consistently):**

```markdown
## Q2 Prioritization — Framework Selection

Context:
- Stage: Post-PMF, scaling (18 months post-launch, product instrumented)
- Data maturity: Quantitative (analytics, NPS, support volume available)
- Decision context: Internal team ranking, not stakeholder communication

Recommended framework: RICE
Rationale: Scaling stage with quantitative data makes Reach and Impact
estimable. Confidence score forces explicit uncertainty acknowledgment.

If context were different:
- Pre-PMF or no analytics → use ICE (faster, less data-dependent)
- Feature discovery with user research → use Kano survey
- Sprint scope negotiation with stakeholders → use MoSCoW

## Q2 RICE Scores

| Feature          | Reach | Impact | Confidence | Effort | RICE  |
|------------------|-------|--------|------------|--------|-------|
| Bulk export      | 4,200 | 2      | 80%        | 3 wks  | 2,240 |
| SSO integration  | 1,800 | 3      | 60%        | 6 wks  | 540   |
| Email digest     | 6,000 | 1      | 90%        | 1 wk   | 5,400 |

Confidence: % based on supporting evidence (interviews, data, analogues).
Do not default to 100% — no estimate deserves it.
```

Reference: [Full framework](../references/prioritization-advisor-full.md)
