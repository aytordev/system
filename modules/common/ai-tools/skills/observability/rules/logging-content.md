---
title: Apply the Levels Test at Log Boundaries
impact: HIGH
impactDescription: Content discipline for log records
tags: observability, logging, effect
---

## Apply the Levels Test at Log Boundaries

**Impact: HIGH**

Log transport and shape — structured records on platform-captured process
streams, recognized levels, ISO timestamps — are a platform concern; this rule
is about *content discipline*.

### The levels test

"Nobody reads warnings, because by definition nothing went wrong," and "if
you choose to handle the error by logging it, by definition it's not an error
any more." Keep the standard four levels — but apply the test to every line:
every `warn` needs a named reader; every `error` log must correspond to a
genuinely unhandled failure, not a handled one being double-reported.

### Log at boundaries; accumulate in between

Most in-request `info` chatter should become fields on the wide event, not
separate lines. A request that produces 40 log lines produces one canonical
event plus a handful of genuinely independent facts.

**Correlation:** every log record carries the active trace ID (W3C trace
context), so logs join to traces and to the canonical event for free.

### Effect logging

In an Effect-based runtime, prefer native logging and annotations with Logger
Layers supplied by composition. Remove threaded JavaScript logger callbacks
and diagnostic wrappers when they merely recreate those capabilities. Keep
domain observations under the architecture rules in
`rules/architecture-placement.md`; native logging is not a reason to
introduce a logger into pure domain decisions.

Use a scoped finalizer or exit-aware equivalent for the wide event, covering
failure and interruption as well as success; a JavaScript `finally` around
construction of an Effect does not observe its execution. Accumulate safe
annotations within the program for that boundary event.

Preserve source redaction and sink-failure isolation during adoption: JSON
output does not enforce either. Check the installed production logger and test
through the operation that a failing sink neither changes the product outcome
nor masks its original failure; use a narrow sink adapter if native behavior
needs containment. For pinned-version API verification and runtime lifetime
rules, use the repository's Effect runtime documentation; a `functional`
companion skill carries that material where installed.
