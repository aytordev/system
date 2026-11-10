---
title: Adapters Translate and the Composition Root Wires
impact: CRITICAL
impactDescription: Keeps business logic out of edges and construction in one place
tags: hexagonal-architecture, adapters, wiring, di
---

## Adapters Translate and the Composition Root Wires

**Impact: CRITICAL**

Adapters implement ports for specific technologies. A good adapter is simple — it
translates between the port's domain types and the technology's native types. No
business logic.

```typescript
// Driven adapter — implements the repository port using Drizzle/D1
const createDrizzleUserRepository = (db: D1Database): UserRepository => ({
  findById: async (id) => {
    const row = await db.select().from(users).where(eq(users.id, id)).get();
    return row ? toUser(row) : undefined;
  },
  save: async (user) => {
    await db.insert(users).values(toRow(user)).onConflictDoUpdate({ ... });
  },
});

// Driven adapter — implements the same port for tests
const createFakeUserRepository = (initial: readonly User[] = []): UserRepository => {
  const store = new Map(initial.map(u => [u.id, u]));
  return {
    findById: async (id) => store.get(id),
    save: async (user) => { store.set(user.id, user); },
  };
};
```

**Adapter error handling:** Translate expected compare-and-save or uniqueness
outcomes into explicit application-port results. Unexpected infrastructure
failures (connection loss, timeout, disk failure) propagate to a top-level
handler. The domain never catches infrastructure errors because it does not know
infrastructure exists.

```typescript
type CreateUserResult =
  | { readonly success: true }
  | { readonly success: false; readonly reason: 'already-exists' };

// Driven adapter: translate an expected storage condition into port vocabulary
const createDrizzleUserCreator = (db: Database) => ({
  create: async (user: User): Promise<CreateUserResult> => {
    try {
      await db.insert(users).values(toRow(user));
      return { success: true };
    } catch (e) {
      if (isUniqueConstraintError(e)) {
        return { success: false, reason: 'already-exists' };
      }
      throw e; // unexpected errors (connection lost, disk full) propagate
    }
  },
});
```

The use case handles `already-exists` exhaustively. Unexpected infrastructure
errors propagate to the top-level handler.

**Key principle:** If swapping an adapter requires changing domain code, the
boundary is wrong.

### Dependency Injection and the Configurator

Inject all dependencies via function parameters. No DI container needed. The
driving adapter gathers impure dependencies, passes them to the use case, and
acts on the result — Seemann's "impureim sandwich" (impure/pure/impure). The use
case implementation is identifiable by its dependencies: it takes driven ports as
parameters; domain functions take only domain types.

```typescript
// WRONG — creates dependencies internally (untestable, tightly coupled)
const createOrder = async (order: NewOrder) => {
  const repo = new DrizzleOrderRepo(getDb());          // hardcoded
  const gateway = new StripeGateway(process.env.KEY);   // hardcoded
  // ...
};

// RIGHT — dependencies injected into a use case implementation
const createOrderPlacement = (
  repo: OrderRepository,
  gateway: PaymentGateway,
): ForPlacingOrders => ({
  placeOrder: async (order) => { /* orchestration against ports */ },
});
```

**Composition root:** Wiring happens at the application entry point — where
adapters are created from environment/config and injected into use cases. This is
the only place that knows about concrete implementations.

```typescript
// Serverless executable entrypoint = inline composition + driving adapter
// Valid only while this object graph remains trivial and unshared.
export async function POST(request: Request) {
  const { env } = getCloudflareContext();
  const db = createDb(env.DB);

  // Wire adapters
  const repo = createDrizzleOrderRepository(db);
  const gateway = createStripeGateway(env.STRIPE_KEY);
  const orderPlacement: ForPlacingOrders = createOrderPlacement(repo, gateway);

  // Translate transport syntax separately from request-schema validation.
  let rawBody: unknown;
  try {
    rawBody = await request.json();
  } catch {
    return NextResponse.json({ error: 'malformed-json' }, { status: 400 });
  }
  const parsedBody = CreateOrderSchema.safeParse(rawBody);
  if (!parsedBody.success) {
    return NextResponse.json({ error: 'invalid-body' }, { status: 422 });
  }

  // Call use case
  const result = await orderPlacement.placeOrder(parsedBody.data);
  return NextResponse.json(result);
}
```

This handler may combine two roles only because the framework makes it the
executable deployment entrypoint and the graph is trivial. Keep the inline wiring
visually distinct from request translation. At an HTTP boundary, malformed JSON
is a transport-syntax failure (`400`); syntactically valid input that fails the
body or path schema is an unprocessable request (`422`). Keep the JSON
`try`/`catch` narrow so it cannot turn application or infrastructure failures
into client errors. In a shared or nontrivial host, construct the graph once in
`main.ts` or `composition/` and give the route a prepared `ForPlacingOrders`; an
ordinary route module never selects implementations. No business logic belongs in
either role.

**The configurator:** whatever code knows all the players and introduces them —
the composition root here — is the pattern's fifth element. Constructor injection
(this skill's default) is one of three sanctioned shapes: a setter or
`ForConfiguring...` function allows driven adapters to be swapped while the
system runs (hazard: an app constructed but never configured), and dependency
lookup hands the application a broker it asks at call time. In tests, the test
case itself plays configurator and driving actor at once; in production, the
composition root does.

**Non-HTTP executable entrypoints** follow the same boundary. A queue callback
that is itself the deployment entrypoint may compose a trivial graph inline; an
ordinary consumer receives a prepared driving port and only parses, delegates,
and translates:

```typescript
// Queue deployment entrypoint = inline composition + driving adapter
const handlePledgeMessage = async (message: SQSMessage, env: Env) => {
  const db = createDb(env.DB);
  const occasionRepo = createDrizzleOccasionRepository(db);
  const contributorRepo = createDrizzleContributorRepository(db);
  const pledging: ForPledgingToOccasions = createPledgingToOccasions(occasionRepo, contributorRepo);

  const dto = PledgeSchema.parse(JSON.parse(message.body));
  await pledging.pledgeToOccasion({
    ...dto,
    pledgeId: createPledgeId(message.messageId),
  });
};
```

The use case doesn't know or care whether it was triggered by an HTTP request, a
queue message, a cron job, or a CLI command. `messageId` is stable across an SQS
redelivery, and pledge persistence must enforce `pledgeId` uniqueness atomically
with the pledge; use a producer event ID from the body instead if logically
identical publishes can have different SQS IDs. Every driving adapter remains
thin translation glue; only an executable-entrypoint exception may also select a
trivial concrete graph.

**Naming:** Use case interfaces and implementations are named after the business
capability — `ForPlacingOrders`, `createOrderPlacement`, `pledgeToOccasion`.
Never `CreateOrderUseCase` or `PlaceOrderHandler`. Pattern suffixes are technical
jargon, not domain language.

*Terminology note:* in the source pattern literature, "use case" is a
requirements technique — its primary/secondary actors map to driving/driven
actors, and ports start out one per actor. This skill uses "use case" for the
orchestration object that implements a driving port. Related, not the same thing.
