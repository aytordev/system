---
title: Workshop Facilitation Protocol
impact: MEDIUM
impactDescription: Unstructured AI-assisted sessions produce noise instead of actionable PM outputs
tags: facilitation, workshop, protocol, entry-modes, guided-session, interactive
---

## Workshop Facilitation Protocol

**Impact: MEDIUM (Unstructured AI-assisted sessions produce noise instead of actionable PM outputs)**

This is the canonical facilitation protocol for all interactive PM skills. It defines the session heads-up format, three entry modes (Guided, Context dump, Best guess), the one-question-at-a-time discipline, and progress labels. Use this as the base pattern when authoring any skill that involves a multi-turn interactive session. Do not skip the entry mode selection — dropping a user directly into questions without offering a context dump option causes information asymmetry and produces outputs that require two rounds of revision instead of zero.

**Incorrect (no entry mode, no structure, floods user with questions):**

```markdown
Let's work on your positioning. Tell me about your product, your users, their
main problems, your competitors, your pricing, your differentiation, your
company stage, your team size, and your key metrics. I'll analyze everything
and give you a positioning statement.
```

**Correct (heads-up + entry mode + one-question-at-a-time + progress labels):**

```markdown
## Positioning Workshop

I'll guide you to a complete positioning statement using Geoffrey Moore's framework.
This takes 6–8 questions. You can exit and resume anytime.

**How do you want to start?**

A) **Guided** — I ask one question at a time, build context as we go (recommended if you're
   still forming your thinking)
B) **Context dump** — Paste or describe everything you know; I'll extract what I need and
   fill gaps with targeted questions
C) **Best guess** — Tell me your product in one sentence; I'll draft a positioning statement
   and we'll refine from there

---
*(User selects A — Guided)*

**[1/6] Target Customer**
Who is the primary user of your product? Describe their role, company size, and
the specific context in which they'd use it.

*(Wait for response before asking question 2)*

---
*(After each response, show progress label and acknowledge before proceeding)*

**[2/6] Problem**
*(building on: mid-market finance teams, 50–200 employees)*

What is the specific, painful problem this person faces that your product solves?
Describe it in terms of their daily experience, not your solution.
```

Reference: [Full framework](../references/workshop-facilitation-full.md)
