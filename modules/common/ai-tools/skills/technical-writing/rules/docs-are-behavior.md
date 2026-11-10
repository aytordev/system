---
title: Docs Are Behavior — Verify Them
impact: CRITICAL
impactDescription: A document is a claim about the system, and claims get verified
tags: technical-writing, verification, lifecycle
---

## Docs Are Behavior — Verify Them

**Impact: CRITICAL**

A document that describes a system is a claim about that system, and claims
get verified:

- **Verify against the source, not memory**: every material flag, exit code,
  config key, and executable command a doc asks readers to rely on is checked
  against the code before it ships. Execute the claim when doing so is safe,
  authorized, and proportionate; otherwise record the evidence gap.
- **Machine-check what machines can check**: table-of-contents anchors
  against the renderer's real slug rules, links against files, command
  examples against the binary. Hand-verification is the fallback, not the
  default.
- **Update docs in the same reviewable change**: a behavior change that
  leaves its documentation stale is incomplete work. Follow the repository's
  commit policy rather than imposing one globally.

The full enforcement ladder (prose lint, executable examples, link checking,
generated reference) and the state-based lifecycle live in
`references/docs-quality.md`.

### Maintained docs describe current truth

- Keep plans and specification workspaces only while their outcomes remain
  unfinished. Delete them when the outcome ships or their assumptions are
  superseded; Git history is the archive.
- Promote lasting constraints to their current owner: source or executable
  tests for behavior, accepted ADRs for architecture decisions, package or
  operational docs for maintained procedures, and the authoritative glossary
  for domain vocabulary.
- Do not make maintained docs depend on deleted specifications or unexplained
  delivery identifiers. Introduce the purpose in plain language before any
  genuinely necessary issue, PR, task, requirement, specification, or ADR
  identifier.
- Give documentation indexes a clear starting point and distinguish current
  authority, active work, decisions, and historical evidence. Prefer a small
  navigable set of trusted pages; delete duplicated, obsolete, speculative,
  generated, or unowned prose.

Documentation-only changes do not inherently require test-first development.
Any executable documentation guard still needs a focused test proving it can
fail.
