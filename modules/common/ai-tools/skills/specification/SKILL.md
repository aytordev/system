---
name: specification
description: "Trigger: an idea, feature request, or problem statement has no agreed rules or examples yet — let's spec this out, what should this actually do, we need acceptance criteria. Runs specification as a conversation: one question at a time, every material assumption becomes a question, and outputs go back into the team's own story artifact as an example map (rules with concrete examples and open questions), acceptance criteria, candidate glossary terms, and parked questions with owners and dates. The agent-facilitated round is a draft for accountable human review before any build or split."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Specification: the Conversation Is the Product

A specification is not a document. It is a conversation between stakeholders
in which shared understanding gets built — and the written result is, at
best, an educated guess about what is really required, refined until reality
gets the deciding vote. The value is in the *planning*, not the plan: asking
an agent to "write the spec" while skipping the conversation misses the
entire point. This skill exists to *force* the conversation — with you first,
then between the humans who own the answers.

**Where this sits:** before story splitting, before implementation planning,
before any acceptance test exists. Its output feeds all three.

The specification-review page template lives at
`assets/spec-review-template.html`; load it only when preparing the
accountable-review handoff.

## Activation Contract

Use this skill when:

- An idea, feature request, or problem statement has no agreed rules or
  examples yet.
- The team needs acceptance criteria derived from a conversation, not
  invented.
- A decision tree exists only in someone's head and must be resolved with
  the people who own the answers.

Do not use it to tighten an existing artifact with holes (that is a
gap-review activity), to slice agreed work (that is story splitting), or to
compare libraries and tools (that is a technology-selection activity).

## Hard Rules

1. **Find the story's home first.** Ask where this story lives — an issue, a
   file, a ticket, anywhere the team already keeps it. Everything this skill
   produces is written back into THAT artifact. If it has no home yet, ask
   where it should live; never invent a parallel convention silently.
2. **One question at a time.** Never a questionnaire. Name the stakes and
   accept "park it" — parked questions get an owner and a decision/review
   date, never silence. Recommend an answer only when repository evidence or
   known trade-offs justify it; otherwise ask neutrally and label any
   tentative hypothesis as such.
3. **Every material assumption becomes a question.** The moment you notice
   yourself deciding an outcome the human never supplied, stop and ask it.
   An answer that cannot change the map was not a real decision question.
4. **The map is data, not prose.** Build it as you go and keep it visible,
   using the card grammar in `rules/example-map.md`.
5. **Challenge the map before trusting it.** Counter-examples, zero–one–many,
   boundaries, and failure behavior. A rule with one example is a guess; a
   rule whose examples all agree is a hypothesis.
6. **The draft is a draft.** The agent-facilitated round becomes usable only
   after the people accountable for the outcome review it; match the review
   group to risk and shared ownership.
7. **Reality gets the final vote.** Acceptance criteria written here are
   hypotheses until the shipped slice confirms them; when reality disagrees,
   the conversation reopens — that is a feature of the method, not a failure
   of the spec.

## Execution Steps

1. **LOCATE** — ask for the story artifact's home and write everything back
   into it.
2. **CONVERSE** — run the contract above one question at a time; build the
   example map as data as you go.
3. **CHALLENGE** — apply the counter-example challenge and read the map's
   shape as a readiness diagnostic (`rules/example-map.md`).
4. **REVIEW** — generate the review page from
   `assets/spec-review-template.html` for the accountable round; run the
   multi-round flow in `rules/accountable-review.md` until a round produces
   no new rules, no changed examples, and no new questions.
5. **CAPTURE VOCABULARY** — add every coined or contested term to
   `candidate terms` with a one-line gloss; route candidates to the team's
   language protocol where one exists, otherwise carry the list with the
   story.
6. **HAND OFF** — hand the stabilised map to the splitting activity; each
   child story carries its rules and examples onward, with per-rule
   questions flattened into the single questions list downstream mapping
   expects.

## Output Contract

Return the updated story artifact path, the example map (rules, concrete
examples, questions with owners and dates, acceptance criteria, candidate
terms), and the review-handoff record: who reviewed, what returned as
feedback, and what remains parked. Verification is the checklist in
`rules/accountable-review.md`; a map that is question-dominated is reported
as not ready to build, never converted into guessed criteria.

## References

- `rules/example-map.md` — the map grammar, challenge protocol, and shape diagnostic.
- `rules/accountable-review.md` — review rounds, review-page generation, vocabulary routing.
- `assets/spec-review-template.html` — the review handoff page template.
- `references/concept-sources.md` — where the practices taught here come from.
- `references/provenance.md` — upstream import details and licence notice.

Companion skills are optional here. Where a story-splitting, planning, or
find-gaps skill is installed, its role is named above and inline; where a
ubiquitous-language skill exists, candidate terms enter its naming protocol
individually. This skill stands alone when none are installed.
