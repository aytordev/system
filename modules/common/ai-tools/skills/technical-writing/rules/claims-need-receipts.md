---
title: Material Claims Need Receipts
impact: CRITICAL
impactDescription: Uncheckable claims are marketing, not documentation
tags: technical-writing, claims, evidence
---

## Material Claims Need Receipts

**Impact: CRITICAL**

Make material capability, current-state, compatibility, and quantitative
claims checkable. Explanatory prose, clearly labelled judgment, and normative
design rationale do not need a fake command or date; unsupported promotional
claims do.

- **No capability claim without evidence**: numbers a reader can verify, a
  command they can run, a file they can open. "Fast" is marketing; "the gates
  run in 14 seconds on this repo's CI" is a claim with a receipt.
- **Counts and versions rot**: changing operational numbers quoted in prose
  (test counts, coverage, versions) are maintenance liabilities — either
  generate it, date it, or bind it to the kept-current rule (updating it is
  part of every change's definition of done).
- **Honest limits are content, not confession**: when the page's scope could
  imply protection, coverage, or capability it does not provide, name those
  limits where the reader makes the decision. A short document need not grow
  a ceremonial limits section when its bounded scope is already explicit.
- **Idle and empty states must speak**: "0 items processed" that reads like
  success is a lie of layout. Distinguish "nothing to do" from "did nothing"
  everywhere output appears in docs and examples.
- **Timeless maintained guidance**: evergreen READMEs and reference docs
  avoid unowned "coming soon", "currently", or "new in…" labels. Release
  notes, migration guides, deprecation notices, and time-bounded status pages
  may need temporal language; attach a version/date and an owner or removal
  condition so it remains evidence instead of stale promotion.
