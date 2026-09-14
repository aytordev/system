---
name: lightweight-change
description: "Bounded understand/change/verify path for routine work: read the real code, make the smallest correct change, and run focused verification. Owns simple changes; structured multi-phase work stays in SDD."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Lightweight Change

A bounded, reviewable lifecycle for routine work: understand the real code, make
the smallest correct change, verify it with a focused check. It exists so simple
work does not have to become a multi-phase process, and it creates no planning
artifacts.

This is one lifecycle with exactly one owner per task. It does not replace SDD,
and it does not duplicate the diagnosis, impact, or review methods.

## Entry Conditions

Use this skill when:

- The request is a small, well-scoped change: a fix, a rename, a small feature,
  a dependency bump, or a documentation correction.
- The change fits in one sitting and does not need requirements, design, or a
  multi-phase plan to proceed safely.
- The user asked for the change directly and did not request SDD or another
  structured workflow.

Do not enter when:

- The request is a question or explanation only; answer it and stop. No
  lifecycle is needed.
- The user explicitly requested SDD or another workflow; keep it where the user
  put it.
- The change is substantial: it spans many components, needs requirements or a
  design decision, or exceeds a focused review. Route it to SDD.
- The work is diagnosis-only or impact-only; use `bug-diagnosis` or
  `impact-analysis` and return their evidence.
- The request is a performance investigation; use a measurement method instead.

## Phases

Three phases, in order. Keep each proportional to the change; do not turn them
into a ceremony.

### 1. Understand

- Read the real code, config, and tests the change touches. Do not guess
  structure or behavior.
- Name the exact behavior change and the file(s) it lands in.
- If the cause or blast radius is unknown, compose a method before continuing:
  - `bug-diagnosis` for "why does this fail" or an unknown root cause.
  - `impact-analysis` for "what could this break" across a contract.
  - `nix` references for Nix build, closure, or activation work.
- Load a method only when it is needed. A method returns its evidence to this
  lifecycle and does not take it over.

### 2. Change

- Make the smallest correct change that satisfies the request. Match existing
  conventions and touch only what the change requires.
- Do not create SDD artifacts: no proposal, spec, design, tasks, or change
  directory. Planning stays in the conversation.
- Do not delegate routine work by default. Delegate only when the change truly
  exceeds the understand/change/verify scope, and keep ownership here.
- Preserve user-requested workflows and authority boundaries: implement and
  activate only what the user authorized.

### 3. Verify

- Run the focused check that proves the changed contract: the relevant build,
  formatter, linter, or test for the touched surface. Prefer an existing check
  over a new one.
- Report the exact command, its result, and the revision it ran against. A pass
  collected before the change is stale and does not count.
- If no focused check exists, say what is unverified rather than claiming
  success. Do not fabricate a pass.
- Stop at verified. Commit, push, or open a PR only when the user asks. For an
  independent review of a non-trivial diff, `judgment-day` remains the review
  lane; this lifecycle does not review itself.

## Completion

Done means: the change is made, the focused check is current and passing, and
the result — what changed, the evidence, and any residual uncertainty — is
reported. No persisted artifact is required.

## Routing

Choose exactly one lifecycle owner per task. SDD remains the owner for
structured, multi-phase work.

| Request | Lifecycle owner | Entry |
| --- | --- | --- |
| Question or explanation only | none — answer directly | — |
| Diagnosis-only ("why does this fail") | `bug-diagnosis` method | `bug-diagnosis` |
| Small, well-scoped change | `lightweight-change` | `lightweight-change` |
| Architecture-only analysis (compare/decide, no implementation) | SDD (read-only explore) | `sdd-explore` |
| Substantial implementation (multi-phase, specs/design) | SDD | `sdd-orchestrator` |
| Explicit SDD request | SDD | `sdd-orchestrator` |

Rules:

- Exactly one lifecycle owns a task. A method invoked inside a lifecycle returns
  to that lifecycle; it never becomes a second owner.
- Prefer the lightest path that is safe. Escalate to SDD when the change needs
  structured requirements, design, or more than a focused review.
- When the user requests a specific workflow, honor it and do not silently
  switch lifecycles.

## Related

- `bug-diagnosis` — bounded, read-only cause finding; never owns a fix.
- `impact-analysis` — follow consumers beyond the diff and prove compatibility.
- `nix` — Nix authoring and operational methods (build, closure, activation).
- SDD (`agents/sdd/`, `skills/sdd-*`) — the structured multi-phase lifecycle.
- `judgment-day` — independent adversarial review, separate from verification.
