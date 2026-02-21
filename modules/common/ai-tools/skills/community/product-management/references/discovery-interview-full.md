# Discovery Interview Prep — Full Framework

## Purpose

Guide product managers through preparing for customer discovery interviews by
defining research goals, identifying target segments, understanding constraints,
and selecting the right interview methodology. The output is a tailored interview
plan with question framework, bias awareness, and success criteria.

This is a strategic prep process, not a script generator. It ensures discovery
interviews yield actionable insights rather than confirmation bias or surface-level
feedback.

## When to Use

- Starting product discovery (validating problem space)
- Repositioning an existing product (understanding new market)
- Investigating churn or drop-off (retention interviews)
- Evaluating feature ideas before building
- Preparing for customer development sprints

## When NOT to Use

- User testing a prototype (use usability testing frameworks instead)
- Quantitative research at scale (use surveys, analytics)
- When you already know the problem well (move to solution validation)

## What This Is NOT

- **Not a user testing script** — discovery is about learning problems, not validating solutions
- **Not a sales demo** — don't pitch; listen and learn
- **Not surveys at scale** — deep qualitative interviews (5-10 people), not broad surveys

## Four-Step Prep Flow

### Step 1: Define Research Goal

What do you need to learn?

1. **Problem validation** — confirm that a problem exists and is painful enough to solve (new product ideas)
2. **Jobs-to-be-Done discovery** — understand what customers are trying to accomplish and why current solutions fail (product strategy)
3. **Retention/churn investigation** — figure out why customers leave or don't activate (existing products)
4. **Feature prioritization** — validate which problems/features matter most (roadmap planning)

Be specific: "What question are you trying to answer?"

### Step 2: Identify Target Segment

Who should you interview? Options vary by research goal:

For problem validation:
1. People who experience the problem regularly (high pain frequency)
2. People who've tried to solve it (understand solution failures)
3. People in the target segment regardless of awareness (uncover latent needs)
4. People who recently experienced the problem (fresh memory)

For churn investigation:
- Customers who churned in last 30 days
- Users who signed up but never activated
- Users who downgraded plans

Be as specific as possible: role, company size, behaviors, demographics.

### Step 3: Assess Constraints

1. **Limited access** — can only interview 5-10 people, results needed in 2 weeks
2. **Existing customer base** — 100+ active customers, easy to recruit
3. **Cold outreach required** — no existing customers, recruit via LinkedIn, ads, communities
4. **Internal stakeholders only** — interview sales/support teams as proxy (less ideal but pragmatic)

### Step 4: Select Interview Methodology

Choose based on goal, segment, and constraints:

**Problem validation (Mom Test style)**
Ask about past behavior, not hypotheticals. Core question: "Tell me about the
last time you [experienced the problem]. What did you try? What happened?"
Best for validating if a problem is real and painful.

**Jobs-to-be-Done interviews**
Focus on what customers are trying to accomplish. Core question: "What were you
trying to get done? What alternatives did you consider? What made you choose X?"
Best for understanding motivations and switching behavior.

**Switch interviews**
Interview customers who recently switched solutions. Core question: "What prompted
you to look for a new solution? What pushed you away from the old tool? What
pulled you to try ours?"
Best for competitive positioning and unmet needs.

**Timeline/journey mapping interviews**
Walk through their entire experience chronologically. Core question: "Walk me
through the first time you encountered this problem. What happened next?"
Best for uncovering full context and pain points.

## Interview Plan Template

```markdown
# Discovery Interview Plan

**Research Goal:** [From Step 1]
**Target Segment:** [From Step 2]
**Constraints:** [From Step 3]
**Methodology:** [From Step 4]

## Opening (5 minutes)
- Build rapport: "I'm researching [problem space]. This isn't a sales call."
- Set expectations: "There are no right answers. Critical feedback is most helpful."
- Get consent: "Is it okay if I take notes / record this?"

## Core Questions (30-40 minutes)

1. [Question] — [Rationale]
   Follow-up: [Dig deeper with...]
   Avoid: [Don't ask leading version like...]

2. [Question] — [Rationale]
   Follow-up: [...]
   Avoid: [...]

[...3-5 questions total...]

## Closing (5 minutes)
- Summarize: "I heard that [key insights]. Did I get that right?"
- Ask for referrals: "Do you know anyone else who experiences this?"
- Thank them.

## Biases to Avoid
[See checklist below]

## Success Criteria
[See checklist below]
```

## Mom Test Question Examples

1. **"Tell me about the last time you [experienced this problem]."**
   Gets specific recent behavior. Follow-up: "What were you trying to accomplish?"
   Avoid: "Would you use a tool that solves this?" (leading, hypothetical)

2. **"How do you currently handle [this problem]?"**
   Reveals workarounds and pain intensity. Follow-up: "How much time/money does that take?"
   Avoid: "Don't you think that's inefficient?" (leading)

3. **"Can you walk me through what you did step-by-step?"**
   Uncovers details and edge cases. Follow-up: "Where did you get stuck?"
   Avoid: "Was it hard?" (yes/no, not useful)

4. **"Have you tried other solutions for this?"**
   Reveals competitive landscape. Follow-up: "What did you like/dislike? Why did you stop?"
   Avoid: "Would you pay for a better solution?" (hypothetical)

5. **"If you had a magic wand, what would change?"**
   Opens space for ideal outcomes (treat with skepticism). Follow-up: "Why does that matter?"
   Avoid: Taking feature requests literally.

## Bias Awareness Checklist

1. **Confirmation bias** — Don't ask "Don't you think X is a problem?" Ask "Tell me about your experience with X."
2. **Leading questions** — Don't ask "Would you use this?" Ask "What have you tried? Why did it work/fail?"
3. **Hypothetical questions** — Don't ask "If we built Y, would you pay?" Ask "What do you currently pay for? Why?"
4. **Pitching disguised as research** — Don't say "We're building Z to solve X." Say "I'm researching X."
5. **Yes/no questions** — Don't ask "Is invoicing hard?" Ask "Walk me through your invoicing process."

## Success Criteria

Interviews are successful when:

- You hear specific stories, not generic complaints ("Last Tuesday, I spent 3 hours..." not "It's annoying")
- You uncover past behavior, not hypothetical wishes ("I tried Zapier but quit after 2 weeks" not "I'd probably use automation")
- You identify patterns across 3+ interviews (same pain points emerge independently)
- You are surprised by something (if everything confirms assumptions, you're asking leading questions)
- You can quote customers verbatim (actual language equals authentic insights)

## Recruiting and Logistics

**Recruiting:**
- Limited access: reach out to 20-30 people to get 5-10 interviews (33% response rate typical)
- Existing customers: email 50 customers with incentive ($50 gift card)
- Cold outreach: LinkedIn, Reddit communities, industry forums

**Scheduling:**
- 45-60 minutes per interview (30-40 min conversation plus buffer)
- Record with consent, or take detailed notes
- Maximum 2-3 per day (you need time to synthesize)

**Synthesis:**
- Write key insights immediately after each interview (memory fades fast)
- After 5 interviews, look for patterns (common pains, jobs, workarounds)
- Use Problem Statement framework to frame findings

## Common Failure Modes

| Failure Mode                    | Example                                           | Fix                                                  |
|---------------------------------|---------------------------------------------------|------------------------------------------------------|
| Asking what customers want      | "What features should we build?"                  | Ask about past behavior, not wishes                  |
| Pitching instead of listening   | Spending 20 min explaining your idea              | Don't mention your solution until last 5 min         |
| Interviewing wrong people       | Friends, family, or unaffected users              | Interview people who experience the problem recently |
| Stopping at 1-2 interviews     | "2 people liked it, let's build!"                 | Minimum 5-10 interviews; look for patterns           |
| Not recording insights          | Relying on memory after sessions                  | Record or take detailed notes; synthesize immediately|

## Relationship to Other Frameworks

- **Problem Statement** — interview insights feed problem framing
- **Proto-Persona** — defines the interview target segment
- **Jobs-to-be-Done** — JTBD methodology for understanding motivations
- **Customer Journey Workshop** — interviews provide research input for mapping
