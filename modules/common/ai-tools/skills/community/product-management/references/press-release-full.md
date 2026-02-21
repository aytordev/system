# Press Release (Working Backwards) — Full Framework

## Purpose

Amazon's Working Backwards method requires writing a customer-facing press release
before any design or engineering work begins. This forces the team to agree on what
success looks like from the outside before committing resources. It is a
decision-forcing document — not actual marketing copy.

If the team cannot write a compelling press release, the vision is not clear enough
to build. Use it to surface assumption gaps and expose misaligned expectations while
the cost of discovery is still low.

## When to Use

- Before starting any major feature or product initiative
- At the start of annual or quarterly planning to define the "big bet"
- When stakeholders disagree on what success looks like
- Before writing a PRD for anything requiring more than 4 weeks of engineering

## Complete Template

```markdown
# [Headline: Customer outcome achieved, not feature launched]
## [Subheadline: Who benefits and how — one sentence, specific]

[City, Launch Date] — [Opening paragraph: problem + solution in customer terms.
Two to four sentences. Write as if summarizing the news for someone who has
never heard of your company. Avoid product names and features — name the
customer outcome.]

[Problem paragraph: Describe the pain the customer experienced before this
product existed. Be specific. Use the voice of the customer. Do not mention
your product in this paragraph. Make the reader feel the frustration.]

[Solution paragraph: Introduce the product and explain how it solves the
problem. Focus on mechanism and outcome, not feature list. One to three
sentences maximum. Specific is better than comprehensive.]

"[Internal quote: A company spokesperson (CEO, VP Product, or Head of
Engineering) explains the strategic rationale and what this means for the
company's mission. Should feel genuine, not promotional. 2–3 sentences.]"

"[Customer quote: A named customer explains the impact in their own words.
This is the most important section — if you cannot write a believable customer
quote, you do not understand your customer's problem. 2–3 sentences.]"

[FAQ section (optional but recommended): 3–5 questions the reader would
immediately ask. Include hard questions. Unanswerable FAQs reveal scope gaps.]

[Call to Action: One clear next step. URL, signup link, or contact. No
multiple CTAs — pick one.]
```

## Worked Example

```markdown
# Finance Teams at Mid-Market SaaS Companies Cut Month-End Close from 10 Days to 4

## CloseLoop automates reconciliation so controllers spend hours reviewing, not days hunting

San Francisco, March 1, 2026 — Starting today, finance teams can eliminate the
manual reconciliation work that consumes two weeks of every quarter. CloseLoop's
automated variance detection flags discrepancies in real time, so controllers
reclaim time that was previously lost to spreadsheet archaeology.

Every month, finance controllers at growing SaaS companies face the same wall:
thousands of line items across disconnected systems, all requiring manual matching
before the books can close. A missed entry means another pass through the data.
Controllers routinely work evenings in the last week of every month — not because
the math is hard, but because the tooling forces them to do it by hand.

CloseLoop connects directly to existing ERP and billing systems, automatically
matches 94% of transactions, and surfaces the remaining 6% for human review with
full context. Controllers no longer reconcile — they review.

"We built CloseLoop because the best finance professionals we know were spending
their most skilled hours on the least skilled work," said Sarah Kim, CEO of
CloseLoop. "Month-end close should be a check, not a project."

"We used to dread the last week of every month," said Maria Chen, Controller at
Launchpad Analytics. "Now close is just another Tuesday. We finished last month
in three days — a new record."

---

**Frequently Asked Questions**

Q: Does CloseLoop work with our existing ERP?
A: CloseLoop integrates with NetSuite, QuickBooks, and Sage out of the box.
   Custom ERP connections available on Enterprise plan.

Q: What happens to the 6% of transactions CloseLoop flags for review?
A: Flagged items appear in a review queue with transaction history, matched
   candidates, and variance explanation. Average review time: 4 minutes per item.

Q: How long does implementation take?
A: Most customers are fully connected and running their first close within 5 days.

Q: Is our financial data secure?
A: SOC 2 Type II certified. Data encrypted at rest and in transit.
   No CloseLoop employee can access customer data.

---

Start your free 14-day trial at closeloop.com/start
```

## Writing Rules

1. **Headline = customer outcome.** If the headline could appear in a product
   changelog instead of a news article, rewrite it.

2. **No feature lists.** A feature list in a press release signals the team
   has not agreed on what problem they are solving.

3. **The customer quote is the hardest section.** If you cannot write a
   believable, specific quote from a real-sounding customer, you do not yet
   understand the problem deeply enough to build the solution.

4. **FAQs reveal gaps.** The questions that are hard to answer are the
   assumptions that most need validation before the project starts.

5. **One call to action.** Multiple CTAs indicate unclear intent. Decide what
   you want the reader to do and ask for it once.

6. **Write it in 45 minutes, iterate over days.** The first draft exposes
   misalignment. Subsequent drafts resolve it. Do not perfect the prose before
   aligning on the content.

## Quality Checklist

- [ ] Headline names a customer outcome, not a feature or a company action
- [ ] Subheadline names who benefits and how — in one specific sentence
- [ ] Problem paragraph contains no mention of the product or solution
- [ ] Customer quote is believable, specific, and names the outcome
- [ ] FAQs include at least one question the team does not yet know how to answer
- [ ] Call to action is singular and specific
- [ ] No superlatives: "revolutionary", "best-in-class", "game-changing"
- [ ] Team reviewed it together and reached agreement on the content
- [ ] The document exposed at least one assumption that needs validation
