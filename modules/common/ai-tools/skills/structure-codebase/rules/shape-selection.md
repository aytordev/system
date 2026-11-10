---
title: Select the Smallest Honest Shape
impact: CRITICAL
impactDescription: Prevents template architecture the project has not earned
tags: structure-codebase, shapes, hexagon
---

## Select the Smallest Honest Shape

**Impact: CRITICAL**

### Core model

Read a well-structured codebase from broadest meaning to narrowest detail:

1. **Product or capability** — why the code exists and who owns it.
2. **Architectural boundary** — inside versus outside, but only when that
   boundary is real.
3. **Feature, domain concept, use case, workflow, or endpoint** — what changes
   together.
4. **Implementation detail** — framework, persistence, SDK, protocol, and
   small helpers.

Treat "screaming architecture" as a fitness question, not a folder taxonomy:
can a newcomer tell what the system does? Technical names such as `hexagon`,
`adapters`, `driving`, `driven`, and `composition` are useful at real seams.
They are harmful only when they replace product meaning or claim boundaries
that do not exist.

Folder names make claims. Packages, exports, imports, tests, and automated
boundary rules prove them.

### Keep the axes distinct

| Axis | It answers | Do not confuse it with |
|------|------------|------------------------|
| Capability | Why does this code exist and change? | A technical layer |
| Bounded context | Where does language and model authority change? | A noun, table, team label, or folder of convenience |
| Hexagon | What policy must remain independently testable from external technology? | DDD, a generic `core`, or every pure library |
| Feature/use case | What behavior changes together? | A required package or bounded context |
| Endpoint | Where does a BFF request enter? | The owner of shared workflow state |
| Package/module | What boundary can tooling enforce? | A business boundary by itself |
| Composition root | Where is the runtime object graph constructed and owned? | A mandatory folder in every library |

### Smallest honest shape by project signal

| Project signal | Primary shape |
|----------------|---------------|
| Tiny package or early prototype | Flat or nearly flat |
| Ordinary backend without ports/adapters | Feature or use-case first |
| DDD without hexagonal architecture | Bounded-context and domain-language first |
| Explicitly hexagonal backend | Capability, then visible inside/outside, then featureful interior |
| BFF or endpoint-heavy edge service | URL/resource-first endpoints plus sibling workflows and composition |
| Framework-constrained backend | Thin required entrypoints delegating to feature-oriented behavior |
| Small frontend | Framework-native routes and shallow colocation |
| Feature-rich frontend | Route/screen composition plus product-feature modules and named foundations |
| Meta-framework full-stack app | Framework route tree with explicit client/server module boundaries |
| Established coherent frontend | Preserve or evolve it according to the requested scope and evidence |
| Frontend monorepo or design system | App/product scope plus earned packages and enforced public APIs |
| Ops, migration, or automation package | Workflow or command first |
| Monorepo | Product/capability grouping plus real leaf package boundaries |

These shapes can combine. A monorepo is an enforcement overlay. A BFF is
often a driving host for other hexagons without being a hexagon itself. DDD
may exist with or without ports and adapters. Domain-driven-design guidance
(context discovery, aggregates, ubiquitous language) is a separate concern
from the physical tree built here.

### Test whether a hexagon is earned

Use a visible hexagon only when the project explicitly chooses ports and
adapters and the proposed boundary has:

- Meaningful application policy that must run without real external systems.
- At least one purposeful conversation with a driving or driven actor.
- Ports expressed in application language rather than cloned SDK APIs.
- A test interactor at each port, or a concrete plan to add one.
- Import, package, or architecture tests capable of enforcing inside versus
  outside.

Do not give adapter wrappers, provider integrations, simple CRUD, operational
scripts, or vocabulary-only packages ceremonial hexagons.
