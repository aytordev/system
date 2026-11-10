---
name: domain-driven-design
description: "Trigger: a project that explicitly uses Domain-Driven Design and needs ubiquitous language, a glossary, value objects, entities, aggregates, domain events, domain services, bounded contexts, or error modeling in TypeScript. Requires an invariant-driven aggregate design, a repository-declared glossary as naming authority, always-valid entities, result types for expected outcomes, and behavioral tests named after domain concepts; do not apply it to simple CRUD or projects without domain modeling."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Domain-Driven Design (DDD)

This skill applies only to projects that have opted in to DDD. Do not apply
these patterns to projects that use a different approach. DDD and hexagonal
architecture (ports and adapters) are complementary but independent — a
project may use one without the other; ports-and-adapters placement is its own
opted-in concern.

Use a codebase-structure skill when designing or changing physical placement:
it keeps bounded context, feature/use-case cohesion, package enforcement, and
any opted-in inside/outside boundary as separate structural axes. If physical
restructuring is not requested, preserve the repo's existing layout while
keeping domain logic isolated.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The project has explicitly opted in to DDD and you are implementing
  ubiquitous language, value objects, entities, aggregates, domain events,
  domain services, bounded contexts, or error modeling.
- Naming needs a glossary decision, or code drifts from the glossary.
- Designing, splitting, or questioning an aggregate boundary.

Do not use it for simple CRUD, technical or infrastructure-focused projects,
or projects without a domain model.

## Hard Rules

1. **The code must speak the language of the domain.** The repository's
   declared glossary is the naming authority for each bounded context. Use the
   canonical spelling and capitalization in types, functions, variables, and
   tests — including when the request or ticket used a rejected alias. A
   concept absent from the glossary is not automatically approved or forbidden;
   it is not yet agreed.
2. **Aggregates are consistency boundaries, not containment hierarchies.** An
   aggregate exists to enforce invariants during state changes. If you cannot
   name the invariant, you probably do not need the aggregate. Reference other
   aggregates by ID; one aggregate root per transaction.
3. **Entities are always valid.** Validate on construction and on every state
   transition — never allow an entity to exist in an invalid state, even
   temporarily. Factory throws = invariant violation (a bug in calling code);
   schemas catch invalid user input at trust boundaries before the factory is
   called.
4. **Money in integer minor units**, never binary floating-point major units;
   decimal text at a boundary converts with the currency's exponent and an
   explicit excess-precision policy, never `Math.round(rawNumber * 100)`.
5. **Expected business outcomes are result types** (discriminated unions);
   exceptions are for programmer mistakes and infrastructure failures. Make
   illegal states unrepresentable: model lifecycles as discriminated unions
   and handle all variants exhaustively.
6. **Domain services are stateless pure decisions** over domain values and
   read-only policy facts; a domain service does not make multi-aggregate
   writes atomic — redraw the boundary, or coordinate one aggregate write plus
   a durable event in the application layer.
7. **Domain events earn their complexity.** Add them when side effects cross
   aggregate or context boundaries; start with explicit returns. Keep domain
   policy free of frameworks, transport and persistence types, clocks, UUID
   generators, vendor SDKs, and UI concerns — pass current time and external
   facts in as typed values.
8. **Purity is necessary but not sufficient.** A pure function that formats a
   date for display is presentation, not domain. The question is always: is
   this a business rule?

## Execution Steps

1. **CHECK APPLICABILITY** — confirm the project has opted in to DDD and the
   domain is genuinely complex.
2. **CONSULT THE GLOSSARY** — translate request vocabulary into canonical
   terms; treat absent terms as candidates requiring agreement
   (`rules/ubiquitous-language.md`).
3. **PLACE** — run the placement table (`rules/placement-and-purity.md`);
   domain policy enforces a business rule, application policy orchestrates,
   presentation formats, infrastructure talks to external systems.
4. **MODEL** — value objects, branded IDs, entities, aggregates by invariant
   (`rules/building-blocks.md`, `rules/aggregates.md`); cross-aggregate
   coordination through domain services or events
   (`rules/domain-services-and-events.md`).
5. **TEST BY DOMAIN CONCEPT** — behavior-named tests at the broadest stable
   boundary (`rules/testing-domain-models.md`); evolve the model as
   understanding deepens.

## Output Contract

A completed model change states: the glossary decisions made (canonical terms
adopted, aliases rejected, candidates deferred); the aggregates touched with
the invariants that justify their boundaries; the invariants enforced and
where; the result types introduced with their reasons; the events added or
explicitly refused; the placement of each new unit under the project's
selected structure; and behavior-named tests proving the rules, including the
exhaustive handling of lifecycle variants.

## References

- `rules/ubiquitous-language.md` — glossary authority, enforcement rules.
- `rules/placement-and-purity.md` — the placement table, the purity test,
  port ownership.
- `rules/building-blocks.md` — value objects, branded types, entities,
  discriminated unions, specifications, repositories.
- `rules/aggregates.md` — invariant-driven design, sizing, root rules,
  enforcement patterns, optimistic locking.
- `rules/domain-services-and-events.md` — domain service vs use case, the
  Decider pattern, dispatch mechanisms, process managers.
- `rules/testing-domain-models.md` — behavioral boundaries, fakes over mocks.
- `references/aggregate-design.md` — aggregate deep dive: invariants, sizing,
  split/combine, CQRS, concurrency.
- `references/bounded-contexts.md` — context mapping, ACLs, discovery signals.
- `references/domain-events.md` — Decider, outbox, process managers in depth.
- `references/testing-by-layer.md` — architecture-neutral test strategy.
- `references/provenance.md` — upstream source, revision, licence, and drops.

Companion skills are optional here. When a TypeScript type-pattern skill is
not installed, apply the general type-safety rules directly: parse, don't
assert, at trust boundaries; brand once through one validating factory; keep
`any` contained at unavoidable interop boundaries. A testing or TDD skill
supplies the house testing rules; until then, behavior through the selected
public boundary and factories over fixtures remain the standard. When a
refactoring skill is applied here, preserve behavior while the glossary and
types evolve together. An observability concern, when present, rides on the
domain-event publisher this skill may produce — it is never a reason to add
events.
