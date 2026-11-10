---
title: Idempotency and Quota Communication
impact: CRITICAL
impactDescription: Stops retries from repeating effects
tags: api-design, idempotency, rate-limiting
---

## Idempotency and Quota Communication

**Impact: CRITICAL**

Network failures happen. Clients retry. Without idempotency, retries create
duplicate charges, duplicate orders, duplicate records. Design for
at-least-once delivery — assume every request might be sent multiple times.

### HTTP method idempotency

| Method | Safe | Idempotent | Notes |
|--------|------|------------|-------|
| GET | Yes | Yes | Read-only requested semantics; incidental logging/metrics are allowed |
| PUT | No | Yes | Same request has the same intended effect; response status/body may differ |
| DELETE | No | Yes | Deleting twice = same outcome |
| POST | No | **No** | Needs explicit idempotency handling |
| PATCH | No | Not guaranteed | Depends on implementation |

### Idempotency keys for POST

For non-idempotent operations (especially those involving money, orders, or
state changes), use client-provided idempotency keys with these design rules:

- Keys are scoped to the API key / authenticated user; one visible-ASCII
  `Idempotency-Key` header of at most 128 characters; reject anything else
  with 400.
- Choose response-cache and claim retention from the documented maximum
  client retry/reconciliation window and effect risk; 24 hours is not a
  universal rule.
- Keep a durable operation identity (and fingerprint or tombstone) after
  cached response eviction, or return an explicit expired/unknown outcome
  until non-duplication can be established — never silently treat a risky
  reused key as a fresh operation.
- If parameters differ on retry with the same key, return an error.
- Claim a key atomically; a separate read-then-create sequence is race-prone.
- Coordinate the business effect with the claim through one transaction or a
  durable downstream operation ID.
- For external payments, persist and reconcile the provider payment/intent
  ID; bound any request-idempotency-key retry to the provider's documented
  retention.
- Represent in-progress claims explicitly and define retry/recovery for a
  worker that fails after claiming.

```typescript
const claim = await idempotencyStore.claim({ scope, key: idempotencyKey, fingerprint });
if (claim.status === 'parameters-mismatch') return res.status(409).json(toProblem('IDEMPOTENCY_PARAMETERS_MISMATCH'));
if (claim.status === 'completed') return res.status(claim.response.status).json(claim.response.body);
if (claim.status === 'in-progress') {
  res.setHeader('Retry-After', '1');
  return res.status(409).json(toProblem('IDEMPOTENCY_REQUEST_IN_PROGRESS'));
}
```

### DELETE idempotency

DELETE must have an idempotent effect: repeating it does not delete anything
else or create a second side effect. The repeated response may remain `204`,
or it may be `404` when absence is meaningful to clients. Choose and document
one contract.

### Rate-limit headers

When an API exposes a quota policy, communicate the applicable policy and
remaining state consistently on responses where that information is useful to
clients. Do not invent quota headers for endpoints without such a policy.

- Prefer the current IETF draft fields (`RateLimit-Policy`, `RateLimit`);
  earlier triplet (`RateLimit-Limit`/`-Remaining`/`-Reset`) and unstandardized
  `X-RateLimit-*` names still exist in shipped APIs — expect any of them when
  consuming. Whichever names you choose, document them: header names are part
  of your contract.
- On 429, include `Retry-After` when the server can give a meaningful retry
  time. HTTP permits a 429 without it.

### Design considerations

- Different limits for different operations — reads are cheaper than writes.
- Communicate limits in documentation — don't make consumers discover them by
  hitting 429s.
- Recommend exponential backoff with jitter in your docs — naive retry loops
  cause thundering herds.
- Protect unauthenticated, costly, or abuse-prone operations from the start;
  never add abuse control only after the operation is attacked.
