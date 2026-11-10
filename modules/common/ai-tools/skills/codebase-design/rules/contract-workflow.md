---
title: Choose Responsibility Before the Seam
impact: HIGH
impactDescription: Stops seams and dependencies from preceding the design
tags: codebase-design, workflow, seams, dependencies
---

## Choose Responsibility Before the Seam

**Impact: HIGH**

### Inventory the full contract burden

List what each caller must know today:

- operations and data shapes;
- invariants and preconditions;
- call ordering and lifecycle;
- configuration and dependency construction;
- errors, retries, partial failure, and effects;
- latency, throughput, consistency, and transaction expectations.

Do not confuse a short type signature with a small interface.

### Map hidden and leaked knowledge

Trace callers and collaborators. Identify duplicated decisions, pass-through
chains, provider types, repeated orchestration, co-changing files, and tests
that must reconstruct internals. Record counterevidence: independent
ownership, different failure domains, or callers that genuinely need separate
policy.

### One sentence before any seam

Write one sentence defining the module's coherent responsibility. Decide what
knowledge belongs behind it. Only then place seams and select dependency
strategies (`references/deepening.md` classifies existing clusters).

**Dependencies:** when a material generic dependency or subsystem is not
already prescribed, feed the responsibility, caller scenarios, effects, and
constraints into an explicit library/tooling evaluation before finalizing a
dependency-shaped contract. Keep the chosen provider or library behind local
application language when doing so preserves a useful change boundary; do not
wrap every stable primitive by reflex or copy a vendor API into the module
contract.

**Domain language:** when a domain term must be proposed or changed, propose
it explicitly through the project's glossary process; never coin it silently
inside a contract.

### Design the contract from use scenarios

Design from representative caller examples, including invalid input, partial
failure, cancellation, retries, and lifecycle where relevant. Specify types,
invariants, ordering, errors, effects, and performance expectations — not
methods alone.

For a consequential choice, read `references/design-it-twice.md` and compare
genuinely different designs before recommending one.

### Test the depth claim

Ask:

- Does the common caller learn less and coordinate less?
- Did implementation knowledge move behind the contract, or merely change
  names?
- Would a policy change concentrate here rather than fan out?
- Are effects and failures still honest?
- Can behavior be tested through the contract with faithful dependencies?
- Did the design avoid speculative flexibility and a generic command-shaped
  god interface?

### Route delivery to the owning concerns

Restated locally, so this folder works alone:

- **Physical placement** — file/package placement and mechanical dependency
  enforcement belong to the structure-codebase companion when installed;
  otherwise design the tree against the same rules: real ownership, enforced
  dependency direction, no ceremonial folders.
- **Published APIs** — public HTTP and contracts published or versioned across
  an ownership boundary need an explicit API-design process with
  compatibility review. Ordinary in-process component props remain with this
  skill.
- **Visibility evidence** — when the current composition is not yet visible,
  produce cited boundaries, signatures, and a call graph before judging; do
  not design from filenames alone.
- **Whole-path reduction** — when the accepted outcome must remove total
  branches, states, dependencies, layers, or operational moving parts rather
  than only improve caller leverage, that is a separate reduction exercise
  with its own evidence, not a claimed side effect of a contract change.
- **Behavior tests** — introduce the minimum enabling point an untested
  dependency needs (the finding-seams companion, when installed), capture
  legacy behavior under test (characterisation-tests), then implement with
  the tdd, testing, or refactoring companions as the change demands. At PR
  readiness follow the repository's mutation policy; where mutation is not
  meaningful, record proportionate alternate evidence.
