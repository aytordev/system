---
title: Design the Stack Before Writing Code
impact: CRITICAL
impactDescription: Boundaries drawn after code become excuses, not review surfaces
tags: stack-pull-requests, design, lineage
---

## Design the Stack Before Writing Code

**Impact: CRITICAL**

### 1. Fix The Story And Stack Scope

Write the selected story's actor and outcome, then record:

- whether the stack is inside one slice or spans a contiguous sequence of slices
- every included slice, its trigger, observable outcome or conserved contract,
  production path, acceptance evidence, class, and release constraint
- the fixed union of approved scope covered by the stack

If the story still describes more than one customer capability, split it into
vertical stories before drawing PR boundaries. Keep every vertical outcome or
reduction transition as a distinct slice in the delivery plan, even when several
slices share a stack. For a cross-slice stack, each PR may add its own approved
acceptance case in dependency order. For an intra-slice stack, freeze the
selected slice's scope before drawing PR layers.

For reduction work, stack membership does not replace the ledger or gates. A
transition cannot claim net reduction while superseded machinery or an added
bridge remains; only the terminal-reduction slice may satisfy the mechanism gate
and claim the fixed terminal state.

### 2. Draw The Lineage Graph

Identify hard dependencies and deliberate flow lineage. Separate both from
habitual build order. "We usually build the backend first" is not evidence; "the
next approved slice starts now on this evolving baseline while review is open"
can be.

Prefer boundaries in this order:

1. **Whole vertical slices** — each PR owns one approved known-good slice; upper
   work has hard or deliberate flow lineage and overlaps lower review.
2. **Testable path increments** — each PR advances the same fixed slice without
   adding an acceptance case that belongs in another slice.
3. **Behavior-preserving preparation** — a focused refactor or safety
   characterization that makes the later change reviewable.
4. **Backward-compatible enablement** — a migration, contract, or infrastructure
   change that is verified, dormant, and directly used by the next PR.
5. **Risk isolation** — a security-, data-, or performance-sensitive change that
   deserves focused expert review.
6. **Reviewer expertise** — a subsystem boundary, only when the PR still makes
   sense without an essay about the rest of the stack.

Avoid:

- all tests in the top PR
- speculative foundations or abstractions
- boundaries whose only claim is "files in the same folder"
- a lower boundary that requires an upper boundary to compile, migrate safely,
  pass CI, or discharge an unowned bridge
- duplicate fixups in upper boundaries instead of fixing the owning lower
  boundary
- a long stack where cascade and review overhead dominate

There is no universal boundary count or line limit. Keep the smallest stack
whose PRs are quick reads with one concept each. If two adjacent boundaries need
the same explanation or evidence, fold them together.

### Examples

#### Use Layers Inside One Vertical Slice

Selected story and fixed implementation slice:

```text
A registered customer can sign in with valid credentials and reach their account.
```

If the end-to-end diff is already reviewable, use one PR containing storage,
authentication behavior, entry point, response, and tests.

If it is too large, a responsible stack could be:

1. Add a backward-compatible, dormant credential-storage migration with
   migration and rollback verification.
2. Add the credential repository adapter behind the existing boundary with
   contract tests.
3. Add the valid-credential path through the real entry point, domain behavior,
   storage, response, and observability, with its behavior tests.

The story and slice remain vertical and their scope does not grow. Layers 1 and
2 are enabling tasks, not user stories or implementation slices. Use separate
"all endpoints" or "all middleware" PRs only when concrete repository
constraints make that safer and every layer still satisfies this skill's gates.
Never defer all tests to a final PR.

#### Stack Several Vertical Slices

A plan may instead define these approved slices:

1. A registered customer can sign in with valid credentials.
2. A customer with invalid credentials sees a safe rejection.
3. Repeated invalid attempts temporarily lock the account.

Keep them as three implementation slices. If each can target trunk and merge in
any order without blocking or duplicating work, use independent PRs. Use a
three-PR cross-slice stack if slices 2 and 3 require the lower behavior, or if
their work starts before lower reviews merge on the same evolving baseline and
fixed lower-first landing is worth the cascade cost. Fix lower-owned feedback in
the lower slice and propagate it upward; keep new upper-slice scope upstack.
