---
title: Problem Framing Canvas
impact: CRITICAL
impactDescription: Solving the wrong problem wastes cycles and erodes team trust
tags: strategy, problem-framing, mitre, canvas, reframing
---

## Problem Framing Canvas

**Impact: CRITICAL (Solving the wrong problem wastes cycles and erodes team trust)**

Use the MITRE Problem Framing Canvas in three sequential phases before committing to any solution: Look Inward (surface your assumptions and biases about the problem), Look Outward (map stakeholders, constraints, and context), then Reframe (synthesize into an actionable problem statement that challenges the original framing). Do not skip the Look Inward phase — unexamined assumptions are the most common source of misdirected roadmaps. The output is a reframed problem statement, not a solution.

**Incorrect (jumping to solution framing):**

```markdown
Problem: Users can't find the export button.
Solution: Move the export button to the top navigation.
→ Team begins design sprint.
```

**Correct (three-phase canvas applied):**

```markdown
Look Inward:
- Assumption: Users want to export data
- Bias: Engineering team suggested this based on support tickets, not user research
- Challenge: Are exports the goal, or is sharing data the goal?

Look Outward:
- Stakeholders: End users (analysts), their managers (recipients of exports)
- Context: Analysts export to send to managers via email every Friday
- Constraint: Managers don't have product access

Reframe:
Original: "Users can't find the export button"
Reframed: "Analysts need a reliable way to share live data snapshots with
stakeholders who lack product access — weekly manual exports are a workaround
for a missing collaboration feature"
```

Reference: [Full framework](../references/problem-framing-canvas-full.md)
