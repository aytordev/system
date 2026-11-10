---
name: when-to-storyboard
impact: HIGH
impactDescription: When to produce a storyboard and what to gather
---

# When to Storyboard

**Impact: HIGH**

## Produce one when

- **A flow has enough related surfaces or states that reviewing them
  separately hides transitions, inconsistencies, or gaps.** Examples:
  signup → verification → onboarding, or a settings flow with destructive and
  recovery states.
- **Before a planned chunk of work** — and only when the combined review earns
  its maintenance cost. A count of surfaces alone is not a reason to create
  another artifact.
- **Single-feature audit** when a feature spans multiple states (a flow with
  loading / empty / populated / error states across three or more steps).
- **The user explicitly asks** for "everything in one place", "the whole
  flow", "audit the mocks", "I want to see all of this together".
- **Before producing new mocks.** Storyboarding the existing ones first
  reveals gaps visually and forces per-gap brainstorm questions before
  drafting.

## Do NOT produce one when

- **Single-mock work** (a one-off copy fix on a settings page). Open the mock
  and run the design audit there.
- **Purely API / data-migration / ops items** with no UX surface. No mocks
  means nothing to storyboard.
- **Exploratory / throwaway work** before scope is settled. A storyboard is a
  reviewing artifact; you need something worth reviewing first.
- **Features already fully built.** The storyboard is pre-implementation. For
  post-hoc visual review, audit the live surfaces directly and skip this
  skill.

## Inputs the skill gathers

Before drafting the HTML, gather:

1. **Scope code + title.** For example `Onboarding v2 — reset regression`,
   `Settings page — profile + notifications`, `M3 · address book`. Sets the
   page title and breadcrumb.
2. **Existing mocks in scope.** Walk the project's design-mocks folder (or
   equivalent) and collect the paths relevant to this scope; each becomes an
   embedded panel.
3. **User flow.** The sequence of states and transitions the user walks
   through, drawn as ASCII in a `<pre>` block, with gaps marked by a
   distinctive colour or glyph.
4. **Gaps.** New mocks the scope needs but does not have yet. Each gap gets
   its own card with brainstorm questions the user must answer before the
   mock is produced — no gap without questions.
5. **Upstream / adjacent surfaces.** Not part of this scope but provide
   context (where the user lands after this flow); embed at smaller height.
6. **Links to companion docs.** Plan entry, design brief, relevant ADR,
   parent index page.

If gathering reveals the feature is too broad, name that finding and route it
back to a splitting conversation before storyboarding further; do not
pre-commit to answers the scope has not made.
