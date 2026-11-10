---
title: Recognize the Violations and Run the Checklist
impact: HIGH
impactDescription: Catches boundary decay before it ships
tags: hexagonal-architecture, anti-patterns, checklist
---

## Recognize the Violations and Run the Checklist

**Impact: HIGH**

### Domain Depending on Infrastructure

The most common hex arch violation. Domain code imports from frameworks,
databases, or external services.

```typescript
// ❌ Domain imports Drizzle
import { eq } from 'drizzle-orm';
export const findActiveUsers = async (db) => db.select()...

// ❌ Same violation, type-only: the use case is shaped by the vendor's client and DTO
import type { OrdersApiClient, OrderDto } from './lib/orders-api';
export const sendReceipts = async (deps: { ordersApi: OrdersApiClient }, customerId: string) => ...

// ✅ Application defines the contract it consumes; adapter implements it
interface UserRepository {
  readonly findActive: () => Promise<readonly User[]>;
}
```

### Business Logic in Adapters

Route handlers or repositories contain business rules instead of delegating to
domain.

```typescript
// ❌ Business rule in route handler
export async function POST(request: Request) {
  const order = await orderRepo.findById(id);
  if (order.itemCount > 100) { await requireManagerApproval(order); } // business rule!
  ...
}

// ✅ Business rule in domain
const placeOrder = (order: Order): PlaceOrderResult => {
  if (order.itemCount > 100) return { success: false, reason: 'requires-approval' };
  ...
};
```

### Bypass Adapters

Route handler accesses the database directly instead of going through a port.

```typescript
// ❌ Route handler hits DB directly
export async function GET(request: Request) {
  const users = await db.select().from(users).where(eq(users.active, true));
  ...
}

// ✅ Route handler calls use case, which uses a port
const result = await getActiveUsers(userRepo);
```

### Port Proliferation

Creating a port for every tiny abstraction. Ports should represent meaningful
boundaries — one per aggregate (repositories) or per external capability
(payment, email, auth).

### Port for a Domain Concept

A driven port represents a conversation with an external system — a database, a
payment provider, a notification channel. Wrapping an internal domain abstraction
in a port interface adds indirection with no boundary to protect. If nothing
outside the hexagon will ever sit behind the interface, it is not a port.

### Nested Hexagons

Hexagons do not nest. The ports-and-adapters boundary belongs at the technology
(or team-authority) edge, where system-level tests are worth maintaining. Inner
hexagon boundaries duplicate that test wall; the inner tests decay, and the
boundary stops being real. Structure the inside with modules, bounded contexts,
or plain functions instead.

### Technology-Shaped Ports

Port methods that expose technology details. Port methods should use domain
language.

```typescript
// ❌ Technology leaks into port
interface UserRepository {
  readonly findBySqlQuery: (sql: string) => Promise<User[]>;
  readonly getFromRedisCache: (key: string) => Promise<User>;
}

// ✅ Business language
interface UserRepository {
  readonly findActive: () => Promise<readonly User[]>;
  readonly findById: (id: UserId) => Promise<User | undefined>;
}
```

### Pattern-Shaped Public Names

Names that advertise the architecture pattern instead of the business role make
code harder to read and easier to cargo-cult.

```typescript
// ❌ Names the pattern or type mechanism
interface IPaymentPort {
  readonly charge: (amount: Money, paymentInfo: PaymentInfo) => Promise<ChargeResult>;
}
const createPaymentGatewayImpl = (): IPaymentPort => ...
const placeOrderUseCase = async (...) => ...

// ✅ Names the role and the concrete adapter
interface PaymentGateway {
  readonly charge: (amount: Money, paymentInfo: PaymentInfo) => Promise<ChargeResult>;
}
const createStripePaymentGateway = (): PaymentGateway => ...
const placeOrder = async (...) => ...
```

### Checklist

**Required by the pattern:**

- [ ] No inside file (use case, domain, ports) imports — even `import type` — from a vendor package or the repo's SDK folder; a deps object made of SDK client types is not a set of ports (grep the use case's imports before finishing)
- [ ] All external boundaries use ports/public contracts — nothing outside reaches past a port
- [ ] Domain logic has zero framework/infrastructure dependencies (no source dependencies on any actor or adapter)
- [ ] Domain logic receives time, generated identifiers, and external facts as values rather than reading clocks, UUID libraries, or SDKs
- [ ] Driven actors are configurable at run time — the application never constructs them internally (the pattern leaves the configurator's shape open; parameter injection is this skill's house default)
- [ ] Ports use business language only; port methods never expose technology types
- [ ] Swapping any adapter requires zero domain code changes
- [ ] Every port has a test interactor — a test driver on the driving side, a fake on the driven side

**This skill's additions (house style):**

- [ ] If a physical hexagonal layout has been established, the visible inside/outside package or import rules are present and passing
- [ ] Driving adapters are thin — parse, authenticate, translate, delegate, respond; only a trivial executable-entrypoint exception also composes
- [ ] Driving adapters translate external input into typed application commands before invoking use cases
- [ ] Driven adapters (repos) implement ports, contain no business logic
- [ ] Ports live with their innermost consumer; use-case, repository, and gateway ports are normally application-owned, while domain owns only ports it genuinely consumes
- [ ] Public interfaces avoid `I` prefixes, `Interface` suffixes, `Port` suffixes, and `Impl` implementations
- [ ] Driving port and use case names use business capability language, not `UseCase`/`Handler` pattern names
- [ ] Wire schemas stay at trust boundaries; business-invariant validation stays inside without provider leakage
- [ ] Reads that JOIN across aggregates use query functions (CQRS-lite)
- [ ] Each layer has behavioral tests at the appropriate level
- [ ] Cross-cutting concerns (auth, technical telemetry, transactions) live in adapters; domain-significant observations go through an explicit driven port or domain events, never a raw logger import
- [ ] Domain returns result types for expected outcomes, never throws for business rules
