---
name: production-parity-skill-builder
description: "Trigger: local, CI, PR, preview, staging, or other non-production environments may drift from production behavior; production-only auth, config, identity-provider groups, feature flags, infrastructure, backing services, or policy differences caused bugs; or a team wants a reusable app-specific skill that detects, documents, tests, and helps fix parity drift. Requires inspecting the repository before asking, a parity map with truth sources and guards, questions only for source-unanswerable decisions, and app-specific fixes only when authorized."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Production Parity Skill Builder

Build a skill for one application. The generated skill's job is to keep local
and non-production environments behaviorally aligned with production, while
making every intentional difference explicit and tested.

Production is the reference contract. Local, CI, PR, preview, and staging may
use lighter infrastructure, but they must either emulate production behavior
or document the divergence with compensating tests. A production authentik
group restriction that is absent locally is a parity bug, not a harmless
convenience.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Non-production environments may drift from production behavior.
- Production-only auth, config, identity-provider groups, feature flags,
  infrastructure, backing services, or policy differences caused bugs.
- A team wants a reusable app-specific parity skill built and stored in the
  application's own repository.

Do not use it for a generic environment audit: the deliverable is always a
reusable, app-specific skill inside the target repository, not a one-off
report.

## Hard Rules

1. **Production is the reference contract.** Non-production may be lighter,
   but every difference must be explicit, justified, and covered by a guard.
2. **Inspect before asking.** Never ask the user to explain what can be
   discovered from files (`rules/inspection-before-asking.md`).
3. **Build the parity map before generating the skill** or comparing
   environment options (`rules/parity-map.md`).
4. **Ask only source-unanswerable decisions**, one at a time, with the
   evidence that triggered the question, capturing every answer into the
   generated skill (`rules/targeted-questions.md`).
5. **The generated skill lives inside the target application's repository** —
   never in a user or global skills folder
   (`rules/generated-skill-contract.md`).
6. **Intentional divergence needs a named reason and a compensating guard.**
   "Local is easier" is not enough.
7. **Parity fixes are authorized separately.** A request to create the skill
   authorizes the skill artifact, not unrelated app or infrastructure
   changes (`rules/safeguards-and-authorization.md`).
8. **Validate the generated skill before finishing**: re-read it as a fresh
   thread, confirm every app-specific claim cites a source or captured
   answer, and run the harness's skill validation if one exists — saying
   exactly why when it cannot run.

## Execution Steps

1. **INSPECT** — build evidence from docs, app code, tests, local setup, CI
   and previews, infrastructure, and production descriptors before any
   question; use the parity surface catalog as a checklist
   (`references/parity-surface-catalog.md`).
2. **MAP** — record per surface: production truth source, non-production
   representation, drift risk, current guard, fix pattern, and owner or
   escalation path.
3. **ASK** — targeted questions only for gaps repository evidence cannot
   close, using the harness's structured ask-question facility when it
   exists (`references/question-patterns.md`).
4. **GENERATE** — write the app-specific skill (normally
   `<app-name>-production-parity`) from
   `references/generated-skill-template.md`, removing irrelevant sections and
   replacing placeholders with app-specific evidence.
5. **NAME SAFEGUARDS** — list the narrowly scoped checks the app needs
   (config, auth, fixture, infra, provider, runtime, smoke parity); implement
   them only when authorized.
6. **VALIDATE** — fresh-thread read-through, claim provenance, project-local
   path check, and available skill validation.

## Output Contract

Return:

- generated skill path, with confirmation it is stored inside the target
  project repository;
- files and directories inspected;
- highest-risk parity gaps found during creation;
- questions asked and captured decisions;
- tests or validation run;
- recommended next fixes if drift was found but not fixed.

Do not present a generic parity report as the final product. The primary
deliverable is the reusable app-specific skill.

## References

- `rules/inspection-before-asking.md` — what to inspect and the search terms.
- `rules/parity-map.md` — the per-surface record to build before generating.
- `rules/targeted-questions.md` — question rules and capture discipline.
- `rules/generated-skill-contract.md` — naming, project-local storage, required sections, validation.
- `rules/safeguards-and-authorization.md` — safeguard surfaces and the authorization boundary.
- `references/parity-surface-catalog.md` — surfaces, drift, and guards checklist.
- `references/question-patterns.md` — reusable question shapes and capture format.
- `references/generated-skill-template.md` — the template for the generated skill.
- `references/provenance.md` — upstream source, revision, and licence notice.

When repository evidence cannot settle a consequential choice among emulator,
local service, hosted sandbox, or testing-tool options, state the known
parity contract and constraints first, then compare options against them —
an `evaluate-existing-solutions` companion covers the comparison method where
installed. Do not let a tool search define what production fidelity means.
