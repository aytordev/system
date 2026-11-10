---
title: Build Bottom To Top, Review in Place, Merge in Order
impact: HIGH
impactDescription: Keeps diffs reviewable and cascade repairs honest
tags: stack-pull-requests, build, review, merge
---

## Build Bottom To Top, Review in Place, Merge in Order

**Impact: HIGH**

### Build Bottom To Top

For each PR boundary:

1. Start from the topmost committed, known-good branch.
2. Confirm the boundary's acceptance criteria or conserved contract with the user
   before code.
3. Complete the applicable implementation route and keep focused/affected checks
   green.
4. When the boundary is otherwise PR-ready, complete its accumulated- or
   alternate-evidence gate and repository checks.
5. Self-review the diff against its parent, not against trunk.
6. Remove work that belongs upstack.
7. Present the focused diff and verification evidence.
8. Commit only when the user and repository workflow authorize it.
9. Create the next branch only after the current boundary is committed and
   known-good; review approval is not required to extend the stack.

Prefer the official `gh stack` command only when the repository has preview
access, the extension is already installed or installation is authorized, and it
matches repository policy. Use current help rather than memorized syntax. Submit
locally tracked native stacks with `gh stack submit`. If branches or PRs were
created with other tooling, use the currently documented linking command.
Otherwise manage an explicitly unlinked dependent chain with existing
Git/GitHub tooling.

Before reporting that a native stack was created or is PR-ready, verify the
remote object: `PullRequest.stack` must be non-null and its trunk and ordered
entries must match the delivery plan. A correct chain of PR base refs is not
sufficient. If remote verification is unavailable, report the PRs as an
unverified dependent chain rather than a native stack.

Open unfinished upper boundaries as drafts. Give each PR a focused title and
concise description containing:

- selected story, included implementation slice(s), and this PR's purpose
- parent/base PR and next boundary, when known
- what to review in this diff
- verification performed
- release state
- intentional deferrals

### Review And Revise

Self-review every PR boundary before requesting review. Check function, intent,
code quality, dependencies, AI-specific mistakes, and test integrity.

Request review from the bottom upward when later boundaries depend strongly on
earlier decisions. Different specialists may review and approve boundaries in
parallel when each focused diff is understandable. Merge readiness and merge
order still flow bottom to top.

When feedback changes a lower boundary:

1. Move to the branch that owns the change.
2. Fix and test it there.
3. Rebase or restack every branch above it.
4. Re-evaluate whether existing evidence remains current under repository
   policy, then rerun affected focused and cumulative checks as required.
5. Re-review upstack diffs for accidental duplication or semantic drift.
6. Push only with safe lease protection and authorization.

Do not add an upstack workaround for a downstack defect.

Put a discovery in the boundary that owns it:

- If it repairs behavior or a contract promised by a lower slice, fix that lower
  branch and restack.
- If it adds acceptance scope owned only by an upper slice, keep it upstack.
- If the owning lower PR already merged, use a focused trunk-based fix; after it
  lands, sync or rebase and recheck the remaining upper stack before continuing.
- If it invalidates the planned boundaries, reshape the stack and plan instead
  of smuggling scope downstack.

Reshape the stack when evidence changes. Fold adjacent PRs that cannot be
reviewed separately; split a boundary that acquired a second concept; reorder
only when dependencies allow it. A clean working tree and recoverable rebase
path are prerequisites for structural changes.

### Merge And Finish

Before merge:

- require passing checks and required approvals for the boundary and every
  boundary below it
- require linear stack history
- verify the top branch satisfies the complete declared stack scope and
  cumulative acceptance criteria or terminal gates
- verify any partially merged state remains safe
- resolve documentation conflicts using current GitHub guidance because native
  stacked-PR behavior is preview

For a GitHub-native linked stack, merge an approved prefix or the full stack
with `gh stack merge`; the selected PR and every PR below it land as one
all-or-nothing operation unless a merge queue splits processing into groups. For
an unlinked dependent chain or other tooling, merge bottom-up and restack after
lower merges. Never merge an upper PR without every dependency below it.

After lower boundaries merge, sync or rebase the remaining stack, rerun affected
checks, and verify each PR still shows only its intended focused diff. Mark a
cross-slice stack's slice complete when its owning PR lands; mark an intra-slice
stack's slice complete only when its top lands. The whole stack completes when
its top lands. Then follow the repository plan owner's close/archive/delete
lifecycle; delete only the fallback temporary plan file with normal authority.
