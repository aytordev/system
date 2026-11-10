---
title: Classify Every Entry Point
impact: CRITICAL
impactDescription: No implicit defaults, no unclassified routes
tags: bff-entry-points, classification, catalog
---

## Classify Every Entry Point

**Impact: CRITICAL**

### The classification union

```typescript
// Canonical definition — references restate it only by pointer.
type EndpointAccess =
  | { readonly kind: 'public'; readonly justification: string }
  | { readonly kind: 'protected-read' }
  | { readonly kind: 'protected-browser-mutation' }
  | { readonly kind: 'protected-upgrade' };   // raw WebSocket upgrades
```

| Classification | Meaning | Registrar installs |
|----------------|---------|--------------------|
| `public` | Intentionally callable without an application session | Validation, abuse controls, explicitly unauthenticated docs |
| `protected-read` | Safe method for an authenticated user | Session resolution → 401 → in-application authorization |
| `protected-browser-mutation` | State change initiated by a browser | Origin/Fetch Metadata/content-type policy → session → CSRF → authorization |
| `protected-upgrade` | Raw WebSocket upgrade | The sibling upgrade registrar's chain |

A project may extend the union — service credentials, signed webhooks,
administrative operations — but every entry point still makes one explicit,
exhaustive declaration, and each added kind defines its own verification chain
in the registrar. Never express a new mode as options on an existing one.
Non-browser driving adapters are not exempt: each authenticates by its own
mode and constructs its own caller principal.

**Public is a claim about callers, not about trust.** Health probes are the
canonical example: public, but verdict-only (no dependency names, versions, or
stack traces). Scope abuse controls sensibly — rate-limiting a liveness probe
into a 429 causes an outage.

### Source of truth and the derived catalog

Endpoint contracts stay feature-local: route, validation schemas, access
declaration, handler, and documentation live together at the endpoint leaf.

Do not build a second, hand-maintained central route-security map. It will
drift from runtime registration, and the drift is invisible until an incident.
Instead, derive a central entry catalog from the two things that are already
true: the feature-local endpoint contracts, and the explicit production
composition — which contracts were actually mounted, including raw WebSocket
upgrades. The registrar records every mount; the catalog is its output, never
an input.

Three reconciliations make it trustworthy (mechanisms in
`references/enforcement-and-testing.md`):

1. Catalog ↔ framework route table: nothing mounted outside the registrar,
   nothing registered but unmounted.
2. Catalog ↔ OpenAPI document: every operation's `security` matches its
   declared access; documented-but-unmounted and mounted-but-undocumented
   both fail.
3. Catalog public subset ↔ reviewed allowlist snapshot.

Dev-only endpoints live in a separate composition importing production one
way; the production catalog test proves their absence (OWASP API9:2023).

### Brownfield ratchet

Adopting on a system that already has routes — ratchet instead of rewriting:

1. Add the route-enumeration test first, with every currently unclassified
   route in an explicit exceptions list — the list may only shrink.
2. Mount all *new* endpoints through the registrar from day one.
3. Migrate existing routes leaf by leaf, highest-privilege first.
4. Add direct provider-free refusal tests operation by operation as each route
   migrates — where the test cannot be written, authorization is
   middleware-only and that operation is your next fix.
5. Tighten the gates to zero exceptions and only then trust the catalog.

### Anti-patterns

- A route mounted directly on the framework app in production code, bypassing
  the registrar — including one that predates it. Changing such a route at
  all, a security fix above all, means moving it onto the registrar with its
  own access declaration in that same change.
- `requireAuth: false`, `skipCsrf`, or any boolean that lets an endpoint owner
  weaken its own chain.
- A hand-edited list of protected paths, or path-prefix matching as the
  authorization boundary.
- A dev-only endpoint reachable from production composition.
