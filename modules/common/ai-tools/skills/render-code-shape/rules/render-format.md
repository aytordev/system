---
title: Render the Shape and the Call Graph
impact: CRITICAL
impactDescription: The waterline cut and the edge notation that make the render checkable
tags: render-code-shape, format, call-graph
---

## Render the Shape and the Call Graph

**Impact: CRITICAL**

### Render the shape

Three parts:

**Types** — every type, interface, or schema that crosses a boundary, declared
with its fields. A type from outside the frame is named and marked external.

**Boundaries** — one row per module: what it owns, what it exposes, what it
depends on, and what it hides behind that surface.

**Signatures** — grouped under their module, each carrying parameter names,
parameter types, return type, and error type as written in the source. Each body
collapses to a single line naming its intent.

Where the cut is not obvious, place it here:

| Above the waterline | Below it |
| --- | --- |
| An effect that leaves the process: network, database, filesystem, clock, randomness, environment | Pure local computation |
| A branch that changes which downstream call happens | A branch that only changes a returned value |
| A helper whose effect crosses the module edge | A private helper contained inside it |
| What is constructed and injected where | Framework and transport boilerplate |

**Complete when:** every type named in a signature is declared here or marked
external, every module row states what it hides, and every signature matches its
source or carries `[NEW]`.

### Render the call graph

One graph per wiring, as an indented tree. Each edge reads
`→ Receiver.method(arg: Type, arg: Type) : Return`, then its annotations, then
its file and line. Order siblings by execution order.

```
submitCheckout(req: HttpRequest) : HttpResponse                          src/http/checkout.ts:14
  → Checkout.submit(cart: Cart, actor: UserId) : Receipt                 src/checkout/service.ts:31
      → Pricing.quote(cart: Cart) : Quote                                src/pricing/quote.ts:8
          → TaxRates.lookup(region: Region) : TaxTable  [boundary: network]   src/pricing/tax.ts:22
      → Payments.charge(quote: Quote, card: CardRef) : Receipt  [boundary: network]   src/payments/stripe.ts:40
      → Orders.insert(order: Order) : OrderId  [boundary: database]      src/orders/store.ts:17
      → Email.receipt(to: EmailAddress, receipt: Receipt) : void  [async]   src/mail/queue.ts:9
      → Checkout.release(cart: Cart) : void  [error: charge declined]    src/checkout/service.ts:58
```

Annotate every edge that is not a plain unconditional in-process call with at
least one:

| Annotation | Meaning |
| --- | --- |
| `[if …]` | Happens only on the named condition |
| `[each …]` | Repeats over the named collection |
| `[async]` | Enqueued, scheduled, or not awaited on this path |
| `[error …]` | Happens on the named failure path |
| `[boundary: …]` | The effect leaves the process — name which |
| `[NEW]` | Does not exist yet |

A function already drawn appears as `→ Name (above)` in place of a second
expansion.

**Complete when:** every edge names the values crossing it, every non-plain edge
carries an annotation, every branch terminates on a read-step condition, and
each wiring that differs from production is drawn beside it.
