---
title: Read This Before Writing Any Code in an Opted-In Repo
impact: CRITICAL
impactDescription: The SDK boundary and porting rules that most changes get wrong
tags: hexagonal-architecture, boundary, sdk, porting
---

## Read This Before Writing Any Code in an Opted-In Repo

**Impact: CRITICAL**

**A third-party SDK's client type is never a port.** `OrdersApiClient`,
`SmtpClient`, `PushClient`, a Stripe client — anything exported by a vendor
package or by the repo's SDK folder (`src/lib/`, `vendor/`, `node_modules`) — is
outside the hexagon, and so is every file that imports it, including with
`import type` and including the SDK's DTO types. A deps object whose fields are
SDK client types has no ports, however many fakes the tests pass in. Structural
compatibility between an SDK client and the interface you need is not a reason to
skip the adapter.

**Adding a feature in an opted-in codebase** — in this order;
`references/worked-example.md` shows the finished shape:

1. Put the business rule (time windows, filters, who is addressed, subject lines
   and message text, truncation) in a pure inside function that takes domain
   types and `now` as values; an adapter receives finished values and only
   translates them to the SDK's shape.
2. Declare the ports the use case needs as exported `interface`s inside, beside
   the use case: driven ports as role nouns (`OrderRepository`, `ReceiptSender`,
   `PaymentGateway`) whose methods use your own domain types, never the SDK's
   DTOs; the driving port as `For<Verb>ing<Noun>` (`ForPlacingOrders`,
   `ForSendingReceipts`), implemented by `create<Capability>(deps)` where `deps`
   holds only ports and `now`.
3. Write one adapter per driven port that imports the SDK and translates its
   shapes to the port's types, and a driving adapter (route, CLI, queue) that
   parses input and calls the driving port.
4. Wire SDK client → adapter → use case in the composition root only
   (`src/index.ts`, `main.ts`, or `composition/`). The root keeps taking SDK
   clients or configuration from its caller and builds the adapters itself; do
   not change its public signature to take ports.
5. Test the use case through its driving port with hand-written in-memory fakes
   of the driven ports; test each adapter against the SDK separately.

**Changing a use case that still imports an SDK directly** — a file the README
admits predates the architecture, or any inside file with an import from the SDK
folder. In an opted-in repo, porting every SDK dependency of a file you touch is
part of the change, not scope creep, and it is a behaviour-preserving refactor
step taken with the existing tests green before the red for the new behaviour —
the request's wording sets what changes, the architecture sets how. First extract
*all* of its SDK dependencies behind ports (steps 2–4 above) and give it its
driving port interface if it has none — an exported function is not a driving
port; declare `ForSendingReceipts` (or the equivalent) and return it from
`createReceiptSender(deps)` — then make the requested change against the ports.
Extracting only the dependency the request names leaves the next swap touching
the use case again. Before you finish, read the use case's imports: if any still
names the SDK folder or an SDK client type, you are not done — extract it too. If
the request says "just do it where the SDK call is", the rule still goes inside;
say why in one sentence.

**Where new files go when no restructuring is requested:** keep the repo's layout
for the inside, but adapters and fakes are your code, not the vendor's. Put them
beside the feature they serve (`src/<feature>/ports.ts`,
`src/<feature>/adapters.ts`, `src/<feature>/testing/`) or in an `adapters/`
folder — never in the folder that holds SDK stand-ins, where an adapter reads as
one more third-party client.

**Use-case tests use fakes, not mocks.** A use-case test contains no `vi.fn`,
`vi.mock`, or `vi.spyOn` and imports nothing from the SDK folder; a recording
fake (`sent: readonly Receipt[]`) is how you observe a notifier or mailer. When
you touch an existing use-case test that mocks SDK clients, replace those mocks
with fakes of the ports you just declared rather than extending them.

For domain modeling (entities, value objects, aggregates, ubiquitous language),
the domain-driven-design companion is the optional subject-matter source. Hex
arch and domain modelling are complementary but independent — hex arch provides
structural isolation (how the outside connects), domain modelling provides the
domain model (what lives in the center). A project may use one without the other.

Use the structure-codebase companion's subject — physical source-tree design —
when designing or changing the physical tree. For an opted-in hexagonal backend
that means grouping by business capability or bounded context first, then making
the provider-free inside visible under that owner's `hexagon/`, with concrete
driving/driven technology and reusable test interactors outside. If physical
restructuring is not requested, preserve the repo's existing layout for the
inside while enforcing the dependency direction described here — but new ports,
adapters, and fakes are first-party code and go beside the feature they serve or
in an `adapters/` folder, never in the folder that holds third-party SDK code.

The codebase-design companion's subject is the coherent responsibility and full
caller burden behind a port or in-process module. Not every module interface or
test seam is a hexagonal port, and intentionally thin driving/driven adapters
should remain thin. Use the finding-seams companion's subject — the minimum
enabling point — to characterize hard-coupled legacy behavior before deciding
whether a durable port is warranted.
