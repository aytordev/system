---
name: observability
description: "Trigger: instrumenting a new or existing service, designing SLIs, SLOs, or alerts, choosing what to log, trace, or measure, correlating a request across a service hop, debugging a failure the logs cannot explain, or reviewing telemetry cost, cardinality, or sampling. Requires wide-event-first telemetry, OpenTelemetry with propagated trace context, cardinality-bounded metrics, symptom-based burn-rate alerting, and hygiene that keeps secrets and personal data out of every signal."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Observability

**Instrument for the questions you have not asked yet.** Monitoring verifies
failure modes you predicted; observability lets you interrogate the system
about failures you never anticipated. Telemetry answers two questions — *what
is broken* (symptom) and *why* (cause) — and the effort split is lopsided:
spend far more on catching symptoms than on enumerating causes.

This skill covers what goes *into* telemetry and how it is consumed. Log
transport and shape stay a platform concern — structured records on
platform-captured process streams, recognized levels, ISO timestamps — and a
`twelve-factor` skill carries that rule where installed. Diagnosing a failing
CI run is `ci-debugging`'s job (optional companion); this skill owns
production telemetry. Sampling and pipeline configuration are parity
surfaces — staging at 100% sampling and production at 1% behave differently
under debugging — and a `production-parity-skill-builder` companion covers
the general drift method.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Instrumenting a new or existing service (backend, worker, API).
- Defining SLIs, SLOs, or an error budget policy.
- Designing, reviewing, or pruning alerts.
- "We cannot see what production is doing" — debugging unknown-unknowns.
- Reviewing telemetry spend, metric cardinality, or sampling strategy.

Do not use it for diagnosing a failing CI run, for local-versus-production
drift investigation, or for browser work: browser observability is real-user
monitoring with Core Web Vitals as the standard SLIs (LCP ≤ 2.5s, INP ≤ 200ms,
CLS ≤ 0.1 at the 75th percentile of real page loads); this package covers
services only.

## Hard Rules

1. **Emit one wide event per request per service.** A single structured,
   information-dense event emitted once in teardown — it must survive the
   exception path, because that is exactly when you need it
   (`rules/wide-events.md`).
2. **Never invent an attribute name semconv already defines**, and inject the
   W3C `traceparent` header on every outbound service hop — a downstream team
   asking for "something we can search on to line your call up with ours" is
   asking for `traceparent`; a bare trace id under a custom key drops the
   parent span id and the sampling flag, and no standard tooling joins it to
   anything (`rules/opentelemetry-baseline.md`).
3. **Route cardinality.** Bounded, low-cardinality dimensions go on metrics;
   unbounded, high-cardinality dimensions go on events and spans. Never use
   raw or unbounded attacker-controlled values as metric labels; map unknown
   values to `_OTHER` or omit them.
4. **Never silently sample the stream your SLOs are computed from.** If
   sampling is unavoidable there, account for it in the SLI math and verify
   error-trace retention separately.
5. **Page on symptoms, not causes**, with multiwindow multi-burn-rate
   construction. Every page is urgent, actionable, user-visible, requires
   human intelligence, and links a runbook (`rules/slos-and-alerting.md`).
6. **Keep secrets and personal data out of every signal.** Never emit
   passwords, tokens, API keys, cookies, or session IDs into any signal;
   allowlist named fields; redact at source in the application
   (`rules/telemetry-hygiene.md`).
7. **Instrumentation is tested behavior.** In-memory exporters and fake
   probes assert the observation through the public API
   (`rules/testing-telemetry.md`).

## Execution Steps

1. **WIDE EVENT** — create a request-scoped accumulator when the request
   enters the service, enrich it as work happens, and emit it once in
   `finally`/teardown. Open the `try` before anything that can throw; the only
   call site that finishes the event sits in the matching `finally`. Prove it
   with a test that throws outside the handler's own `catch`.
2. **BASELINE SIGNALS** — set `service.name` and resource attributes, use
   semantic-convention names, propagate trace context across every hop, and
   export through a Collector (or a documented direct-export exception that
   demonstrably meets buffering, retry, backpressure, filtering, and
   operational needs). Instrumentation initializes before application code
   loads.
3. **ROUTE CARDINALITY** — apply the routing rule to every metric label; keep
   sampling decisions on the ladder (none → head → tail) with an explicit
   error-trace retention objective.
4. **DEFINE SLOs** — a handful of ratio-based SLIs per journey, latency
   thresholds explicit, percentiles for diagnosis, internal targets slightly
   stricter than published ones, and an error budget policy agreed before the
   first breach.
5. **ALERT** — build multiwindow multi-burn-rate rules from the parameter
   table, link a runbook to every page, and prune alerts that repeatedly page
   without actionable work.
6. **HYGIENE PASS** — allowlist emitted fields, redact at source, and add the
   substring-sweep test proving secrets never reach a signal.
7. **TEST** — assert instrumentation through in-memory exporters or probe
   fakes; unit-test alert rules where the stack supports it.

## Output Contract

Present: the wide-event field inventory; the telemetry setup (resource
attributes, propagation, exporter path with any documented exception);
cardinality and sampling decisions with their cost rationale; SLO definitions
with thresholds and the error budget policy; alert rules with windows, burn
rates, and runbook links; hygiene measures; and the tests that prove
observations are emitted — including on the failure path.

Never present `console.log` additions as instrumentation. When a file you are
already editing carries such noise on paths you were not asked about, remove
all of it from that file — half-cleaned leaves lines nobody can query and
nobody will come back for.

## References

- `rules/wide-events.md` — the wide-event contract, construction rule, field inventory, pillars position.
- `rules/opentelemetry-baseline.md` — semconv, propagation, the Collector, cardinality routing, sampling ladder.
- `rules/slos-and-alerting.md` — SLI/SLO discipline and symptom-based burn-rate paging.
- `rules/logging-content.md` — the levels test, boundary logging, and Effect runtime logging.
- `rules/telemetry-hygiene.md` — what must never be logged, allowlisting, redaction at source.
- `rules/architecture-placement.md` — where instrumentation lives in ports-and-adapters codebases.
- `rules/testing-telemetry.md` — testing instrumentation and alert rules.
- `references/node-patterns.md` — OpenTelemetry wiring for Node/TypeScript services.
- `references/slo-alerting.md` — SLI worksheet, burn-rate math, parameter tables, Prometheus shape, runbook template.
- `references/source-notes.md` — the rationale and original sources.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When a log-transport, CI-diagnosis, or
parity skill is not installed, apply the rules directly: structured records
on platform-captured process streams with recognized levels and ISO
timestamps; evidence-first diagnosis for pipeline failures; and explicit,
guarded documentation of every intentional environment difference.
