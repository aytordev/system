---
title: Emit One Wide Event Per Request
impact: CRITICAL
impactDescription: The canonical log line is the default instrumentation
tags: observability, wide-events, logging
---

## Emit One Wide Event Per Request

**Impact: CRITICAL**

The opinionated default: emit one structured, information-dense event per
request per service. This is the canonical log line — one long record at the
end that includes many of the request's key characteristics — and the
"arbitrarily-wide structured event" at the heart of modern observability.

### Mechanics

1. Middleware creates a request-scoped accumulator when the request enters
   the service.
2. Business logic and middleware add fields as work happens.
3. The event is emitted once, at the end of the request, in
   `finally`/teardown logic — **it must survive the exception path**, because
   that is exactly when you need it.

### Construction rule — one exit, proved by a throw

For Promise-based handlers, open the `try` before anything that can throw:
request parsing and body reads included, not just the business call. The
*only* call site that finishes the event — setting the outcome attributes,
recording the exception, ending the span or emitting the record — sits in the
matching `finally`. A helper that does all three is fine, but it is called
from the `finally` and from nowhere else. A helper invoked on the success
path, paired with a `finally` that merely ends a span or flushes, still loses
every field on the throw. Before calling the work done, run a test that makes
the handler throw *outside* its own `catch` and assert that one event
carrying the outcome is still recorded.

### What goes in it

| Category | Example fields |
|----------|---------------|
| Request | method, normalized route template (omit when unavailable), status, duration |
| Identity | user/principal ID, auth method, API key ID |
| Rate limiting | allowed, quota, remaining |
| Performance | DB query count, cache hits, external call timings |
| Business context | which rule fired, rejection reason, feature flags |
| Error | error code, error class, retry count |
| Correlation | trace ID, request ID, build/deploy ID |

High-cardinality identifiers belong in events, subject to privacy policy —
request IDs, build IDs, and privacy-approved or pseudonymous subject
identifiers can make an event useful. High cardinality is a feature for
events and a cost explosion on metrics, but event suitability is never
permission to emit personal data.

Why this beats scattered log lines: the data arrives pre-joined. You query
complete rows instead of reconstructing a request from fragments with regex
and hope. An OpenTelemetry root span with rich attributes is a valid
implementation of the same pattern — instrumenting via spans satisfies both
the wide-event and the tracing camps at once.

### Pillars, honestly

The industry framing is "three pillars": logs, metrics, traces. The serious
critique: three pillars means many sources of truth scattered across tools,
each request stored several times, engineers correlating by hand, and cost
multiplied per pillar. The alternative: one source of truth — wide structured
events — from which metrics, traces, and SLOs are *derived* at read time.

House position:

- **Wide events are the instrumentation default.** They avoid duplicate
  instrumentation and preserve more future questions, but export, processing,
  and storage still need an explicit telemetry cost budget.
- **Metrics still earn their place** for cheap, long-retention aggregates and
  alerting math — with strictly bounded label sets.
- **Traces are wide events with structure** — parent/child causality across
  services. Instrument via OTel spans and you get both.

Honest limit: deriving everything at read time assumes a backend that can
aggregate over raw events at scale. Not every stack has one. Do not
cargo-cult either camp — emit wide events regardless (the data is the asset;
backends change), and keep a small set of bounded metrics for dashboards and
alert rules.
