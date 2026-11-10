---
title: Demand Actionable Findings and Converge on Evidence
impact: HIGH
impactDescription: Makes the review checkable, resolvable, and honestly bounded
tags: double-check, findings, verdict, ledger
---

## Demand Actionable Findings and Converge on Evidence

**Impact: HIGH**

### Finding shape

Each finding must include:

- a one-line title;
- severity: `blocker`, `major`, `minor`, or `nit` — judged by impact if
  shipped, never by effort-to-fix or the reviewer's certainty;
- concrete evidence with a file location or reproducible scenario;
- an evidence tier: `executed` (observed by running a safe check), `read`
  (traced end-to-end in the code), or `inferred` (pattern-match or judgment);
- a suggested direction, without applying the change.

### Before the verdict

The response must also report, every round, even when clean:

- **Claim dispositions** — one line per named claim and per scrutinize-hardest
  area: `holds`, `broken (Fn)`, or `could not verify`, each with its evidence.
- **Coverage** — what was actually read and run, and an explicit list of what
  was **not** checked. A response with no not-checked list is incomplete.
- **Scope fidelity** — the three outcomes, one line each:

```text
Scope fidelity — unrequested additions: none | <finding IDs>
Scope fidelity — unrequested removals: none | <finding IDs>
Scope fidelity — removed/weakened tests: none | <finding IDs>
```

### Verdict

Exactly one machine-recognizable verdict ends the response:

- `VERDICT: issues-found` when any finding remains, at any severity (even one
  nit);
- `VERDICT: no-issues` only when the reviewer reports zero findings of every
  severity.

A verdict without claim dispositions and a coverage statement is incomplete —
ask for the missing parts rather than accepting it. Do not accept
`no-issues` while the riskiest claims rest on `inferred` evidence alone; weigh
every not-checked item against the scrutinize-hardest list before treating the
verdict as meaningful.

### Resolving findings

For each finding, record one host action:

- **Fix** — confirm the issue and update the work.
- **Push back** — reject it with concrete contrary evidence.
- **Defer** — acknowledge a real out-of-scope issue and surface it to the user.

Push back with evidence, never with a desired disposition. Hand the reviewer
contrary evidence at a file and line and ask it to re-examine; do not ask it
to agree, and do not signal which outcome you want. A finding closes on
evidence: the reviewer must restate the finding's strongest surviving form and
name the specific evidence that defeated it. A withdrawal justified only by
deference to confident pushback is invalid — the finding stays open.

Keep a stable ledger:

| ID | Severity | Finding | Host action | Reviewer disposition |
|----|----------|---------|-------------|----------------------|
| F1 | major | Concrete issue | Fixed at file:line | Open |

A finding closes only when it is fixed and accepted, rejected with reviewer
agreement, or explicitly deferred to the user. Silence in a later round is not
closure.

### Review the final state

After fixes or rebuttals, give the reviewer the updated work, validation
evidence, and point-by-point ledger. Resume the isolated review context when
the host supports safe continuity; otherwise launch a new read-only round with
the complete ledger.

The fixes themselves are fresh, unreviewed code written under review pressure.
The final round must sweep the fix diff for new defects as first-class review
work, not merely confirm that each ledger item is addressed.

`VERDICT: no-issues` is meaningful only when:

- every prior finding is closed;
- the reviewer has inspected the final state after the last change;
- the final round reports zero findings of every severity;
- the final round reports an explicit clean scope-fidelity result;
- the final round includes claim dispositions and a coverage statement, and no
  scrutinize-hardest area rests on `inferred` evidence alone; and
- the primary agent agrees no real issue remains.

Cap ordinary review at about three or four rounds. If a substantive
disagreement does not converge, present both arguments and a recommendation to
the user instead of declaring success.

### Anti-patterns

- Reusing the authoring conversation as the reviewer context.
- Selecting a second executable backed by the same provider and calling it
  independent.
- Allowing reviewer writes because read-only invocation is inconvenient.
- Omitting the objective, original scope, constraints, diff scope, or
  validation evidence.
- Reviewing only the changed code's correctness while ignoring what was
  silently added to or removed from the requested scope.
- Accepting a test deletion because the code it covered was also deleted,
  without checking that removing that behavior was itself in scope.
- Accepting or dismissing findings based on confidence rather than evidence.
- Closing a finding because the host pushed back confidently rather than
  because evidence defeated it.
- Accepting `no-issues` without a coverage statement saying what was not
  checked.
- Treating the first clean response as convergence after later changes.
- Letting the reviewer quote credentials, tokens, or keys verbatim instead of
  referencing them by location.
- Baking one provider's commands, model aliases, authentication behavior, or
  project workflow into the skill.
