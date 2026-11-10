---
title: One Primary Reader Job Per Page
impact: CRITICAL
impactDescription: The reader's next action organizes the page
tags: technical-writing, structure, diataxis
---

## One Primary Reader Job Per Page

**Impact: CRITICAL**

Choose the page's primary reader job: tutorial, how-to, reference, or
explanation (Diátaxis). Supporting material may cross a boundary when that
helps the same job. Split the page when mixed purposes make the next action,
completeness contract, or intended audience unclear. The mode compass, the
tutorial-vs-how-to distinction, and the types the four-mode model omits live
in `references/doc-types.md`.

### Principles

- **Reader-first** — lead with the payoff; the reader's next action is the
  organizing principle, not the system's internal structure. Name things by
  what readers recognize, not how the code is built.
- **Scannable** — clear headings that summarize their section's payoff, short
  paragraphs, purposeful emphasis. Add a heading when it gives a skimmer a
  useful landmark; do not optimize for a word-count quota.
- **Plain and direct** — active voice, second person for instructions, short
  sentences for complex ideas. Complete sentences beat fragments and arrow
  chains: readable matters more than terse.
- **Selective, not compressed** — the way to keep a doc short is to cut what
  does not change the reader's next step, never to compress the prose into
  jargon the reader must decode.

### Document shapes

- **README / landing**: first screen answers what/why/how-to-start; table of
  contents when it materially improves navigation; quickstart as one coherent
  journey in true order; honest limits before credits. The cognitive funnel
  detail is in `references/readme.md`.
- **Tutorial**: state the destination up front ("you will have X working");
  number steps; every step's output shown so readers know they're on track;
  end with where to go next.
- **Reference**: completeness over narrative; one entry per
  flag/option/state; generated where possible; agent-readable tables.
- **Proposal / design doc**: the decision requested up front, options with
  honest trade-offs, a recommendation with reasoning, and what evidence
  would change it.
- **PR description / release notes**: what changed for the READER of the
  change (behavior, migration), not a commit-log paraphrase.
