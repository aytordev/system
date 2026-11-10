---
title: Never Log Secrets or Personal Data
impact: CRITICAL
impactDescription: Operational-safety boundary for every telemetry signal
tags: observability, hygiene, pii, secrets
---

## Never Log Secrets or Personal Data

**Impact: CRITICAL**

Telemetry is a disclosure surface. Every rule below is a hard boundary; none
may be softened for convenience, debugging speed, or vendor defaults.

### What must never be logged

- **Never emit passwords, tokens, API keys, cookies, or session IDs into any
  signal** — logs, traces, metrics, events, error messages, URLs, analytics,
  or test fixtures.
- **Never serialize whole request, user, or config objects.** A JSON
  serializer will happily dump auth headers. **Allowlist named fields** —
  emit only fields you can name and justify.
- **Never put raw attacker-controlled values into metric labels** — IDs,
  paths, query strings, arbitrary headers, or body fields (see
  `rules/opentelemetry-baseline.md` for the cardinality side of the same
  rule).
- **Never make high-cardinality event suitability a permission to emit
  personal data.** Events welcome identifiers; privacy policy governs them.

### Personal data rules

- Emit personal identifiers only when a stated operational need and the
  applicable privacy policy permit it; minimize or pseudonymize them and
  apply appropriate retention, access, and deletion controls.
- In regulated environments, every log line containing PII becomes a
  compliance obligation (retention, access control, right-to-erasure). Treat
  adding one like adding a compliance liability, because it is.

### Redact at source

Redact in the application, at the emission boundary — the pipeline is a
second line of defense, not the first. A Collector redaction processor is a
net behind the app, never a substitute for an allowlist where the data
originates.

### Test the boundary

Redaction rules are behavior with a compliance stake; test them:

```typescript
it('never emits the authorization header into telemetry', async () => {
  const logger = createRecordingLogger();
  const app = createApp({ logger, ...fakePorts() });

  await request(app).post('/pledges').set('Authorization', 'Bearer secret-token').send(validBody);

  const serialized = JSON.stringify(logger.records);
  expect(serialized).not.toContain('secret-token');
});
```

Crude, and deliberately so — a substring sweep over everything emitted
catches the leak no matter which field it rode in on. Never write a test that
asserts a token appears in a URL, a response body, or a log; an existing
assertion of that shape pins a leak, not a behavior.
