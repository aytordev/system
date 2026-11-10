---
title: Colocate Change and Own Composition
impact: HIGH
impactDescription: Keeps cohesion, sharing, and wiring honest
tags: structure-codebase, cohesion, composition
---

## Colocate Change and Own Composition

**Impact: HIGH**

### Cohesion and sharing

- Keep files that change together close, including focused tests, schemas,
  fixtures, and mappers owned by one slice.
- Expose a small explicit public API from every package or cross-feature
  module.
- Prevent sibling features from importing one another's internals.
- Promote code only when more than one current owner needs it and the promoted
  capability has a stable, purpose-specific name.
- Give reused concepts purpose-named owners such as `monetary-values`,
  `runtime-clock`, or `order-event-contracts`; do not hide ownership under
  root `shared`, `common`, `utils`, `helpers`, or `services` buckets.
- Split a folder when navigation or change cohesion improves; split a package
  when a dependency, ownership, release, or trust boundary needs mechanical
  enforcement.

### Composition roots

Only executable applications have composition roots. Keep concrete selection
near the entry point and nowhere else.

- Use `composition/` when a host has a nontrivial graph, configuration
  families, owned resources, or lifecycle/shutdown behavior.
- Let `main.ts`, a framework startup file, or a small factory serve the role
  inline when the graph is trivial.
- Do not make libraries, bounded contexts, or every feature contain an empty
  `composition/` folder.
- Do not let ordinary endpoints, use cases, or adapters construct their
  concrete collaborators. When a serverless framework makes a handler or
  consumer the executable deployment entrypoint, that entrypoint may also host
  trivial inline composition; keep wiring visibly separate from translation
  and extract it as soon as the graph is shared, stateful, or nontrivial.

### DDD placement

Let bounded contexts define language and model authority; let the hexagon
define the technology test wall. One does not imply the other.

- Use a separate context only when terminology, invariants, lifecycle,
  ownership, or integration contracts diverge.
- Keep domain concepts as nouns and use cases/workflows as verbs.
- Communicate across contexts through explicit contracts, events, or
  anti-corruption layers.
- Keep any shared kernel minimal, stable, and assigned to one explicit owner;
  never use a repository-root catch-all.
- Keep a concept as a feature module inside an existing context when the
  context evidence is weak.

Aggregate, entity, value-object, event, and ubiquitous-language modeling rules
are a domain-modelling concern, not additional folder rules here.

### Visible hexagonal backend grammar (summary)

For an opted-in monorepo capability, prefer:

```text
<capability>/                       # grouping directory, not a package
├── hexagon/                        # unmistakable INSIDE
│   └── <inside-package>/           # real workspace package
│       └── src/
│           └── <feature-or-use-case>/
├── adapters/                       # unmistakable OUTSIDE
│   ├── driving/
│   │   └── <transport-adapter>/    # real workspace package
│   └── driven/
│       └── <provider-adapter>/     # real workspace package
└── testing/                        # outside test interactors
    └── <fake-or-contract-suite>/   # real workspace package when reusable
```

Apply these semantics:

- Put pure business rules in domain modules; put provider-free application
  policy and orchestration in the hexagon even when it calls injected ports.
- Put each port with the innermost consumer that owns the conversation.
  Driving ports and infrastructure-facing repository/gateway ports are
  normally application-owned; domain owns a port only when the domain model
  itself consumes it.
- Put every concrete transport, database, filesystem, queue, clock, UUID
  generator, cloud service, and provider SDK outside.
- Put reusable fakes, test drivers, and behavioral adapter contracts under
  `testing/`, never inside the production hexagon. Keep ordinary behavior
  tests colocated with the code they verify.
- Put concrete construction, configuration, resource ownership, and shutdown
  in the executable host's composition root.
- Organize inside packages by feature, domain concept, or use case. Do not
  replace one flat god file with a flat layer folder.
- Keep domain and application as separate packages only when that dependency
  boundary earns its cost. One cohesive inside package is valid.
- In a single-package service, keep capability first (for example,
  `src/ordering/hexagon/` beside `src/ordering/adapters/`) and protect it with
  path-based import or architecture tests. Do not replace a repository-wide
  package boundary with root technical buckets such as `src/hexagon/` and
  `src/adapters/`.

Full package-level targets, port naming, and earned exceptions live in
`references/visible-hexagon.md`.

### Frontend structure is a first-class mode

Read `references/frontend-patterns.md` and classify route ownership,
product-feature cohesion, UI reuse level, state/data ownership, runtime
boundaries, and package ownership before choosing a tree. Preserve an
established frontend only when the requested scope or evidence supports
preservation. Do not project backend `hexagon/`, ports, adapters, DDD
entities, or composition-root vocabulary onto client code unless the frontend
explicitly adopts those patterns for a real boundary. In a full-stack
repository, classify client and server modules independently and enforce the
framework's client/server graph.

When the frontend uses statecharts, state/data ownership includes **which
layer owns machines and actors**. Declare it explicitly and enforce it the
same way as any other import rule: an agent producing an otherwise correct
machine in a forbidden layer is a routine failure, and one to catch in a
boundary test rather than in CI. Any statechart library defers to what this
skill and the repository declare.
