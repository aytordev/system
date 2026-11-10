---
title: Inspect Before Asking
impact: CRITICAL
impactDescription: Never ask the user to explain what files can answer
tags: parity, inspection, evidence
---

## Inspect Before Asking

**Impact: CRITICAL**

First build evidence from the repository. Do not ask the user to explain what
can be discovered from files.

Inspect, as applicable:

- docs: `README*`, `docs/`, ADRs, runbooks, onboarding, local setup,
  deployment notes
- app code: config loading, auth/authz, tenancy, feature flags, service
  clients, scheduled jobs, webhooks
- tests: unit, integration, E2E, smoke, contract, auth fixtures, seed data,
  factories
- local setup: Dockerfile, compose files, devcontainers, scripts, seeders,
  Makefiles, package scripts
- CI and previews: GitHub Actions, GitLab CI, Buildkite, preview deployment
  config, test matrices
- infra: Terraform, Pulumi, CDK, Helm, Kustomize, Kubernetes manifests,
  Cloudflare/Vercel/Netlify/Fly/Render config
- production descriptors: env schemas, secret names, IdP/OIDC/SAML settings,
  ingress, network policy, runtime versions, database extensions, queues,
  object storage, cron, external provider config

Use `rg --files` and targeted `rg` searches. Search for environment names and
parity-sensitive terms:

```text
prod|production|staging|preview|pr|local|dev|ci|docker|compose|k8s|helm|terraform|pulumi|auth|oidc|saml|jwt|group|role|claim|permission|feature flag|secret|env|webhook|cron|queue|seed|fixture|migration
```

Use the parity surface catalog in
`references/parity-surface-catalog.md` as a checklist, not as a claim that
every app needs every surface.
