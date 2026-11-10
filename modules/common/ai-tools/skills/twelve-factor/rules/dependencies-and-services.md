---
title: Dependencies, Backing Services, and Parity
impact: HIGH
impactDescription: Factors II, IV, and X make providers swappable at composition time
tags: twelve-factor, dependencies, backing-services
---

## Dependencies, Backing Services, and Parity

**Impact: HIGH**

### Dependencies (Factor II)

Explicitly declare all dependencies. Never rely on implicit system-wide
packages.

- Every dependency in the application manifest (e.g. `package.json`).
- Lockfile committed to the repository.
- Dependencies are isolated — the app does not leak from or depend on the
  system environment (local dependency directories, not global installs).
- System tools invoked through subprocesses are explicit runtime dependencies:
  document them, version them where practical, and check them at startup or
  build time.

### Backing Services (Factor IV)

Treat every backing service (database, cache, queue, email, storage) as an
attached resource supplied at composition time through injected configuration.
A URL is common, but platform bindings, socket paths, resource names, handles,
and structured credentials are valid when they are the platform contract.

**Domain code makes no distinction between local and third-party services.**
Swapping equivalent providers changes injected resource configuration, not
domain behavior; a provider with a different protocol may also require a
different adapter. Factory-based wiring of URL-based backing services is one
common example in `references/node-patterns.md`.

For projects using ports-and-adapters architecture, backing services map
naturally to ports (interfaces) and adapters (implementations).

### Dev/Prod Parity (Factor X)

Keep development and production similar in the characteristics that affect
behavior. Exact products may differ when a compatible substitute is deliberate
and contract-tested.

- Prefer production-equivalent backing services for integration and parity
  tests where semantic differences matter.
- Use the repository's existing local-service mechanism; containers are one
  option, not a requirement.
- Config schema validation (Factor III) catches mismatches at startup.
