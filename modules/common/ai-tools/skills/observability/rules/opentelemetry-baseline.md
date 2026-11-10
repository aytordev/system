---
title: Hold the OpenTelemetry Baseline
impact: CRITICAL
impactDescription: Semconv, propagation, Collector, cardinality, and sampling
tags: observability, opentelemetry, cardinality, sampling
---

## Hold the OpenTelemetry Baseline

**Impact: CRITICAL**

OpenTelemetry (OTel) is the vendor-neutral standard for producing telemetry.
Adopting it means the instrumentation outlives any backend choice.

### The substrate

- **Signals** — traces, metrics, logs, all exported over OTLP.
- **Resource attributes** — `service.name` is mandatory; it identifies the
  emitting service in every backend.
- **Semantic conventions** — standardized attribute names
  (`http.request.method`, `db.system`) that make telemetry correlatable
  across teams and tools. **Never invent an attribute name semconv already
  defines.**
- **Context propagation** — the W3C `traceparent` header carries trace ID and
  parent span ID across every service hop; this is what makes distributed
  traces exist at all. **Whenever your code builds an outbound request to
  another service — through a vendor SDK, a generated client, or hand-written
  headers — inject the active context into that request's headers
  (`propagation.inject(context.active(), headers)`) instead of writing a
  correlation header of your own.** `x-trace-id`, `x-correlation-id`, and a
  bare trace id under any custom key drop the parent span id and the sampling
  flag; no standard tooling joins them to anything.
- **The Collector** — a receive → process → export pipeline that runs beside
  your services. It is the recommended production default for batching,
  retry, redaction, and backend swaps without code changes. A documented
  direct-export design is acceptable when the deployment is simple and the
  SDK/backend path demonstrably meets its buffering, retry, backpressure,
  filtering, and operational requirements.

Initialization order matters: instrumentation loaded after the application's
modules silently captures nothing. Load it before application code
(`node --import ./instrumentation.mjs` in Node runtimes).

### The cardinality routing rule

Every unique label combination on a metric is a separate time series. Add
`tenant_id` (10,000 values) to a metric with 1,000 existing series and you
have 10 million series, not 11,000; each active series costs memory and most
vendors bill per series or per custom metric.

**The rule: bounded, low-cardinality dimensions go on metrics; unbounded,
high-cardinality dimensions go on events/spans.** Request-derived labels are
safe only after normalization to a fixed allowlist (for example, a known
method or result category); map unknown values to `_OTHER` or omit them.
Never use raw or unbounded attacker-controlled values such as IDs, paths,
query strings, arbitrary headers, or body fields. When someone asks "can we
break this metric down by customer?", the answer is "that question belongs to
the event store."

### The sampling ladder

| Stage | When | How |
|-------|------|-----|
| No sampling | Low volume | Keep everything — sampling is a cost tool, not a virtue |
| Head sampling | Volume grows | Decision at trace start (probabilistic on trace ID), propagates consistently, cheap — but cannot guarantee capturing errors |
| Tail sampling | Decisions need completed-trace attributes | Decision after the full trace arrives; can preferentially retain selected errors and outliers, but requires a stateful Collector tier — buffering, scaling, operational cost, possible lock-in |

**Never silently sample the stream your SLOs are computed from.** If sampling
is unavoidable there, account for it in the SLI math. Configure and verify
error-trace retention separately; tail sampling policy and capacity determine
what is actually retained.
