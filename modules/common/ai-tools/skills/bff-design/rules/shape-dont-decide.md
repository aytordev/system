---
title: Shape, Don't Decide
impact: CRITICAL
impactDescription: Keeps business rules out of the BFF
tags: bff-design, scope, domain-logic
---

## Shape, Don't Decide

**Impact: CRITICAL**

The BFF owns presentation-model work: aggregation, reshaping, payload
thinning, per-experience defaults, and translating upstream results into what
one UI renders. It does not own:

- **Business rules.** Pricing, eligibility, workflow state — the moment a BFF
  decides these, it competes with the domain services and changes for two
  masters. The documented failure mode is feature integration and business
  logic accreting in BFFs.
- **Product authorization.** Decided inside the application operations it
  calls; the BFF contributes an honest principal, nothing more.
- **Durable domain state.** A BFF may cache and hold per-session/connection
  state; systems of record live behind the domain services.

### The borderline test

Filtering a list to what this user's tier *may see* is a decision
(authorization-shaped — it belongs in the domain operation); truncating,
reordering, or thinning what came back for this screen is shaping. When in
doubt, apply the deletion test:

> Could you delete the BFF without losing a business rule?

If not, the BFF has accreted decisions.

### The push-down ladder

Decision-shaped logic goes down into a domain service *immediately*,
duplication or not — the ladder governs only presentation-adjacent
duplication. When presentation logic appears in a second BFF:

1. **Tolerate the duplication first.**
2. **Extract a shared library only for non-domain plumbing** — and beware
   upgrade cascades across BFFs.
3. **At the third occurrence** (rule of three), ask whether the repeated logic
   was domain-shaped all along, and if so push it *down* into a domain service
   beneath all BFFs — never merge BFFs upward. Merging BFFs to remove
   duplication produces "highly bloated code with multiple concerns squashed
   together".

The rule of three schedules *abstraction of presentation plumbing*; it never
grants business or authorization decisions three free passes.

### Aggregation with domain logic is a service, not a BFF feature

Custom domain logic, complex transformations, or long-running orchestration
belongs in a dedicated service behind the gateway. The BFF composes and
shapes; when composition grows rules, push it down.

### Anti-patterns

- Business rules, product authorization, or systems of record living in the
  BFF.
- One general-purpose "BFF" serving all clients — that is the one-size-fits-all
  API with a fashionable name.
- Merging BFFs upward to remove duplication instead of pushing shared domain
  logic down.
- Sequential fan-out; retries at every layer; a page that 500s because one
  optional section's upstream is down.
- The BFF calling upstreams with client-credentials plus an `X-User-Id`
  header.
- Adding a separate BFF service beside a meta-framework server that already is
  one.
