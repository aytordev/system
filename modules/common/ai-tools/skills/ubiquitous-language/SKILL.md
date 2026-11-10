---
name: ubiquitous-language
description: "Trigger: naming domain concepts, a term missing from or fighting the glossary, synonyms or near-duplicate identifiers, bootstrapping a glossary, or renaming across a bounded context. Makes the repository-declared glossary the naming authority: one ubiquitous language per bounded context, an explicit five-step protocol (detect, propose, decide, record, rename) for every new, changed, or suspect term, recorded decisions instead of drift, context-scoped aliases, and safe renames with deliberately versioned published boundaries."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Ubiquitous Language

A change in the language **is** a change to the model (Evans). One ubiquitous
language per bounded context — apply a single language to a whole enterprise
and you will fail (Vernon). This skill makes the repository's declared glossary
the naming authority. The language is expected to evolve, but only through an
explicit, recorded decision.

The documented agent failure mode this kills: terminology drift —
`processUserData` vs `processUserInfo` near-duplicates, "booking" quietly
becoming "reservation" mid-feature. Prompt-level glossaries steer;
deterministic gates enforce.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Naming a domain concept, or a term is missing from or fights the glossary.
- You spot a synonym or near-duplicate, or a term feels awkward in
  conversation.
- Bootstrapping a glossary for a greenfield or brownfield context.
- Renaming a term across a bounded context, or deciding where a rename may
  cross a published boundary.

Do not use it for aggregate and bounded-context design, module structure, or
generic code style — treat the companion skills named in `rules/boundaries.md`
as optional and restate their rule inline when they are not installed.

## Hard Rules

1. **One declared glossary per bounded context is the naming authority.** Use
   the repository's chosen file location and schema; do not impose a different
   glossary format. Canonical spelling and capitalization matter whenever the
   concept is named.
2. **Absence from the glossary means not yet agreed.** It does not
   automatically approve or forbid a word.
3. **Silent evolution is forbidden.** Every new, changed, or suspect domain
   term runs the five-step protocol: DETECT, PROPOSE — never adopt, DECIDE,
   RECORD, RENAME (`rules/language-protocol.md`).
4. **An agent never coins a domain term silently.** Present term, proposed
   definition, bounded context, example sentence, and alternatives considered
   to the human, one term at a time, with a recommendation.
5. **The glossary diff rides the same reviewable change** as the code that
   introduces the vocabulary. Rejected or replaced terms become aliases that
   name the owning context and canonical replacement.
6. **Rename decision first, then code, tests, and glossary together** in one
   reviewable change. Inside the bounded context, rename freely. At the
   published boundary — APIs, event schemas, database contracts other contexts
   consume — the language is versioned deliberately: additive evolution,
   explicit deprecation, never a casual rename.
7. **Report enforcement honestly.** Until a generated lint layer or equivalent
   gate exists, everything here is convention — say so. A green targeted
   ratchet is not proof that every identifier and prose passage uses the
   language correctly, and every guard needs a positive control that proves
   known-forbidden vocabulary fails with the replacement named.

## Execution Steps

1. **DETECT** — name the trigger: missing term, synonym or near-duplicate,
   awkward-in-conversation signal, or a targeted lint hit.
2. **PROPOSE** — stop; do not use the term yet. Present it with definition,
   context, example sentence, and alternatives (one structured question or one
   concise plain-text question).
3. **DECIDE** — the human approves, renames, or rejects.
4. **RECORD** — add or update the glossary entry in the same reviewable
   change; model-changing renames use the repository's decision-record
   mechanism, routine additions need only the glossary diff.
5. **RENAME** — refactor code, tests, DSL, and docs together; propagate
   through schemas, APIs, diagrams, fixtures, and generated clients in scope.
6. When creating or editing a glossary, follow
   `references/glossary-format.md` for schema, aliases, forms, bootstrap
   paths, and what does not belong in a glossary.

## Output Contract

Report the protocol outcome per term: the decision taken (approved / renamed /
rejected), where it was recorded (glossary path, decision record), and what was
renamed or deliberately left untouched. When enforcement tooling exists, state
its configured paths and token classes and whether a positive control was run;
never imply whole-repository language proof from a targeted green run. If you
declined to introduce a term, say so and leave the glossary unchanged.

## References

- `rules/language-protocol.md` — the five steps, the boundary rule, the worked example.
- `rules/mechanical-enforcement.md` — lint ratchets, teaching messages, adoption spectrum.
- `rules/boundaries.md` — where the language lives, what is out of scope, the checklist.
- `references/glossary-format.md` — schema, aliases, bootstrap paths.
- `references/provenance.md` — upstream source, revision, and licence notice.
