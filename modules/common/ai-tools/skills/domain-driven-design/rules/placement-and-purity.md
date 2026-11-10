---
title: Place Code by Role, Prove Rules by Purity
impact: HIGH
impactDescription: Domain, application, presentation, or infrastructure
tags: ddd, placement, purity
---

## Place Code by Role, Prove Rules by Purity

**Impact: HIGH**

### The placement framework

The roles below are logical placement guidance; a codebase-structure skill
chooses their physical folders and packages.

| Question | If yes → |
|----------|----------|
| Does it enforce a business rule or compute a business value? | Domain policy (entity function, value object, or domain service) |
| Does it orchestrate domain operations without owning the rules? | Application policy / use case |
| Does it format, transform, or prepare data for display? | Presentation code; in hexagonal architecture, often at the driving edge |
| Does it talk to an external system (DB, API, file system)? | Infrastructure/integration code; in hexagonal architecture, a driven adapter implements an inside-owned port |
| Is it framework-specific glue (route handler, middleware)? | Framework entrypoint; in hexagonal architecture, a driving adapter |

### The purity test is necessary but not sufficient

A pure function that formats a date for display does not belong in domain
policy just because it's pure. The question is always: "Is this a business
rule?"

```typescript
// ❌ Pure but NOT domain — formats for human display
export const formatEventDate = (date: string | null) =>
  date ? format(parseISO(date), "MMMM d, yyyy") : undefined;
// → Belongs in presentation code; a hexagonal app may place it at the driving edge

// ✅ Pure AND domain — business rule that affects behavior
// The application supplies current time as data; domain code does not read a clock.
export const isPastEvent = (eventDate: Date | null, now: Date) =>
  eventDate ? eventDate.getTime() < now.getTime() : false;

// ✅ Pure AND domain — business calculation
export const calculateCommittedTotal = (items: readonly GiftItem[]) =>
  items.filter(i => i.status !== "idea").reduce((sum, i) => sum + i.pricePence, 0);
```

**Why placement matters:** domain-policy code typically has strict coverage
requirements and zero infrastructure imports. Putting code in the wrong role
creates unnecessary testing obligations and architectural violations.

### Port ownership follows the innermost consumer

When an architecture uses ports, ownership follows the innermost consumer that
needs the abstraction. Repository and gateway ports are normally
application-owned because use cases consume them. A port belongs in domain
only when the domain model itself genuinely consumes that abstraction.
"Inside-owned" does not mean "domain-owned."

Keep domain policy free of frameworks, transport and persistence types,
clocks, UUID generators, vendor SDKs, and UI concerns. Parse external input at
the edge; pass current time, identifiers, and other external facts into domain
functions as typed values. Application use cases coordinate those functions
and any required ports.

When a structure skill has been applied, enforce domain and any visible
hexagonal boundary mechanically with its package/import rules.

### Anti-patterns

- **Presentation logic in domain.** Display formatting does not belong in
  domain policy, even if pure.
- **Leaking domain logic.** Business logic in route handlers, database
  queries, or adapters; keep it in domain-policy modules under the selected
  physical shape.
- **Anemic domain model.** Entities are data bags with no behavior; all logic
  in "services". Fix: put behavior as pure functions next to the types they
  operate on.
