---
title: One Prepared Registrar
impact: CRITICAL
impactDescription: The chain is installed by construction
tags: bff-entry-points, registrar, request-ordering
---

## One Prepared Registrar

**Impact: CRITICAL**

### The deep module

Composition prepares the registrar once, supplying everything an endpoint must
never choose for itself: session resolution, browser-request policy, safe
error translation (RFC 9457 problem details without internals), and
telemetry. An endpoint owner supplies only its contract and a thin handler.

```typescript
// composition/ — the only place that knows the enforcement machinery
const endpoints = createEndpointRegistrar({
  app,            // framework instance
  sessions,       // cookie → validated session → AuthenticatedPrincipal
  browserPolicy,  // exact-origin allowlist, Fetch Metadata, CSRF, content types
  abuse,          // rate limits and payload caps, keyed by endpoint contract
  errors,         // safe problem-details translation
  telemetry,
});

// endpoints/api/orders/by-order-id/get.ts — contract + thin handler only
endpoints.register(getOrderContract, async ({ principal, params }) => {
  const result = await orders.viewOrder({ principal, orderId: params.orderId });
  return toHttpResponse(result);
});
```

The endpoint owner cannot choose, order, or omit authentication middleware —
there are no optional flags. The handler's type is derived from the
declaration: a `public` handler receives no principal; a protected handler
receives a principal it could not have minted itself — non-constructibility is
enforced by module boundary and an import-boundary gate, not convention. For
public endpoints the registrar emits explicitly unauthenticated documentation
(`security: []`, a deliberate greppable marker — never an omitted field); for
protected endpoints it emits matching OpenAPI security metadata, so runtime
behavior and documentation cannot disagree.

Keep the registrar's core framework-neutral; only its inner adapter touches
framework APIs. A concrete Hono binding exists upstream but is dropped here;
the framework-neutral decisions it encoded are restated in
`references/endpoint-protection.md`, and the mapping of responsibilities to
Fastify, Express, and Fetch-based routers is a per-project binding exercise:
contract carrier, chain installation, boot-time fail-closed hook, and runtime
route enumeration for the gates.

Two consequences hold on every change, not only greenfield work:

- **The chain lives in the registrar and nowhere else.** An endpoint module
  that checks Origin, a CSRF token, or the content type itself has reopened
  the seam the registrar exists to close — put the missing check into the
  registrar's chain and let the endpoint receive it.
- **Any route you change goes through the registrar in that change**, a route
  already mounted straight on the app included. Moving a mount changes neither
  the app factory's signature nor its dependencies, so an instruction to keep
  those as they are is not a reason to leave the bypass in place.
- **A state-changing kind is registered only with its whole chain.** The
  branch that adds it adds, before the handler runs: an exact-Origin allowlist
  match, a Fetch Metadata check, a content-type check, session resolution, and
  a session-bound CSRF token check. All five, whatever you name the kind. A
  branch that resolves the session and checks the content type is a read chain
  that accepts a body — registering a mutation on it is the omission this
  skill exists to prevent. Build in that same change whatever the chain needs
  and composition does not yet have: where no allowlist is configured, a
  service that serves one front end matches the request's own origin; where
  the session record carries no token field, mint one by HMAC over the session
  id.

### Request ordering

**Protected read:** resolve and validate the application session → stable 401
when authentication is absent or invalid → authorize the requested product
resource inside the application → only then read, subscribe, issue
credentials, or perform other protected work.

**Protected browser mutation:**

1. Reject invalid Origin, unsuitable Fetch Metadata, or unsupported content
   type — without revealing whether a session exists.
2. Resolve the application session.
3. Validate session-bound CSRF protection — not optional and not a follow-up:
   where the session record cannot carry a synchronizer token, mint one by
   HMAC over the session id with a server-side secret (signed double-submit,
   session-bound) and validate that, rather than registering the mutation with
   an Origin-and-content-type chain and leaving the token for later.
4. Perform any coarse operation or path-resource authorization available from
   the principal and validated params.
5. Parse and validate the bounded body.
6. Authorize every body-referenced object, field, target, and operation.
7. Only then perform effects.

Contract paths use OpenAPI `{param}` syntax everywhere; the registrar
translates to framework syntax, and the catalog stores the contract form. Put
a primary target identity in the path when that is the honest resource model,
but do not contort batch, share, or field-level operations merely to avoid
body-dependent authorization. A deferred `body()` thunk preserves the coarse
path check before parsing; all bounded body data is still validated and
authorized before effects. Enforce body-size limits ahead of parsing. Seed
both ordering cases: a coarse refusal never parses; a body-dependent refusal
parses and validates but performs no effect.

### Failure semantics without oracles

| Status | Meaning |
|--------|---------|
| 401 | Authentication is required or no longer valid — identical status/headers/body across missing, expired, revoked, and disabled causes, same code path (no cause-specific shortcut) |
| 403 | A deliberately disclosed request-policy or known-forbidden result |
| 404 | Inaccessible or cross-tenant resource whose existence must not be disclosed (RFC 9110 §15.5.4 sanctions this) |
| 415 | Unsupported content type |

API, SSE, and WebSocket entry points return protocol failures. They never
redirect to an HTML login page — a redirected `fetch` yields an unparsable 200
HTML, and a redirected `EventSource` fails opaquely on content type. Endpoints
translate operation results through one composition-owned helper, so no single
endpoint can quietly turn a no-oracle `not-found` into an
existence-confirming 403.
