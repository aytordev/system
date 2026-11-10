---
title: Test Instrumentation Like Behavior
impact: HIGH
impactDescription: Untested telemetry is the classic silent regression
tags: observability, testing, alerts
---

## Test Instrumentation Like Behavior

**Impact: HIGH**

Instrumentation is behavior: someone (an operator, a dashboard, an SLO)
depends on it, so it is test-driven like any behavior. Untested
instrumentation is the classic silent regression — nothing fails when a
refactor drops the one attribute an alert was built on. When a testing or TDD
workflow is installed, the failing test precedes the instrumentation it
demands; otherwise write the assertion first by hand and watch it fail.

### In-memory exporters

The OTel SDKs ship them — spans are captured in process memory where
assertions can inspect every span, attribute, and status without network
calls, flakiness, or an external backend: "this request emits one canonical
event containing `pledge.rejection_reason`", "this failure sets span status
to error". Use the synchronous processor in tests even though production
uses batching.

Use `SimpleSpanProcessor` in tests (synchronous export — no batching delay
to await) even though production uses the batching processor.

```typescript
// test/helpers/telemetry.ts
import { NodeTracerProvider, SimpleSpanProcessor, InMemorySpanExporter } from '@opentelemetry/sdk-trace-node';

export const createTestTelemetry = (): {
  readonly exporter: InMemorySpanExporter;
  readonly provider: NodeTracerProvider;
} => {
  const exporter = new InMemorySpanExporter();
  const provider = new NodeTracerProvider({
    spanProcessors: [new SimpleSpanProcessor(exporter)],
  });
  return { exporter, provider };
};
```

Assert through the public API — drive the handler, inspect the exported
spans. Do not spy on `span.setAttributes` calls; that tests HOW, not WHAT.

```typescript
it('records the rejection reason on the request span', async () => {
  const { exporter, provider } = createTestTelemetry();
  const handler = createPledgeHandler({ tracer: provider.getTracer('test'), ...fakePorts() });

  await handler(getMockPledgeRequest({ amount: tooMuch }));

  const spans = exporter.getFinishedSpans();
  expect(spans[0]?.attributes).toMatchObject({
    'pledge.rejection_reason': 'insufficient-balance',
  });
});
```

### The canonical event is a contract

Inject a recording logger and assert the emitted event's fields:

- exactly one canonical event per request — *including on failure*;
- the failure path carries the outcome fields (status, error type) — this is
  precisely the regression the one-exit rule in `rules/wide-events.md` pins.

```typescript
it('emits one canonical event per request, including on failure', async () => {
  const logger = createRecordingLogger();
  const app = createApp({ logger, ...fakePorts({ repoFails: true }) });

  await request(app).post('/pledges').send(validBody);

  const canonical = logger.records.filter((r) => r.message === 'canonical-log-line');
  expect(canonical).toHaveLength(1);
  expect(canonical[0]?.fields).toMatchObject({
    'http.response.status_code': 500,
    'error.type': 'RepositoryUnavailable',
  });
});
```

The "including on failure" case is the one that matters — the skipped
canonical event on the exception path is precisely the failure mode this
test pins.

### Telemetry ports get fakes

Where domain-significant observations flow through an explicit driven port (a
Domain Probe, see `rules/architecture-placement.md`), the port gets a
recording fake like every other driven port: accumulate observations, assert
on them through the public API. This keeps domain tests free of OTel imports
entirely; the probe's *adapter* — the code translating observations into
span attributes or metric increments — is tested separately with the
in-memory exporter, as adapter code.

### Alert rules are code

Where the stack allows (Prometheus rule unit tests, SLO-as-code tools), test
that the burn-rate expression fires on synthetic data. A broken alert fails
silently until the outage it was for.

### Mutation note and honest limits

An unasserted probe/telemetry call is a surviving-mutant farm — which is
itself the argument for asserting observations.

You cannot meaningfully unit-test sampling percentages, Collector pipelines,
or backend retention. Verify those in a staging environment with a real
Collector — and note that sampling config is itself a parity surface:
staging at 100% and prod at 1% behave differently under debugging. Document
every intentional difference with a compensating guard; a parity-method
companion skill covers the general drift workflow where installed.
