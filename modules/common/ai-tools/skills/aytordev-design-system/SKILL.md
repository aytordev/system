---
name: aytordev-design-system
description: "Evolve the consuming project's existing design system: discover its source of truth, token primitives and semantic roles, component anatomy, variants, and states, then propose decisions, documentation, and adoption/migration plans with compatibility and rollback. Use when auditing, extending, documenting, or migrating a design system, or when token or component decisions need escalation. Triggers on design system, token audit, semantic tokens, component anatomy, state matrix, adoption plan, migration plan."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Design-system work for the consuming project

Evolve the project's existing design system; do not invent a replacement. The
consuming project's tokens, components, and conventions supply every value; this
skill supplies the method for discovering, assessing, and changing them safely.
Upstream design-system knowledge (see `references/provenance.md`) informs the
method; WAI/WCAG 2.2 floors remain authority over both upstream advice and
project taste.

## Operating contract

| Aspect | Contract |
| --- | --- |
| Inputs | The system in scope (token files, component library, styles, existing design-system docs); the change requested (audit, addition, documentation, migration); stated constraints. |
| Outputs | A discovery summary of the current system, an assessment, proposed decisions with rationale, optional project-shaped documentation, and an adoption or migration plan with compatibility notes and a rollback path. Source edits only when separately requested. |
| Stop and ask | When critical context is missing and would materially change the result: which artifact is the source of truth, who owns the system, which platforms or modes it must cover, or what compatibility the migration must keep. State the specific question; do not guess. |
| Stop and report | When a request needs capabilities this skill does not describe: defining brand values, choosing a framework, screen or flow design (see an interface-design skill), `.pen` canvas operations, or code implementation. Name the concern; do not improvise. |

Load a reference only when its concern is in scope; every reference resolves
inside this folder and no sibling skill, host tool, framework, or platform is
required.

## Non-negotiables

1. **Discover before proposing.** Locate the existing system and its source of
   truth first. Express every proposal with the project's token primitives and
   semantic roles, components, and styling approach. Never introduce a second
   token system, hard-coded product values, or framework mandates.
2. **Never overwrite a code-bearing design-system directory.** When the target
   path already contains tokens, components, or build outputs, propose additive
   or versioned changes and say what would be lost; refuse silent replacement.
   Details: `references/adoption-and-migration.md`.
3. **Escalate accessibility conflicts; never hide them.** When a token role,
   component state, or documented convention conflicts with a WCAG 2.2 floor
   (4.5:1 normal text, 3:1 large text and non-text contrast, 24x24 CSS px
   targets, 320 CSS px reflow — each applying only as its criterion's
   applicability and exceptions define, including the inactive-component and
   target-size exemptions), name the conflict, cite the requirement, and
   propose the smallest correction inside the system. Never silently retain a
   defect or silently redesign the system. Applicability details:
   `references/components-and-states.md`.
4. **Decisions, not values.** Document decisions and rules ("use the semantic
   role, not the primitive, in components"); never ship brand palettes, chosen
   fonts, or style opinions as if they were this skill's output. Project
   documentation is optional and shaped by the project, not by fixed templates.

## References

| Concern | Reference |
| --- | --- |
| Token primitives and semantic roles | `references/tokens-and-roles.md` |
| Component anatomy, variants, and states | `references/components-and-states.md` |
| Decisions, adoption, migration | `references/adoption-and-migration.md` |
| Sources, licenses, corrections | `references/provenance.md` |

## Acceptance examples

| Example | Expected behavior |
| --- | --- |
| Existing-system reuse | A token or component proposal names the project's existing primitive, role, or component it builds on, or explains why none fits and proposes the addition separately. |
| Path conflict | Asked to create a design system where a code-bearing directory already exists, the response inventories what is there, proposes additive or versioned changes, and never overwrites it. |
| Missing critical context | Asked to migrate tokens with no identified source of truth, the response stops and asks which artifact is canonical instead of picking one. |
| Isolated loading | The folder works alone: all reference links resolve inside the folder, with no sibling-skill, host-tool, or platform requirement. |

These examples describe the instruction contract. Static repository checks
prove packaging, publication, and folder completeness only; the behavioral
examples are not executed model-behavior tests, and no runtime compliance is
claimed for them.

## Provenance

The method is adapted from the pinned MIT-licensed Nisus74 `pencil-skill`
design-system material, with recorded corrections and omissions. The pin,
license notice, and correction rationale live in `references/provenance.md`;
the original 49-file PDS-1 audit was not recovered and is not claimed.
