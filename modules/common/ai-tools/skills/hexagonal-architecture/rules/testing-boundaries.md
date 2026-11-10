---
title: Test the Use Case Through Its Port with Fakes
impact: CRITICAL
impactDescription: Makes the boundary real and the primary suite fast
tags: hexagonal-architecture, testing, fakes
---

## Test the Use Case Through Its Port with Fakes

**Impact: CRITICAL**

Hex arch's primary benefit is testability. The primary test boundary is the **use
case** — call it with driven ports replaced by in-memory **fakes** (not mocks).
This proves the feature works as a whole.

| Priority | Boundary | What it proves |
|----------|----------|----------------|
| **Primary** | Use case (faked driven ports) | Feature works end-to-end within the hexagon |
| **Complement** | Domain pure functions | Complex business rules in isolation |
| **Secondary** | Driven adapters (real DB/MSW) | Adapter translates correctly |
| **Verification** | E2E (full stack) | User experience works |

**Fakes over mocks:** Fakes implement the real interface and maintain state.
Mocks verify call sequences and break on refactoring. Concretely: a use-case test
has no `vi.fn`, `vi.mock`, or `vi.spyOn` and no import from a vendor SDK or the
repo's SDK folder; it builds `createFake<Port>()` for each driven port and asserts
on the fake's recorded state (`notifier.sent`, `repo.saved`). An existing
use-case test that mocks SDK clients is converted to fakes of the ports the moment
you touch it, not extended. See `references/testing-hex-arch.md` for detailed
patterns.

**A port is only real if it is tested.** Every port needs a test interactor — a
test driver at each driving port, a fake at each driven port. Without one, the
"port" is just a line on a diagram; nothing enforces it as a boundary. The test
wall doubles as the leak detector: business logic drifting into an adapter, or
technology detail drifting into the domain, breaks a boundary test immediately.

**The swappability test** is the ultimate validation of the boundaries: can you
swap an adapter without changing domain code or use case tests?

- Swap PostgreSQL for DynamoDB → only the repository adapter changes
- Swap Stripe for PayPal → only the payment adapter changes
- Use case tests continue to pass with any adapter (they use fakes)

If any swap requires changing domain code or use case tests, the boundary is
wrong.

For a complete worked example showing one feature traced through every layer
(glossary → types → domain → use case → adapters → tests → file locations), see
`references/worked-example.md`.
