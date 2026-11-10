---
title: Keep the Three Units Separate and Decide Honestly
impact: CRITICAL
impactDescription: Prevents stacking from becoming scope invention or reflex
tags: stack-pull-requests, units, decision
---

## Keep the Three Units Separate and Decide Honestly

**Impact: CRITICAL**

| Unit | Question | Owner | Rule |
|---|---|---|---|
| Backlog story | What bounded capability delivers value or learning? | Vertical splitting | Keep it vertical and fix its acceptance scope before delivery planning |
| Implementation slice | What smallest vertical increment advances that story and leaves a known-good state? | Delivery planning | Merge and release it safely once declared prerequisites land; use one PR by default |
| PR boundary | How should planned implementation work be packaged for review? | This skill | Usually owns one whole slice; may instead be a dependent layer within one slice |

A sequence describes work order; a stack describes branch dependency. A lower PR
in a stack may be independently mergeable, while every upper PR targets the
branch below it. Several vertical slices are therefore not automatically
independent PRs and not automatically a stack.

Use independent PRs when each slice can target trunk and merge in any safe order
without blocking or duplicating work, or when the next branch starts only after
its predecessor merges. Use a cross-slice stack for either **hard lineage** (an
upper slice requires a lower slice) or **flow lineage** (slices remain
separately complete, but upper work starts before lower review and merge on the
same evolving baseline, and fixed lower-first landing is acceptable). Use an
intra-slice stack when one fixed slice is too large for one effective review.

Backtracking is a real stack benefit: a lower-branch correction stays with its
owning PR and stack tooling propagates it upward. It is not free insurance.
Every changed upper branch must be rebased, pushed, rechecked, and may conflict
or lose stale approvals. Treat likely lower-boundary iteration while dependent
upper work is already in flight as a benefit; do not manufacture a branch
dependency solely because an earlier decision might someday change.

An intra-slice PR layer is not a child story or implementation slice and must
not add acceptance scope. A cross-slice stack member may own a complete planned
slice and its acceptance criteria; it must not invent scope outside the approved
slices.

Use this order:

1. If the request still contains multiple customer outcomes, paths, roles, or
   quality levels, split it into vertical stories first — one bounded
   capability per story, acceptance scope fixed before delivery planning.
2. Select one vertical child story.
3. Define its vertical implementation slices, dependencies, evidence, and
   terminal obligations in the project's delivery plan.
4. Use this skill when one slice needs review layers or when a contiguous run of
   hard- or flow-lineage slices should be in flight together.
5. Keep slices as independent trunk-based PRs when no review, lead-time, or
   correction-routing benefit earns fixed order and cascade cost.
6. If acceptance criteria, release constraints, or intermediate safety remain
   unclear, resolve them before stacking.

Do not turn `database → API → UI → tests` into backlog stories. If those
boundaries help review one selected implementation slice, describe them as
dependent PR layers and keep their release state explicit.

## Decide: Independent PRs Or A Stack

Choose a stack only when all of these hold:

- Its scope is one fixed slice or a contiguous deliberately ordered sequence of
  already planned vertical slices or reduction transitions.
- At least one benefit is concrete: the combined change needs focused diffs, or
  later ordered work should proceed before lower review and merge complete.
- The branches have deliberate one-way lineage: a hard dependency, or deliberate
  flow lineage where upper work actually begins before lower merge on the same
  evolving baseline and fixed lower-first landing is acceptable.
- Each PR owns one whole slice where practical, or one coherent intra-slice
  layer that can be understood from its own diff plus the layers below.
- Each PR boundary can leave its cumulative branch known-good: buildable,
  verified, and safe to deploy or explicitly dormant.
- Every lower slice remains useful and safe to merge if all upper work is
  abandoned.
- The expected cascade/rebase cost is lower than the focused-review, lead-time,
  and correction-ownership benefit.
- The repository and team can support dependent branches, cascading rebases, and
  native prefix/group merge or manual bottom-up merge.
- The intended stack mechanism can apply the required CI and repository rules to
  every PR.

Prefer independent trunk-based PRs when any of these hold:

- The whole change is already a quick, coherent review.
- The proposed slice PRs can target trunk and merge, reorder, or be dropped
  independently without blocking or duplicating work.
- The next dependent slice can wait until its prerequisite merges without
  blocking useful work or feedback.
- Splitting would separate tests or evidence from the behavior or contract they
  protect.
- Reviewers must understand the full stack to judge every layer.
- Intermediate merges would expose an unsafe schema, contract, bridge, or
  half-feature.
- The change is cross-cutting enough that every layer would repeatedly touch the
  same code.
- The only proposed boundaries are files, architectural tiers, work phases, or
  team ownership.
- The only proposed benefit is speculative convenience if an earlier decision
  changes.
- Rebase and CI churn would cost more than the smaller diffs save.

### Run Two Counterfactuals

1. **Trunk counterfactual:** Could every proposed PR start from current trunk
   and merge, reorder, or be dropped without incorporating a sibling? If no, use
   a hard-lineage stack when the other gates pass.
2. **Flow counterfactual:** If yes, will upper work actually start before the
   lower PR lands on the same evolving path, is fixed lower-first landing
   acceptable, and will saved wait time or lower-owned correction routing
   outweigh restacking and re-review? If yes, a flow-lineage stack is valid.
   Otherwise use independent PRs.

Do not stack by reflex. Record the decision in one sentence:

```text
Delivery: single PR — the end-to-end change is already one focused review.
```

or:

```text
Delivery: 3-PR stack — the dormant migration, tested repository adapter, and
fixed sign-in slice form one-way dependencies with meaningful verification.
```

or:

```text
Delivery: 3-PR flow-lineage stack — each vertical slice is known-good in order,
upper work starts now on the same evolving path, and lower-first landing is acceptable.
```
