---
title: Analyze the Environment Delta
impact: HIGH
impactDescription: Localizes the difference between local success and CI failure
tags: ci, reproduction, environment
---

## Analyze the Environment Delta

**Impact: HIGH**

Reproduce locally when a faithful environment is available, before pushing a
fix. Run the **exact** failing command, not a close equivalent. Match the CI
environment as closely as the machine allows: runtime version, environment
variables, dependency resolution.

If it passes locally, treat the environment delta as the evidence to localize.
The cause may still be timing, state, or an external dependency.

| Factor | Check |
| --- | --- |
| Runtime version | CI config versus the local runtime's version |
| OS | Linux CI versus a macOS local host |
| Dependency resolution | The repository's locked clean-install command versus a cached install directory |
| Environment variables | CI secrets and configuration versus the local `.env` |
| Parallelism | CI may shard or parallelize differently |
| Resources | CI runners often have less memory and CPU |
| Network | CI may block outbound network access |
| File system | Case sensitivity on Linux versus case-insensitive macOS |

### Turn the delta into a hypothesis

Each row names a cause you can test one at a time: pin the runtime, force the
locked install, inject the missing variable, disable parallelism, cap memory,
deny the network, or repeat the run on a case-sensitive path. Prefer the test
that reproduces the failure cheaply.

### When a faithful reproduction is impossible

Say so. Then gather the strongest available proxy — the run's environment
versions from its logs, the workflow's exact commands, and the failure's
determinism across attempts — and state what remains unverified.
