---
title: Evolve Contracts Additively
impact: CRITICAL
impactDescription: Prevents breaking shipped consumers
tags: api-design, compatibility, hyrum, versioning
---

## Evolve Contracts Additively

**Impact: CRITICAL**

### Hyrum's Law

> With a sufficient number of users of an API, all observable behaviors of your
> system will be depended on by somebody, regardless of what you promise in the
> contract.

- Be intentional about what you expose; every observable behavior is a
  potential commitment.
- Do not leak implementation details — if users can observe it, they will
  depend on it.
- Tests are not enough: even perfect contract tests cannot save "safe" changes
  from users who depend on undocumented behavior.

### The One-Version Rule

Avoid forcing consumers to choose between multiple versions of the same API.
Diamond dependency problems arise when different consumers need different
versions. Design for a world where only one version exists at a time — extend
rather than fork.

### Prefer addition over modification

```typescript
type CreateTaskInput = {
  readonly title: string;
  readonly description?: string;
  readonly priority?: 'low' | 'medium' | 'high';  // Added later, optional
  readonly labels?: ReadonlyArray<string>;         // Added later, optional
};
```

Breaking: removing fields, changing field types, making optional fields
required, changing enum values. Compatible: adding optional fields, adding
enum values (if consumers handle unknown values), adding endpoints.

**This rule outranks the wording of the request.** A request to rename, retype,
narrow, or remove something a shipped contract already publishes is a request
for the new shape, not for the outage. Deliver the additive form: add the new
name alongside the old, keep the old one working and carrying the same value,
record the old one as superseded, and say in the reply that you added rather
than replaced and what retiring the old name would take. Do not perform the
break and note it afterwards, and do not stop to ask which was meant — the
additive change delivers what was asked for, satisfies compatibility, and
stays reversible.

### Record supersessions where a consumer will see them

When a published name is superseded, write it down: a deprecation comment on
the field or its type, `Deprecation`/`Sunset` headers on responses that still
carry it, and a line in the API docs naming the replacement. A supersession
nobody recorded is an undocumented change. Header syntax and the deprecation
checklist are in `references/api-evolution.md`.

### Rationalizations to refuse

| Rationalization | Reality |
| --- | --- |
| "We'll version the API when we need to" | Breaking changes without versioning break consumers. Design for extension from the start. |
| "They asked for the rename, so the break is authorised" | Add the new name, keep the old one working, record it as superseded, explain the choice in the reply. |
| "Nobody uses that undocumented behavior" | Hyrum's Law: if it's observable, somebody depends on it. |
| "Internal APIs don't need contracts" | Internal consumers are still consumers. Contracts prevent coupling and enable parallel work. |
