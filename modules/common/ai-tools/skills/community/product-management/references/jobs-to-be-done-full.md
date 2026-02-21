# Jobs-to-be-Done — Full Framework

## Purpose

Systematically explore what customers are trying to accomplish (functional, social,
and emotional jobs), the pains they experience, and the gains they seek. Use this
framework to uncover unmet needs, validate product ideas, and ensure your solution
addresses real motivations — not surface-level feature requests.

This is a structured lens for understanding why customers "hire" your product and
what would make them "fire" it.

## When to Use

- Early-stage discovery (before you know the solution)
- Validating product-market fit (does your solution address the right jobs?)
- Prioritizing roadmap (which jobs are most painful/important?)
- Competitive analysis (what are customers hiring competitors for?)
- Marketing messaging (speak to jobs, not features)

## When NOT to Use

- After you've already built and shipped (too late for discovery)
- For trivial features (don't over-analyze small tweaks)
- As a substitute for quantitative validation (JTBD informs hypotheses; data validates them)

## The Three Job Types

### 1. Functional Jobs

Tasks customers need to perform. These are verb-driven and solution-agnostic.

```
Functional Jobs:
- [Task 1 customer needs to perform]
- [Task 2 customer needs to perform]
- [Task 3 customer needs to perform]
```

Examples:
- "Reconcile monthly expenses for tax filing"
- "Onboard a new team member in under 2 hours"
- "Deploy code to production without downtime"

Quality checks:
- **Verb-driven:** jobs are actions ("send," "analyze," "coordinate")
- **Solution-agnostic:** don't say "use email to communicate" — say "communicate with remote teammates"
- **Specific:** "manage finances" is too broad; "track business expenses for tax deductions" is right

### 2. Social Jobs

How customers want to be perceived by others.

```
Social Jobs:
- [Way customer wants to be perceived 1]
- [Way customer wants to be perceived 2]
```

Examples:
- "Be seen as a strategic thinker by my exec team"
- "Appear responsive and reliable to clients"
- "Look tech-savvy to younger colleagues"

Quality checks:
- **Audience-specific:** who is the customer trying to impress? (boss, clients, peers)
- **Emotional weight:** social jobs often drive adoption more than functional jobs

### 3. Emotional Jobs

Emotional states customers want to achieve or avoid.

```
Emotional Jobs:
- [Emotional state customer seeks or avoids 1]
- [Emotional state customer seeks or avoids 2]
```

Examples:
- "Feel confident I'm not missing important details"
- "Avoid the anxiety of manual data entry errors"
- "Feel a sense of accomplishment at the end of the day"

Quality checks:
- **Positive and negative:** include what they seek ("feel in control") and what they avoid ("avoid embarrassment")
- **Rooted in research:** don't fabricate emotions — use customer quotes

## Pain Categories

### Challenges
Obstacles preventing the customer from completing the job.
- "Tools don't integrate, forcing manual data entry"
- "No visibility into what teammates are working on"

### Costliness
What takes too much time, money, or effort.
- "Generating monthly reports takes 8 hours of manual work"
- "Learning the current tool requires 20+ hours of training"

### Common Mistakes
Frequent errors that could be prevented.
- "Forgetting to CC stakeholders on critical emails"
- "Accidentally overwriting someone else's work in shared files"

### Unresolved Problems
Gaps in current solutions.
- "Current CRM doesn't track customer health scores"
- "Existing tools require technical expertise we don't have"

## Gain Categories

### Expectations
What would make the customer love a solution.
- "Automatically categorizes expenses without manual tagging"
- "Integrates seamlessly with tools we already use"

### Savings
Time, money, or effort reductions that delight.
- "Reduce report generation from 8 hours to 10 minutes"
- "Cut onboarding time from 2 weeks to 2 days"

### Adoption Factors
What would make the customer switch from their current solution.
- "Free trial with no credit card required"
- "Migration support to import existing data"

### Life Improvement
How a solution makes life easier or more enjoyable.
- "I could leave work on time instead of staying late for reports"
- "I could focus on strategic work instead of busywork"

## Step-by-Step Process

### Step 1: Define Context
Before exploring JTBD, clarify:
- **Target segment:** who are you studying? (use Proto-Persona)
- **Situation:** in what context does the job arise?
- **Current solutions:** what do they use today? (competitors, workarounds, doing nothing)

### Step 2: Explore Customer Jobs
Document functional, social, and emotional jobs using the formats above.

### Step 3: Identify Pains
Capture challenges, costliness, common mistakes, and unresolved problems.

### Step 4: Uncover Gains
Document expectations, savings, adoption factors, and life improvements.

### Step 5: Prioritize and Validate
- Rank pains by intensity (acute vs. mild annoyances)
- Identify must-have vs. nice-to-have gains
- Cross-reference with personas (different personas may have different jobs)
- Validate with data: survey a broader audience to confirm interview insights

## Output Template

```markdown
# Jobs-to-be-Done Analysis: [Product/Problem]

**Target Segment:** [Who]
**Situation:** [When/where the job arises]
**Current Solutions:** [What they use today]

## Customer Jobs
### Functional: [list]
### Social: [list]
### Emotional: [list]

## Pains
### Challenges: [list]
### Costliness: [list]
### Common Mistakes: [list]
### Unresolved Problems: [list]

## Gains
### Expectations: [list]
### Savings: [list]
### Adoption Factors: [list]
### Life Improvement: [list]

## Priority Matrix
| Pain/Gain          | Intensity | Evidence | Priority |
|--------------------|-----------|----------|----------|
| [item]             | High      | 6/8 said | Must-fix |
| [item]             | Medium    | 3/8 said | Should   |
```

## Worked Example (Excerpt)

```
Target Segment: Freelance designers managing 5+ clients
Situation: End of month when invoicing and expense tracking converge

Functional Job: Reconcile project hours against invoiced amounts
Social Job: Appear professional and organized to clients
Emotional Job: Avoid the dread of discovering missed billable hours

Pain (Challenge): Time tracking tool doesn't integrate with invoicing
Pain (Costliness): Reconciliation takes 4 hours per month manually
Gain (Savings): Reduce reconciliation from 4 hours to 15 minutes
Gain (Adoption Factor): Import existing client list from current tool
```

## Common Failure Modes

| Failure Mode                     | Example                                        | Fix                                                |
|----------------------------------|-------------------------------------------------|----------------------------------------------------|
| Confusing jobs with solutions    | "I need to use Slack"                          | Ask "why?" five times to find the underlying job   |
| Generic jobs                     | "Be more productive"                           | Get specific: which tasks, for whom, by when       |
| Ignoring social/emotional jobs   | Only documenting functional tasks              | Explicitly ask about perception and emotions       |
| Fabricating JTBD without research| Filling template from assumptions              | Conduct switch interviews or contextual inquiries  |
| Treating all pains as equal      | Listing 20 pains with no prioritization        | Rank by intensity; "if we only solved one, which?" |

## The "Five Whys" Technique

When a customer states a job that sounds like a solution, ask "why?" repeatedly:

```
"I need Slack" → Why? → "To communicate with my team"
→ Why? → "To get quick answers" → Why? → "To avoid project delays"
→ Why? → "Missing deadlines damages client relationships"

Real job: Protect client relationships by preventing project delays
```

## Relationship to Other Frameworks

- **Proto-Persona** — defines who has these jobs, pains, and gains
- **Problem Statement** — JTBD informs the "trying to" and "but" sections
- **Positioning Statement** — JTBD informs the "that need" statement
- **Discovery Interview Prep** — JTBD methodology for structuring interviews
- **Customer Journey Workshop** — journey phases map to functional jobs
