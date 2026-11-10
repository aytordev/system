---
name: wtf
description: "Trigger: the user explicitly asks to re-explain the immediately previous response because it did not land (wtf, too dense, say that again more clearly). Never invoked implicitly. Re-explains it in plain, precise UK English while preserving its meaning and every technical detail, without starting new work."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# WTF

Re-explain the immediately previous response when it did not land: unclear, too
dense, or difficult to follow. The re-explanation is a rewrite of an existing
answer, not a fresh one: the content budget, the claims, and the boundaries
all come from the previous response. Invoke this skill only when the user
explicitly asks for it; never fire implicitly on confusion the user has not
voiced.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- The user explicitly asks to re-explain the immediately previous LLM response.
- The user signals the previous response did not land: "wtf", "too dense",
  "say that again more clearly", or an equivalent request.

Do not use it for explaining a new topic, summarising an earlier turn, or any
task other than re-explaining the immediately previous response. If the user
then asks a follow-up question, answer it as new work — the re-explanation
contract does not extend to it.

## Hard Rules

1. **Re-explain only the immediately previous LLM response.** Keep the
   explanation about that response; do not perform a new task and do not
   answer questions the previous response never addressed.
2. **Preserve its meaning and all relevant technical details**: constraints,
   exceptions, conditions, dependencies, examples, values, units, and
   warnings. Nothing the response carried may be silently dropped.
3. **Do not introduce new information.** Nothing that was not in the previous
   response enters the explanation — including material read from terminology
   files. State uncertainty when the previous response was uncertain.
4. **Use the glossary that owns the relevant context** to select canonical
   terms and meanings. Resolve the authority per `rules/glossary-authority.md`
   before rewording domain terms; never create a new glossary convention.
5. **Write in plain, precise UK English**, in the style inspired by ASD-STE100
   Simplified Technical English. The full writing rules and clarity controls
   are in `rules/plain-language.md`.

## Execution Steps

1. **READ** — read the immediately previous LLM response in full.
2. **RESOLVE TERMINOLOGY** — if the response uses domain terms, follow
   `rules/glossary-authority.md`: inspect repository guidance for its declared
   glossary authority and bounded-context scope; otherwise check common
   locations without creating a new convention. Use only the glossary that
   owns the relevant context.
3. **REWRITE** — re-explain the response with a clearer structure and simpler
   wording under `rules/plain-language.md`: active voice, short sentences, one
   main action each, prerequisites before actions, exact nouns instead of
   pronouns, uncommon terms defined on first appearance.
4. **VERIFY** — check the result against the completion criterion: it
   re-explains the immediately previous response, preserves its meaning and
   relevant technical details, uses clearer plain language, and starts no new
   work.

## Output Contract

The reply is the re-explanation itself. It is complete when it re-explains the
immediately previous LLM response, preserves its meaning and relevant
technical details, and uses clearer plain language without starting new work.
Where the original was uncertain, say so with the same scope. A reply that
adds new claims, answers a different question, or drops a constraint is not
complete.

## References

- `rules/glossary-authority.md` — resolving the terminology authority.
- `rules/plain-language.md` — writing rules and clarity controls.
- `references/provenance.md` — upstream source, revision, and licence notice.
