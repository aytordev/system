---
title: Ports Are Public Contracts Named in Business Language
impact: CRITICAL
impactDescription: Keeps the boundary purposeful and swap-safe
tags: hexagonal-architecture, ports, naming
---

## Ports Are Public Contracts Named in Business Language

**Impact: CRITICAL**

A port is a named, purposeful conversation at the inside/outside boundary. In
TypeScript, represent ports as explicit `interface` types when the boundary is
public or architectural: driving adapters call driving port interfaces, and
driven adapters/fakes implement driven port interfaces.

A port is owned by the innermost consumer that needs the abstraction. Driving
ports are application-owned because they expose application use cases.
Infrastructure-facing repository and gateway ports are also normally
application-owned because use cases consume them. A port belongs in domain only
when the domain model itself genuinely owns and consumes that conversation.
Preserve dependency inversion without conflating **inside-owned** with
**domain-owned**.

Use case implementations satisfy the driving port. The driving adapter should
depend on the port's role-shaped interface, not a framework-specific controller,
handler class, or concrete adapter.

### Naming Ports and Public Interfaces

Name every port from the application's point of view, using the domain language
of the conversation. The source pattern names *every* port — driving and driven —
for the intention of the conversation: `ForPlacingOrders`, `ForGettingTaxRates`,
`ForStoringTickets`. The pattern legislates no naming at all, though. This skill
keeps intention names for driving ports and uses role nouns (`OrderRepository`,
`PaymentGateway`) for driven ports as a deliberate house choice: both styles are
purpose names, never technology names. A codebase already using `For...` names on
the driven side is following the source convention — leave it be.

| Boundary | Good names | Avoid | Why |
|----------|------------|-------|-----|
| Driving/public API | `ForPlacingOrders`, `ForPledgingToOccasions` | `PlaceOrderUseCase`, `PlaceOrderHandler`, `OrderInputPort` | Names the actor capability, not the pattern |
| Aggregate persistence | `OrderRepository`, `ContributorRepository` (or `ForStoringOrders`) | `OrderDatabase`, `OrderDao`, `SqlOrderPort` | Names aggregate access needed by the use case |
| External service | `PaymentGateway`, `ExchangeRateProvider` (or `ForPaying`, `ForObtainingRates`) | `StripeClient`, `HttpPaymentPort` | Names the capability the app needs, not the vendor/protocol |
| Notifications/events | `OrderEventPublisher`, `ReceiptSender` (or `ForNotifyingContributors`) | `SnsAdapter`, `MessageBusPort` | Names the business-side interaction |

**Public interface naming rules:**

- Use `interface` for behavior contracts, not data shapes that are better modeled
  as `type`/schemas.
- Do not prefix interfaces with `I` or suffix them with `Interface`; name the
  role (`PaymentGateway`, not `IPaymentGateway` or `PaymentGatewayInterface`).
- Avoid `Port` in type names. A name like `PaymentPort` says "architecture"
  instead of "conversation."
- Avoid `Impl` in implementation names. Name the concrete technology or strategy:
  `createStripePaymentGateway`, `createFakePaymentGateway`,
  `createDrizzleOrderRepository`.
- Prefer role interfaces over header interfaces: include only the methods the use
  case needs, not every method an adapter happens to expose.
- Make names stable under adapter swaps. If moving from Stripe to PayPal, SQL to
  DynamoDB, or HTTP to a queue forces a port rename, the port name leaked
  infrastructure.

```typescript
// Driving port — exposed by the application, called by driving adapters
interface ForPlacingOrders {
  readonly placeOrder: (command: PlaceOrderCommand) => Promise<PlaceOrderResult>;
}

// Driven port — application-owned because the use case consumes it
interface UserRepository {
  readonly findById: (id: UserId) => Promise<User | undefined>;
  readonly save: (user: User) => Promise<void>;
}

type PreparePaymentResult =
  | { readonly success: true; readonly paymentId: PaymentId }
  | { readonly success: false; readonly reason: PaymentFailure };

// Driven port — application-owned because the use case consumes it
interface PaymentGateway {
  readonly preparePayment: (request: {
    readonly amount: Money;
    readonly reference: OrderId;
    readonly idempotencyKey: OrderId;
  }) => Promise<PreparePaymentResult>;
  readonly completePayment: (request: {
    readonly paymentId: PaymentId;
    readonly paymentInfo: PaymentInfo;
  }) => Promise<PaymentOutcome>;
}

// Driven port — event publishing (outbound to message brokers)
interface OrderEventPublisher {
  readonly publish: (event: OrderEvent) => Promise<void>;
}
```

**Port design principles:**

- Name ports by business purpose, not technology (`UserRepository`, not
  `DatabasePort`)
- Keep ports focused — one per aggregate or capability, not one god port
- Port methods use domain types, never infrastructure types (no `SqlRow`, no
  `HttpResponse`) and never a vendor SDK's DTO or message type (`OrderDto`,
  `PushMessage` from the SDK are infrastructure — declare your own
  `Order`/`Receipt` inside and map in the adapter)
- Creation param schemas co-locate with the repository port they describe
