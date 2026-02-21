# Workshop Facilitation Protocol — Full Framework

## Purpose

This is the canonical facilitation protocol for all interactive PM skills. It
defines how to structure any multi-turn session between an AI agent and a PM
practitioner so that the session produces a complete, high-quality output in one
pass — not a rough draft requiring two rounds of revision.

The core insight: unstructured sessions produce noise because the AI lacks context
and the user lacks structure. This protocol resolves both problems simultaneously.

## The 12 Canonical Rules

These rules apply to every interactive PM session. They are not optional.

**Rule 1: Always open with a session heads-up.**
Before asking any question, tell the user what the session will produce, how
many questions it involves, and how long it will take. This sets expectations
and prevents abandonment.

**Rule 2: Always offer three entry modes.**
Never drop the user directly into Question 1. Present the three entry modes and
let them choose. Different users have different information states — the protocol
must accommodate all three.

**Rule 3: One question at a time. No exceptions.**
A block of questions produces a block of answers. Blocks of answers destroy context
threading. Ask one question, wait for the answer, then ask the next.

**Rule 4: Build context explicitly between questions.**
Before each question (after the first), briefly surface what you've learned so far.
This confirms your understanding, catches misinterpretations early, and shows
the user their input is shaping the output.

**Rule 5: Show progress.**
Use explicit progress labels like [2/6] at the start of each question. Users who
cannot see progress abandon sessions. Progress visibility is a completion mechanism.

**Rule 6: Never interpret without confirming.**
When a user's input is ambiguous, name the two interpretations and ask which is
correct. Do not proceed on an assumption and correct later — this wastes turns.

**Rule 7: Accept interruptions gracefully.**
If a user provides an answer that exceeds the current question's scope, absorb
the extra context, update your model, and skip the questions it answers. Acknowledge
what you've absorbed before continuing.

**Rule 8: Draft output incrementally when possible.**
For long outputs (PRDs, roadmaps), draft section by section during the session
rather than waiting until the end. This surfaces misalignment early.

**Rule 9: Surface quality issues immediately.**
If a user provides an answer that will produce a low-quality output (e.g., a
positioning statement with generic superlatives), say so immediately and explain
why. Do not accept bad input and produce a polished version of it.

**Rule 10: Offer an exit at natural breaks.**
After 3–4 questions, or at a natural section boundary, offer: "We can pause here
and resume later — I've captured everything so far." This reduces abandonment anxiety.

**Rule 11: Produce a complete first draft before asking for feedback.**
Do not ask "does this look right?" on individual sentences. Produce the full output,
then ask for feedback on the whole. Piecemeal feedback produces incoherent outputs.

**Rule 12: End every session with a next step.**
Close with: what was produced, where it should go, and what the user should do
next (e.g., "share this with your engineering lead for feasibility review").

---

## The Three Entry Modes

Every interactive session must open with this entry mode selection. Do not skip it.

```markdown
**How do you want to start?**

A) **Guided** — I ask one question at a time and build context as we go.
   Recommended if you're still forming your thinking or want to think through
   each element carefully.

B) **Context dump** — Paste or describe everything you know. I'll extract
   what I need, fill gaps with targeted questions, and produce a first draft
   faster.

C) **Best guess** — Tell me your [topic] in one sentence. I'll draft a
   [output type] immediately and we'll refine from there. Fastest path to
   a working draft.
```

**Mode A (Guided):** Question-by-question, full threading. Best for complex
frameworks where each question depends on the previous answer. Use for positioning
statements, problem statements, PRDs.

**Mode B (Context dump):** Extract the structured fields from unstructured input.
Parse what the user gave you, identify what's missing, ask targeted gap-fill
questions (not the full sequence). Best for users with an existing document or
strong existing context.

**Mode C (Best guess):** Draft immediately, then refine. Best for users who
want a concrete artifact to react to rather than answering abstract questions.
The draft must be labeled as a best guess based on limited input — not presented
as complete.

---

## Session Opening Template

Use this exact structure to open any interactive PM session:

```markdown
## [Skill Name] — Session Start

I'll guide you to a complete [output name] using [framework name].

**What we'll produce:** [One sentence describing the output]
**Questions:** [N] questions total
**Time:** Approximately [N–N] minutes

You can exit and resume anytime — I'll remember where we were.

---

**How do you want to start?**

A) **Guided** — I ask one question at a time (recommended if you're
   still forming your thinking)
B) **Context dump** — Paste what you have; I'll extract and fill gaps
C) **Best guess** — One sentence from you; I draft immediately and we refine

*(Reply A, B, or C to begin)*
```

---

## Question Format Template

Use this format for every question in a Guided session:

```markdown
**[N/Total] [Question Category]**
*(building on: [brief summary of relevant context from previous answers])*

[The question — one sentence, clearly framed]

[Optional: explain why this matters, in one sentence]
```

Example:
```markdown
**[3/6] Competitive Alternative**
*(building on: mid-market SaaS finance teams; problem: manual reconciliation
adds 5+ days to month-end close)*

What do these finance teams use today to solve this problem?
Name the actual tool or process — often a spreadsheet, a legacy ERP module,
or a manual workflow — not a direct software competitor.
```

---

## Progress Labels

Use these consistently to signal session state:

| Label              | When to Use                                           |
|--------------------|-------------------------------------------------------|
| [N/Total]          | On every question in Guided mode                      |
| [Building on: ...]  | Context threading summary before each question       |
| [Draft in progress] | When generating a section mid-session               |
| [DRAFT — needs review] | On any Best Guess output                        |
| [Pausing here]     | When offering an exit at a natural break             |
| [Session complete] | When the final output has been produced              |

---

## Interruption Handling

When a user provides context that answers future questions:

1. Acknowledge what you received: "You mentioned X and Y — that covers questions
   3 and 4."
2. Update your model explicitly: Show the updated context summary.
3. Skip the answered questions with a note: "[Skipping questions 3–4 — answered above]"
4. Continue with the next unanswered question.

Never pretend you didn't receive the extra context and ask the question anyway.
This signals you are not listening and destroys user confidence in the session.

---

## Quality Intervention Protocol

When a user's input will produce a low-quality output:

1. Name the specific issue: "This phrasing uses a generic superlative
   ('best-in-class') that can't be verified or used for alignment."
2. Explain the consequence: "If we use it in the positioning statement,
   any feature or message can claim to fit it."
3. Offer a reframe: "Try: [specific alternative with concrete claim]"
4. Ask, do not impose: "Does that capture what you mean, or is there a
   specific differentiator you want to name here?"

---

## Session Completion Template

```markdown
## [Output Type] — Complete

[The full output artifact — clean, formatted, ready to share]

---

**What was produced:** [One-sentence summary]

**Suggested next step:** [Specific action — who should review this, what
decision it enables, or what document it feeds into]

**To refine:** [Any known gaps or open questions to address in follow-up]
```

---

## Anti-Patterns to Avoid

| Anti-Pattern                     | Consequence                                    |
|----------------------------------|------------------------------------------------|
| No entry mode selection          | Information asymmetry; 2 rounds of revision    |
| Multiple questions at once       | Answers lose threading; context collapses      |
| No progress labels               | User loses orientation; session abandonment    |
| Proceeding on ambiguous input    | Output requires complete rewrite               |
| Accepting low-quality input silently | Polished version of a bad answer          |
| Asking for feedback before full draft | Piecemeal feedback; incoherent output   |
| No next step at close            | Output has no forward momentum                 |
