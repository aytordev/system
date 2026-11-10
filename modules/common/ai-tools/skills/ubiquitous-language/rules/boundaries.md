---
title: Know Where the Language Lives
impact: HIGH
impactDescription: Separates authority from evidence and keeps scope honest
tags: ubiquitous-language, scope, boundaries
---

## Know Where the Language Lives

**Impact: HIGH**

### The four places language appears

1. **The declared glossary** is the naming authority for its bounded context.
   Canonical spelling and capitalization matter whenever the concept is named.
   Use the repository's chosen file location and schema; do not impose a
   different glossary format.
2. **Domain code and executable examples** consume and exercise that language.
   Identifiers, branded types, DSL verbs, and test titles should use the
   canonical terms.
3. **The rest of the maintained system** propagates approved terms through
   schemas, APIs, documentation, diagrams, fixtures, and generated clients.
   Public wire vocabulary may need deliberate versioning even after an
   internal rename.
4. **Speech, plans, research, comments, historical documents, and existing
   code** expose candidate vocabulary and possible drift. They are evidence
   for a proposal, not authority that can silently canonize a term.

Absence from the glossary means **not yet agreed**. It does not automatically
approve or forbid a word.

Working names must be visibly provisional and name how they will be ratified
or replaced. Do not let a placeholder spread as if it were approved language.
Historical plans and specifications can explain why a name once existed, but
they do not override the current glossary.

### Out of scope — restate the rule, treat companions as optional

| Situation | Rule to apply inline |
|-----------|---------------------|
| Value objects, entities, aggregates, bounded-context boundaries | Model the concept per the repository's domain-design conventions; the glossary records language, not structure |
| Ports/adapters and architecture layering | Structural policy lives in architecture rules, never in a vocabulary lint |
| DSL and test-title vocabulary in the outer loop | Use the project's acceptance/specification conventions; route new verbs through the protocol |
| Recording a model-changing rename | Use the repository's decision-record mechanism |
| Naming questions during discovery | Use the host's available question mechanism |
| Terms from *other* bounded contexts | If Ordering keeps talking about Shipping's concepts, that is a context-mapping conversation, not a glossary entry |

Where a domain-driven-design, hexagonal-architecture, or structure-codebase
skill is installed, it may own the full treatment of these questions; treat it
as optional and never as a dependency of this folder.

## Verification Checklist

- [ ] One repository-declared glossary authority per bounded context
- [ ] The repository's declared glossary format and location are preserved
- [ ] Canonical spelling and capitalization are used when naming declared concepts
- [ ] Missing terms are treated as not yet agreed
- [ ] No domain term coined without the five-step protocol — proposals presented, never adopted silently
- [ ] Glossary diff rides the same reviewable change as the code that introduces the vocabulary
- [ ] Replaced terms recorded as deprecated aliases with replacements
- [ ] Rejected aliases point to the owning bounded context and canonical term
- [ ] Model-changing renames use the repository's decision-record mechanism
- [ ] Published language at context boundaries versioned, never casually renamed
- [ ] Approved terms propagated through code, types, schemas, APIs, tests, docs, diagrams, fixtures, and generated clients in scope
- [ ] Working names are visibly provisional with a ratification or replacement path
- [ ] Alias and word-form checks are scoped to their owning bounded context
- [ ] Lint rules carry three-part teaching messages
- [ ] Green lint results are reported as targeted ratchets, not whole-repository language proof
- [ ] Positive controls prove forbidden vocabulary is detected
- [ ] Brownfield enforcement is scoped, its baseline does not grow silently, and its limits are reported
- [ ] Provisional spike vocabulary is ratified or replaced before promotion
