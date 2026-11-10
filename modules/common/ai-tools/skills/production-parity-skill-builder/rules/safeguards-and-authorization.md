---
title: Name Safeguards; Add Them Only When Authorized
impact: CRITICAL
impactDescription: Skill creation is not license to mutate the target app
tags: parity, safeguards, authorization
---

## Name Safeguards; Add Them Only When Authorized

**Impact: CRITICAL**

### Safeguard surfaces

The generated skill should name narrowly scoped checks the target app needs:

- config parity: schema validation for required env vars and production-only
  restrictions
- auth parity: tests for required IdP groups, roles, claims, redirect URIs,
  cookies, and session policies
- fixture parity: seeded users, tenants, feature flags, roles, plans, quotas,
  and data lifecycle states
- infra parity: parse or diff deployment manifests against local/preview
  manifests for security-relevant settings
- provider parity: contract tests or recorded fixtures for external APIs,
  webhooks, email, storage, queues, and payment providers
- runtime parity: pinned versions for language runtime, database, extensions,
  image tags, and build commands
- smoke parity: a preview/staging smoke test that proves the app starts with
  production-equivalent restrictions before merge

### Intentional differences

When a difference is intentional, require a named reason and compensating
guard. "Local is easier" is not enough. Every intentional divergence records:
surface, production behavior, non-production behavior, reason, risk,
compensating guard, owner, and review trigger. If any field is missing, the
divergence is not explicit enough.

### The authorization boundary

Implement those checks in app code, tests, configuration, fixtures, or
infrastructure only when the user explicitly asked for parity fixes or
authorizes the additional mutation after seeing the gap. A request to create
the reusable skill alone authorizes the skill artifact, not unrelated app or
infrastructure changes. Otherwise put the exact guard contract and recommended
location in the generated skill/output and leave the target app untouched.
