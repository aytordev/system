---
title: Place Instrumentation at the Edges
impact: HIGH
impactDescription: Domain code never sees a trace ID
tags: observability, architecture, ports-and-adapters
---

## Place Instrumentation at the Edges

**Impact: HIGH**

In ports-and-adapters codebases, observability code has four homes:

1. **Technical telemetry → adapters.** Request/response logging, SQL timings,
   retries, auto-instrumentation. Never in domain code.
2. **Domain-significant observations → an explicit driven port (Domain
   Probe) or domain events.** When an intermediate business fact matters
   ("which pricing rule fired") or the observation is a requirement (support
   logging, business metrics), the observability backend is a driven actor
   behind a per-capability, severity-free, fire-and-forget port — never a
   generic `Logger` port. Where domain events already exist, an observability
   subscriber beats a second channel.
3. **Correlation and wide-event assembly → middleware/adapters only.** The
   domain never sees a trace ID. Domain dimensions reach the wide event via
   result types, the probe, or events.
4. **Instrumentation is tested behavior.** A probe is a driven port; every
   driven port gets a fake (see `rules/testing-telemetry.md`).

Domain-oriented observability (Hodgson, martinfowler.com) is the source for
the Domain Probe pattern and its announcement models; read it for full
treatment.

Even without hexagonal architecture, the same instinct applies: business
logic returns data and announces facts; edges translate those into telemetry.
