---
name: review-lifecycle
impact: HIGH
impactDescription: Output location, wiring, review sequence, deletion
---

# Review Lifecycle

**Impact: HIGH**

## Output location

Place the storyboard HTML in the project's existing mocks or launch-planning
folder, next to where the mocks live so relative iframe paths work. Common
locations:

- `apps/<app>/design-mocks/<scope>-audit.html`
- `design-mocks/<scope>-storyboard.html`

Treat the storyboard as an active review artifact, not a permanent record.
Follow the repository's artifact layout while it is in use; delete it when
the reviewed outcome ships or its assumptions are superseded unless a named
owner still maintains it for a current question. Git history is the archive.

Match the naming convention of other artifacts in the repo. If there is a
mock manifest or index page, add a featured link so the storyboard is
discoverable.

## Convention integration

After producing the storyboard:

1. **Link it from the project's mocks manifest or index page** under an
   "Active audits" or similar section while it is current.
2. **Reference it from the active decision artifact** (plan, audit note, or
   PR description) as the visual companion.
3. Remove active links when the storyboard is deleted or superseded; promote
   lasting design constraints to maintained product documentation or tests.

## Proposed review sequence

The storyboard's section 8 records the steps from review to code-lands:

1. The user reviews the page and approves existing mocks or flags concrete
   fixes.
2. The brainstorm questions on each gap card are answered.
3. The gap mocks are produced through the local design pipeline, then run
   through the same audit disciplines as the existing mocks.
4. Fixes to existing mocks flagged by the audit are applied.
5. The reviewed mocks and audit note are saved through the repository's
   authorized delivery workflow. Implementation starts.

Every audit-checklist item names a real design discipline that will actually
run; never list a review step that cannot be executed locally.

## Non-negotiables and rules of thumb

- Prefer live, rendered mocks when the authoritative source is embeddable and
  safe; use the labelled static-authority fallback otherwise.
- Every gap has brainstorm questions.
- One page, not a tree.
- `<pre>` for ASCII. Never `<div class="whitespace-pre">`.
- Use the project's existing design tokens.
