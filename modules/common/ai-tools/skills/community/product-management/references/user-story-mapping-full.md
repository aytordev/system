# User Story Mapping — Full Framework

## Purpose

Visualize the user journey by creating a hierarchical map that breaks down high-level
activities into steps and tasks, organized left-to-right as a narrative flow. Use this
to build shared understanding across product, design, and engineering, prioritize
features based on user workflows, and identify gaps or opportunities in the user
experience.

This is not a backlog. It is a strategic artifact that shows how users accomplish their
goals, which then informs what to build.

## When to Use

- Kicking off a new product or major feature.
- Aligning stakeholders on the user workflow.
- Prioritizing backlog based on user needs rather than technical considerations.
- Identifying MVP scope versus future releases.
- Onboarding new team members to the product vision.

## When NOT to Use

- Trivial features where the workflow is already well understood.
- Constantly changing user workflows (the map stabilizes workflows).
- As a replacement for user stories (the map informs stories, it does not replace them).

## The Jeff Patton Story Mapping Framework

### Two-Dimensional Structure

**Horizontal axis (left to right):** User journey over time.
- Backbone: high-level activities the user performs.
- Steps: specific actions within each activity.
- Tasks: detailed work required to complete each step.

**Vertical axis (top to bottom):** Priority and releases.
- Top rows: essential tasks (MVP / Release 1).
- Lower rows: nice-to-have tasks (future releases).

### Visual Structure

```
Segment -> Persona -> Narrative (User's goal)
------------------------------------------------------------
[Activity 1]  ->  [Activity 2]  ->  [Activity 3]  ->  [Activity 4]
     |                 |                 |                 |
  [Step 1.1]        [Step 2.1]        [Step 3.1]        [Step 4.1]
  [Step 1.2]        [Step 2.2]        [Step 3.2]        [Step 4.2]
     |                 |                 |                 |
  [Task 1.1.1]      [Task 2.1.1]      [Task 3.1.1]      [Task 4.1.1]
  [Task 1.1.2]      [Task 2.1.2]      [Task 3.1.2]      [Task 4.1.2]
  ...                ...               ...               ...
```

## The 7-Step Process

### Step 1 — Define the Segment

Who are you building for? Be specific.

- Not "users" but "enterprise IT admins" or "freelance designers."
- One segment per map. Multiple segments need separate maps or swim lanes.

### Step 2 — Define the Persona

Describe the persona within the segment: demographics, behaviors, pains, goals.

Example: "Sarah, 35-year-old freelance graphic designer. Manages 5-10 client
projects simultaneously. Struggles with invoicing and payment tracking. Wants to
spend less time on admin and more time designing."

### Step 3 — Define the Narrative

What is the user trying to accomplish? Frame as a single-sentence jobs-to-be-done
statement.

- Outcome-focused: not "use the product" but "deliver a client project on time and
  get paid."
- If it takes more than one sentence, the scope may be too broad.

### Step 4 — Identify Activities (Backbone)

List 3-5 high-level activities the persona engages in to fulfill the narrative. These
form the backbone and run left to right in workflow order.

Quality checks:
- Sequential: activities happen in order.
- User actions: describe what the user does, not what the product provides.
- 3-5 activities: too few is oversimplified, too many is overwhelming.

### Step 5 — Break Activities into Steps

For each activity, list 3-5 steps detailing how the activity is carried out.

Quality checks:
- Actionable: each step is something the user does.
- Observable: you could watch someone perform this step.
- Logical sequence: steps follow a natural order.

### Step 6 — Break Steps into Tasks

For each step, list 5-7 tasks that must be completed.

Quality checks:
- Granular: tasks are small, specific actions.
- Include both user-facing and behind-the-scenes tasks.
- Prioritizable: you will arrange tasks vertically (top = essential, bottom = nice-to-have).

### Step 7 — Prioritize Vertically and Identify Gaps

Arrange tasks top-to-bottom by priority. Draw horizontal release lines:
- Top rows: MVP / Release 1 (must-have).
- Middle rows: Release 2 (important but not critical).
- Bottom rows: Future / nice-to-have.

Then review the map: are there missing steps? Unaddressed pain points? Opportunities
to delight? Does the flow make logical sense?

## Full Template

```markdown
## User Story Map: [Scope]

### Who

**Segment:** [Target segment]
**Persona:** [Persona name, role, key characteristics]

### Backbone

**Narrative:** [Single-sentence user goal]

**Activities:**
1. [Activity 1]
2. [Activity 2]
3. [Activity 3]
4. [Activity 4]
5. [Activity 5 — optional]

### Steps

**Activity 1: [Name]**
- Step 1: [Detail]
- Step 2: [Detail]
- Step 3: [Detail]

**Activity 2: [Name]**
- Step 1: [Detail]
- Step 2: [Detail]
[Repeat for all activities]

### Tasks

**Activity 1, Step 1: [Name]**
MVP (Release 1):
- Task 1: [Detail]
- Task 2: [Detail]

Release 2:
- Task 3: [Detail]
- Task 4: [Detail]

Future:
- Task 5: [Detail]
[Repeat for all steps]
```

## Worked Example — Freelance Invoicing Product

**Segment:** Freelance creative professionals (designers, writers, photographers).

**Persona:** Sarah, 35, freelance graphic designer. Manages 5-10 clients. Struggles
with invoicing and payment tracking. Wants less admin time.

**Narrative:** Complete a client project from kickoff to final payment without admin hassle.

**Activities:**
1. Negotiate project scope and pricing
2. Execute design work
3. Deliver final assets
4. Send invoice and receive payment
5. Follow up on late payments

**Tasks for Activity 4, Step 1 (Create invoice):**

MVP:
- Enter client name and contact info
- Add line items (description, hours, rate)
- Calculate total automatically
- Preview invoice before sending

Release 2:
- Add logo and custom branding
- Save invoice templates for repeat clients
- Auto-populate from project notes

Future:
- Generate invoices from time tracking data
- Multi-currency support

## Common Pitfalls

| Pitfall                         | Symptom                                           | Fix                                                                |
|---------------------------------|---------------------------------------------------|--------------------------------------------------------------------|
| Activities are features         | "Use the dashboard," "Generate reports"           | Reframe as user actions: "Monitor progress," "Summarize for team" |
| Too many activities             | 10+ activities across the backbone                | Consolidate; you are mixing activities with steps. Aim for 3-5    |
| Tasks are too vague             | "Do the thing"                                    | Be specific: "Enter client email in the Bill To field"            |
| No vertical prioritization      | All tasks at the same level                       | Draw release lines. Force hard choices about what is MVP          |
| Mapping in isolation            | PM creates map alone, presents to team            | Map collaboratively in a workshop with product, design, and eng   |
| Technical backbone              | "Frontend -> Backend -> Database"                 | Follow user workflow, not system layers                            |

## Key Principles

- **User-centric:** organize work around user goals, not engineering modules.
- **Shared understanding:** product, design, and engineering all see the same journey.
- **Prioritization clarity:** top tasks = MVP, lower tasks = future iterations.
- **Gap identification:** missing steps or tasks become obvious in 2D layout.
- **Release planning:** horizontal release lines define scope at a glance.

## References

- Jeff Patton, *User Story Mapping* (2014)
- Teresa Torres, *Continuous Discovery Habits* (2021)
- Source skill: `deanpeters/Product-Manager-Skills` — `skills/user-story-mapping/SKILL.md`
