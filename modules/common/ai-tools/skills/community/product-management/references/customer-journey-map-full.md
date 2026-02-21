# Customer Journey Map — Full Framework

## Purpose

A Customer Journey Map visualizes the end-to-end experience a specific persona has
while pursuing a specific goal. It surfaces cross-functional gaps and emotional low
points that no single team owns. Use it to identify where to intervene in the
experience, not to document a process flow.

Based on the Nielsen Norman Group methodology. The feelings row is not optional —
emotional friction predicts churn and advocacy more reliably than functional friction.

## When to Use

- Before starting discovery research to frame what you're looking for
- After discovery interviews to synthesize cross-session patterns
- In cross-functional workshops to align teams on where the experience breaks
- When optimizing retention or reducing churn from experience friction

## Map Scope Rules

- One persona per map. Multiple personas on one map creates noise.
- One goal per map. "Buy a product" and "get support" are two separate maps.
- Scope should span the complete experience: from first awareness to post-purchase.
- Time horizon: a journey map covers days to months, not minutes.

## NNGroup Row Structure

Each stage of the journey requires six rows:

| Row           | What to Capture                                              |
|---------------|--------------------------------------------------------------|
| Stage         | Named phase of the experience (Awareness, Consider, etc.)   |
| Actions       | Concrete steps the persona takes — observable behavior      |
| Thoughts      | What they are thinking — questions, doubts, intentions      |
| Feelings      | Emotional state + intensity score (1 = low, 5 = high)       |
| Pain Points   | Specific frictions, failures, and unmet expectations        |
| Opportunities | Interventions that could improve the experience at this stage|

## Complete Template Structure

```markdown
## Journey Map: [Persona Name] | Goal: [Specific goal]
**Data sources:** [Interviews, analytics, support tickets, etc.]
**Last updated:** [Date]

---

### Stage 1: [Stage Name]

**Actions**
- [Concrete action the persona takes]
- [Another action]

**Thoughts**
- "[Question or internal monologue in their voice]"
- "[Doubt or intention]"

**Feeling:** [Emotional label], [intensity score 1–5]
*(Mark as LOW POINT if this is the lowest emotional score in the map)*

**Pain Points**
- [Specific friction — concrete, not general]

**Opportunities**
- [Intervention that would improve this stage]

---

### Stage 2: [Stage Name]
[Repeat structure]

---

## Summary

**Emotional LOW POINT:** Stage [N] — [label and why it matters]
**Highest-leverage opportunity:** [Stage and specific intervention]
**Cross-functional owner gaps:** [Stages where no team currently owns the experience]
```

## Worked Example (Abbreviated)

```markdown
## Journey Map: First-Time Buyer | Goal: Purchase a gift under $50
**Data sources:** 12 usability sessions, 3 months cart abandonment analytics
**Last updated:** Feb 21, 2026

---

### Stage 1: Awareness

**Actions**
- Sees Instagram ad, taps to website
- Scans above-the-fold content for 8 seconds

**Thoughts**
- "Do they have something for my sister?"
- "Is this legit or is it some dropshipping store?"

**Feeling:** Curious, slightly skeptical (2/5)

**Pain Points**
- No gift category or occasion filter visible on landing page
- No social proof (reviews, press mentions) on the homepage

**Opportunities**
- Add "Shop by Occasion" entry point on landing page
- Surface trust signals (rating count, press logos) above the fold

---

### Stage 2: Browse

**Actions**
- Types "birthday" in search
- Scans 40+ results in grid view

**Thoughts**
- "How do I know what's good quality?"
- "There's so many options, I don't know where to start."

**Feeling:** Overwhelmed, anxious (1/5) — EMOTIONAL LOW POINT

**Pain Points**
- No social proof at browse level; reviews only visible on individual product pages
- No "bestseller" or "most gifted" sorting option
- Price filter exists but gift-budget filter does not

**Opportunities**
- Surface star ratings and review counts in grid view
- Add "Most Gifted" sort option and "Under $50" gift filter
- Show editorial curations ("Gifts for her", "Popular this week")

---

### Stage 3: Purchase

**Actions**
- Adds item to cart
- Begins checkout — enters email, address, payment

**Thoughts**
- "I hope this arrives before Saturday."
- "Do I have to create an account?"

**Feeling:** Cautiously optimistic (3/5)

**Pain Points**
- Estimated delivery date shown only on the order confirmation page, after payment
- Guest checkout option not visible until the second step of checkout

**Opportunities**
- Show estimated delivery on PDP and in cart before checkout begins
- Surface guest checkout option on the first checkout screen

---

## Summary

**Emotional LOW POINT:** Stage 2 (Browse) — overwhelmed by choice with no
quality signals available at the browse level. This is where 68% of cart
abandonment occurs (analytics).

**Highest-leverage opportunity:** Stage 2 — surface star ratings in grid view.
Estimated dev effort: 3 days. Estimated impact: reduce browse abandonment by 15%.

**Cross-functional owner gaps:**
- Stage 1 owned by Marketing (acquisition). No Product ownership of landing page trust signals.
- Stage 2 owned by no one: search and merchandising span Product, Marketing, and Engineering.
```

## Feelings Scoring Guide

Use a consistent 1–5 scale to make emotional intensity comparable across stages
and to track improvement over time.

| Score | Label              | Customer Observable Behavior                         |
|-------|--------------------|------------------------------------------------------|
| 1     | Frustrated / Lost  | Abandons, calls support, expresses confusion         |
| 2     | Uncertain / Wary   | Pauses, searches for reassurance, reads FAQ          |
| 3     | Neutral / Calm     | Proceeding without friction; no visible engagement   |
| 4     | Confident / Pleased| Moves quickly, engages with content, expresses ease  |
| 5     | Delighted          | Shares, returns, recommends; exceeds expectations    |

Mark the lowest score in the map as the emotional LOW POINT — this is the primary
intervention target.

## Quality Checklist

- [ ] Single persona with named role and context
- [ ] Single goal with a defined scope (start and end of the experience)
- [ ] All six NNGroup rows present for each stage
- [ ] Feelings row uses a 1–5 intensity score, not just emotional labels
- [ ] Emotional LOW POINT identified and marked
- [ ] Pain points are specific observations, not product critique
- [ ] Opportunities are actionable and owned by a specific team
- [ ] Cross-functional gaps explicitly identified in summary
- [ ] Data sources cited (not based on internal assumptions alone)
