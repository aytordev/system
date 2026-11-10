---
title: REST Conventions and Caching
impact: HIGH
impactDescription: Predictable shapes, naming, and freshness
tags: api-design, rest, pagination, caching
---

## REST Conventions and Caching

**Impact: HIGH**

### Resource naming

| Pattern | Convention | Example |
|---------|-----------|---------|
| Endpoints | Plural nouns, no verbs | `GET /api/tasks`, `POST /api/tasks` |
| Query params | camelCase | `?sortBy=createdAt&pageSize=20` |
| Response fields | camelCase | `{ createdAt, updatedAt, taskId }` |
| Boolean fields | is/has/can prefix | `isComplete`, `hasAttachments` |
| Enum values | UPPER_SNAKE | `"IN_PROGRESS"`, `"COMPLETED"` |
| Headers | No `X-` prefix (RFC 6648/BCP 178) | `Example-Request-Id` |

### Resource design

```
GET    /api/tasks              → List tasks (with query params for filtering)
POST   /api/tasks              → Create a task
GET    /api/tasks/:id          → Get a single task
PATCH  /api/tasks/:id          → Update a task (partial)
DELETE /api/tasks/:id          → Delete a task
GET    /api/tasks/:id/comments → List comments for a task (sub-resource)
```

Use PATCH for partial updates (only provided fields change). Use PUT only when
the client sends the complete object. Verbs in REST URLs
(`/api/createTask`) are a red flag.

### Pagination and filtering

Paginate list endpoints whose result can grow beyond a bounded, safe response.
Small closed enumerations may return the complete set when that bound is part
of the contract. Define pagination or another documented safe bound before
the result can grow beyond one response.

```typescript
type PaginatedResult<T> = {
  readonly data: ReadonlyArray<T>;
  readonly pagination: {
    readonly page: number;
    readonly pageSize: number;
    readonly totalItems: number;
    readonly totalPages: number;
  };
};
```

Use query parameters for filters:
`GET /api/tasks?status=in_progress&assignee=user123&createdAfter=2025-01-01`.

### Input/output separation

Separate what the caller provides from what the system returns: inputs carry
caller-provided data; outputs include server-generated fields (`id`,
timestamps, ownership).

```typescript
// Input: what the caller provides
type CreateTaskInput = {
  readonly title: string;
  readonly description?: string;
};

// Output: includes server-generated fields
type Task = {
  readonly id: TaskId;
  readonly title: string;
  readonly description: string | null;
  readonly createdAt: Date;
  readonly updatedAt: Date;
  readonly createdBy: UserId;
};
```

### HTTP caching

Assign explicit freshness lifetimes on responses. Don't rely on heuristic
freshness.

- Prefer `Cache-Control: max-age=N` over `Expires` — even short freshness
  (e.g. `max-age=5`) enables reuse across multiple clients.
- Assign ETags for efficient revalidation without re-transferring the body.
- If a request header changes the response, use `Vary` on ALL responses from
  that resource (including the default).
- Use `no-store` for responses containing sensitive data — `no-cache` does
  NOT mean "don't cache" (it means "stored but revalidate before use").

The full `Cache-Control` directive table, content negotiation, header design,
and protocol version independence are in `references/http-fundamentals.md`.
Browser-facing entry points apply the security headers their content and
deployment policy require (`X-Content-Type-Options`, `Content-Security-Policy`,
`Referrer-Policy`) — see `references/api-security.md`.
