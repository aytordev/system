---
name: twelve-factor
description: "Trigger: configuring deploy-time environment, backing services, process startup/shutdown, logging, or operational parity for a software-as-a-service or long-running process application, or adopting Twelve-Factor App patterns incrementally in a brownfield service. Rules, anti-patterns, and code-level implications live per factor in rules, with Node/TypeScript implementation examples in references. Apply individual principles to frontends, serverless functions, and CLIs only where their runtime and platform make them relevant."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Twelve-Factor App Patterns

The original methodology targets software-as-a-service applications. Its
principles can inform other deployables, but port binding, concurrency, process
disposability, runtime config, and artifact parity do not map literally to
every frontend, serverless function, or CLI. Based on 12factor.net.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Deploy-time environment configuration, backing services, process
  startup/shutdown, logs, or operational parity is being configured, reviewed,
  or changed in a SaaS or long-running process application.
- A brownfield service is adopting the factors incrementally from observed
  risk.

Do not use it to force every factor onto every artifact: apply individual
principles to frontends, serverless functions, and CLIs only where their
runtime and platform make them relevant. Static sites, serverless handlers, and
platforms that intentionally own the server lifecycle follow their platform
contract instead.

## Hard Rules

1. **Deploy-varying configuration lives outside the build** and is validated at
   startup with a schema; the process fails fast with a clear error if config
   is invalid.
2. **A config change consolidates every environment read in the same change**
   and ships operator-facing documentation for every required setting —
   placeholder examples only, never a real credential, never a committed
   `.env`.
3. **Environment-name branching is deleted, not flagged.** Two deploys given
   identical settings must behave identically; remove every environment-name
   comparison in the files you touch, then say you did.
4. **In-memory session state and local filesystem state between requests are
   defects**, and an in-process scheduler duplicates jobs across replicas.
5. **Logs are structured event streams on the platform-captured process
   streams** — no file transports — and every request-scoped record carries a
   request or trace identifier.
6. **Shutdown is graceful**: handle termination signals, drain in-flight
   connections within a timeout, close backing-service connections, and exit
   non-zero on shutdown failure.
7. **Backing services are attached resources supplied at composition time**;
   domain code makes no distinction between local and third-party services, and
   equivalent providers are swappable by changing injected configuration.

## Execution Steps

1. **ASSESS** — for greenfield SaaS/process applications, assess all twelve
   factors and adopt the ones that fit the runtime and platform. For brownfield
   applications, adopt improvements incrementally from observed risk; a common
   starting order is config validation, structured process-stream logging,
   graceful shutdown, injected backing-service bindings, then migrating
   in-memory state to backing services.
2. **MAP THE FACTORS** — apply the factor rules from `rules/`:
   [`rules/config-and-build.md`](rules/config-and-build.md) (codebase, config,
   build/release/run), [`rules/dependencies-and-services.md`](rules/dependencies-and-services.md)
   (dependencies, backing services, dev/prod parity),
   [`rules/processes.md`](rules/processes.md) (stateless processes, port
   binding, concurrency, disposability, admin processes),
   [`rules/logs.md`](rules/logs.md) (logs as event streams).
3. **IMPLEMENT WITH INJECTION** — parse configuration in a testable function,
   inject it via options objects, and never read the environment deep in the
   call tree; Node/TypeScript examples live in
   [`references/node-patterns.md`](references/node-patterns.md).
4. **TEST THROUGH BEHAVIOR** — these patterns are testable without mocking
   global state: config validation throws on missing required settings and
   returns correct defaults, shutdown closes all injected connections, backing
   services are exercised through injected bindings, and handlers do not depend
   on prior request state.
5. **VERIFY THE CHANGE IS FINISHED** — a config, logging, or statelessness
   change covers every affected site the request never named: grep for
   remaining environment reads, unstructured or file-routed logs, and
   request-scoped records without identifiers before reporting done.

## Output Contract

Report the factors assessed, the ones adopted or violated with file-level
evidence, the anti-patterns found, and the checklist state for the factors in
scope. When a factor does not apply to the artifact's runtime or platform, say
so explicitly instead of silently skipping it. Unfixed drift you merely flagged
is not a finished change: fix it, then report it.

## Completion Check

- [ ] One owned codebase has many deploys; shared code has an explicit owner.
- [ ] Deploy-varying config is injected outside the build and validated at
      startup with a schema.
- [ ] An operator-facing example documents every required setting alongside the
      schema (placeholders only).
- [ ] Dependencies are explicitly declared in a manifest with a lockfile
      committed.
- [ ] Backing services are injected as platform-appropriate resource locators;
      equivalent providers are swappable at composition time.
- [ ] No in-memory session state, no local filesystem state between requests.
- [ ] Separate process types exist where work has distinct scaling or lifecycle
      needs.
- [ ] Termination-signal handlers with drain timeout; connections closed on
      shutdown.
- [ ] Platform-required health/readiness probes are implemented.
- [ ] Logs are structured on the platform-captured process streams, with every
      request-scoped record carrying a request or trace id.
- [ ] Long-running web services satisfy the platform's port-binding contract.
- [ ] Development and production backing services are parity-tested where
      differences matter.
- [ ] Admin scripts live in the repo and use the same config and dependencies.

## References

- [`rules/config-and-build.md`](rules/config-and-build.md) — Factors I, III, V.
- [`rules/dependencies-and-services.md`](rules/dependencies-and-services.md) — Factors II, IV, X.
- [`rules/processes.md`](rules/processes.md) — Factors VI, VII, VIII, IX, XII.
- [`rules/logs.md`](rules/logs.md) — Factor XI.
- [`references/node-patterns.md`](references/node-patterns.md) — Node/TypeScript implementation examples.
- [`references/provenance.md`](references/provenance.md) — upstream source, revision, and licence notice.

Companion skills are optional here. When a schema-first typing skill is not
installed, still validate configuration with a schema at trust boundaries. When
a behavior-testing skill is not installed, still test config validation,
shutdown, and backing-service bindings through behavior-driven tests with
injected doubles. When an observability skill is not installed, this skill
still owns log transport and shape; wide events, traces, SLOs, and alerting are
separate concerns.
