---
title: Build the Acceptance Contract First
impact: CRITICAL
impactDescription: Turns authority into independently decidable criteria
tags: acceptance-review, contract, authority
---

## Build the Acceptance Contract First

**Impact: CRITICAL**

Resolve, in order: the implementation subject, the comparison base, the
authoritative artifact, repository rules, linked accepted decisions, and
exclusions.

### Authority

Raw meeting notes or a disputed recollection are not authority. Locate the
current accepted artifact; when you cannot, record the affected criteria as
ambiguous and return an `Indeterminate` verdict. Do not treat historical
plans, meeting notes, or delivery claims as current authority without
repository evidence that says they are.

### Criterion mapping

Map every in-scope normative statement to one independently decidable
criterion. Preserve its source identifier and meaning. Split a combined
statement only when its outcomes can differ. For each criterion record the
observable outcome, affected surfaces, edge cases, assumptions, and
exclusions.

If no in-scope normative statement remains after resolving authority and
exclusions, stop with `VERDICT: indeterminate`: there is no acceptance
contract to prove. An empty criterion set is never vacuous satisfaction.

### Completion check

The authority and subject are explicit; each normative statement maps exactly
once; ambiguities and exclusions are recorded.
