---
title: Write the Assessment Into the Reply
impact: CRITICAL
impactDescription: Makes every candidate decision explicit and reviewable
tags: refactoring, assessment, reply
---

## Write the Assessment Into the Reply

**Impact: CRITICAL**

An unstated assessment is an unmade assessment.

### Priority classes

| Priority | Action | Examples |
| --- | --- | --- |
| Critical | Fix now | Behaviour-changing mutation, divergent copies of one business rule, control flow that obscures a high-risk path |
| High | This session | Magic numbers (one constant per rule), unclear names, functions coordinating multiple responsibilities |
| Nice | Later | Minor naming, single-use helpers |
| Skip | Do not change | Already clean code |

### Reply shape

One line per candidate, closed by a decision:

```text
Critical: <what and why>
High: <what and why>
Nice: <what and why>
Skip: <what and why>
Decision: <what you did or did not do>
```

A summary of the diff is not this shape. An unlabelled recommendation is not this
shape either.

### Example

```typescript
// After GREEN establishes a passing behaviour-test baseline:
const planBatch = (batch: Batch): PlannedBatch => {
  const itemSlots = batch.items.reduce((sum, item) => sum + item.quantity, 0);
  const bufferSlots = itemSlots > 50 ? 0 : 6;
  return { ...batch, plannedSlots: itemSlots + bufferSlots, bufferSlots };
};
```

```text
High: magic numbers 50 and 6 in the buffer rule - name them
Skip: structure is clear enough
Decision: extract the two constants only
```

### The tests come first, even when nothing changes

Run the applicable tests before assessing, before your first edit, and before
any reply that declines to edit. Declining a request, or classifying every
candidate as Skip, is still an assessment, and an assessment that rests on no
test run rests on nothing.
