# Proof of Life (PoL) Probe — Full Framework

## Purpose

A Proof of Life (PoL) probe is a lightweight, disposable validation artifact
designed to surface harsh truths before expensive development. It tests a single
hypothesis as cheaply and quickly as possible. PoL probes are reconnaissance
missions, not MVPs — they are explicitly planned for deletion, not scaling.

This framework prevents prototype theater (expensive demos that impress
stakeholders but teach nothing) and forces you to match the validation method
to the actual learning goal.

Coined by Dean Peters (Productside), building on Marty Cagan's 2014 work on
prototype flavors and Jeff Patton's principle: "The most expensive way to test
your idea is to build production-quality software."

## When to Use

- You have a specific, falsifiable hypothesis to test
- A particular risk blocks your next decision (feasibility, task completion,
  stakeholder support)
- You need harsh truth fast — within days, not weeks
- Building production software would be premature or wasteful
- You can articulate what failure looks like before you start

## When Not to Use

- You are trying to impress executives — that is prototype theater
- You already know the answer and want validation — that is confirmation bias
- You cannot articulate a clear hypothesis or disposal plan
- The learning goal is too broad ("Will customers like this?")
- You are using it to avoid making a hard decision

## The 5 Essential Characteristics

Every PoL probe must satisfy all five:

| Characteristic    | What It Means                                     |
|-------------------|---------------------------------------------------|
| Lightweight       | Minimal resource investment (hours/days, not weeks)|
| Disposable        | Explicitly planned for deletion, not scaling       |
| Narrow Scope      | Tests one specific hypothesis or risk              |
| Brutally Honest   | Surfaces harsh truths, not vanity metrics          |
| Tiny and Focused  | Reconnaissance missions, never MVPs                |

If your "prototype" feels too polished to delete, it is not a PoL probe — it
is prototype theater.

## PoL Probe vs MVP

| Dimension  | PoL Probe                              | MVP                                      |
|------------|----------------------------------------|------------------------------------------|
| Purpose    | De-risk through narrow hypothesis test | Justify ideas or defend roadmap          |
| Scope      | Single question, single risk           | Smallest shippable product increment     |
| Lifespan   | Hours to days, then deleted            | Weeks to months, then iterated           |
| Audience   | Internal team + narrow user sample     | Real customers in production             |
| Fidelity   | Just enough illusion to catch signals  | Production-quality or close              |
| Outcome    | Learn what does not work               | Learn what does work and ship it         |

PoL probes are pre-MVP reconnaissance. You run probes to decide if you should
build an MVP, not to launch something.

## The 5 Prototype Flavors

Match the probe type to your hypothesis, not your tooling comfort.

### 1. Feasibility Check
- **Core question:** "Can we build this?"
- **Timeline:** 1-2 days
- **Methods:** GenAI prompt chains, API tests, data integrity sweeps, spike-and-delete code
- **When to use:** Technical risk is unknown; third-party dependencies are unclear

### 2. Task-Focused Test
- **Core question:** "Can users complete this job without friction?"
- **Timeline:** 2-5 days
- **Methods:** Optimal Workshop, UsabilityHub, task flows
- **When to use:** Critical moments (field labels, decision points, drop-off zones) need validation

### 3. Narrative Prototype
- **Core question:** "Does this workflow earn stakeholder buy-in?"
- **Timeline:** 1-3 days
- **Methods:** Loom walkthroughs, Synthesia/Sora videos, slideware storyboards
- **When to use:** You need to tell vs. test — share the story, measure interest

### 4. Synthetic Data Simulation
- **Core question:** "Can we model this without production risk?"
- **Timeline:** 2-4 days
- **Methods:** Synthea (user simulation), DataStax LangFlow (prompt logic testing)
- **When to use:** Edge case exploration; unknown-unknown surfacing

### 5. Vibe-Coded PoL Probe
- **Core question:** "Will this solution survive real user contact?"
- **Timeline:** 2-3 days
- **Methods:** ChatGPT Canvas + Replit + Airtable ("Frankensoft")
- **When to use:** You need user feedback on workflow/UX but not production-grade code

**Golden rule:** Use the cheapest prototype that tells the harshest truth. If it
does not sting, it is probably just theater.

## Probe Template

```markdown
# PoL Probe: [Descriptive Name]

## Hypothesis
[One sentence. Example: "If we reduce the onboarding form to 3 fields,
completion rate will exceed 80%."]

## Risk Being Eliminated
[What specific risk or unknown? Example: "We do not know if users will
abandon signup due to form length."]

## Prototype Type
- [ ] Feasibility Check
- [ ] Task-Focused Test
- [ ] Narrative Prototype
- [ ] Synthetic Data Simulation
- [ ] Vibe-Coded PoL Probe

## Target Users / Audience
[Who interacts with this probe? Example: "10 users from early access
waitlist, non-technical SMB owners."]

## Success Criteria (Harsh Truth)
- Pass: [Example: "8+ users complete signup in under 2 minutes"]
- Fail: [Example: "<6 users complete, or average time exceeds 5 minutes"]
- Learn: [Example: "Identify specific drop-off fields"]

## Tools / Stack
[Example: "ChatGPT Canvas for form UI, Airtable for data capture,
Loom for post-session interviews."]

## Timeline
- Build: [days]
- Test: [days]
- Analyze: [days]
- Disposal: [date — delete all code, keep learnings doc]

## Disposal Plan
[When and how you will delete this. Example: "After sessions complete,
archive recordings, delete Frankensoft code, document learnings in Notion."]

## Owner
[One person accountable for running and disposing of this probe.]

## Status
- [ ] Hypothesis defined
- [ ] Probe built
- [ ] Users recruited
- [ ] Testing complete
- [ ] Learnings documented
- [ ] Probe disposed
```

## Quality Checklist

Before launching, verify every item:

- [ ] Lightweight — can you build this in 1-3 days?
- [ ] Disposable — have you committed to a disposal date?
- [ ] Narrow scope — does it test ONE hypothesis?
- [ ] Brutally honest — will the data hurt if you are wrong?
- [ ] Tiny and focused — is this smaller than an MVP?
- [ ] Falsifiable — can you describe what failure looks like?
- [ ] Clear owner — is one person accountable for execution and disposal?

If any answer is "no," revise the probe or reconsider whether you need one.

## Worked Example

```
Probe: Archive vs Delete Mental Model
Hypothesis: Users can distinguish "archive" from "delete" in the new UI.
Type: Task-Focused Test
Audience: 12 existing users from mid-market segment
Pass: 80%+ correct interpretation across both actions
Fail: <70% correct, or >3 users confuse the two
Tools: UsabilityHub first-click test
Timeline: Build 1 day, test 2 days, analyze 1 day, dispose day 5
Disposal: Delete test assets, archive results in Notion
```

## Common Pitfalls

| Pitfall                                        | Consequence                                | Fix                                                    |
|------------------------------------------------|--------------------------------------------|--------------------------------------------------------|
| Broad "will users like this?" experiment       | Ambiguous results that confirm nothing      | Test one falsifiable hypothesis per probe              |
| Treating a probe as a proto-MVP                | Sunk-cost fallacy prevents disposal         | Pre-commit to disposal date before building            |
| Using vanity metrics                           | Avoid uncomfortable truth                   | Define pass/fail criteria that can prove you wrong     |
| Skipping pre-defined failure threshold         | Cannot tell if the probe succeeded or failed| Write fail criteria before testing begins              |
| Choosing tools first, hypothesis second        | Tool drives the experiment, not the question| Start with hypothesis, then pick cheapest matching tool|

## Relationship to Other Frameworks

1. **Problem Statement** — define the problem before creating the probe
2. **Epic Hypothesis** — frame the hypothesis the probe will test
3. **PoL Probe Advisor** — decision framework for choosing which prototype flavor
4. **Discovery Process** — use PoL probes during the validation phase
5. **Lean UX Canvas** — Box 8 (experiments) often produces PoL probes

## References

- Marty Cagan, *Inspired* (2014) — prototype flavors framework
- Jeff Patton, *User Story Mapping* — lean validation principles
- Dean Peters, "Vibe First, Validate Fast, Verify Fit" (deanpeters.substack.com, 2025)
- Source: `deanpeters/Product-Manager-Skills` — `skills/pol-probe/SKILL.md`
