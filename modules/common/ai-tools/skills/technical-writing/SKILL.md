---
name: technical-writing
description: "Trigger: writing developer-facing prose that can be skimmed first and trusted enough to finish — READMEs, guides, tutorials, reference docs, proposals, PR descriptions, release notes — before drafting, rewriting, restructuring, or editing technical documents, when a doc reads as a wall of text, when material claims need receipts, or when docs must serve AI agents. Requires one primary reader job per page, claims verified against source, doc changes riding the same reviewable change as the behavior they describe, and enumerable facts in tables with exact copy-paste strings."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Technical Writing: Skimmed First, Trusted Enough to Finish

Developers skim before they commit. A document earns the full read by
answering three questions in its first screen: what is this, why should I
care, and how do I start. Everything below serves that contract.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Writing, rewriting, restructuring, or editing developer-facing prose:
  READMEs, guides, tutorials, reference docs, proposals, PR descriptions,
  release notes.
- A document reads as a wall of text or buries its payoff.
- Material claims need receipts or docs must serve AI agents as well as
  humans.

Sentence-level voice and generic AI-shaped prose follow the same reader-first
and plainness rules here; a sentence-level voice guide may refine them
further where the repository provides one. For plain English, lay readers, or
translation constraints, apply the plainest register that keeps the meaning
exact.

## Hard Rules

1. **One primary reader job per page.** Choose tutorial, how-to, reference,
   or explanation; supporting material may cross a boundary when it serves
   the same job; split the page when mixed purposes make the next action,
   completeness contract, or intended audience unclear
   (`rules/reader-first-structure.md`).
2. **Material claims need receipts.** Capability, current-state,
   compatibility, and quantitative claims are checkable — numbers a reader
   can verify, a command they can run, a file they can open. Counts and
   versions rot: generate them, date them, or bind them to the kept-current
   rule (`rules/claims-need-receipts.md`).
3. **Verify docs against source, not memory.** Every material flag, exit
   code, config key, and executable command a doc asks readers to rely on is
   checked against the code before it ships; machine-check what machines can
   check (`rules/docs-are-behavior.md`).
4. **Doc changes ride the same reviewable change** as the behavior they
   describe; a behavior change that leaves its documentation stale is
   incomplete work.
5. **Maintained docs describe current truth.** Keep plan and specification
   workspaces only while their outcomes are unfinished; promote lasting
   constraints to their current owner; never make maintained docs depend on
   deleted specifications or unexplained delivery identifiers.
6. **Agent-readable is a first-class audience.** Enumerable facts appear in
   table rows, not only inside paragraphs; every operation states its
   preconditions and postconditions; copy-pasteable things get exact strings
   (`rules/agent-readable-docs.md`).
7. **Idle and empty states must speak.** "0 items processed" that reads like
   success is a lie of layout; distinguish "nothing to do" from "did
   nothing" everywhere output appears in docs and examples.

## Execution Steps

1. **CHOOSE THE READER JOB** — tutorial, how-to, reference, or explanation;
   the honest limits and the omitted types are in
   `references/doc-types.md`.
2. **DRAFT READER-FIRST** — lead with the payoff; headings summarize their
   section's payoff; short paragraphs; cut what does not change the reader's
   next step rather than compressing prose into jargon.
3. **CLAIMS** — attach a receipt to every material claim; state honest limits
   where the page's scope could imply protection it does not provide; keep
   evergreen docs free of unowned temporal labels.
4. **VERIFY** — check flags, exit codes, config keys, and commands against
   source; run executable examples where safe, authorized, and proportionate;
   machine-check ToC anchors and links; record any evidence gap.
5. **AGENT PASS** — move enumerable facts into tables; add exact strings and
   pre/postconditions; state every screenshot's load-bearing information in
   text.
6. **SHIP** — docs in the same reviewable change as the behavior; consult the
   verification checklist below before calling the document done.

## Output Contract

Return: the document with its reader-job choice stated; the receipts behind
material claims; verification results (what was executed or checked, and any
recorded evidence gap); limits stated where implied scope could mislead; and
the doc's own next-action signposts. Do not claim a doc was verified when
only some claims were checked — list which were.

## References

- `rules/reader-first-structure.md` — reader-job principles and document shapes.
- `rules/claims-need-receipts.md` — the receipts rule, rot, limits, timeless docs.
- `rules/docs-are-behavior.md` — verification, lifecycle, and the same-change rule.
- `rules/agent-readable-docs.md` — tables, pre/postconditions, exact strings.
- `references/doc-types.md` — the four Diátaxis modes, tutorial vs how-to, omitted types, scoped minimalism.
- `references/readme.md` — the README cognitive funnel and README-driven development.
- `references/docs-quality.md` — prose lint, executable examples, link checking, lifecycle, Git archaeology.
- `references/agent-docs.md` — llms.txt, clean source, retrievable pages, evidence rule.
- `references/formatting.md` — titles, headings, paragraphs, lists, emphasis, code, intros/outros.
- `references/sources.md` — sources for every claim above.
- `references/source-notes.md` — the pinned origin and local adaptation history.
- `references/provenance.md` — upstream source, revision, and licence notice.

## Verification Checklist

- [ ] First screen answers what / why / how-to-start
- [ ] Headings summarize payoffs; a ToC is present where warranted and its anchors are machine-checked
- [ ] Material capability/current-state/quantitative claims carry a receipt or date; promotional claims have evidence
- [ ] Commands, flags, and executable examples readers rely on are verified against source and run where feasible
- [ ] Material limits appear where implied scope could otherwise mislead
- [ ] Enumerable facts appear in tables; exact strings given for anything copy-pasteable
- [ ] Counts/versions bound to the kept-current rule or generated
- [ ] Doc changes ride the same reviewable change as the behavior they describe
- [ ] Maintained docs describe current truth; completed or superseded workspaces are deleted
- [ ] Lasting constraints live with their current owner, not only in historical delivery artifacts
- [ ] Indexes distinguish current authority, active work, decisions, and history

Boundaries beyond this skill: REST/API reference semantics (errors,
pagination, versioning) belong to API design documentation — an
`api-design` companion carries that where installed. CLI help text, exit
codes, and output design follow the CLI's own output contract under the same
rules here (skimmed first, exact strings). Diagrams: author them only where
they carry the payoff, and state every diagram's load-bearing information in
text. Recording a learning while fresh is the repository's expectations
practice; domain vocabulary in prose follows the bounded context's
authoritative glossary (`ubiquitous-language` companion where installed).
