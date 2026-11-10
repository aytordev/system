---
name: expectations
description: "Trigger: a non-obvious discovery, gotcha, workaround, or decision appears and the user asks where it should live, be written down, or be kept for the next person. Routes each fact to its durable owner and separates reusable principle from project-local policy."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Expectations

Route each discovery to the artifact that owns its truth. Never turn one
project's architecture, delivery process, or tooling conventions into universal
guidance.

`rules/` is bundled with this skill. Repository paths such as `docs/decisions/`
or `AGENTS.md` refer to the target repository, not to files beside this skill.
Use the host's file and search capabilities; report a missing capability instead
of claiming a fact was recorded.

## Activation Contract

Use this skill when:

- The user just discovered, learned, or found out something non-obvious.
- The user asks where a fact, gotcha, workaround, or decision should be recorded.
- The user asks whether something belongs in agent guidance, a `README`, an ADR,
  a glossary, a test, or a reusable skill.
- A task is closing and the question "what did I wish I had known at the start?"
  has an answer worth keeping.

## Hard Rules

1. **Reusable principle or local policy?** A principle applies across projects
   without one repository's names, paths, tools, or release process. A policy
   depends on this product's domain, architecture, risk posture, workflow, or
   infrastructure. When in doubt, make the narrower local update: reuse must be
   earned by evidence from more than one project, not inferred from one success.
2. **One owner per fact.** Do not duplicate what the repository already records:
   current code structure, Git history, or behaviour obvious from source and
   tests.
3. **Promote before deleting.** If a temporary artifact reveals a lasting
   constraint, move the constraint to its owner first. Git history is the
   archive, not the destination.
4. **State the classification.** Every recommendation says explicitly whether it
   is a reusable principle or a local policy.

## Capture Criteria

Capture a learning when any of these is true:

- It would save future developers significant time.
- It prevents a class of bugs or errors.
- It reveals non-obvious behaviour or constraints.
- It captures architectural rationale or trade-offs.
- It documents domain-specific knowledge.
- It identifies an effective pattern or anti-pattern.
- It clarifies a tool setup or configuration gotcha.

Kinds worth capturing: gotchas, patterns, anti-patterns, decisions, edge cases,
and tool knowledge.

## Destination Table

| Learning | Destination | Why |
| --- | --- | --- |
| Cross-project practice with evidence beyond one repository | The relevant reusable skill | Reusable guidance stays provider- and project-neutral |
| Project-specific architecture, delivery rule, tool setup, or gotcha | Repository agent guidance or canonical project documentation | Local policy stays with the project that owns it |
| Domain term, definition, alias, or naming rule | The owning bounded context's authoritative glossary | Vocabulary has one context-scoped authority |
| Accepted architecture, dependency, platform, or build-versus-adopt decision | The repository's accepted ADR location | Durable decisions retain rationale and rejected alternatives |
| Observable behavioural constraint or regression | Source code and executable tests | The maintained behaviour proves the rule |
| In-flight blocker, sequencing choice, or scope change | Current status artifact or active plan | Temporary delivery knowledge expires with the work |
| User-facing behaviour, setup, API usage, or operations | Maintained product, package, or operational documentation | Readers find current truth at the owning surface |

## Execution Steps

1. **Classify** the fact: reusable principle or local policy.
2. **Find the owner** in the destination table before writing anything.
3. **Check for an existing record.** If the owner already states it, improve that
   text instead of adding a second copy.
4. **Write it where the owner lives**, in that surface's own format.
5. **Confirm the outcome** to the user: what was recorded, where, and why that
   owner.

## Output Contract

Name the destination, the classification, and whether you edited an existing
record or created one. If the honest answer is "nowhere yet — this is unproven
in a second project", say that and record it as local policy.

## References

- `rules/capture-format.md` — entry shape and communication rules.
- `references/provenance.md` — upstream source, revision, and licence notice.

Prose for the document itself is outside this skill. If a companion writing
skill is not installed, apply the rule directly: match the surrounding
document's structure, define terms on first use, and keep each entry scannable.
Domain terminology belongs to the glossary that owns the context, not here.
