---
title: Run the Session Loop, Not a Lecture
impact: CRITICAL
impactDescription: Keeps sessions interactive, spaced, and logged
tags: teach-me, sessions, pacing
---

## Run the Session Loop, Not a Lecture

**Impact: CRITICAL**

Use this loop as a multi-session template, scaled to the learner's stated time
and interaction preference. In an interactive lesson the learner does more of
the cognitive work; a requested explanation can be tutor-led.

```
SESSION FLOW
│
├─► REVIEW (skip for first session)
│   3-5 spaced repetition questions on previous material.
│   Target areas where the learner struggled.
│   Calibration: "Before I ask — how confident do you feel about [previous topic]?"
│
├─► OBJECTIVE
│   State the session goal: "After this you'll be able to [observable verb] [specific thing]."
│   Connect to the big picture and to prior knowledge.
│
├─► TEACH
│   Concrete examples before or alongside abstraction when they reduce cognitive load.
│   Cite sources from resources.md. Keep difficulty LOW here — difficulty is
│   the enemy of acquisition. Pause when interaction would improve
│   understanding; do not interrupt a requested concise explanation mechanically.
│
├─► CHECK (Active Recall)
│   "Explain what you just learned in your own words."
│   Socratic follow-ups: "Why?" / "What if?" / "How is this different from?"
│   Do NOT confirm understanding after surface-level answers. Probe deeper.
│
├─► PRACTICE
│   3-5 progressively harder problems or scenarios.
│   For code topics: examples to explain, predict, modify, or extend.
│   Immediate, specific feedback — not just correct/incorrect.
│   Mix in questions from previous topics (interleaving).
│   Difficulty is the TOOL here — effortful retrieval builds retention.
│
├─► REFLECT
│   Feynman check: "Explain [concept] as if teaching someone who has never heard of it."
│   Metacognition: "What was hardest? What surprised you? What's still fuzzy?"
│   Calibration: "Rate your confidence now, 1-10."
│
├─► LESSON (offer, don't impose)
│   Generate a self-contained HTML lesson: lessons/NNNN-[slug].html.
│   See references/html-lessons.md. Learner short on time? Capture mode.
│
└─► LOG
    Update session log: topics, performance, gaps, confidence calibration.
    Write learning records; promote newly-mastered terms to the glossary.
    Update learning plan progress; preview next session; recommend one source.
```

### Pacing rules

- If the learner gets 3+ questions right in a row without hesitation → increase
  difficulty or advance.
- If the learner struggles with 2+ questions in a row → slow down, add
  scaffolding, revisit the prerequisite.
- If self-rated confidence is high but performance is low → blind spots; use
  targeted probing.
- If self-rated confidence is low but performance is high → encourage; the
  learner may be underestimating themselves.

### Capture mode

When the learner is short on time — or asks for the material "to read later" —
generate the lesson *up front*, at the point where teaching would normally
happen, and skip or defer the interactive CHECK/PRACTICE steps. The lesson's
recap quiz becomes their asynchronous practice, and the next session's REVIEW
covers the captured material as spaced retrieval.

Log the lesson as **captured, not taught**: a captured lesson is exposure, not
evidence, so nothing from it qualifies for a learning record or counts toward
mastery until the learner demonstrates it in a later session. Say so when
offering capture mode — generating up front spoils retrieval.
