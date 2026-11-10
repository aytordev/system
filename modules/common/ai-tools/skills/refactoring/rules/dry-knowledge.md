---
title: DRY Is Shared Knowledge, Not Shared Code
impact: HIGH
impactDescription: Prevents one edit from silently changing two business rules
tags: refactoring, dry, coupling
---

## DRY Is Shared Knowledge, Not Shared Code

**Impact: HIGH**

### Abstract when

- It is the same business concept (same semantic meaning).
- It would change together if requirements change.
- It is obvious why the pieces are grouped.

### Keep separate when

- They are different concepts that merely look similar (structural).
- They would evolve independently.
- Coupling them would confuse.

Two rules that share a body or a number today are a coincidence, not shared
knowledge. Keep each rule's own body and its own named constant even when the
values are equal: never define one rule in terms of the other, and never route
both through a shared predicate helper.

### When a request asks you to fold look-alike definitions together

Do not do it. Run the applicable tests before answering even though you change
nothing — the refusal is an assessment and needs the same green baseline as an
edit. Then name the two different rules, say they would drift apart the moment
either changes, leave both definitions standing, and offer only the changes that
do not merge them.

### Deliver complete slices

Deliver a small complete change around one bounded owner or behaviour path.
Update affected contracts, adapters, and consumers together; a horizontal
migration of all handlers followed by all services leaves half-converted paths.

Keep existing behavioural oracles as preservation evidence, and identify
separately any tests a new mechanism needs.

When claiming simplification, show what wrapper, repeated decision, translation,
or dependency was removed. Extraction alone may improve comprehension without
reducing mechanism. Add compatibility scaffolding only for a demonstrated
rollout constraint, with an owner and a removal condition; a whole-path reduction
claim needs the project's reduction plan.
