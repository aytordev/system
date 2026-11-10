---
name: storyboard
description: "Trigger: the user asks to see the whole flow in one place, audit the mocks together, or put everything on one page, or when reviewing several UX surfaces separately would hide transitions, inconsistencies, or gaps. Produces a single reviewable HTML storyboard embedding related mock surfaces side-by-side with per-mock audit checklists, an ASCII flow diagram in a pre element, state-gap flags, and gap cards whose brainstorm questions must be answered before any new mock is drafted. Embeds mocks as sandboxed iframes only when authoritative and safe to load; otherwise uses a labelled static authority."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Storyboard

A **storyboard** is a single reviewable HTML page that stitches every UX
surface in a scope of work into one view. Existing mocks are embedded as
sandboxed `<iframe>` elements only when they are authoritative and safe to
load; otherwise the page uses a labelled static image. A flow diagram at the
top shows how the user moves through them. Gap cards mark mocks that still
need producing, each carrying brainstorm questions that must be answered
before drafting. Per-mock audit checklists give the reviewer a place to
approve or flag concrete fixes.

**Purpose:** move the design audit from "open a dozen tabs and try to hold
the flow in your head" to "open one page and scroll". A storyboard is a
pattern, not a template: every storyboard has the same sections in the same
order, with scope-specific content.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- A flow has enough related surfaces or states that reviewing them separately
  hides transitions, inconsistencies, or gaps (signup → verification →
  onboarding; a settings flow with destructive and recovery states).
- A feature spans multiple states across three or more steps and needs a
  single-feature audit.
- The user explicitly asks for "everything in one place", "the whole flow",
  "audit the mocks", or "see all of this together".
- New mocks are planned: storyboarding the existing ones first reveals gaps
  visually and forces per-gap questions before drafting.

Do not use it for single-mock work (open the mock and run the design audit
there), API/data-migration/ops items with no UX surface, exploratory
throwaway work before scope settles, or features already fully built
(review the live surfaces instead).

## Hard Rules

1. **One page, not a tree.** Scrolling one page beats navigating a tree of
   links. If the scope becomes unreadable, split by sub-flow — one page per
   split, with the split reason documented.
2. **Every gap card carries brainstorm questions.** Each bullet is one
   explicit decision required before drafting the mock. A gap card without
   questions is dead weight; brainstorm now or remove the card.
3. **Prefer live, rendered authority.** Use iframes when the authoritative
   source is embeddable and safe; label static fallbacks non-interactive and
   record which states cannot be exercised.
4. **The checklist is genuine, not decorative.** Every audit-checklist item
   corresponds to a design discipline that will actually run locally. List
   only what will run.
5. **`<pre>` for every ASCII diagram.** Never `<div class="whitespace-pre">`;
   formatters reformat the latter and destroy the layout.
6. **Reuse the project's design tokens.** Never invent new colours, fonts, or
   layout systems for the storyboard; use a minimal accessible fallback only
   when no local convention exists.
7. **Sandbox every embedding.** Follow `rules/embedding-safety.md`; never
   embed credential-bearing URLs or private third-party pages.

## Execution Steps

1. **GATHER** — scope code and title; existing mocks in scope; the user flow
   as a sequence of states and transitions; gaps (new mocks needed);
   upstream/adjacent surfaces for context; links to companion docs.
2. **DRAFT** — brainstorm questions per gap (do not answer them — the user
   will). Produce the HTML at the canonical project path with the nine
   required sections in `rules/page-structure.md`.
3. **HARDEN** — apply iframe sandbox, content-security policy, and prettier
   safety from `rules/embedding-safety.md`.
4. **WIRE** — link from the mocks manifest or index page while current;
   reference from the active decision artifact.
5. **REVIEW** — the user answers gap questions and approves existing mocks or
   flags fixes; follow `rules/review-lifecycle.md` for the sequence to
   code-lands and for deletion.

## Output Contract

Return the storyboard file path, a summary of the flow diagram and gaps, and
the outstanding brainstorm questions per gap card. The page is an active
review artifact, not a permanent record; report its planned deletion point.

## References

- `rules/when-to-storyboard.md` — triggers, refusals, and input gathering.
- `rules/page-structure.md` — the nine required sections and style conventions.
- `rules/embedding-safety.md` — iframe sandboxing, CSP, and formatter safety.
- `rules/review-lifecycle.md` — wiring, review sequence, and artifact deletion.
- `references/provenance.md` — upstream source, revision, and licence notice.

Where a story-splitting, planning, or find-gaps skill is installed, it is an
optional companion after the audit: splitting when the storyboard reveals the
feature is too broad, planning to sequence the reviewed scope, and gap review
to turn unanswered brainstorm questions into acceptance criteria. The
storyboard itself restates those uses inline and depends on none of them.
