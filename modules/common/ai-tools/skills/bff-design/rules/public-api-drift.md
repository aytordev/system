---
title: Guard Against Public-API Drift
impact: HIGH
impactDescription: Stops a BFF becoming an unversioned public API
tags: bff-design, boundaries, drift, threat-model
---

## Guard Against Public-API Drift

**Impact: HIGH**

The moment a second *experience* consumes a BFF, it stops being one: the
contract freezes, the coordination tax returns, and "part of the application"
silently becomes an unversioned public API.

### Guardrails, all three

1. **Separate surfaces, honestly policed.** Browser and native apps are
   *public clients* — nothing they carry cryptographically authenticates the
   client software; even native-app registration identifies the registration,
   not the binary (RFC 8252). So "authenticate the client" is not literally
   available; what is: each BFF is its own host/origin with its own credential
   mode — the web BFF's browser-request policy and session issuance excludes
   *browser-origin* cross-surface misuse, and a mobile BFF accepts only user
   bearer tokens whose issuer, audience, and authorized-party claims name *its*
   surface. A determined scripted client that obtains its own session is
   governed by these policies plus abuse controls, not cryptographically
   excluded — say so in the threat model instead of overclaiming. Attestation
   APIs and client telemetry are risk signals on top, never verified identity.
2. **A new consumer gets its own surface.** Another *experience* (including a
   partner integration you build and own) gets its own BFF; consumers you do
   not control, or non-frontend consumers, get a real public API under the
   external-contract discipline (additive evolution, versioning, documented
   errors). A data feed is neither an experience nor the BFF's to serve: front
   it from the domain services — the BFF holds no durable state to feed from.
3. **Watch for it**: record the accepted credential mode, issuer, and client
   registration per request; an unfamiliar registration or credential mode in
   BFF telemetry is an architectural incident, not a support question.

### Recovering from drift (the audit case)

A second consumer is already coupled:

1. **Declare it** — name the drift explicitly.
2. **Freeze the contract additively** — no breaking changes while coupled.
3. **Stand up the consumer's own surface** — its BFF or a public API.
4. **Migrate strangler-style route by route** with a published deprecation
   date.
5. **Only then enforce the boundary rejection.**

Enforcing first breaks a consumer you accepted; never enforcing means the
drift is now the architecture.

### Anti-patterns

- A BFF consumed by a second experience, a second team, or any consumer you do
  not control. (Two platform builds of one experience are one consumer, not
  two.)
- Sharing the BFF across teams that co-own it.
- A "partner BFF" that quietly becomes a data API for the domain services.
