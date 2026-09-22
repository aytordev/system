# Evidence-Based Review

Adapted from the pinned Krehel review skills; pins, license, and corrections:
`provenance.md`.

## Scope and read-only default

- Resolve the scope first (screen, flow, component, or change) and state it.
  Never imply uninspected surfaces were reviewed; if the scope is too large to
  inspect credibly, narrow it to one complete flow and state the boundary.
- A review request is read-only: produce findings and a verdict without
  editing files. Implement only when separately requested, and keep the
  consolidated report as the change scope.
- Classify findings against a change scope as introduced, regression, or
  pre-existing, by what the change touched rather than which file they sit in.

## Evidence

- Recon before judgment: framework, styling system, tokens, supported
  viewports, and what the project documents about its own interface. A
  documented convention is leverage and a reporting location, not permission;
  it does not retire a finding.
- Every finding cites its location (`path/to/file:line`, or the exact screen
  and component when there is no source) and shows the current state.
- Inspect rendered behavior when it determines the outcome; do not report a
  visual claim from source alone or a code claim from appearance alone.
- Consolidate one root cause into one finding listing every affected location.

## Severity and verdict

- HIGH: blocks a task, misleads, hides content or controls, risks data loss,
  or repeats systemically. Escalations are HIGH on sight: a control with no
  accessible name, invisible focus, pointer-only paths, `prefers-reduced-motion`
  violations, breakage at 320 CSS px or 200% zoom, a failing contrast pair,
  meaning carried by color alone, or an unconfirmed destructive action.
- MEDIUM: meaningfully harms comprehension, efficiency, adaptability, or
  consistency. LOW: isolated polish.
- Report rejected candidates and why they were rejected; a short review or no
  findings is a valid result.

## Verification

Run the safe checks the project offers (linters, tests, keyboard traversal,
zoom) and report the exact command or interaction with the observed result.
Label anything not run as not verified and state what remains; never convert
a verification gap into a finding.
