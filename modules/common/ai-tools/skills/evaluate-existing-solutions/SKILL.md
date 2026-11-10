---
name: evaluate-existing-solutions
description: "Trigger: library, tool, service, or primitive recommendations; build-versus-adopt questions; replacing custom machinery; due diligence on a prescribed but unadopted material dependency. Compares established options against an explicit bespoke baseline on total lifecycle ownership and produces an evidence-backed adopt, adapt, combine, build, defer, or do-nothing proposal."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Evaluate Existing Solutions

Reuse before invention is a **decision discipline**, not a rule that every
problem needs a dependency. Compare existing capabilities and a bespoke
baseline on total lifecycle ownership. Prefer an established solution when it
fits and lowers overall risk and mechanism; prefer bespoke when evidence shows
it is the smaller, safer, more controllable, or more differentiating choice.

This skill researches and decides. It does not install packages, run untrusted
code, create accounts, start procurement, accept licenses, send data to a
service, or implement the choice without separate authority.

`rules/` and `assets/` are bundled with this skill. Repository paths refer to
the target repository, not to files beside this skill.

## Activation Contract

Use three proportionate depths:

1. **Lightweight preflight** — before proposing material bespoke generic
   machinery, inspect existing repository capabilities and standard, framework,
   and platform primitives. Continue only when a credible alternative or
   material ownership decision exists.
2. **Due diligence only** — when the user has prescribed a named but
   not-yet-adopted material dependency, verify the exact version/tier,
   compatibility, maintenance, security, license, provenance,
   lifecycle/execution risk, and local fit without reopening the market
   comparison. Surface a failed hard gate; otherwise honor the prescribed
   choice.
3. **Full comparison** — for a consequential unresolved choice, compare
   credible existing options with a genuine bespoke baseline and produce the
   decision proposal.

Use the full comparison for a durable direct dependency or framework; a
generic cross-cutting capability such as auth, queues, scheduling, validation,
search, observability, storage, migrations, or feature flags; an open-source
application, developer tool, build system, database, runtime, managed service,
or platform capability; replacing selected custom machinery with an
established primitive; or a build/adopt/defer decision with meaningful
lifecycle cost.

Do not impose it on domain-specific policy, a small transparent helper,
one-off glue, a routine fix or refactor with no new mechanism, or routine use
of a tool the project already owns. Agent-skill discovery is a different job:
this skill evaluates software libraries, tools, applications, and services,
not installable instruction packages.

## Hard Rules

1. **Establish the job and hard constraints before shopping.** If behavior is
   still ambiguous, resolve it first — ask one focused question at a time
   until the hard constraints are clear. Do not let one candidate redefine the
   requirements after discovery begins.
2. **Inspect the repository and its existing capabilities before searching
   externally.** An existing capability, standard library, open standard, or
   platform primitive often wins.
3. **Treat versions, maintenance, security, support, pricing, and licenses as
   volatile.** Verify live candidates from primary sources; never rely only on
   model memory. Read `rules/evidence-and-currentness.md` before external
   research.
4. **Keep a bespoke baseline in the comparison.** Adoption is not
   automatically superior.
5. **Compare total ownership** — integration glue, wrappers, upgrades,
   migration, security response, testing, operations, support, and exit — not
   initial implementation effort alone. Read `rules/evaluation-dimensions.md`
   before comparing finalists.
6. **Apply hard gates before qualitative trade-offs.** Eliminate or name a
   credible mitigation when a candidate fails a hard constraint; never
   disguise judgment as a weighted numeric score.
7. **Research does not authorize execution.** A proof-of-fit runs in a
   disposable, least-privilege sandbox under explicit authority
   (`rules/decision-and-ownership.md`).
8. **Record uncertainty, confidence, evidence dates, and what would change the
   recommendation.** Calibrate research to impact and reversibility; stop once
   further search is unlikely to change the decision.

## Execution Steps

1. **FRAME** — the job, users and operators, observable outcomes, must-have
   constraints, non-goals, expected lifetime, criticality, reversibility,
   decision owner, and the research depth proportionate to blast radius.
2. **INSPECT LOCAL** — governing instructions, architecture decisions, active
   plans, manifests, lockfiles, workspace configuration, and nearby code.
   Identify an existing capability, a standard library or open standard, a
   platform primitive, and dependencies the team already owns. Local reuse
   still needs fit evidence; old code does not win merely because it is
   present.
3. **DEFINE CANDIDATES** — only credible classes: do nothing/reuse local,
   standard or platform primitive, maintained library, open-source tool,
   managed service, adapt/wrap/combine a few options, bespoke. Two or three
   representative finalists plus the bespoke baseline are often enough.
4. **GATHER EVIDENCE** — live primary sources for every external candidate
   (`rules/evidence-and-currentness.md`); record observed version/tier,
   evidence date, URL, and the specific finding.
5. **GATE AND COMPARE** — hard gates first, then qualitative trade-offs on the
   whole adopted system, including transitive dependencies, hosted control
   planes, operator workflows, and the bespoke glue still required
   (`rules/evaluation-dimensions.md`).
6. **RESOLVE UNCERTAINTY** — the smallest proof-of-fit that can change the
   decision, under sandbox and authority rules
   (`rules/decision-and-ownership.md`).
7. **DECIDE AND ROUTE** — write the decision with
   `assets/solution-decision-template.md` and route ownership
   (`rules/decision-and-ownership.md`).

## Output Contract

Return the decision proposal in the template shape: job and outcomes, hard
constraints and non-goals, local capabilities inspected, candidates with
hard-gate results, the evidence ledger, qualitative trade-offs, the decision
(outcome, why it wins, strongest counterargument, remaining ownership, what
would change it), proof-of-fit record, ownership route, and exit/re-evaluation
triggers. Every agent-produced result starts as **proposed**; only the named
decision owner can accept it.

## References

- `rules/evidence-and-currentness.md` — evidence hierarchy, minimum evidence record, supply-chain and execution safety.
- `rules/evaluation-dimensions.md` — hard gates and the qualitative comparison.
- `rules/decision-and-ownership.md` — decision classes, proof-of-fit safety, ownership routing, re-evaluation triggers.
- `assets/solution-decision-template.md` — the decision-artifact skeleton.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When an expectations, technical-writing,
planning, TDD, testing, refactoring, or mutation-testing skill is not
installed, apply the discipline directly: record the accepted decision in the
project's existing ADR or decision convention, write a consequential proposal
as clear prose, sequence delivery through the project's plan, write the
failing test before new behavior, keep refactors behaviour-preserving, and
verify the accumulated result once at PR readiness.
