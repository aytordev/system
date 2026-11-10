---
name: hexagonal-architecture
description: "Trigger: a project has explicitly opted in to hexagonal (ports and adapters) architecture — a README, CLAUDE.md, or ADR that says so is the opt-in — and work touches it: a new feature, a transport or SDK swap, a bug fix, or a small business-rule change to a function that still calls an SDK directly. Implements TypeScript ports, driving/driven adapters, dependency inversion, and domain isolation. Do not infer hexagonal architecture from a generic adapter, interface, test seam, or isolation request in a project that has not opted in."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Hexagonal Architecture (Ports & Adapters)

This skill applies only to projects that have opted in to hexagonal architecture.
Do not apply these patterns to projects that use a different architecture. Once a
project has opted in, load this for every code change in it, not only
architecture work, and load it alongside a failing-test-first workflow, never
instead of it. For introducing hex arch into an existing codebase incrementally,
see `references/incremental-adoption.md`.

`rules/` and `references/` are bundled with this skill. Repository paths refer to
the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The project has explicitly opted in via a README, CLAUDE.md, or ADR, and any
  code change is requested in it.
- Introducing hex arch incrementally into an existing codebase.
- Starting a hex project from scratch.
- Reviewing whether a change respects the inside/outside boundary.

Do not use it to infer ports from a generic adapter, interface, or test seam in a
project that has not opted in.

## Before You Write Code

Read this section as instructions; the rest of the skill explains why. The full
version with every ordering rule is `rules/before-you-write-code.md`.

**A third-party SDK's client type is never a port.** Anything exported by a
vendor package or the repo's SDK folder is outside the hexagon, and so is every
file that imports it — including with `import type` and including the SDK's DTO
types. A deps object whose fields are SDK client types has no ports.

**Adding a feature**: put the business rule in a pure inside function that takes
domain types and `now` as values; declare driven ports as role nouns
(`OrderRepository`, `PaymentGateway`) and the driving port as `For<Verb>ing<Noun>`
(`ForPlacingOrders`); write one adapter per driven port plus a thin driving
adapter; wire SDK client → adapter → use case in the composition root only; test
the use case through its driving port with hand-written in-memory fakes.

**Changing a use case that still imports an SDK directly**: in an opted-in repo,
porting every SDK dependency of a file you touch is part of the change, not scope
creep — a behaviour-preserving refactor step taken with the existing tests green
before the red for the new behaviour. Extract *all* of its SDK dependencies, not
just the one the request names; before you finish, read the use case's imports
and extract any that still name the SDK folder.

**Use-case tests use fakes, not mocks**: no `vi.fn`, `vi.mock`, or `vi.spyOn`,
and no import from the SDK folder; a recording fake (`sent: readonly Receipt[]`)
is how you observe a notifier or mailer.

## Hard Rules

1. **Dependencies point inward.** Domain code depends on no framework, transport,
   persistence, clock, UUID generator, vendor SDK, or UI concern; supply time,
   identifiers, and external facts as typed inputs. Adapters import inside
   public contracts, never the reverse.
2. **A port is owned by its innermost consumer** and named from the application's
   point of view in business language — never technology names, no `I` prefix,
   no `Interface`/`Port` suffix, no `Impl` implementations.
3. **Port methods use domain types**, never infrastructure types or a vendor
   SDK's DTO or message types; the adapter maps.
4. **If swapping an adapter requires changing domain code, the boundary is
   wrong.**
5. **Driving adapters stay thin** — parse, authenticate, translate, delegate,
   respond; only a trivial executable-entrypoint exception may also compose the
   object graph inline.
6. **A port is only real if it is tested.** Every port needs a test interactor: a
   test driver at each driving port, a fake at each driven port.
7. **The domain never imports a logger, catches HTTP errors, or manages
   transactions.** It returns results; business-significant intermediate facts go
   through an explicit driven port (Domain Probe) or domain events.
8. **Expected outcomes are result types**, never thrown business rules;
   unexpected infrastructure failures propagate to a top-level handler.

## Execution Steps

1. **GATE** — confirm the opt-in; without it, stop.
2. **ORDER** — pick the route: new feature, legacy use case still importing the
   SDK, incremental adoption (`references/incremental-adoption.md`), or
   greenfield sequence (`references/greenfield-sequence.md`).
3. **INSIDE** — declare ports beside their consumer, keep business rules pure,
   and make the use case take ports and `now` as parameters
   (`rules/ports-and-naming.md`).
4. **OUTSIDE** — write translation-only adapters and a thin driving adapter;
   wire in the composition root (`rules/adapters-and-wiring.md`).
5. **VERIFY** — use-case tests with fakes at the primary boundary, adapter
   integration tests second, E2E last (`rules/testing-boundaries.md`,
   `references/testing-hex-arch.md`).
6. **SWEEP** — read the use case's imports: any remaining SDK folder or SDK
   client type means the porting step is not done.

## Output Contract

Present the change with its boundary evidence: which ports were declared or
touched, which adapters were written or reused, where the wiring landed, and the
tests that prove each boundary (use-case tests on fakes, adapter tests, E2E where
applicable). When a request said "just do it where the SDK call is", state the
one-sentence reason the rule still went inside. Close with the checklist results
from `rules/anti-patterns.md`.

## References

- `rules/before-you-write-code.md` — the SDK-is-never-a-port rule, feature order, legacy porting, file placement, fakes in tests.
- `rules/ports-and-naming.md` — port ownership, naming tables, design principles.
- `rules/adapters-and-wiring.md` — adapter translation, dependency injection, composition root, configurator.
- `rules/testing-boundaries.md` — test priority table, fakes over mocks, swappability test.
- `rules/anti-patterns.md` — violations with examples and the full checklist.
- `references/worked-example.md` — one feature traced through every layer with tests and a file map.
- `references/testing-hex-arch.md` — test patterns, fake-probe, `createTestDb`.
- `references/cqrs-lite.md` — reads that JOIN across aggregates.
- `references/cross-cutting-concerns.md` — auth, logging tiers, transactions, error formatting.
- `references/incremental-adoption.md` — strangler-fig extraction steps.
- `references/greenfield-sequence.md` — the first honest boundary and four wirings.
- `references/sources.md` — source rationale, especially port naming.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. When they are not installed, apply the rules
directly: domain modelling (entities, value objects, aggregates, ubiquitous
language) follows the domain-driven-design companion's subject — hex arch
provides structural isolation, domain modelling provides what lives in the
center; a project may use one without the other. Physical source-tree design is
the structure-codebase companion's subject; keep the repo's existing layout for
the inside when restructuring is not requested. The minimum enabling point for
characterizing hard-coupled legacy behaviour is the finding-seams companion's
subject. Reads that become event-sourced (events as the write model, projections
as read models) are the event-sourcing companion's subject. For what goes into
telemetry content (wide events, SLOs, alerting), see the observability
companion; this skill owns where the code lives.
