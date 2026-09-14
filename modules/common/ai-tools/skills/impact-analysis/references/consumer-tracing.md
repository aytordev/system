# Consumer Tracing and Evidence

Detail for the `impact-analysis` method. Read `SKILL.md` first.

## Where grep stops

Searching symbol references is step one, not the answer. Also check:

- The source of the library you call, at the pinned version, plus any local
  patch or override.
- Execution order: microtasks, teardown, cancellation, and error paths.
- Shapes a symbol search misses: serialized JSON, a database column, a wire
  format, another language reading the same bytes, a feature flag.
- Consumers several hops downstream of the changed symbol.

## Evidence Ladder

A write-up that sounds right reads as convincing whether or not it is true. For
each fact the change's safety depends on, get as far down this ladder as is
cheap and say where it stopped:

1. You said so. Worthless on its own.
2. You pointed at the line. A real `file:line`, or the library's own source.
3. You walked the failure path and showed the bad case cannot happen.
4. You ran it. A script or test that calls the real code and fails loud if the
   assumption is wrong.
5. You reproduced it in the running app.

A fact you cannot reach step 4 is unproven. Say so; do not round up. Step 4 is
usually one small script that imports the same code the app ships and calls the
exact function you are worried about.

## Handback Shape

```
What it does: <the change, including what the diff does not show>
Material assumption: <the one fact the change is safe because of>
  Proof: <existing check or isolated probe + observed result; ladder step>
Risks: <each with file:line, how likely, how bad, and how to check>
Cleared: <what you checked and why it is fine>
Before merge: <the cheapest test or repro that catches the real bug>
Unproven: <remaining evidence limit, or None>
```

## Isolation

- Put throwaway scripts and fixtures in an isolated directory under ignored
  build scratch or the user cache, never in tracked source.
- Run mutation-capable probes against disposable copies with isolated state.
- Remove only your own scratch. If safe isolation is unavailable, report the
  evidence limit instead of running the probe.
