---
title: Authorization Lives in the Application
impact: CRITICAL
impactDescription: Proven by direct provider-free tests
tags: bff-entry-points, authorization, principal, testing
---

## Authorization Lives in the Application

**Impact: CRITICAL**

### The provider-free principal

The BFF translates a validated session into a small provider-free value before
invoking any operation:

```typescript
declare const authenticated: unique symbol;

type AuthenticatedPrincipal = {
  readonly [authenticated]: true;   // opaque brand — structural assembly won't type-check
  readonly userId: UserId;          // branded domain type
  readonly tenantId: TenantId;      // branded domain type
};
```

- Each authentication mode has exactly one production constructor, owned by
  the adapter that performs that mode's authentication. Endpoint handlers,
  workflows, and application code receive the principal; they never mint it.
  Brand the type, export the constructor only from the authenticating modules,
  and add a restricted-import rule that keeps the test factory out of
  production code — a gate, not review discipline.
- It carries only what the application needs to authorize and attribute; it
  never carries provider material: no token claims, no identity-provider
  groups, no cookie names, no session IDs, no HTTP anything.
- One active tenant per session. A URL naming a different tenant is an
  authorization refusal (no-oracle 404), never a "helpful" switch.

**Authentication answers "who is calling?"** — driving-adapter work. **Authorization
answers "may this caller perform this product operation?"** — application
policy, executed inside the operation itself, in product language, before any
protected effect (OWASP ASVS 5.0 §8.3.1: enforce at a trusted service layer).
The precondition holds for every driving adapter — HTTP, CLI, test harness,
another BFF, a queue consumer added next year.

### System and non-browser callers

Every driving adapter must be able to present an honest principal. A CLI
acting for a human operator authenticates that operator and constructs the
same user principal a session would have produced. Scheduled jobs are not
users: give them a discriminated system identity, constructed only by the
composition root that schedules them, with separate system-facing operations
and their own authorization rules — never a user operation with `userId` made
optional, and never a loop borrowing a fake user. Introduce the
`CallerPrincipal` union only when system callers exist.

### Product language, not an authorization bucket

Express authorization as focused product rules inside the operations that own
them — "order in this tenant", "only the organizer closes funding" — not as a
generic `authorization/` utilities module. Layer tenancy and operation rules
deliberately: prefer a tenant-scoped repository contract as the cross-cutting
floor, and let the operation express only operation-level rules. Membership
lookups are driven-port lookups in domain language, then a product rule on the
result. Return refusals as result types, never throws; each driving adapter
translates results into its own vocabulary (404/403/2xx for HTTP, exit codes
for a CLI, reject/dead-letter for a queue).

### Actor mapping after authorization

Map the principal to an attributable domain actor only after authorization
succeeds: authenticate → authorize → resolve the acting domain identity and
attribute effects to it. Never accept an actor, user ID, or tenant ID from the
request body or query when the session already identifies the caller: request
schemas for session-authenticated endpoints simply never declare actor or
tenant fields, and strict parsing rejects unknown fields.

**Confused-deputy guard:** when the BFF calls downstream services,
authorization downstream must be decided on the originating principal, not on
the BFF's own service identity (ASVS 5.0 §8.3.3). Forward the user's identity
(token exchange, signed headers per your platform); a downstream that trusts
"the BFF called me" has no object-level authorization at all.

### Row-level security is containment

Database row-level security is the final backstop when an application check is
missed — it bounds the blast radius. It is not the source of permission, and
an RLS-empty result must still surface as the no-oracle 404, which only the
application can decide. Keep both: authorization in the application as the
decision, RLS as defense-in-depth containment.

### Direct provider-free tests (most important)

For every protected operation, a test invokes it directly — no HTTP, no
cookies, no registrar — with an unauthorized principal from the test factory,
and proves refusal happens before any effect:

```typescript
test('cancelOrder refuses a foreign tenant before touching effects', async () => {
  const orders = createFakeOrderRepository([anOrder({ tenantId: tenantA })]);
  const cancellation = createOrderCancellation(orders);

  const result = await cancellation.cancelOrder({
    principal: aPrincipal({ tenantId: tenantB }),
    orderId: anOrderId(),
  });

  expect(result).toEqual({ outcome: 'not-found' });
  expect(orders.savedOrders()).toHaveLength(0);   // fail closed before the protected action
});
```

If this test can only be written through HTTP, authorization lives in the
adapter — that is the defect, not a test inconvenience. A test driven through
the route proves the wiring, not the rule; an authorization rule covered only
through HTTP is unfinished. "No effect" is asserted through fakes: repository
saved nothing, publisher published nothing, no credential was issued.
