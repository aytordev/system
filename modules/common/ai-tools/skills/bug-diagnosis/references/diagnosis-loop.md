# Diagnosis Loop

Detail for the `bug-diagnosis` method. Read `SKILL.md` first.

## The Loop

```
symptom (exact, reproducible)
   │
   ▼
red-capable feedback command ── none? ──▶ report attempts + ask for the smallest missing access
   │ red observed
   ▼
minimize reproduction (drop one element at a time; stop when all are load-bearing)
   │
   ▼
3–5 falsifiable hypotheses (each with one observable prediction)
   │
   ▼
one-variable probes (debugger/REPL before logging)
   │
   ▼
supported cause + rejected hypotheses + evidence + residual uncertainty
```

Converge when a probe confirms one hypothesis and the others are falsified by
their own predictions. If two hypotheses survive, the probe was not
one-variable; narrow it and repeat.

## Good and Bad Predictions

- Good: "If the retry counter resets on each call, a second identical call in
  the same second returns the cached error." Observable, and false for the
  competing cause.
- Bad: "Something is wrong with the cache." Not observable, does not separate
  hypotheses.

## Evidence Report Shape

```
Symptom: <exact observable wrong result>
Reproduction: <minimized command or steps, and its red result>
Supported cause: <statement>
  Evidence: <probe + observed result, quote the output>
Rejected: <hypothesis — the prediction that failed>
Residual uncertainty: <what remains unproven, or None>
```

## Read-Only Discipline

- Keep throwaway scripts in an isolated temporary directory, never in tracked
  source, and delete only your own scratch.
- A remote probe needs explicit scope confirmation from the user and a
  non-mutating contract.
- If you added temporary instrumentation, remove it before handoff and say so.
