---
name: find-gaps
description: "Trigger: tightening a written artifact — stories, plans, acceptance criteria, specs, or design mocks — before planning or coding (what's missing, poke holes in this, what could go wrong, help me tighten this up). Surfaces missing states, unhandled edge cases, unstated assumptions, unverifiable criteria, and slices still too broad, then asks one question at a time and writes each confirmed answer back into the artifact."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Find Gaps

Most shipped bugs and post-launch firedrills come from things that were never
written down — not from things that were specified wrong. This skill
systematically surfaces those absences *before* implementation, when fixing
them is cheap.

But finding gaps is only half the job. A list of open questions that nobody
answers is just a todo list with extra steps. When material gaps exist, the
real output is an **updated artifact** — a plan, AC set, or mock spec that now
contains decisions it didn't contain before, made by the user, captured
verbatim, and written back to the source of truth. A clean review is also
valid when it names the sections and hostile cases checked; never invent a gap
to make the process look productive.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when the user:

- Asks "what's missing?", "find gaps", "poke holes in this", "what could go
  wrong?", "help me tighten this up".
- Shares a plan, spec, acceptance criteria, or design mocks and asks for
  review.
- Is about to start implementing and wants a pre-implementation sanity check.
- Is handing work to another team/engineer and wants a completeness pass.
- Is doing a pre-mortem.

This skill needs an artifact to inspect. If nothing is written down yet,
establish the artifact first: ask one focused question at a time until the
decision tree is resolved, then review the written result. If the problem is
oversized or horizontal work rather than unresolved intent — a story too large
to review as one slice — say so and route it to a splitting step instead of
gapping it. When reviewing multiple mocks together, build the single-page view
first, then find what is missing across them.

## Hard Rules

1. **Silence is a red flag, not a green light.** A plan that says nothing
   about errors doesn't handle them gracefully — it doesn't handle them at
   all. An acceptance criterion with no measurement isn't ambiguous — it's
   unverifiable. A mock with no empty state isn't flexible — it's broken the
   first time a new user opens it.
2. **Every gap is a conversation, not a comment.** The loop — ask, capture,
   write back, confirm — is the product. A static gap list is only a report.
3. **One question at a time.** A twenty-question dump is a report; twenty
   questions, each answered and captured, is a tightened artifact. Never
   bundle unrelated questions; a tightly coupled pair is the only exception.
4. **Capture decisions visibly, every time.** Every confirmed answer becomes
   visible text in the artifact before you move on. Never build a private list
   to reconcile at the end — it evaporates.
5. **Never accept vague answers.** "The user sees an error" is not testable;
   ask the follow-up that makes it a specific, observable outcome.
6. **Mirror the user's vocabulary.** If they say "buyer," the artifact says
   "buyer." Domain language is a feature, never silently rewritten.
7. **Do not invent gaps or options.** An evidenced clean result is valid;
   fabricated blockers and invented choice options anchor the user to your
   guesses and hide their actual answer.
8. **Triage before asking.** Classify each candidate gap Blocker /
   Should-address / Nice-to-have, then ask the concrete question — never
   "do you want to address this?" for every gap.

## Execution Steps

1. **SURVEY** — walk the relevant checklist (`rules/gap-checklists.md`) and
   note candidate gaps silently. Run mixed artifacts section by section so
   the checklists don't bleed. Cross-check plan ↔ AC ↔ mocks: gaps often
   appear as contradictions between two of them.
2. **TRIAGE** — classify each candidate: Blocker (implementation can't proceed
   or will be wrong without a decision), Should-address (rework or a bug if
   left open), Nice-to-have (won't block this iteration). If everything is
   Nice-to-have, make one adversarial pass for missed failure paths and
   unstated assumptions; if that still produces no material gap, say so with
   the checklist evidence.
3. **OPEN THE LOOP** — before the first question, tell the user the artifact
   type and sections reviewed, counts by severity, which section has the most
   gaps, and that you'll walk through them one at a time starting with
   Blockers. Get explicit agreement to proceed. If the user wants the full
   list up front, provide it — but still loop through Q&A afterwards.
4. **ASK, REFINE, CAPTURE** — per gap: state it in one sentence; ask the
   concrete question (`rules/questioning-discipline.md`); refine vague answers
   into testable ones; convert the answer into an artifact update
   (`rules/conversion-patterns.md`); show the proposed update verbatim and
   offer write as-is / edit inline / discard; write it to the source of truth
   once confirmed; move on.
5. **RECAP every 3–5 gaps** — summarize what's closed, what's left by
   severity, and any inconsistencies between answers ("the buyer can retry
   from the error screen, but two gaps ago we said only admins can retry").
6. **EXIT** — stop when all Blockers and Should-addresses are closed; when the
   user calls time, produce an explicit parking-lot list of unresolved gaps
   with owners; when a gap needs a decision the user isn't empowered to make,
   name the actual owner, park it, and keep going. If the artifact needs a
   larger rewrite than Q&A can deliver (e.g. the AC set is describing three
   different features tangled together), say so explicitly and recommend
   restarting that artifact.

## Output Contract

The primary output is the updated artifact, written wherever the source of
truth lives: new/revised acceptance criteria in the AC list, new paragraphs or
sections in the plan, a companion states spec per screen for mocks. The
secondary output is a resolution log at the end of the session — resolved gaps
with severity and destination (`[Blocker → AC-14] Duplicate invitation
handling`), and parked gaps with owners — placed in the PR description,
release notes, or wherever the work is tracked, so decisions and parked items
don't vanish.

## References

- `rules/gap-checklists.md` — survey checklists for plans, acceptance criteria, and design mocks.
- `rules/conversion-patterns.md` — turning answers into criteria, plan updates, and mock state specs.
- `rules/questioning-discipline.md` — cadence, structured-input judgment, and anti-patterns.
- `references/provenance.md` — upstream source, revision, and licence notice.
