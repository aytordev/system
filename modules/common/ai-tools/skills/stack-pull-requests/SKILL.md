---
name: stack-pull-requests
description: "Trigger: deciding whether planned vertical implementation work ships as independent pull requests or a stack of small ordered ones, splitting one slice into review layers, stacking dependent slices, or reviewing, restacking, and merging stacked PRs. Treats stacking as optional branch topology that must earn its coordination cost, keeps tests with the earliest boundary that owns the behaviour, and requires every intermediate state to stay safe."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Stack Pull Requests

Use stacked pull requests as an optional **branch, review, and integration
topology**, not as a substitute for vertical story splitting.

Default each vertical implementation slice to one PR against trunk. Stack only
when ordered branches materially improve review quality or let work continue on
the same evolving baseline before lower reviews merge, without weakening
testing, deployability, or comprehension.

GitHub's native stacked-PR support and the official `gh-stack` extension are
limited-preview features and may not be enabled for the repository. Load
`references/source-notes.md` when exact GitHub behaviour, command provenance, or
the rationale behind these rules matters. Verify current official docs,
repository access, and `gh stack --help` before relying on preview-specific
commands.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- One slice is too large for effective review as a single diff.
- Later slices should proceed on the same evolving baseline before earlier PRs
  merge.
- AI-generated code volume needs deliberate review boundaries.
- A plan already defines dependent PR boundaries or non-trunk bases.
- The user mentions stacked PRs, PR stacks, dependent PRs, bottom-up review, or
  splitting an implementation across branches.

Do not use it to split epics or invent horizontal backlog stories. If the
request still contains multiple customer outcomes, paths, roles, or quality
levels, split it into vertical stories first: one bounded capability per story,
acceptance scope fixed before delivery planning. A sequence describes work
order; a stack describes branch dependency.

## Hard Rules

1. **Keep the three units separate.** A backlog story is a bounded capability;
   an implementation slice is the smallest vertical increment that leaves a
   known-good state; a PR boundary is a delivery packaging decision. An
   intra-slice PR layer is never a child story and must not add acceptance
   scope; a cross-slice stack member may own a complete approved slice but must
   not invent scope outside the approved slices.
2. **Stacking must earn its cost.** Choose a stack only when every gate in
   `rules/units-and-decision.md` holds; run the trunk and flow counterfactuals
   and record the delivery decision in one sentence.
3. **Tests live with the earliest boundary that owns the behaviour.** Never
   defer all tests to a final PR. A behaviour's first test belongs in the PR
   that introduces it.
4. **Every intermediate state is safe**: independently deployable and useful,
   behaviour-preserving, backward-compatible and dormant, behind a flag, an
   independently verifiable reduction transition, or explicitly merge-only as
   part of a contiguous approved group.
5. **Verify CI topology before stacking.** Dependent branches do not prove a
   GitHub-native stack object exists; never describe an unlinked chain as a
   native stack, and verify the remote stack object before claiming one.
6. **Put a discovery in the boundary that owns it.** Fix lower-branch defects on
   the lower branch and restack; never add an upstack workaround.
7. **Merge bottom-up.** Never merge an upper PR without every dependency below
   it; native prefix/group merges land all-or-nothing.
8. **No git side effects without authorization.** Do not create branches,
   commit, push, submit PRs, rebase shared branches, or merge unless the user
   authorized that action.

## Execution Steps

1. **DECIDE** — confirm the scope is one fixed slice or a contiguous run of
   planned vertical slices, run both counterfactuals, and record the delivery
   decision (`rules/units-and-decision.md`).
2. **DESIGN** — draw the lineage graph, pick boundaries in the preferred order,
   and route verification by boundary type (`rules/stack-design.md`).
3. **PLAN** — write the delivery shape and per-boundary review questions, and
   verify CI topology before creating any PR (`rules/verification-and-ci.md`).
4. **BUILD** — bottom to top from the topmost committed known-good branch;
   self-review against the parent, not trunk (`rules/build-review-merge.md`).
5. **REVIEW** — bottom-up for lineage-sensitive boundaries; route feedback to
   the owning branch and restack upward.
6. **MERGE** — satisfy the pre-merge gates, then merge bottom-up or as an
   approved native prefix; sync and recheck the remaining stack.

## Output Contract

Present the one-sentence delivery decision (`Delivery: single PR —` /
`Delivery: N-PR stack —` / `Delivery: N-PR flow-lineage stack —`), the delivery
plan table with per-boundary verification and release states, and the
whole-stack gate checklist. When reporting a native stack, state the evidence
that the remote stack object exists; otherwise report an unverified dependent
chain. Present focused diffs and verification evidence per boundary — a
cumulative diff is not a boundary's review surface.

## References

- `rules/units-and-decision.md` — the three units, stack gates, counterfactuals.
- `rules/stack-design.md` — lineage, boundary preference order, scope freezing.
- `rules/verification-and-ci.md` — verification routing, CI topology, safe
  intermediate states, the delivery plan template.
- `rules/build-review-merge.md` — build order, review and restack rules, merge
  gates.
- `references/source-notes.md` — GitHub preview provenance, command model, and
  update guidance.

Companion skills are optional. When the relevant companion is not installed,
apply the rule directly: drive behaviour-changing boundaries with a failing test
first and keep focused checks green (the tdd and testing companions); run the
accumulated-scope verification once per PR-ready boundary (the mutation-testing
companion) or record proportionate alternate evidence; characterize
hard-coupled legacy behaviour before wrapping it (the finding-seams and
characterisation-tests companions); treat a reduction transition's ledger,
conserved contract, and bridge obligations as binding (the
reduce-system-complexity companion); and surface unclear acceptance criteria or
release constraints before stacking (the find-gaps companion).
