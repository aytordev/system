---
title: Stateless Processes, Concurrency, Disposability, Admin
impact: CRITICAL
impactDescription: Factors VI, VII, VIII, IX, and XII govern process lifecycle
tags: twelve-factor, processes, disposability
---

## Stateless Processes, Concurrency, Disposability, Admin

**Impact: CRITICAL**

### Stateless Processes (Factor VI)

Execute the app as stateless, share-nothing processes. Any data that must
persist lives in a backing service.

**Stateless anti-patterns:**

```typescript
const sessions = new Map<string, UserSession>();

app.post('/upload', (req, res) => {
  fs.writeFileSync(`/tmp/uploads/${req.file.name}`, req.file.data);
});

let requestCount = 0;
app.use(() => { requestCount++; });

setInterval(() => sendReport(), 60_000);
```

**Why these are wrong:** In-memory state is lost on restart and invisible to
other process instances. Local filesystem state cannot be shared across
processes. An in-process scheduler runs once in every replica, causing
duplicate jobs unless a separate coordination mechanism intervenes. Use backing
services (Redis, S3, database) and an external scheduler or explicit
distributed coordination instead.

### Port Binding (Factor VII)

The app is self-contained and exports its service by binding to a port:

```typescript
const server = app.listen(config.PORT, () => {
  logger.info('Server started', { port: config.PORT });
});
```

This factor applies to long-running web services. Static sites, serverless
handlers, and platforms that intentionally own the server lifecycle follow
their platform contract instead.

### Concurrency (Factor VIII)

Scale out via the process model. Design the app so work can be divided across
process types.

- Separate entry points for each process type (web, worker, scheduler).
- Move durable or long-running background work to an appropriate worker/queue;
  keep small request-owned work inline when that is simpler and meets
  latency/retry requirements.
- Each process type scales independently.
- Declare process types in the platform's existing configuration (a
  `Procfile`-style declaration is one example):

```text
web: node dist/web.js
worker: node dist/worker.js
```

### Disposability (Factor IX)

Maximize robustness with fast startup and graceful shutdown.

- Handle SIGTERM and SIGINT for graceful shutdown.
- Set a drain timeout — force exit if shutdown hangs.
- Await `server.close()` to drain in-flight connections.
- Close database pools, Redis connections, queue consumers.
- Exit with non-zero code on shutdown failure.
- Keep startup fast without moving unsafe initialization failures into the
  first live request.
- Design background jobs to be reentrant/idempotent so interrupted work can be
  safely retried.
- Provide the health/readiness mechanism expected by the deployment platform
  when it uses probes.

### Admin Processes (Factor XII)

Run admin tasks (migrations, data fixes, console sessions) as one-off processes
using the same codebase and config. Admin scripts live in the repo alongside
application code (e.g. `scripts/migrate.ts`). They are not separate tools or
ad-hoc shell commands. Admin processes run in an identical environment to the
app — same release, same config, same dependencies.
