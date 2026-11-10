---
title: Logs as Event Streams
impact: CRITICAL
impactDescription: Factor XI — structured records on process streams with request correlation
tags: twelve-factor, logs, observability
---

## Logs as Event Streams

**Impact: CRITICAL**

Treat logs as event streams. Write structured records to the process streams
captured by the deployment platform; stdout is the normal application stream
and stderr may carry error records or diagnostics when the collector captures
both. Never route or store logs in files from within the app.

**A logging change is not finished until three things are true**, whatever the
request named: records are structured, they go to the process streams and
nowhere else, and every record written while serving a request carries that
request's identifier. The third is the one most often skipped — a structured
stdout log that cannot be filtered to one request still cannot be used during
an incident — so bind a per-request child logger at the entry to each handler
before you migrate its call sites, and check the handlers for the id before you
report the work done.

This factor owns log *transport and shape*. For what goes into the stream —
wide events / canonical log lines, traces, SLOs, alerting — apply the
repository's own observability contracts; that is a separate concern.

For internet-facing servers, RFC 6302 (BCP 162) specifies minimum logging
requirements: source and destination addresses and ports, timestamps
(preferably UTC), and transport protocol. These should be captured at the
server/framework level in addition to application-level structured logging.

### Semantic requirements

For long-running services, start from these properties and defer exact fields
to the repository's observability and platform contracts:

- **Structured output** — logs are machine-parseable (JSON preferred), not
  free-form strings.
- **Process streams only** — use the platform's documented stdout/stderr
  contract; the app never writes to log files or configures file transports.
- **Useful severity** — use the levels the platform recognises, rank them, and
  compare every record against a threshold before emitting it. The threshold
  comes from outside the logger: an option on the factory with a sensible
  default (so an existing zero-argument call site keeps working), or one
  deploy-time setting read where config is built and injected. A factory that
  takes nothing has hard-coded its threshold, and nobody can turn debug on for
  one deploy without shipping code.
- **Contextual data** — logs accept structured metadata (key-value pairs), not
  just message strings.
- **Timestamp included** — every log entry includes an ISO 8601 timestamp.
- **Request correlation** — every record emitted while serving a request
  carries a request or trace identifier. Take it from the inbound trace or
  request-id header when one arrives and generate one per request when none
  does; then give it to each log call for that request, usually by binding a
  per-request child logger at the entry to the handler and logging through
  that. "No id arrived" is not a reason to omit the field: an operator who
  cannot pull one request's lines out of an hour of them cannot use the logs at
  all. Prefer the platform's W3C trace context integration where it exists.

Projects may use any logging library as long as these semantics are met. If an
existing logger is missing levels or structured-data support, adapt it to meet
these requirements. An illustrative implementation lives in
`references/node-patterns.md`.

### Logging anti-patterns

```typescript
import fs from 'fs';
fs.appendFileSync('/var/log/app.log', message);

import winston from 'winston';
const logger = winston.createLogger({
  transports: [new winston.transports.File({ filename: 'error.log' })],
});

console.log(`User ${userId} logged in`);
```

**Why these are wrong:** File transports mean the app is routing its own logs.
Unstructured string interpolation produces logs that cannot be parsed or
queried. The execution environment (container orchestrator, PaaS) captures its
documented process streams and routes them to the appropriate destination.

### Field discipline

Extend log fields through an explicit reviewed allowlist. Do not accept
arbitrary objects, raw error messages/stacks, request bodies, headers, tokens,
or personal data; redact at source and keep detailed diagnostics behind
separately controlled tooling.
