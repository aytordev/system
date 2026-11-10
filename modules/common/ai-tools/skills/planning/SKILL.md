---
name: planning
description: "Trigger: starting significant work, turning an already-split story into an implementation plan, planning pull requests, or sequencing complex tasks. Plans as vertical slices in small known-good increments — each slice names an actor, trigger, and observable outcome, ships end to end through the real path, and defaults to one independent trunk-based pull request. Horizontal work only when it explicitly unblocks the next slice or advances an explicitly selected reduction program."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Planning in Vertical Slices

Plan work as vertical slices in small, known-good increments. Each slice
delivers the smallest end-to-end behavior a real actor can observe, while
leaving the codebase in a known-good state where all tests pass. A sequence is
work order; a branch stack is topology. Default every slice to one independent
trunk-based pull request.

If the input is still a broad story, epic, feature idea, or backlog item with
multiple possible customer outcomes, split it into child stories first — the
splitting work is a different activity and precedes this skill.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Starting significant work that needs sequencing into deliverable increments.
- Turning an already-split story into an implementation plan with slices,
  acceptance criteria, evidence, and a delivery shape.
- Planning pull requests: deciding what merges independently and in what order.
- Reviewing an existing plan that is drifting into horizontal layer work.

Do not use it for product slicing of a broad epic (split first), for choosing
between technologies or libraries (a separate comparison activity), or for
implementing a slice without a plan artifact owning the acceptance criteria.

## Hard Rules

1. **Vertical before horizontal.** Every slice delivers one observable behavior
   through the real production path. Horizontal work is allowed only when it
   explicitly unblocks the next vertical slice and is independently verifiable,
   or when it belongs to an explicitly selected reduction program whose
   terminal state retires one complete mechanism while conserving behavior.
2. **Each slice is known-good.** It leaves all tests passing, is independently
   deployable, has clear done criteria, fits one sentence, and is describable
   to a reviewer without holding unrelated concepts in mind.
3. **Name the unit.** Every slice names its Actor, Trigger, Observable outcome,
   Production path, and Smallest deployable value.
4. **Red first for behavior change; baseline first for preservation.** A
   behavior-changing slice writes its failing test before implementation. A
   pure refactor or reduction slice starts from passing preservation evidence.
   Never fabricate a failing test to manufacture red.
5. **No commit and no plan change without explicit approval.** Present the
   increment and ask; explain plan changes and wait for approval.
6. **Evidence gates run once at the review boundary, not per edit.** Run the
   end-of-phase evidence gate (mutation where meaningful, otherwise explicit
   `N/A` plus proportionate alternate evidence) when the boundary is otherwise
   ready for review.
7. **Classify every slice.** Behavior change, pure refactor, reduction
   transition, or terminal reduction — a transition never claims net
   mechanism removal; only the terminal slice earns that claim after both
   behavior and mechanism gates pass.

## Execution Steps

1. **SCOPE** — reframe the input as one sentence of outcome. If it still
   contains multiple customer outcomes, roles, workflow branches, or quality
   levels, return to splitting before writing slices.
2. **SEQUENCE** — name the outcome, map the real path, pick the walking
   skeleton, add one behavior or state at a time, check reversibility.
3. **CLASSIFY** — label each slice with the class and its evidence route.
4. **WRITE** — create or update the repository-declared plan artifact
   (fallback: `plans/` at the project root, descriptive filename). Use the
   structure in `references/plan-template.md`.
5. **CONFIRM** — present the acceptance criteria and wait for approval before
   any code is written.
6. **DELIVER** — one independent pull request per slice by default; use the
   delivery rules for the rare stack.
7. **GATE** — at review readiness, run the end-of-phase evidence gate and the
   pre-PR checks in `rules/implementation-cadence.md`.
8. **CLOSE** — verify every owning PR landed and every criterion is met, merge
   significant learnings, then follow the repository's plan lifecycle (delete
   the fallback `plans/` file and remove the directory when empty).

## Output Contract

Return the plan artifact path, the slice list (one sentence per slice, each
carrying its class, delivery shape, and acceptance criteria), and the approval
point: criteria before code, plan changes before edits, commits only on
explicit approval. If no honest vertical slice exists, say so and stop rather
than emitting layer-cake slices.

## References

- `rules/vertical-slices.md` — slice definition, choosing slices, size heuristics.
- `rules/known-good-increments.md` — known-good requirements, horizontal exceptions, reduction programs.
- `rules/delivery-and-review.md` — plan/story/PR units, small-PR discipline, stack rules.
- `rules/implementation-cadence.md` — red-green-refactor cadence, evidence gates, commit discipline.
- `references/plan-template.md` — the file-backed plan template.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. Where a story-splitting skill is
installed, load it when the input still needs product slicing; where a
find-gaps skill is installed, use it to tighten acceptance criteria. The
red-green-refactor cadence, preservation baseline, and end-of-phase evidence
gate are restated inline in `rules/implementation-cadence.md`; no other skill
is required to plan and deliver safely.
