---
name: folder-structure
description: "Trigger: only the exact legacy name folder-structure, an explicit $folder-structure invocation, or an old reference to it. Deprecated compatibility alias: redirect the structure request to the structure-codebase skill and never improvise the retired screaming-architecture convention."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Folder Structure Compatibility Alias

The former screaming-architecture guidance published under this name has been
retired. `structure-codebase` is the sole authoritative skill for physical code
organization and dependency-boundary design.

This alias contains no independent architecture guidance. Its whole job is a
safe redirect: it exists so an old invocation, saved prompt, or muscle-memory
trigger still lands on correct behaviour instead of improvised structure
advice.

## Activation Contract

Use this skill only when one of these is literally present:

- The request names `folder-structure` exactly (for example an explicit
  `$folder-structure` invocation).
- An old document, prompt, or habit refers to the former folder-structure
  guidance.

Do not activate it implicitly for general folder or architecture questions:
those belong to the structure-codebase skill whenever it is installed, and to
your own best judgement with that skill's absence noted when it is not.

## Hard Rules

1. **This folder owns no structure guidance.** Never invent, reconstruct, or
   infer architecture rules under this name — not from memory of the retired
   guidance, not from conventions of the surrounding repository.
2. **Do not reproduce the retired convention.** The former guidance protected a
   `domain/` directory with sibling `use-cases/` directories as a universal
   shape. That convention is retired: it is not to be reproduced, recommended,
   or partially revived under any wording.
3. **Delegate by name, not by relative path.** Name the structure-codebase
   skill in prose. Do not reference or load any file outside this folder; the
   alias must stay valid when it is installed alone.
4. **When the canonical skill is unavailable, stop and ask.** Tell the user
   that `structure-codebase` is required and how it is normally obtained. Do
   not improvise in its place, and do not answer with faded recollections of
   the retired guidance.

## Execution Steps

1. Recognize the legacy trigger and reply that `folder-structure` is a
   deprecated alias for `structure-codebase`.
2. If the structure-codebase skill is installed, read its `SKILL.md`
   completely and follow it as the governing skill for this request, including
   whichever references it selects for the current project shape.
3. If it is not installed, stop: report the missing skill, do not proceed with
   any structure proposal, and leave the repository unmodified.
4. Never reinterpret a legacy request as instruction to resurrect the retired
   `domain/`-plus-`use-cases/` convention.

## Output Contract

The reply is a redirect, not guidance. State: that this name is deprecated,
that structure-codebase is the canonical skill, whether it was found and
followed or is missing, and — when missing — what must be installed before the
request can be answered. No tree proposals, naming rules, or migration advice
originate from this alias.

## References

- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional. The alias depends on nothing: the
structure-codebase companion is named because it is the canonical successor,
not because this folder loads it, and every required decision above is
restated inline.
