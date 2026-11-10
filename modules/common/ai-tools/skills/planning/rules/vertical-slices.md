---
name: vertical-slices
impact: CRITICAL
impactDescription: Defines what a plan slice is
---

# Vertical Slices

**Impact: CRITICAL**

A vertical slice is not "small because it touches one layer." It is small
because it delivers one observable behavior through the real production path.

## What Every Slice Names

- **Actor**: who receives the value (user, admin, API client, scheduled job,
  support operator).
- **Trigger**: what starts the behavior (click, request, event, command, timer).
- **Observable outcome**: what proves the behavior happened.
- **Production path**: the real surfaces, use case, domain logic, persistence,
  and external adapters involved.
- **Smallest deployable value**: the narrowest useful version that can ship
  safely.

Good slices are often thin but complete:

- A form submits one valid field through the real API and persists it.
- A background job handles one event type and emits the expected audit result.
- A CLI command supports one input shape and returns stable stdout/stderr.
- A read-only screen shows one real state using production data loading.

## Choosing Slices

Before writing plan slices:

1. **Name the outcome** — describe the user- or system-visible result in one
   sentence.
2. **Map the path** — list the real entry point, business path, state change,
   output, and observability.
3. **Pick the walking skeleton** — choose the thinnest end-to-end version that
   proves the path works.
4. **Add one behavior or state at a time** — validation, permissions, error
   states, empty states, retries, analytics, and polish become later slices.
5. **Check reversibility** — each slice should be easy to revert or disable
   without undoing unrelated work.

Ask "what is the smallest real behavior we can ship?" before asking "what
files need to change?" If the answer still contains multiple customer
outcomes, roles, workflow branches, or quality levels, split the parent into
child stories before writing the plan; do not emit layer-cake or role-sliced
"stories" as a substitute.

## Size Heuristics

**Too big if:**

- Takes more than one session.
- Has multiple "and"s in the description.
- You are unsure how to test it.
- Needs many unrelated fixtures, mocks, screens, or endpoints.
- Builds a layer without proving an outcome.

**Right size if:**

- One clear behavior.
- One primary test case plus focused edge cases.
- You can explain it to someone quickly.
- It is obvious when done.
- It touches only the path needed for the behavior.
- It leaves a useful checkpoint even if later slices never happen.

**If you cannot describe a slice in one sentence, break it down further.**
