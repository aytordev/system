---
name: bff-entry-points
description: "Trigger: adding or reviewing browser-facing HTTP endpoints, classifying which routes are public, protecting BFF or backend entry points, session cookies, CSRF or Origin policy, Fetch Metadata, protected SSE or WebSocket registration, browser session coordination, login or logout flows, or an authorization bug reported on an endpoint. Requires an explicit public/protected access classification for every production route, a composition-prepared registrar that installs policy by construction, provider-free in-application authorization proven by direct tests, and automated enforcement gates."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# BFF Entry Points

A BFF is a driving host: it owns the browser-facing HTTP boundary and invokes
application operations on behalf of one user experience. This skill owns the
*behavioral security model* of that boundary — who may call each entry point,
how that is enforced by construction, and how the application stays safe when
a caller is not a browser. It follows the IETF BCP-track guidance for
browser-based apps: tokens stay server-side, the browser holds only a session
cookie; RFC 9700 / BCP 240 is the published OAuth security baseline.

Whether to have a BFF, how many, aggregation, and upstream identity mediation
are pattern-level decisions owned by a BFF-design concern this skill assumes
are settled. Physical endpoint placement belongs to a codebase-structure
concern; this skill defines what each endpoint leaf must declare and how
registration enforces it.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Adding or reviewing HTTP endpoints, or auditing which routes are public.
- A tenant or customer can see another's data through a route, or any
  authorization bug is reported on an endpoint.
- Working on authentication middleware, session cookies, CSRF or Origin
  policy, protected realtime streams, or login/logout flows.

## Hard Rules

1. **Every production entry point declares its access classification.** There
   is no implicit default — an unclassified route is a build failure, not
   "protected by whatever middleware happens to run first" (OWASP API5:2023;
   CWE-306 names the missing check as the vulnerability).
2. **Public is a claim about callers, not about trust.** A public endpoint is
   still validated, rate-limited, monitored, and free of secrets. Keep the
   public set small, snapshot it in a reviewed allowlist test, and treat any
   diff as a security review.
3. **The chain lives in the registrar and nowhere else.** Composition prepares
   the registrar once, supplying session resolution, browser-request policy,
   safe error translation, and telemetry; an endpoint owner supplies only its
   contract and a thin handler. An endpoint module that checks Origin, CSRF,
   or content type itself has reopened the seam the registrar exists to close.
4. **Any route you change goes through the registrar in that change** — a
   route mounted straight on the app included. A state-changing kind is
   registered only with its whole chain: exact-Origin allowlist, Fetch
   Metadata check, content-type check, session resolution, and session-bound
   CSRF, all before the handler runs. A missing collaborator is the work of
   this change, never permission to install fewer checks.
5. **Authentication is adapter work; authorization is application policy.**
   Every protected application operation independently authorizes a
   provider-free principal before any protected effect, in product language,
   whatever the driving adapter is. Inner code never depends on the HTTP
   framework, cookies, identity providers, or browser fields.
6. **Failure semantics are stable and non-oracular.** 401 means "no valid
   session" and nothing else, identical across causes and code paths; 403 is
   reserved for deliberately disclosed refusals; cross-tenant resources get
   the no-oracle 404; 415 for unsupported content type. API, SSE, and
   WebSocket entry points return protocol failures and never redirect to an
   HTML login page.
7. **Realtime entry points get first-class classification.** SSE streams are
   protected reads whose chain completes before the first byte; raw WebSocket
   upgrades go through a sibling upgrade registrar (exact Origin first, then
   session, then in-application authorization, then accept) and appear in the
   derived catalog.

## Execution Steps

1. **CLASSIFY** — give every mounted production endpoint an explicit access
   declaration (`public`, `protected-read`, `protected-browser-mutation`,
   `protected-upgrade`), extending the union only with a new kind and its own
   verification chain.
2. **PREPARE THE REGISTRAR** — composition owns session resolution, browser
   policy, abuse controls, error translation, and telemetry; endpoints register
   contracts and thin handlers only.
3. **ORDER REQUESTS** — reads: session → stable 401 → in-application
   authorization → protected work. Mutations: browser-request policy (no
   session disclosure) → session → CSRF → coarse authorization → bounded body
   parse → authorize every body-referenced target → effects.
4. **DERIVE THE CATALOG** — the registrar records every mount; the catalog is
   its output, never an input. Never hand-maintain a central route-security
   map.
5. **GATE** — reconcile catalog ↔ runtime route table ↔ OpenAPI security
   metadata ↔ public allowlist; pin positive controls and the hostile matrix
   per classification; prove each protected operation refuses an unauthorized
   principal directly, provider-free, with no effect (`rules/authorization-boundaries.md`).
6. **COORDINATE THE BROWSER** — one authentication coordinator, one
   deduplicated realtime probe, nothing provider-shaped in the browser
   (`references/browser-session-coordination.md`).

Read a reference before working in its area: `references/endpoint-protection.md`
(contract shape, cookie profile, browser-request policy),
`references/hexagonal-auth-boundaries.md` (principal, authorization),
`references/realtime-entry-points.md` (SSE and upgrades),
`references/browser-session-coordination.md` (the coordinator),
`references/enforcement-and-testing.md` (gates and test matrix).

## Output Contract

Present: the classification of every touched entry point; the registrar chain
installed (or the ratchet step taken on a brownfield route); the derived
catalog state; the gates that run and the violation each was seeded against;
the positive control and hostile rows per protected surface; the direct
provider-free refusal tests with their no-effect assertions; and the browser
coordinator behavior where realtime exists. A security review states the
public allowlist and its justification prose explicitly.

## References

- `rules/access-classification.md` — the classification union, the derived
  catalog, brownfield ratchet.
- `rules/prepared-registrar.md` — the deep module, chain ordering, request
  ordering, failure semantics.
- `rules/authorization-boundaries.md` — provider-free principal, product
  language, direct refusal tests, RLS containment.
- `references/provenance.md` — upstream source, revision, licence, and drops.

Companion skills are optional here. When a codebase-structure skill is not
installed, apply the placement rules directly: keep endpoint contracts beside
their handlers, keep dev-only composition importable from production one way,
and enforce import boundaries with the tooling the repository already has. A
BFF-design companion owns adoption and upstream identity; until its concerns
exist, the confused-deputy guard in `rules/authorization-boundaries.md` states
the downstream rule. Testing and TDD skills supply the house testing rules;
until then, behavior through public contracts, factories over fixtures, and
fail-closed-before-effect remain the standard here.
