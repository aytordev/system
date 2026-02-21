# Discovery Process — Full Framework

## Purpose

The Discovery Process is a structured 3–4 week cycle for validating whether a
problem is real, significant, and worth building a solution for. Use it before
committing engineering capacity to any significant product investment. It prevents
the most common and costly failure mode: building solutions for unvalidated problems.

## When to Use

- Before writing a PRD for any initiative requiring more than 4 weeks of engineering
- When a new opportunity or problem area is proposed without existing evidence
- When customer feedback is contradictory and the team lacks shared understanding
- At the start of a new product area, market segment, or strategic bet

Do NOT use a compressed discovery sprint in place of this process. The synthesis
phase cannot be rushed — insights not synthesized across participants produce
contradictory outputs that stall alignment.

## 4-Phase Process

### Phase 1: Frame
**Duration:** Days 1–3 (3 days)
**Purpose:** Align the team on what you are investigating and why before any
research begins. Undirected research produces mountains of data and no decisions.

**Activities:**
1. Write the problem hypothesis:
   "We believe [persona] struggles with [problem] in [context], which causes [consequence]."
2. Define 3–5 research questions. These are the specific things you must learn.
   Frame as: "What is true about [behavior/belief/context] for this persona?"
3. Identify what evidence would confirm or disconfirm the hypothesis.
4. Define the participant profile: role, company size, experience level, context.
5. Recruit 8–12 participants. Use mix of current customers, churned customers,
   and non-customers if problem framing spans market segments.

**Participants:** PM, UX Researcher (if available), one engineer (recommended)
**Exit criterion:** Team alignment on written problem hypothesis and research questions.
   All team members can state what would change their minds.

---

### Phase 2: Research
**Duration:** Days 4–14 (8 working days)
**Purpose:** Gather direct evidence from the people who experience the problem.

**Activities:**
1. Run 8–12 discovery interviews using Mom Test protocol:
   - Ask about past behavior, not hypothetical preferences
   - Ask "walk me through the last time..." not "would you ever..."
   - Never pitch the product idea during discovery
   - Treat every compliment as a data quality failure — dig underneath it
2. Log raw observations in real time. Do not interpret during the session.
   Use a structured note format: observation, direct quote, inference (separate columns).
3. Observe in context where possible (contextual inquiry). One contextual
   observation session yields the equivalent insight of 3 interviews.
4. Review notes after each session; flag emerging patterns to revisit.

**Participants:** PM (must attend at minimum 4 sessions), UX Researcher
**Exit criterion:** Theme saturation — no substantially new themes emerging after
   the last 3 consecutive interviews. Minimum 8 interviews regardless.

**Interview question framework (Mom Test-compliant):**
```
Opening (set context, do not pitch):
"I'm trying to understand how you [job area]. Tell me about last week.
What did [relevant activity] look like for you?"

Behavior questions (specific, past-tense):
"Walk me through the last time [problem situation] happened."
"When that happened, what did you do?"
"What tools were open on your screen at that moment?"

Dig on pain:
"How often does that happen?" (frequency = severity proxy)
"What have you tried to fix it?" (existing workarounds reveal real motivation)
"Why didn't that work?" (gaps reveal the actual problem)

Close:
"Is there anything I should have asked that I didn't?"
```

---

### Phase 3: Synthesize
**Duration:** Days 15–17 (3 days)
**Purpose:** Transform raw observations into shared team understanding.

**Activities:**
1. Individual affinity clustering: each team member who attended sessions
   independently groups raw observations by theme — before group synthesis.
2. Group synthesis session (2–3 hours): compare individual clusters, resolve
   conflicts, merge themes into a shared set.
3. Build a frequency × severity matrix for each pain point:
   - Frequency: what percentage of participants mentioned this theme?
   - Severity: how much does it cost them (time, money, emotional toll)?
4. Write 3–5 insight statements using the format:
   "When [context], [persona] [behavior] because [belief/constraint]."
   Each insight must be grounded in specific observations, not just patterns.

**Participants:** PM + all team members who attended sessions
**Exit criterion:** Insights reviewed and challenged by at least one person who
   did NOT attend the research sessions. Their "I don't understand this" questions
   are the signal that insights need more grounding.

**Frequency × Severity Matrix:**
```
                    LOW SEVERITY         HIGH SEVERITY
HIGH FREQUENCY  |  Monitor/log        |  Primary target  |
LOW FREQUENCY   |  Deprioritize       |  Niche case      |
```

---

### Phase 4: Validate
**Duration:** Days 18–21 (4 days)
**Purpose:** Test the riskiest assumption before committing to build.

**Activities:**
1. Map top insights to the opportunity: which insight represents the problem
   worth solving first?
2. Identify the single riskiest assumption — the one belief that, if wrong,
   invalidates the entire investment thesis.
   Ask: "What must be true for this opportunity to be real?"
3. Design a Proof of Learning (PoL) probe to test that assumption:
   - Smoke test (landing page, ad campaign) to test demand
   - Concierge MVP (manual delivery of the solution) to test value
   - Prototype test to test usability or desirability
4. Run the probe. Minimum viable signal: defined before starting, not after.
5. Hold a decision gate:
   - **Proceed:** evidence confirms opportunity; begin PRD
   - **Pivot:** evidence reveals a different, better opportunity; return to Phase 1
   - **Park:** evidence is insufficient or timing is wrong; document and revisit

**Participants:** PM, Engineering Lead, Business Stakeholder
**Exit criterion:** Go/no-go decision documented with evidence and rationale.
   "We believe X, we tested it with Y, we observed Z, therefore we will [decision]."

---

## Phase Entry/Exit Criteria Summary

| Phase       | Entry Criteria                              | Exit Criteria                                         |
|-------------|---------------------------------------------|-------------------------------------------------------|
| Frame       | Problem area identified; stakeholder buy-in | Written hypothesis + research questions; team aligned |
| Research    | Participants recruited (8+ confirmed)        | Theme saturation (no new themes in last 3 interviews) |
| Synthesize  | All sessions complete; notes documented     | Insights challenged by non-research team member       |
| Validate    | Insights prioritized; riskiest assumption named | Go/no-go documented with evidence                |

## Common Failure Modes

| Failure Mode                        | Consequence                                        | Prevention                                    |
|-------------------------------------|----------------------------------------------------|-----------------------------------------------|
| Skipping Phase 1 (no hypothesis)    | Research collects everything; learns nothing       | Write the hypothesis before recruiting        |
| Fewer than 8 interviews             | Pattern recognition unreliable; false saturation   | Hard minimum of 8; do not rationalize less    |
| PM skips all sessions               | Synthesis based on second-hand interpretation      | PM must attend at least 4 sessions directly   |
| Skipping individual synthesis step  | Groupthink; loudest voice defines the findings     | Cluster independently before group session    |
| Testing multiple assumptions at once| Signal ambiguity; cannot isolate what worked       | Isolate one riskiest assumption per probe     |
| Skipping the decision gate          | Discovery becomes a ritual without consequences    | Require written go/no-go with evidence        |
