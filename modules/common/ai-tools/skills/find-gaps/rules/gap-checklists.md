---
title: Survey With the Checklists
impact: HIGH
impactDescription: Cost of checking is one line; cost of missing is an outage
tags: find-gaps, checklists, survey
---

## Survey With the Checklists

**Impact: HIGH**

Walk these end-to-end per artifact. Don't skip categories because "that
probably doesn't apply" — the cost of checking is one line; the cost of
missing is an outage. If the artifact is mixed (plan with embedded mocks, AC
referencing a mock), run each section separately so the checklists don't
bleed.

### Plans

- **Scope & intent:** out-of-scope stated? one-sentence problem statement?
  success metric + baseline? cost of doing nothing?
- **Prerequisites & dependencies:** what must already exist/be true? which
  other teams must ship first? cross-cutting migrations?
- **Sequencing & incremental value:** can this ship in slices? smallest
  valuable first slice? rollback path per slice? dark-launch / feature flag /
  canary? any database-only/API-only/UI-only component slices that should go
  back through splitting?
- **Failure & recovery:** top 3 prod failure modes? detection (named
  dashboards/alerts) per mode? recovery (runbook, auto-retry, rollback)?
  data-loss blast radius?
- **State & data:** finite state model per entity? concurrent-modification
  handling? idempotency? backfill/migration plan? retention / deletion / GDPR?
- **Observability & ops:** what do we log/emit to know this works in prod?
  on-call owner? runbook link? SLOs / error budgets?
- **Security & compliance:** auth/authz matrix? PII + secrets handling? threat
  model for the top attack vector?
- **Testing:** strategy per layer (unit / integration / E2E)? what's
  explicitly NOT tested and why is that OK?
- **Unstated tribal knowledge:** if a new engineer read only this plan, what
  would they get wrong?

### Acceptance criteria

- **Measurability:** verifiable by a machine or a test? Vague-word hit list:
  *fast, intuitive, seamless, modern, clean, responsive, works well, just
  works, robust* — each needs a number or a concrete behaviour.
- **Precondition / trigger / outcome discipline:** every criterion has a
  precondition, a trigger, and an observable outcome. Any missing → it's a
  wish.
- **Negative paths:** for every happy path, the failure path (timeout,
  validation error, concurrent edit, permission denied, quota exceeded,
  offline, stale data).
- **Input edge cases:** empty / null / missing optional; min / max / boundary;
  very long strings; non-ASCII, emoji, RTL, combining marks; duplicates, case
  variants, whitespace; numeric zero / negative / very large / currency
  precision.
- **Time & locale:** timezones (user vs server vs storage), DST transitions,
  i18n text expansion, plural forms, date-format ambiguity.
- **Actors & roles:** which role does each criterion apply to — anon / authed
  / admin / service / impersonator? What happens when permission changes
  mid-session?
- **Non-functional:** performance target (p50/p95 + workload), accessibility
  (WCAG level, keyboard, screen reader), security (auth, rate-limit, audit
  log), privacy (PII visibility).
- **Observability criteria:** what event/metric proves it was met in prod, not
  just in test?
- **Completion:** what does "done" mean — merged, deployed, rolled out to
  100%, observed working for N users?

### Design mocks

- **UI states:** loading / skeleton, empty (first-use), partial, error
  (network, validation, 404, 403, 500, timeout), success/confirmation,
  disabled, read-only (no permission), offline, rate-limited,
  stale/needs-refresh.
- **Content variance:** shortest (1 char, 1 item), longest (max-length, 10k
  list), zero/one/many; missing avatar, broken image; unicode (emoji, RTL, CJK
  wrap, combining marks); numbers (0, negative, large, currency, percent);
  dates (today, relative, far-past, far-future).
- **Interaction states:** hover, focus (keyboard!), active, selected,
  disabled, dragging, async-pending vs optimistic.
- **Responsive & density:** ≤360px mobile, tablet portrait/landscape, desktop,
  ultra-wide / cramped, browser zoom 200%.
- **Accessibility:** color-only signalling, contrast on interactive, focus
  ring + order, SR labels/aria/alt, touch ≥44×44, reduced-motion alternative,
  form labels + error association.
- **Theme / platform:** light / dark / system / high-contrast, reduced motion,
  back/forward/refresh/deep-link, mobile web vs native.
- **Permissions & role:** anon view, view-only, edit, admin, mid-session role
  change.
- **Data lifecycle:** create/edit/delete flows + undo + confirmation;
  behaviour when the underlying record is deleted by someone else.
- **Internationalization:** text expansion (+40% German), contraction (CJK),
  RTL mirroring (layout not just text), locale-formatted numbers/dates/currency.

### Quick reference

| Artifact | Top-3 gaps to always check |
| --- | --- |
| Plan | Out-of-scope not stated · No rollback path · No observability |
| Acceptance criteria | Unmeasurable words · Missing negative paths · No non-functional targets |
| Design mocks | No loading/empty/error states · No long-text variance · No keyboard focus treatment |
