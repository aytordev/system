---
title: Turn Answers Into Artifact Updates
impact: CRITICAL
impactDescription: A gap is not closed until it is in the document
tags: find-gaps, conversion, write-back
---

## Turn Answers Into Artifact Updates

**Impact: CRITICAL**

Every resolved gap ends as text in the artifact. These are the three
conversion patterns.

### Answer → acceptance criterion

Write each criterion as **precondition → trigger → observable outcome**, with
a single observable outcome per criterion. Include actor, state, specific
UI/data behaviour, and any emitted events the user actually confirmed. This is
a structural discipline for criteria, not an instruction to write Gherkin
scenarios or a given/when/then test DSL — tests stay behaviour-driven: write
the failing test for the criterion's behaviour before implementing it.

Worked example:

- **Gap:** "No spec for a duplicate workspace invitation."
- **Question:** "What should the owner see when the invite API reports that
  this email is already invited?"
- **Vague answer:** "We tell the user."
- **Follow-up:** "What exact message appears, and where?"
- **Refined answer:** "Show 'This person already has a pending invitation.' in
  the email-field error slot."
- **AC to add:**

> **AC-14:** With an authenticated workspace owner on the invite form, when
> the invite API returns `already-invited`, the UI shows *"This person already
> has a pending invitation."* in the email-field error slot.

**Test:** a QA engineer should be able to execute this criterion without
asking a single follow-up question. If they'd need to ask, the criterion isn't
finished — keep refining.

### Answer → plan update

Write the sentence (or paragraph) that would have been in the plan if the
author had thought of it. Name the section, name the trade-off, name the
failure mode.

- **Gap:** "No rollback strategy for the migration."
- **Question:** "If the migration fails halfway through, how do we get back to
  a working state?"
- **Answer:** "Each step has a reverse; we have `migrate down` that runs
  reverses in order."
- **Plan update (new section):**

> **Rollback.** Each migration step in `migrations/` exposes `up()` and
> `down()`. On failure, run `pnpm migrate down` to replay `down()` for every
> completed step, in reverse order. **Data-loss risk:** any rows inserted
> between `up()` completion and failure will be orphaned by `down()` —
> mitigated by holding the `migration-in-progress` flag in Redis, which the
> app layer reads to short-circuit inserts for the duration of the migration.

### Answer → mock state spec

For every missed state, capture **name / trigger / visual / behaviour / exit**
so the state is implementable without re-asking.

- **Gap:** "Contacts list has no empty state."
- **Question:** "What should a new user see the first time they open the
  Contacts screen?"
- **Answer:** "A friendly message and buttons to import CSV or add manually."
- **State spec:**

> **empty-first-use**
> - *Trigger:* authenticated user, 0 contacts in account
> - *Visual:* centred column; illustration (reuse an existing illustration
>   token if present); H2 "No contacts yet"; paragraph "Bring your network
>   into the app."; two buttons — primary "Import CSV" (opens import sheet),
>   secondary "Add manually" (opens add-contact form)
> - *Behaviour:* buttons enabled on load, no other actions available
> - *Exit:* any successful contact add or import → `populated` list state

### Write-back discipline

Show the proposed update verbatim, then offer *write as-is / edit inline /
discard and redo*. Write to the source of truth once confirmed — a gap isn't
closed until it's in the document; verbal agreements evaporate between
sessions. Mock specs go to a companion states file or equivalent per screen.
