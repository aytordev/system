# Prioritization Framework Advisor — Full Framework

## Purpose

Prioritization frameworks are tools for structured decision-making — they are not
ranking algorithms. The right framework depends on product stage, data maturity,
and the decision being made. Applying the wrong framework to the wrong context
generates false confidence and produces rankings that no one trusts or uses.

Key principle: Pick one framework per planning cycle and apply it consistently.
Mixing frameworks in one backlog invalidates all rankings.

## The 4 Adaptive Questions

The advisor uses four questions to select the appropriate framework. Ask them
in sequence; the answer to each constrains the options.

---

**Question 1: What is your product stage?**

A) Pre-PMF — still searching for product-market fit; user base under 1,000 or
   less than 6 months post-launch
B) Post-PMF / Scaling — validated product, growing user base, instrumented with
   analytics
C) Mature / Optimizing — large user base, revenue goals, competitive market
   position to defend

---

**Question 2: What is your data maturity?**

A) Qualitative only — customer interviews, support tickets, anecdotal feedback;
   no reliable usage analytics
B) Mixed — some usage data but sparse or untrustworthy; directional signals only
C) Quantitative — reliable analytics, known user counts, measurable impact proxies

---

**Question 3: What is the decision context?**

A) Internal team ranking — choosing what to build next; team alignment is the goal
B) Stakeholder communication — justifying prioritization to leadership, sales, or
   customers; transparency is the goal
C) Feature discovery — categorizing user needs to identify delighters vs. basics;
   research is the goal

---

**Question 4: How many items are you prioritizing?**

A) Under 10 items — small, focused backlog or sprint
B) 10–50 items — quarterly backlog or program-level planning
C) 50+ items — portfolio or annual planning

---

## Recommendation Output Template

After collecting answers to all four questions, produce:

```markdown
## Prioritization Framework Recommendation

**Your context:**
- Stage: [A/B/C from Q1]
- Data maturity: [A/B/C from Q2]
- Decision context: [A/B/C from Q3]
- Backlog size: [A/B/C from Q4]

**Recommended framework:** [Framework name]

**Rationale:** [2–3 sentences explaining why this framework fits the context]

**If context changes:**
- If [alternate condition] → use [alternate framework] instead
- If [alternate condition] → use [alternate framework] instead

**Framework application guide:** [Step-by-step instructions for this specific context]
```

---

## Framework Comparison Table

| Framework | Best Fit Stage   | Data Required         | Decision Context      | Backlog Size |
|-----------|------------------|-----------------------|-----------------------|--------------|
| RICE      | Post-PMF+        | Quantitative          | Internal ranking      | 10–50        |
| ICE       | Pre-PMF or Post  | Qualitative or mixed  | Internal ranking      | Any          |
| Kano      | Any              | User research         | Feature discovery     | 5–30         |
| MoSCoW    | Any              | Qualitative           | Stakeholder communication | Any      |
| Value/Effort | Pre-PMF      | Qualitative or mixed  | Internal ranking      | Under 20     |

---

## RICE Framework

**Formula:** (Reach × Impact × Confidence) / Effort

**When to use:** Post-PMF with quantitative data; internal team ranking; 10–50 items.

**Component definitions:**

| Component  | Definition                                             | Unit                  |
|------------|--------------------------------------------------------|-----------------------|
| Reach      | How many users affected per time period                | Users per quarter     |
| Impact     | Magnitude of effect per user                           | 1=min, 2=low, 3=med, 4=high, 5=massive |
| Confidence | How reliable are the Reach and Impact estimates?       | Percentage (20–100%)  |
| Effort     | Total person-months of work across all contributors    | Person-months         |

**Critical rules:**
- Never use 100% confidence. No estimate earns it.
- Use the same time window for Reach across all items in the same cycle.
- Effort includes design and QA, not just engineering.

**Example:**
```
| Feature       | Reach | Impact | Confidence | Effort    | RICE  |
|---------------|-------|--------|------------|-----------|-------|
| Email digest  | 6,000 | 1      | 90%        | 0.5 mo    | 10,800|
| Bulk export   | 4,200 | 2      | 80%        | 1.5 mo    | 4,480 |
| SSO           | 1,800 | 3      | 60%        | 3 mo      | 1,080 |
```

---

## ICE Framework

**Formula:** Impact × Confidence × Ease

**When to use:** Pre-PMF or when data is sparse; faster scoring than RICE;
works with qualitative signals.

| Component  | Definition                                             | Scale  |
|------------|--------------------------------------------------------|--------|
| Impact     | How much will this move the needle on the goal?        | 1–10   |
| Confidence | How certain are you of the Impact estimate?            | 1–10   |
| Ease       | How easy is it to implement? (inverse of effort)       | 1–10   |

**Advantage over RICE:** No unit normalization required. Faster to score.
**Disadvantage vs RICE:** Impact and Ease are not grounded in data; subjective.

---

## Kano Model

**When to use:** Feature discovery; categorizing what users need vs. what delights them.
Research-based — requires user surveys or structured interviews.

**Five categories:**

| Category       | Definition                                              | Example               |
|----------------|---------------------------------------------------------|-----------------------|
| Basic (Must-be)| Expected; absence causes dissatisfaction; presence is neutral | Login, data save |
| Performance    | More is better; directly proportional to satisfaction  | Search speed          |
| Delighter (Attractive) | Unexpected; presence causes delight; absence is neutral | Smart suggestions |
| Indifferent    | Users do not care either way                           | Keyboard shortcut X   |
| Reverse        | Presence causes dissatisfaction for some users         | Forced onboarding     |

**Survey question pair per feature:**
1. Functional: "If this feature IS present, how do you feel?" (Like / Expect / Neutral / Tolerate / Dislike)
2. Dysfunctional: "If this feature is NOT present, how do you feel?" (Like / Expect / Neutral / Tolerate / Dislike)

**Kano lookup table:** Combine answers to classify the feature.

**Output:** Prioritize Basics first (fix what's broken), then Performance improvements,
then Delighters for differentiation. Never prioritize Indifferent items.

---

## MoSCoW Framework

**When to use:** Stakeholder scope communication; sprint or release scoping;
NOT as a ranking algorithm. MoSCoW does not produce a ranked list — it produces
four buckets.

| Label          | Definition                                           |
|----------------|------------------------------------------------------|
| Must Have      | Non-negotiable. Absence = release failure.           |
| Should Have    | High value; painful to omit but workaround exists.  |
| Could Have     | Nice to have; included only if capacity remains.    |
| Won't Have     | Explicitly out of scope for this release.           |

**Common failure mode:** "Must Have" bucket becomes the entire backlog.
Fix: The Must Have list must fit in half the available capacity. Anything that
does not fit is a Should Have at best.

**Anti-pattern:** Using MoSCoW as a ranking tool. Items within each bucket
are not ordered by MoSCoW — apply ICE or RICE within the Must Have bucket
to sequence them.

---

## Value / Effort Matrix (2×2)

**When to use:** Under 20 items; fast alignment sessions; pre-PMF or early-stage.

```
                LOW EFFORT          HIGH EFFORT
HIGH VALUE  |  Quick Wins         |  Strategic Bets  |
LOW VALUE   |  Fill-ins (if time) |  Money Pits      |
```

**Protocol:**
1. Plot all items as a group (avoid scoring individually and comparing)
2. Discuss placement openly; surface disagreements
3. Commit to Quick Wins first; evaluate Strategic Bets against strategy
4. Explicitly park Money Pits with documented rationale
5. Do not build Fill-ins until all Quick Wins and Strategic Bets are decided

---

## Framework Selection Decision Tree

```
Is data quantitative and reliable?
├── YES → Is backlog 10+ items for internal ranking?
│         ├── YES → RICE
│         └── NO  → ICE or Value/Effort
└── NO  → What is the decision context?
          ├── Feature discovery / user research → Kano
          ├── Stakeholder scope alignment → MoSCoW
          └── Internal fast ranking → ICE or Value/Effort
```
