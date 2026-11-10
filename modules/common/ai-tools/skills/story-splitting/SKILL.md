---
name: story-splitting
description: "Trigger: refining a backlog, decomposing an epic, planning an MVP or walking skeleton, finding vertical slices, reducing story size, applying SPIDR or Hamburger slicing, avoiding scatter-gather component stories, or deciding the first valuable story before implementation planning. Splits broad requirements, large stories, features, or initiatives into small end-to-end child stories that each preserve a whole user-visible capability — never technical component tasks — and names the first slice that delivers value or learning even if no sibling ever happens."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Story Splitting

Split work so the team can deliver, test, learn, and change direction in
small batches. A good split preserves a whole user-visible capability while
reducing variation, uncertainty, scope, or quality level.

The goal is not "make smaller tickets." The goal is **N% of the system 100%
done and demonstrable**, not 100% of the system N% done.

## Activation Contract

Use this skill when:

- An epic, large story, feature idea, roadmap item, or backlog item must
  become small, independently valuable child stories.
- An existing split keeps producing component tasks, scatter-gather tickets,
  or stories that cannot be tested alone.
- The first valuable story must be chosen before any implementation plan.

Do not use it to interrogate every product decision from scratch — when the
decision tree is the real work and no artifact exists, run a specification
conversation (one focused question at a time, restated in the boundaries
below). Do not use it to produce implementation tasks. Do not use it when
there is no artifact to harden yet.

## Hard Rules

1. **Slice capabilities, not components.** Every child story describes a
   change in behavior from a real user's or external system's point of view.
   If the "user" is an internal component, layer, queue, database, API, or
   service, it is a task, not a story.
2. **Stay in the problem space first.** Ask what the simplest options are for
   delivering value to the customer soon — not how to build the
   already-imagined solution.
3. **Start with a primitive whole.** Prefer a tiny end-to-end whole over a
   polished part; state its release constraint honestly; label disposable
   tracer work as such.
4. **Keep story boundaries vertical** regardless of the repository's
   implementation or pull-request workflow. Never turn database, API, UI,
   and tests into separate backlog outcomes.
5. **Never defer a legal, safety, privacy, contractual, or security
   requirement** without a clear non-release constraint.
6. **This skill stops at the product split.** Implementation workflow, TDD
   timing, mutation timing, feature-flag policy, pre-PR gates, branch
   topology, and delivery mechanics belong to project instructions and the
   implementation planning activity; story splitting neither requires nor
   prohibits a mutation run or a feature flag.

## Execution Steps

1. **REFRAME** — write the parent in plain language: actor, need or
   capability, outcome, and the current constraint. A solution phrase
   ("build online banking portal") becomes capabilities; a technical task
   ("add payment database") finds the user behavior it serves, or stays a
   task attached to the first story that proves it matters.
2. **SURFACE EXAMPLES** — list happy paths, alternate and error paths, roles,
   data shapes, business rules, interfaces, quality attributes, and unknowns
   before inventing tickets. Acceptance examples are often natural splits.
3. **FIND DIMENSIONS** — use the seven split dimensions as prompts —
   capability, path, interface, data, rules, quality, and risk — and choose
   the split that creates the most value and optionality. The named-method
   details (SPIDR, Hamburger, Humanizing Work patterns, Bill Wake's split
   families) live in `references/pattern-catalog.md`; load it when a story
   needs more prompts than the seven dimensions.

   | Dimension | Useful question |
   |-----------|-----------------|
   | Capability | Which narrower customer capability still delivers value? |
   | Path | Which happy path, alternate path, workflow branch, or operation can stand alone? |
   | Interface | Which channel, consumer, UI level, device, browser, or integration can prove the behavior first? |
   | Data | Which data subset, file type, entity type, field subset, or quantity can we support first? |
   | Rules | Which business, validation, permission, compliance, or policy rules can be scoped safely? |
   | Quality | What is the simplest acceptable quality level: manual, batch, low fidelity, small scale, slower, generic UI? |
   | Risk | What spike, tracer bullet, or walking skeleton would answer a specific risky unknown? |
4. **UNSTICK** — if the team keeps decomposing technically, apply the
   Hamburger Method from `references/pattern-catalog.md`: list the layers,
   list simpler-to-richer options per layer, take one first "bite" across
   every layer so the result stays end-to-end.
5. **CHOOSE THE FIRST SLICE** — prefer the split that lets the team
   deprioritize or delete a follow-up story, produces similarly sized
   children, has the highest value-to-cost ratio, or burns down
   integration risk early.
6. **WRITE CHILD STORIES** — title (actor + action + narrow scope), value,
   scope, intentional deferrals, acceptance examples (precondition →
   trigger → observable outcome), release constraint, and follow-ups, in the
   user's domain vocabulary.
7. **VALIDATE** — run the quality bar in `rules/quality-and-output.md` on
   every child before returning the split.

## Output Contract

Return the compact split artifact defined in `rules/quality-and-output.md`
(parent, recommended first slice with its why, split-candidate table, parking
lot, warnings, next step). On request, run an interactive refinement session
instead: one high-value question at a time, starting with the question that
most changes the split — usually actor, outcome, release constraint,
highest-value segment, or biggest risk.

## References

- `rules/capability-slices.md` — the core principles behind every split.
- `rules/quality-and-output.md` — INVEST bar, validation checklist, red flags, output format.
- `references/pattern-catalog.md` — named patterns: SPIDR, Hamburger, deferrals, first-version patterns.
- `references/source-notes.md` — source-by-source provenance for the method.
- `references/provenance.md` — upstream import details and licence notice.

Companion skills are optional here. Where a specification skill is installed,
use it to resolve a fuzzy decision tree before or after splitting; where a
planning skill exists, hand it the selected child story for implementation
sequencing; where design-storyboard or find-gaps companions exist, they
harden mocks and acceptance criteria after the split. The splitting rules
above stand alone without any of them.
