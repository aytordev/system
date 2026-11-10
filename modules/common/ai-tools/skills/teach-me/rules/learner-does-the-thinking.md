---
title: Make the Learner Do the Thinking
impact: CRITICAL
impactDescription: Prevents information dumping and illusions of mastery
tags: teach-me, techniques, anti-patterns
---

## Make the Learner Do the Thinking

**Impact: CRITICAL**

### Fluency vs storage strength

The framing principle behind everything else. Distinguish two kinds of learning:

- **Fluency strength**: in-the-moment retrieval. High right after teaching —
  and dangerously misleading, because it gives both tutor and learner an
  illusory sense of mastery.
- **Storage strength**: long-term retention. The real goal. Built only through
  effortful, spaced, varied retrieval.

The corollary is asymmetric difficulty: when introducing knowledge, excessive
difficulty is the enemy — keep explanations simple and concrete. When
practicing, desirable difficulty is a tool — effortful retrieval, spacing, and
interleaving strengthen retention. See `references/learning-science.md` for
the research basis.

### Socratic questioning

When the learner has relevant prior knowledge and accepts an interactive style,
guide discovery through questions before explaining:

- "What do you think X might be, given what you know about Y?"
- "Where have you encountered something similar?"
- If the learner cannot form a useful attempt, supply the missing model rather
  than forcing a guess.

### Concrete before abstract

Use concrete examples from the learner's project or domain when they make the
abstraction easier to build. One decisive example may be enough; contrasting
examples help when boundaries or transfer matter. If the learner already knows
the domain or asks for reference material, stating the principle first may be
clearer.

### Progressive difficulty (Bloom's ladder)

| Level | Question type | Example |
|-------|-------------|---------|
| Remember | Recall facts | "What are the three types of X?" |
| Understand | Explain meaning | "Why does X work this way?" |
| Apply | Use in new context | "How would you apply X to solve this?" |
| Analyze | Compare/contrast | "What's the difference between X and Y?" |
| Evaluate | Judge/justify | "Which approach is better here, and why?" |
| Create | Design/build | "Design a solution using X for this scenario" |

Diagnose the learner's current level and pitch questions there. Only advance
when the current level is solid. Question templates per level are in
`references/assessment-patterns.md`.

### Interleaving

After teaching multiple related concepts, mix them in practice. Do not label
which concept each question tests — require the learner to identify the
relevant approach. This builds discrimination and transfer.

### Code demonstrations

For technical topics, use code as a teaching tool:

- **Predict**: Show code, ask what it does before explaining.
- **Identify**: Ask which concept the code demonstrates.
- **Modify**: Have the learner change the code to handle a new case.
- **Debug**: Show broken code, ask the learner to find and explain the bug.
- **Build**: Have the learner write code that applies the concept.

### Feynman technique

The most powerful comprehension check. Four steps:

1. Ask the learner to explain the concept simply, as if teaching a beginner.
2. Play the confused beginner — ask follow-up questions, flag jargon, point
   out skipped steps.
3. When the explanation breaks down, that is the gap — focus there.
4. Have them refine until the explanation is genuinely clear.

### Anti-patterns

- **Giving answers immediately** — prompt retrieval first when the learner has
  relevant knowledge. Treat "I don't know" as evidence to distinguish a recall
  gap from missing prerequisite knowledge; do not force an uninformed guess.
- **Information dumping** — break up an explanation when a check or question
  would improve learning; do not interrupt a concise direct-reference answer
  to satisfy a paragraph quota.
- **Accepting "I understand" at face value** — verify with explanation or
  application before recording mastery or advancing a durable plan.
- **Constant difficulty regardless of performance** — calibrate continuously.
- **Never fading scaffolding** — early: hints and guided questions; later:
  open-ended problems with minimal guidance. The goal is independence.
- **Skipping review** — default multi-session learning to spaced review; skip
  or shorten it only when the learner requests a one-off/capture session, time
  or accessibility makes it disproportionate, or no prior material is due;
  record the gap and offer a later review when retention is still the goal.
- **Testing memorization over understanding** — prefer application, analysis,
  and evaluation questions over pure recall.
- **Confirming understanding prematurely** — "Good start — now explain *why*
  that's the case."
- **Passive monologue** — if the tutor is doing most of the talking, something
  is wrong.
- **Treating all "I don't know" the same** — "haven't learned yet" means teach
  it; "learned but can't recall" means prompt retrieval with hints.
- **Teaching from parametric knowledge alone** — for fast-moving or factual
  topics, curate trusted sources into `resources.md` first and cite them.
- **Confusing fluency with mastery** — prefer spaced performance before
  graduating a concept from a long-term review plan.
