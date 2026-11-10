---
name: api-design
description: "Trigger: designing REST endpoints, cross-team boundaries, versioned service contracts, error semantics, pagination, idempotency, rate limiting, caching, or backward-compatible API evolution. Requires contract-first definition, one consistent error format (RFC 9457 for public APIs), additive-only evolution with recorded supersessions, validation at trust boundaries, and idempotency for retriable state-changing operations."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# API and Interface Design

Use this skill for consumer compatibility and protocol semantics of APIs that
external or independently released consumers call. An in-process module's
responsibility, caller burden, and information-hiding depth are a separate
module-design concern; use both lenses only when an internal module also
exposes a public or cross-team contract.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Designing new API endpoints or cross-team contracts.
- Defining or changing interfaces between teams or independently released
  consumers.
- Choosing error semantics, pagination, idempotency, rate-limit, or caching
  policy for an HTTP API.
- Planning backward-compatible evolution or deprecation of a shipped contract.

Do not use it for a purely internal module's interface depth, for OAuth/OIDC
protocol-flow design (a dedicated protocol workflow), or for browser-facing
entry-point protection (an entry-point security concern).

## Hard Rules

1. **Contract first.** Define the typed interface before implementing it; the
   contract is the spec. Tests are written against the contract, then the
   implementation follows.
2. **Hyrum's Law governs exposure.** Every observable behavior — error text,
   ordering, timing, undocumented quirks — becomes a commitment once users
   depend on it. Be intentional about what you expose, never leak
   implementation details, and plan deprecation at design time, recording it
   the moment it happens.
3. **Prefer addition over modification — this rule outranks the wording of the
   request.** A request to rename, retype, narrow, or remove something a
   shipped contract already publishes is a request for the new shape, not for
   the outage. Add the new name alongside the old, keep the old one working
   with the same value, record it as superseded where a consumer can see it,
   and say in the reply that you added rather than replaced. Do not perform
   the break and note it afterwards; do not stall asking which was meant.
4. **One error strategy per versioned contract.** RFC 9457
   (`application/problem+json`) for public APIs; a simpler consistent shape is
   valid for a single-frontend internal API if it can evolve toward RFC 9457.
   Errors are actionable, never a debugging tool: no stack traces, internal
   paths, or implementation details. Include a correlation identifier as an
   extension member or via `instance` — a lookup key, not a detail leak.
5. **Validate at trust boundaries, then pass derived types inward.** Return
   400 when the representation cannot be parsed; 422 when a parsed value fails
   the endpoint schema or business validation. Third-party API responses are
   untrusted data — validate shape and content before use. Domain smart
   constructors and transition checks stay with the model that owns the value.
6. **Retriable POST needs explicit idempotency.** Client-provided
   `Idempotency-Key`, scoped to the authenticated caller, claimed atomically,
   with parameters-mismatch detection, explicit in-progress handling, and a
   durable operation identity that survives response-cache expiry. DELETE must
   have an idempotent effect under one documented response contract.
7. **Communicate quota policy where it exists.** Expose the applicable limit
   state consistently on responses; include `Retry-After` on 429 when a
   meaningful retry time is known; do not invent quota headers for endpoints
   with no quota policy.
8. **Assign explicit freshness.** Prefer `Cache-Control: max-age=N`, ETags for
   revalidation, `Vary` on all responses a request header varies, `no-store`
   for sensitive data.

## Execution Steps

1. **SCOPE** — determine who consumes the contract and how recallable they are
   (browser tab-hours vs app-store years); this sets versioning discipline.
2. **DEFINE** — write the typed contract (inputs, outputs, errors) before any
   implementation; pick the error format and document it.
3. **VALIDATE** — place schema validation at the boundary; decide the 400/422
   mapping and document any house deviation only when used consistently.
4. **GUARD** — classify every non-idempotent operation, define the idempotency
   and retry story, and protect unauthenticated, costly, or abuse-prone
   operations from the start.
5. **EVOLVE** — additive changes only; record every supersession with
   `Deprecation`/`Sunset` headers and a consumer-visible replacement note.
6. **VERIFY** — run the checklist in the Output Contract.

Read a reference before working in its area:

- `references/problem-details.md` — RFC 9457 member semantics, JSON examples,
  §5 security guidance.
- `references/api-evolution.md` — versioning strategies, Postel's Law,
  `Deprecation`/`Sunset` headers, enum evolution, contract testing.
- `references/api-security.md` — OWASP API Security Top 10, authentication
  pattern selection, transport security.
- `references/auth-security.md` — JWT BCP (RFC 8725) deep dive.
- `references/http-fundamentals.md` — RFC 9205 method/status/header discipline,
  caching directives, browser security headers.

## Output Contract

A completed API design states: typed input/output contracts per endpoint; the
single error format with a worked problem-details example; the compatibility
position (what was added, what was superseded and where it is recorded); the
idempotency and retry story for state-changing operations; pagination or
another documented safe bound for growing lists; quota and caching headers;
and the verification checklist, all items confirmed or explicitly deferred.

Before finishing, check: no published name, type, status, or route was removed
or repurposed by this change; superseded names still serve their old value;
error responses cannot leak internals; third-party inputs are validated;
naming follows the REST conventions; contract-first was actually followed.

## References

- `rules/compatibility-and-evolution.md` — Hyrum's Law, the one-version rule,
  additive evolution, the request-outweigh rule.
- `rules/errors-and-validation.md` — error-format choice, status mapping,
  no-oracle responses, boundary validation.
- `rules/idempotency-and-quotas.md` — method idempotency, idempotency keys,
  rate-limit headers, retry guidance.
- `rules/rest-conventions.md` — naming, resource design, pagination,
  input/output separation, caching.
- `references/provenance.md` — upstream source, revisions, and licence notice.

Companion skills are optional here. When a TypeScript type-pattern, functional,
or testing skill is not installed, apply the rules directly: parse, don't
assert, at trust boundaries; keep domain invariants with their owner; and prove
API behavior through contract tests before shipping. A BFF-design companion
legitimately relaxes versioning discipline for a single-consumer BFF deployed
in lockstep with its frontend; an entry-point protection companion owns
browser-facing access classification and security headers. An observability
concern, when present, consumes the correlation identifier this skill already
requires; the requirement stands without it.
