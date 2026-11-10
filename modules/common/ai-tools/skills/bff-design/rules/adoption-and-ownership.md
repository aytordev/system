---
title: Adopt by Signal, Own by Team
impact: CRITICAL
impactDescription: Keeps BFF count and ownership honest
tags: bff-design, adoption, ownership, granularity
---

## Adopt by Signal, Own by Team

**Impact: CRITICAL**

### Adoption signals

| Signal | Reading |
|--------|---------|
| A second client *type* is arriving (mobile app, partner surface, TV) | Strongest adoption trigger — consider a BFF for each party from the outset |
| One page/screen fans out to many downstream calls | Aggregation belongs server-side, near the services, shaped per experience |
| Frontend teams queue behind a general-purpose API team for every endpoint | The founding problem — a BFF moves the contract inside the frontend team |
| Browser app handles sensitive/personal data (default: any app with logins qualifies) | The IETF browser-apps BCP-track guidance strongly recommends the BFF architecture on security grounds alone — tokens stay server-side |
| Only one interface, making simple, similar requests to one backend | Skip it on the aggregation motive — *unless another row fires*: the security row alone justifies a BFF for a sensitive single-backend SPA |
| You already run GraphQL with frontend-specific resolvers, or a meta-framework server | You may already *have* a BFF — apply this skill to it instead of adding another box |

The "against" case answers the *aggregation/divergence* motive only; it vetoes
a BFF when no other signal fires. Token confinement needs no aggregation
motive.

One upstream is still a valid BFF: a single general-purpose API behind a BFF
is the most common starting point, and the machinery collapses to one deadline,
one empirical timeout, one retry owner, one fast-fail — but overload
protection stays whole. Getting there is a strangler migration, not a
cutover: stand the BFF beside the general-purpose API, move one screen at a
time, delete per-client endpoints as each moves, and run the coexistence
period deliberately with a published end date.

### Granularity: experience first, Conway second

- **One experience, one BFF.** Platform alone does not split a BFF; a
  genuinely different experience does. iOS and Android listener apps share one
  BFF; the creator app has its own.
- **Team structure can override the experience default.** Separate iOS and
  Android teams justify separate BFFs even for near-identical experiences. The
  inverse — one experience, two teams sharing a BFF — is an ownership smell:
  appoint one owning team or split; never co-own.
- **Micro-frontends pair vertically — when the slice is really vertical.** A
  separately owned business capability brings its own BFF slice, owned by the
  same team, deployed together; a merely technical subdivision inside one
  experience shares the experience's BFF as a module.

### Ownership and the deployment unit

The frontend team owns the BFF — language choice, release cadence,
priorities. BFF and frontend form one deployment unit: same repo where
practical, contracts co-evolved rather than versioned.

### Versioning by consumer recallability

- **Web**: old bundles live for browser-tab-hours. The BFF briefly serves
  versions N and N−1: additive changes, tolerant-reader clients,
  expand-contract migrations. No URL versioning.
- **Mobile**: app-store binaries live for years and cannot be recalled. A
  mobile BFF *concentrates* the skew — per-version response shaping in one
  owned place, with a versioned surface from day one and a support window so
  per-version shaping has a retirement schedule.
- If a migration window needs any guarantee, use consumer-driven contract
  tests (the frontend's expectations, executable) rather than version numbers.

Hyrum's Law still applies, scaled down: one consumer you control is the one
situation where observable-behavior coupling is manageable by discipline.

### Honest cost accounting

Each BFF-as-service is a full deployable: own lifecycle, pipeline, security
surface, patching, monitoring, SLOs, plus one added network hop and probable
duplication. Three legitimate shapes:

| Shape | When |
|-------|------|
| Modular-monolith BFF — per-experience modules, one deployable | Boundaries and ownership wanted, but independent scaling/cadence/language not yet exercised |
| BFF per experience as separate services | Teams genuinely release at different cadences, scale differently, or choose different stacks |
| Meta-framework server as the web BFF | You already run Next/Remix/SvelteKit with a server; a separate web BFF beside it is redundant |

State the benefit side next to the costs: endpoint-change lead time and
payload size/request count per screen. A cost sheet with no revenue line reads
as a reason to do nothing. Never pay microservice costs for boundaries a
module would give you; shared-library extraction too early produces upgrade
cascades across every BFF.
