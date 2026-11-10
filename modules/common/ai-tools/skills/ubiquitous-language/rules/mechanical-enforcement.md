---
title: Enforce Mechanically, Report Honestly
impact: HIGH
impactDescription: Keeps ratchets scoped, teachable, and truthful
tags: ubiquitous-language, enforcement, lint
---

## Enforce Mechanically, Report Honestly

**Impact: HIGH**

Prompt-level glossaries steer; deterministic gates enforce. Where a mechanical
enforcement layer is installed (lint rules generated from the glossary), it
runs inside the agent's loop, scoped to domain paths — and enforces:

- **Project-declared vocabulary smells** — a repository may choose to flag
  vague suffixes such as `Manager`, `Helper`, or `Impl` in selected domain
  paths. Treat them as prompts for review, never universal bans: a canonical
  glossary term overrides a generic smell list.
- **Glossary-driven identifier check** — split identifiers into words;
  validate domain words against the context's glossary using **token
  classes**: glossary terms / deprecated aliases (flagged with their
  replacement) / path-scoped technical stopwords / exempt framework
  identifiers.
- **Test-title check** — titles validated against the glossary; deprecated
  aliases rejected *naming the canonical replacement*.
- **DSL vocabulary check** — a new acceptance-DSL verb either exists in the
  glossary or triggers the protocol.
- **Context-scoped aliases and forms** — validate aliases within their owning
  context; enforce canonical case, plurals, identifier forms, and public wire
  names where the glossary declares them.
- **Language scope only** — do not smuggle structural or dependency policy
  into a vocabulary lint; architecture enforcement is a separate concern
  (restate the boundary inline where an architecture skill is absent).

## Every rule teaches

Three-part messages: what fired, why the rule exists, what to do instead, with
a pointer to the owning glossary. A gate with no exit invites bypass, so the
documented-exception process (justified in the review, recorded) stays open.

## Enforcement status is part of the answer

Until a generated lint layer or equivalent gate is installed in the project,
everything here is convention — say so; never imply protection that is not
there. Even when the command is green, report its configured paths and token
classes: a targeted ratchet is not proof that every prose passage and
identifier uses the ubiquitous language correctly.

Every language guard needs a positive control: a fixture or focused test that
introduces known-forbidden vocabulary and proves the guard fails with the
owning context and canonical replacement. Scanning the current tree and
finding nothing proves only that the scanner completed.

## The Adoption Spectrum

- **Greenfield** — start with the glossary and the smallest useful
  positive-control guard; add enforcement only where it catches a
  demonstrated drift risk.
- **Brownfield — the protected-core ratchet.** A rule that fires thousands of
  times on day one will be bypassed. Start with one capability or bounded
  context, enforce its domain/application boundary, and expand as work touches
  adjacent behavior. Pre-existing violations may freeze in a baseline whose
  counter only goes down. The glossary can roll out warn-first and
  diff-scoped, with its limited scope stated explicitly.
- **Spikes** — treat vocabulary as provisional and route it through the
  protocol before promotion into maintained code. Follow the repository's
  existing spike or experimental-code policy rather than inventing a global
  marker.
