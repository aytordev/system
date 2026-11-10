---
title: Ask With Discipline
impact: HIGH
impactDescription: Cadence and question quality decide the outcome
tags: find-gaps, questioning, structure
---

## Ask With Discipline

**Impact: HIGH**

### Working with the user

- **Ask only what the user can answer.** "What's the error-handling strategy?"
  is a design spike. "When the payment declines, what message should the user
  see?" is a decision.
- **One question per turn** — unless two are tightly coupled ("what's the
  error, and can the user retry from it?"). A structured-input request may
  batch tightly related subquestions only within the host capability's
  supported limits; batching *unrelated* gaps into one request reverts to a
  gap dump. If you find yourself typing "Also," stop and pick the most
  important one.
- **Surface trade-offs, don't hide them.** If an answer creates a downstream
  issue: "That means anonymous users can still submit the form but get a 401 —
  is that the experience you want, or redirect to sign-in first?"
- **Know when to escalate.** If a gap needs a decision the user can't make
  alone, name the actual owner, park it explicitly with a question and owner,
  and continue.
- **Don't re-ask triage.** You've already decided each gap is a Blocker /
  Should-address / Nice-to-have — state the gap, ask the concrete question,
  capture, move on.

### Free text or structured input

Every question is either free text or structured through a capability the
current host actually exposes. Inspect and follow that capability's schema
rather than assuming a provider-specific tool name, fields, or limits. Pick
based on where the value lives:

- **The options are the value** → supported structured input. Picking is
  faster than generating, the user benefits from seeing the choice space, and
  the common answers are knowable.
- **The user's specific words are the value** → free text. Domain vocabulary,
  microcopy, novel decisions, anything that will be copied verbatim into the
  artifact.

Good structured fits — the answer space is genuinely enumerable and recurs:

| Situation | Why it helps |
| --- | --- |
| Failure strategy | Retry / fail fast / queue / fail-over — each has a named trade-off worth surfacing |
| Severity re-triage | Blocker / Should / Nice — useful when your triage and the user's disagree |
| State-variance scoping | Which states matter for v1 — selecting named choices reduces back-and-forth |
| Parking decisions | Park with owner / escalate now / keep working — closes the gap-handling loop |
| Write-back confirmation | Write as-is / edit inline / discard — classic 3-option close after you've drafted the update |
| Variant comparison | Two AC drafts or two state specs in a supported side-by-side representation |

Bad fits — don't force structure where it doesn't belong:

- **Microcopy** — "what error message should appear?" needs the user's exact
  words; structured options destroy them.
- **Truly open questions** — "what are you trying to achieve here?" You'd be
  inventing the options.
- **Domain-expert questions** — "what does 'confirmed' mean in our pricing
  flow?" The user knows things you don't; options anchor them to your guesses.
- **Performative prompts** — if the right answer is already obvious, don't
  ask. Just propose it.

Structural rules:

- Batch only **tightly-related** subquestions and stay within the host's
  supported question and option limits.
- Follow the discovered schema for labels, descriptions, recommendation
  markers, custom-answer behavior, and previews; do not invent unsupported
  fields.
- Keep labels short and put the material trade-off in the option description
  when that field exists.
- Use side-by-side previews only when the host supports them and the artifacts
  are genuinely comparable.

### Anti-patterns

- **Dumping a list of 20 gaps and walking away.** That's a report, not a
  review. Loop through them.
- **Asking "do you want to address this?" for every gap.** You already
  triaged.
- **Accepting vague answers.** Keep refining until there's a specific,
  observable outcome.
- **Bundling questions.** "What's the message, when does it show, can they
  retry, and is it logged?" → four turns, not one.
- **Silently rewriting the user's language.** If they say "checkpoint," write
  "checkpoint," not "save state."
- **Skipping the artifact write-back.** A gap isn't closed until it's in the
  document.
- **Letting one giant gap swallow the session.** If a single gap needs 30
  minutes of discussion, it's a design spike. Park it, keep moving, come back.
- **Stopping at an arbitrary quota.** Finish the relevant checklist and follow
  evidence across linked artifacts; do not invent gaps to look thorough.
- **Treating taste as a gap.** Stylistic preferences aren't gaps. Absence of
  decision is.
- **Reviewing the artifact in isolation.** Cross-check plan ↔ AC ↔ mocks;
  contradictions between them are gaps too.
- **Inventing options just to use structured input.** If you don't know the
  real choice space, ask free text.
- **Batching unrelated gaps into one structured request.** Questions about
  different gaps are a gap dump in disguise.
