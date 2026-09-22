---
name: aytordev-pen-ops
description: "Execute authorized changes in a pen.dev (Pencil) design-tool session using only capabilities observed in that session: inspect the open document, selection, and live tool schemas first, propose read-only, then apply narrow bounded edits with readback or visual verification. Use when a user asks to inspect, change, or verify designs in a running Pen session. Triggers on pen.dev, Pencil, .pen document, canvas edit, design tool session."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Pen session operations

Operate safely inside a running pen.dev design-tool session. This skill owns
the operational-safety method only: what to inspect before acting, how to
separate inspection from authorized edits, and when to stop. It does not choose
aesthetics, tokens, or components, and it never launches, authenticates to, or
provisions the tool.

## Operating contract

| Aspect | Contract |
| --- | --- |
| Inputs | A running Pen session the user already opened (never launched by this skill); the change requested; the user's explicit authorization for edits. |
| Outputs | An observed-capability summary, a read-only inspection of the current document state (target, selection, relevant identifiers), a change proposal, and — only when separately authorized — applied edits with per-batch verification evidence and an honest report of anything unverified. |
| Stop and ask | Before any edit that was not explicitly authorized; when the requested change conflicts with project-owned style or component decisions; when critical context is missing and would materially change the result (which document, which scope, what "done" means). State the specific question; do not guess. |
| Stop and report | When a needed operation or tool is absent from the session's exposed capabilities, when a batch fails or lands partially, when verification is unavailable, or when the session's behavior contradicts any documented recipe. Name what was observed, what was applied, and what remains unverified; never improvise an undocumented operation. |

## Non-negotiables

1. **Observe capabilities before choosing operations.** Enumerate the tool
   schemas actually exposed in this session and the current document state
   before selecting operations. Use only observed capabilities. Documentation
   examples — including this skill's own historical references — are not
   executable authority; a documented tool that is absent or behaves
   differently is a stop-and-report condition, not an invitation to guess
   signatures. Details: `references/inspection-and-editing.md`.
2. **Inspection and proposals are read-only; edits need explicit
   authorization.** Present the inspected state and a scoped proposal, and
   wait for a clear yes before the first mutating call. No authorized edit
   reaches past the confirmed scope.
3. **Narrow changes, bounded batches, verified results.** Prefer property-level
   updates over replacement; keep each batch small enough that a failure's
   blast radius is obvious; after each batch, verify by readback or visual
   check when the session offers one, and say so when it does not. On a failed
   or partially landed batch, stop and report instead of replaying blindly.
   Never silently replace a component or rewrite an entire file.
4. **Never choose aesthetics, system tokens, or component substitutes.** Style
   direction, token values, and component selection belong to the project and
   to the design-system owner. Apply the user's stated direction inside the
   authorized scope; escalate conflicts instead of resolving them silently.
   Details: `references/inspection-and-editing.md`.

## References

| Concern | Reference |
| --- | --- |
| Inspection, authorization, batching, verification method | `references/inspection-and-editing.md` |
| Sources, licenses, corrections, stale-recipe record | `references/provenance.md` |

## Acceptance examples

| Example | Expected behavior |
| --- | --- |
| Missing capability | Asked to perform an operation whose tool is not exposed in the session, the response reports the gap and stops instead of inventing an operation or reusing a documented name from another environment. |
| Read-only review | Asked only to review a design, the response inspects the document, reports observations and a proposal, and performs no mutating call. |
| Authorized scope with partial outcome | A batch fails midway; the response stops, reports exactly which changes landed and which did not, marks the outcome uncertain, and asks how to proceed instead of replaying the batch. |
| Isolated loading | The folder works alone: all reference links resolve inside the folder, with no sibling-skill, host-tool, or platform requirement. |

These examples describe the instruction contract. Static repository checks
prove packaging, publication, and folder completeness only; the behavioral
examples are not executed model-behavior tests, and no runtime compliance is
claimed for them. No live Pen session, model call, or app interaction was used
to validate this skill.

## Provenance

The method is adapted at the concept level from the pinned MIT-licensed
Nisus74 `pencil-skill`, with recorded omissions and corrections against both
the pinned recipe and the current official pen.dev documentation. The pin,
license notice, and the stale-recipe record live in
`references/provenance.md`; the original 49-file PDS-1 audit was not recovered
and is not claimed.
