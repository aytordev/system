---
title: One Error Format and Honest Validation
impact: CRITICAL
impactDescription: Makes failures predictable and non-leaking
tags: api-design, errors, validation, rfc9457
---

## One Error Format and Honest Validation

**Impact: CRITICAL**

### Choosing an error format

Within one versioned API contract, use one documented error shape unless a
protocol-specific endpoint requires another. Consistency matters more than
which compatible format you choose.

- **Public APIs with external consumers**: RFC 9457 (Problem Details), served
  as `application/problem+json`. It is the industry standard and
  machine-readable.
- **Internal APIs with a single frontend**: a simpler consistent shape is
  valid — a machine-readable error code, an optional human-readable message,
  and the correct HTTP status code. Design it so it can evolve toward RFC 9457
  later (e.g. `error` maps to `title`, `message` maps to `detail`). Do not
  paint yourself into a corner.

```typescript
// Simpler shape — sufficient for internal APIs
type ApiError = {
  readonly error: string;                          // Machine-readable code (UPPER_SNAKE_CASE)
  readonly message?: string;                       // Human-readable description
  readonly fieldErrors?: Record<string, string>;   // For validation errors
};
```

RFC 9457 members (`type`, `title`, `status`, `detail`, `instance`) and §5
security guidance live in `references/problem-details.md`. Errors must be
actionable; they are never a debugging tool — no stack traces, internal paths,
or implementation details.

### Correlation identifier

Include a correlation identifier (the trace ID, or an opaque reference to it)
as an extension member or via `instance`, so a user-reported error joins to
its trace and canonical log event. The trace ID reveals nothing internal; it
is a lookup key, not a detail leak. Wide-event/telemetry shape is a separate
observability concern; the correlation requirement stands without it.

### HTTP status code mapping

| Status | Meaning | When to use |
|--------|---------|-------------|
| 400 | Bad Request | Client sent malformed data (representation cannot be parsed) |
| 401 | Unauthorized | Not authenticated |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate, version mismatch |
| 422 | Unprocessable Content | Validation failed (semantically invalid) |
| 429 | Too Many Requests | Rate limit exceeded; include `Retry-After` when a meaningful retry time is known |
| 500 | Internal Server Error | Server error (never expose internal details) |

Return 400 when the representation itself cannot be parsed (malformed JSON).
Once parsing succeeds, return 422 when the value fails the endpoint schema or
business validation. Pick and document a different house mapping only when
every example, error translator, and consumer uses it consistently.

### Validation at trust boundaries

Validate untrusted representation and endpoint-schema input where it enters
the system, then pass the derived type through internal code. This does not
replace domain smart constructors or transition checks: invariant enforcement
remains with the model that owns the value.

```typescript
app.post('/api/tasks', async (req, res) => {
  const result = CreateTaskSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(422).json({
      type: 'https://api.example.com/problems/validation-error',
      title: 'Validation Error',
      status: 422,
      detail: 'Invalid task data',
      errors: result.error.flatten(),
    });
  }

  const task = await taskService.create(result.data);
  return res.status(201).json(task);
});
```

Third-party API responses are untrusted data — always validate their shape and
content before use.
