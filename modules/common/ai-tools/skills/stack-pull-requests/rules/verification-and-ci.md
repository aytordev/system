---
title: Route Verification by Boundary and Verify CI Topology
impact: CRITICAL
impactDescription: Stops tests migrating to the top PR and unverified stack claims
tags: stack-pull-requests, verification, ci, plan
---

## Route Verification by Boundary and Verify CI Topology

**Impact: CRITICAL**

### Route Verification By Boundary Type

GitHub's tutorial illustrates tests as a final layer; do not copy that ordering
into this workflow.

For a behavior-changing production boundary:

- Load the failing-test-first and applicable testing guidance before code
  changes; drive the behaviour owned by that boundary in fast red-green-refactor
  increments.
- Put contract, migration, unit, integration, or UI tests in the earliest
  boundary that owns the behavior.
- When the boundary is otherwise PR-ready, run the accumulated-scope
  verification once against its parent where meaningful, or record its
  proportionate alternate-evidence `N/A`.

For a behavior-preserving production boundary:

- Load applicable testing guidance; if protection is inadequate, characterize
  the legacy behaviour first.
- Establish passing preservation evidence for the touched consumer paths.
- Refactor without changing behavior, keeping the applicable focused/affected
  tests green.
- At PR readiness, run the same once-per-boundary accumulated-verification-or-
  alternate-evidence gate; do not fabricate structural mutants.

For reduction-transition or terminal-reduction boundaries, also preserve the
selected slice's reduction ledger, conserved contract, bridge
ownership/removal obligations, and behavior/mechanism gate status.

For documentation, release metadata, configuration, or non-production mechanical
changes, use the smallest executable verification that can fail if the boundary
is wrong and record the accumulated-verification `N/A` when appropriate.

For every PR boundary, run the repository's required build, lint, type,
security, and complete non-watch test checks and verify the cumulative branch,
because an upstack PR contains every lower boundary.

The top boundary must prove the cumulative acceptance examples or terminal gates
for every included slice. It may add stack-level tests, but a behavior's first
test belongs in the PR that introduces that behavior, not a later stack member.

### Verify CI Topology Before Stacking

Before creating any PR, record whether the PRs will be linked as a GitHub-native
stack or merely form an unlinked dependent branch chain. When the requested
outcome is a stack, default to the native mechanism if GitHub and repository
policy support it; use an unlinked chain only when the user or repository
chooses it explicitly or native support is unavailable. Then inspect workflows,
rulesets, required status contexts, and the merge queue:

- For a GitHub-native linked stack, GitHub evaluates Actions, branch protection,
  required checks, reviews, CODEOWNERS, and code scanning against the stack
  trunk. A `pull_request` workflow filtered to that trunk runs for every stack
  PR; do not require a workflow change merely because an upper PR directly
  targets a feature branch.
- For unlinked dependent PRs or tooling without equivalent stack metadata,
  ordinary immediate-base semantics apply. Confirm feature-base PRs trigger the
  required workflows before relying on them.
- Confirm every required status is produced for every PR boundary that needs it.
- If the repository uses a merge queue, confirm required workflows handle
  `merge_group`.
- Decide which focused checks run per boundary and which cumulative or
  end-to-end checks run at the top; do not weaken required merge checks to make
  stacking convenient.
- Account for rebase-triggered reruns and existing affected-test or cache
  behavior.

Dependent branches and feature-branch PR bases are necessary for either
mechanism, but they do not prove that GitHub's remote stack object exists. Do
not describe an unlinked chain as a GitHub-native stack.

Prefer one PR when the chosen stack mechanism cannot give every boundary
trustworthy required checks without risky CI changes.

### Make Intermediate States Safe

Every lower PR must be one of:

- independently deployable and useful
- behavior-preserving
- backward-compatible and dormant
- hidden behind a flag
- an independently verifiable reduction transition with owned, bounded bridges
  and no premature net-reduction claim
- intended to merge only as part of a contiguous approved group, with the
  reason stated

Never merge an intermediate state that breaks callers, requires an unavailable
schema, weakens security, or exposes incomplete behavior. Backward-compatible
expand/contract changes usually belong in separate stacks because cleanup must
wait until all consumers have moved.

## Write The Delivery Plan

For an intra-slice stack, add this section under the selected implementation
slice. For a cross-slice stack, place one shared map immediately before the
first included slice and reference it from every included slice:

```markdown
#### Delivery Shape

**Mode**: Single PR | Stacked PRs
**Stack scope**: Intra-slice | Cross-slice
**Reason**: [Why this shape improves review without weakening delivery]
**Story scope**: [Fixed parent story; PR boundaries must not expand it]
**Included slices**: [One fixed slice, or the exact contiguous slice sequence]
**Done when**: [Acceptance criteria or terminal gates for all included slices]

| # | Ownership unit | PR boundary | Base | Owns | Depends on | Verification | Release state |
|---|---|---|---|---|---|---|---|
| 1 | [whole slice or intra-slice layer] | [focused title] | [repository default branch] | [one coherent change] | — | [tests/evidence/checks] | [deployable/dormant/etc.] |
| 2 | [whole slice or intra-slice layer] | [focused title] | [boundary 1 branch] | [one coherent change] | [specific contract or deliberate flow lineage] | [tests/evidence/checks] | [...] |

### Whole-stack gate

- [ ] Every included slice's acceptance examples, conserved contract, and applicable terminal gates pass cumulatively at the top
- [ ] Every PR boundary's focused and cumulative checks pass
- [ ] No behavior waits beyond its owning PR for its first test
- [ ] Every PR-ready boundary has current accumulated or alternate evidence for its focused review scope
- [ ] Intermediate merge and release states are explicit and safe
- [ ] Reduction ledger, bridge, and mechanism-gate obligations remain accurate when applicable
- [ ] Native stack-trunk or unlinked immediate-base CI semantics are identified; required statuses and `merge_group` run where applicable
- [ ] When native stacking was selected, GitHub's remote stack object exists and its trunk and bottom-to-top entries match this plan; PR base refs alone are not proof
- [ ] Review sequence is bottom-up for lineage-sensitive boundaries; independent specialist reviews may run in parallel
- [ ] Merge includes every required lower PR: native all-or-nothing prefix/group, or manual bottom-up order
```

For each PR boundary, also record:

- focused review question
- included and excluded scope
- likely files or subsystem, without prescribing unnecessary implementation
- required specialist reviewer, if any
- acceptance criteria and verification route for the behavior, conserved
  contract, or mechanical change it owns

Use repository branch naming conventions. Do not create branches, commit, push,
submit PRs, rebase shared branches, or merge unless the user has authorized that
action.
