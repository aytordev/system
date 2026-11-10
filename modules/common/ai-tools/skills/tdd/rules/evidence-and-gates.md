---
title: Record Evidence and Gate Once
impact: HIGH
impactDescription: Makes the TDD sequence checkable instead of claimed
tags: tdd, evidence, mutation
---

## Record Evidence and Gate Once

**Impact: HIGH**

### The cycle

**RED** — for new or changed behaviour, no production code before a failing
behaviour test. The test describes the desired behaviour, not the implementation,
and must fail for the right reason. Before finalizing it, scan the intended
behaviour against the mutator rules: boundaries, boolean combinations, equality,
arithmetic identities, array and string operations, optional chaining, side
effects. Add the obvious missing cases immediately; ask the human only when the
expected behaviour is a product judgment.

**GREEN** — write only enough code to pass. Resist functionality no test demands.
Faking is legitimate: hardcode, then triangulate.

**REFACTOR** — assess after GREEN with the passing tests as the safety net.
Record `N/A` when restructuring does not apply.

Repeat until the PR scope is complete. Do not run the mutation harness after each
increment, refactor, or commit.

### End-of-phase gate, once

1. **Mutate or record alternate evidence** for the accumulated branch/PR scope,
   where meaningful.
2. **Kill valuable mutants**: strengthen tests, fix obvious gaps, ask the human
   when a survivor's value is ambiguous.
3. **Re-run inside the gate** while addressing survivors.
4. **Verify**: finish the remaining PR checks with the complete non-watch run.

Never invent structural mutants to fill the workflow.

### Evidence in the reply

State all three:

- The RED run: selector plus the failure it produced, for example
  `createUser is not a function`.
- The GREEN run: selector and result.
- The final non-watch full run against the final tree.

A reply that reports only passing counts has not reported TDD evidence. Commit
history may corroborate the sequence; do not reshape commits to stage TDD
theatre.

### PR checklist

- [ ] Every new or changed behaviour was demanded by a failing test, or the slice
      is explicitly a behaviour-preserving refactor with its own evidence.
- [ ] RED, GREEN, and final verification evidence recorded.
- [ ] Focused and affected tests stayed green through the loop.
- [ ] Every claimed result names a test that was actually collected and executed.
- [ ] Watcher stopped; no process or fixture left behind.
- [ ] Completed non-watch gate passes before review.
- [ ] Any coverage claim verified with the repository's own command.
- [ ] Mutation gate outcome stated in one line.
- [ ] Test state isolated; behaviour verified, not implementation details.
