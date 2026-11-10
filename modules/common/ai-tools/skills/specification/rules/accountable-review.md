---
name: accountable-review
impact: CRITICAL
impactDescription: Review rounds, review-page generation, vocabulary routing
---

# Accountable Review and Vocabulary Capture

**Impact: CRITICAL**

## The Recommended Path: Draft, Then Accountable Review

The agent-facilitated conversation produces a **first draft** of shared
understanding. It becomes usable only after the people accountable for the
outcome review it. Match the review group to the work: a sole owner may be
enough for a low-risk local change; shared, regulated, irreversible, or
cross-discipline behavior needs the affected business, development, testing,
security, operations, or design perspectives. Record any material perspective
intentionally absent and why.

**Recommended flow, multi-round:**

1. **Round 1 (agent-facilitated)**: run the conversation contract with
   whoever brought the idea. Write the map back to the story artifact.
   Generate the review page (below) from it.
2. **Round 2 (accountable humans)**: the review page goes to the owner and
   the risk-relevant perspectives. A three-amigos conversation (business,
   development, testing) is a strong default for shared product behavior,
   not a ceremony to manufacture for every small task. Reviewers annotate
   the page; disagreements become new questions, not silent edits.
3. **Round 3+ (reconcile)**: their feedback returns to the agent round as
   answers and new questions. Update the map and the artifact; regenerate
   the page. Repeat until a round produces no new rules, no changed
   examples, and no new questions.
4. **Then split**: the stabilised map goes to the splitting activity; each
   child story carries its rules and examples onward — per-rule questions
   flatten into the single questions list that downstream mapping expects —
   and where an acceptance-test outer loop is installed, those examples
   become the seed of its per-slice mapping.

## The Review Page

For round 2, generate a single self-contained page from
`assets/spec-review-template.html`:

1. Build the review data as JSON matching the template's documented shape —
   sections share one card engine: a **Rules** section (one card per rule —
   the rule as the card name, its concrete examples as the plain text, its
   attached questions in the highlight line, the verbatim map entry
   collapsible beneath), a **Parked questions** section (question as name,
   owner + decision/review date + context as plain text), and a **Candidate
   vocabulary** section (term as name, one-line gloss as plain text).
2. Replace ALL occurrences of the double-underscore REVIEW_DATA token,
   escaping every `<` in string values as backslash-u003c so the JSON can
   never terminate the script tag.
3. Write the result to a session temp directory and open it in the
   reviewers' local browser. **Never commit the generated page.**

The page is a conversation artifact, not an approval record — regenerate it
freely every round. Every card takes comments; the copy-feedback control
assembles all annotations into one markdown block that returns to the next
round.

## Vocabulary Capture

Specification conversations coin vocabulary constantly — that is half their
value. Every term the conversation invents, contests, or uses in two
different senses goes into `candidate terms` with a one-line gloss.

Where a ubiquitous-language skill is installed, candidates enter its
language protocol individually (extraction gathers candidates; only the
protocol admits them). Where it is not, the candidate list still travels with
the story so the naming conversation happens somewhere.

## Verification Checklist

- [ ] The story artifact's home was asked, not assumed; all output written
      back into it.
- [ ] Questions went one at a time; recommendations appeared only when
      evidence or known trade-offs justified them.
- [ ] Every rule has at least one concrete example (real values, real
      outcome).
- [ ] Each rule survived the counter-example challenge.
- [ ] Parked questions have owners and decision/review dates.
- [ ] Candidate terms captured (and routed to the language protocol where
      installed).
- [ ] The accountable owner reviewed the page; risk-relevant perspectives
      joined or their absence was recorded.
- [ ] Feedback returned as answers/questions, never as silent edits.
- [ ] Map shape checked: not question-dominated, not rule-dominated,
      examples concrete.
