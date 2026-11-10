---
name: bff-design
description: "Trigger: deciding whether a system needs a backend-for-frontend, how many, and what each may own, aggregating upstream services, handling partial failure and resilience budgets, forwarding user identity downstream, weighing a BFF against a shared gateway, GraphQL federation, or a meta-framework server, or auditing a BFF that has drifted into a public API or a business-logic layer. Requires one experience per BFF with frontend-team ownership, shape-don't-decide discipline with the push-down ladder, and upstream calls that carry the user's verified identity rather than the BFF's own."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# BFF Design

A backend-for-frontend is an ownership pattern before it is a technology: the
API a client application uses is *part of that application*, owned by the team
that owns the frontend, and consumed by no other application (Calçado, the
pattern's originator). Architecturally it is a driving host for one user
experience — it shapes, aggregates, and mediates; it does not decide.

This skill owns the pattern-level decisions: whether to have a BFF, how many,
what each may own, how it aggregates and survives upstream failure, and how it
carries user identity toward upstream services. Protecting the BFF's own
boundary — access classification, sessions/CSRF, realtime entry points,
enforcement gates — is a separate entry-point security concern; nothing here
repeats it.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Adopting a BFF, splitting or merging BFFs, or deciding who owns them.
- Aggregating upstream services or handling upstream failures.
- Forwarding user identity downstream (token exchange, confused-deputy
  prevention).
- Weighing GraphQL, a shared gateway, or a meta-framework server against
  per-client BFFs.
- Auditing a BFF that has drifted into a public API or a business-logic layer.

Do not use it for the entry-point security model itself, for REST semantics of
externally consumed contracts, or for OAuth/OIDC protocol-flow design.

## Hard Rules

1. **One experience, one BFF.** The unit of granularity is the experience —
   one coherent product surface, whatever platforms render it. iOS and Android
   listener apps rendering the same experience are one consumer with two
   builds, not two consumers. Team structure can override the default
   (separate platform teams may justify separate BFFs), but one experience
   served by two teams is an ownership smell: appoint one owning team or split
   the BFF; never co-own it.
2. **The frontend team owns its BFF** — language, release cadence, priorities.
   A BFF owned by a backend platform team recreates the coordination queue the
   pattern exists to remove.
3. **Shape, don't decide.** The BFF owns presentation-model work: aggregation,
   reshaping, payload thinning, per-experience defaults. It never owns
   business rules, product authorization, or durable domain state. When in
   doubt, apply the deletion test: could you delete the BFF without losing a
   business rule?
4. **Decision-shaped logic goes down, not sideways.** Push domain logic into a
   domain service immediately, duplication or not. The ladder governs only
   presentation-adjacent duplication: tolerate it; extract a shared library
   only for non-domain plumbing; at the third occurrence ask whether the
   logic was domain-shaped all along, and if so push it down. The rule of
   three never grants business or authorization decisions three free passes.
5. **Identity-keyed caching, or none.** Per-request memoization is always
   safe; shared caches key on tenant/user or the coarsest attribute actually
   used; an unkeyed identity-varying response is a cache-poisoning leak.
6. **Forward the user's identity, never the BFF's service identity plus a user
   header.** Exchange the session-bound token per upstream for a
   narrow-audience, down-scoped token, or propagate a trust-domain-scoped
   transaction token unchanged under that model's own rules; upstreams
   authorize on verified claims — that is the confused-deputy rule.
7. **Partial failure is a contract decision.** Classify every response section
   as required or optional in the contract; degrade optional sections through
   a declared fallback chain; make partial responses an explicit, predictable
   shape. Exactly one retry owner per edge, budgeted and jittered; deadlines
   propagated per request.

## Execution Steps

1. **GATHER** — client types and their recallability, team topology, upstream
   shape, authorization-server capabilities, data sensitivity, partner plans,
   and operational maturity before any adoption decision.
2. **DECIDE ADOPTION** — apply the signal table (`rules/adoption-and-ownership.md`);
   if you already run a meta-framework server or GraphQL with frontend
   resolvers, you may already have a BFF — improve it instead of adding
   another box.
3. **SIZE** — pick the deployment shape (modular-monolith BFF, BFF per
   experience, meta-framework server) from the costs you actually exercise.
4. **CLASSIFY LOGIC** — run the deletion test on every BFF behavior; move
   decision-shaped logic down.
5. **DESIGN RESILIENCE AND IDENTITY** — read
   `references/aggregation-and-resilience.md` before fanning out, and
   `references/upstream-identity.md` before calling upstreams on behalf of a
   user.
6. **GUARD THE SURFACE** — apply the public-API drift guardrails
   (`rules/public-api-drift.md`) and record credential modes and client
   registrations per request in telemetry.
7. **CHECK COMPLETION** against the Output Contract.

## Output Contract

A completed BFF advisory states: the single experience served and the single
owning team; the deployment shape and its cost justification; the logic
classification (everything presentation-shaped, with the deletion test
answered); the aggregation contract naming which sections may degrade and how;
the retry ownership per edge with propagated deadlines; the upstream identity
mechanism (exchanged audience-narrowed tokens or transaction tokens, never
service-identity-plus-user-header); the caching policy with identity in the
key; and the boundary guardrails with the scripted-client residual recorded in
the threat model rather than overclaimed.

## References

- `rules/adoption-and-ownership.md` — adoption signals, granularity, ownership,
  deployment shapes, versioning by consumer recallability.
- `rules/shape-dont-decide.md` — what a BFF may own, the deletion test, the
  push-down ladder.
- `rules/public-api-drift.md` — the second-consumer failure mode, guardrails,
  recovery from drift.
- `references/adoption-and-granularity.md` — sources and mechanics behind
  adoption, granularity, mobile skew, and cost accounting.
- `references/aggregation-and-resilience.md` — composition, partial failure,
  resilience budgets, caching, streaming.
- `references/upstream-identity.md` — token layering, exchange, revocation.
- `references/alternatives.md` — gateway vs BFF, GraphQL federation,
  token-mediating backend, meta-framework servers.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When a codebase-structure skill is not
installed, apply the placement rules directly: keep the BFF's module
boundaries explicit inside the framework server, and put endpoint leaves
beside their contracts. An entry-point protection companion, when installed,
owns the BFF's own HTTP and realtime boundary; until then, classify every
route explicitly and enforce the chain in one place. A front-end testing
companion covers degraded-render tests; until then, write behavior-driven
tests for partial payloads yourself. An observability concern, when present,
consumes the per-request credential-mode telemetry this skill requires; the
requirement stands without it.
