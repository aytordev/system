---
title: Build the Parity Map Before Generating
impact: CRITICAL
impactDescription: The map is the evidence base for the generated skill
tags: parity, mapping
---

## Build the Parity Map Before Generating

**Impact: CRITICAL**

Create a working parity map before writing the generated skill — and before
comparing emulator, local service, hosted sandbox, or testing-tool options.
For each surface, record:

- production truth source: file, manifest, doc, dashboard export, or user
  answer
- non-production representation: local, CI, PR/preview, staging
- drift risk: what user-visible or security behavior changes if this differs
- current guard: test, schema check, smoke test, contract test, policy check,
  or none
- fix pattern: emulate, seed, contract-test, validate config, parse infra, or
  document explicit divergence
- owner or escalation path when the repo cannot answer it

Use the catalog in `references/parity-surface-catalog.md` to choose surfaces
and checks. It is a checklist, not a claim that every app needs every
surface.

An unknown production truth source is a parity risk, not a blank to fill
with an assumption: record it, and raise it as a targeted question
(`rules/targeted-questions.md`).
