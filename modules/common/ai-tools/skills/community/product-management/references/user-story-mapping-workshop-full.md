# User Story Mapping Workshop — Full Framework

## Purpose

Guide teams through creating a user story map — a two-dimensional visualization
that organizes stories by user workflow (horizontal) and priority (vertical).
Story maps replace flat backlogs with a narrative structure that communicates the
big picture, reveals missing functionality, and enables incremental release
planning. Based on Jeff Patton's story mapping framework.

## When to Use

- Starting a new product or major feature
- Reframing an existing flat backlog into a visual map
- Aligning stakeholders on scope and release priorities
- Planning MVP or incremental delivery slices

## When Not to Use

- Single-feature projects (story map is overkill)
- Backlog is already well-understood and prioritized
- Technical refactoring work with no user workflow to map

## Core Concepts

### Two-Dimensional Structure

**Horizontal axis (left to right):** Activities arranged in narrative order —
the sequence you would use to explain the system to someone new.

**Vertical axis (top to bottom):** Priority within each activity. Most essential
tasks at the top, nice-to-haves at the bottom.

```
Activities:   [Browse] → [Add to Cart] → [Checkout] → [Confirm]
                 |            |              |            |
Tasks:        View list    Add item       Enter addr   See summary
              Search       Adjust qty     Enter card   Get email
              Filter       Save later     Apply promo  Track order
```

### Key Vocabulary

| Term             | Definition                                                    |
|------------------|---------------------------------------------------------------|
| Backbone         | Top row of activities — the system's structural narrative     |
| Walking Skeleton | Highest-priority task across every activity — the minimal MVP |
| Ribs             | Supporting tasks descending vertically under each activity    |
| Release Slice    | Horizontal line cutting across all activities at a priority   |

### Build Strategy

Build left-to-right, top-to-bottom: deliver thin slices across all activities
rather than completing one activity fully before starting the next. Each release
delivers end-to-end value, not a single completed column.

## Five-Step Workshop Process

### Step 1: Gather Context

Before mapping, collect:

- Product concept, PRD draft, or existing backlog
- Target personas or user segments (proto-personas, JTBD)
- Existing user research, journey maps, or interview findings
- Website copy, positioning materials, or user flows

### Step 2: Define Scope

Choose what you are mapping:

| Scope Type             | Example                                    | Best For                     |
|------------------------|--------------------------------------------|------------------------------|
| Entire product         | Full end-to-end system                     | New products, full rewrites  |
| Major feature area     | "Onboarding," "Checkout," "Reporting"      | Feature launches             |
| User journey           | "Hire a contractor," "File taxes"          | JTBD-driven mapping          |
| Redesign / refactor    | Existing product being rebuilt             | Legacy modernization         |

### Step 3: Build the Backbone (Activities)

Generate 5-8 activities arranged in the user's workflow order. The backbone
is the narrative — not technical architecture, not org structure.

Good backbone (user workflow):
```
Sign Up → Configure Settings → Invite Team → Start Project → Track Progress → Generate Report
```

Bad backbone (technical layers):
```
UI Layer → API Layer → Database Layer → Deployment
```

**Validation question:** "If I walked someone through this product, would I
explain it in this order?" If yes, the backbone is correct.

### Step 4: Add User Tasks Under Each Activity

For each backbone activity, list 3-5 tasks vertically by priority:

```
Sign Up (Activity)
├─ Create account with email/password     (must-have, Release 1)
├─ Verify email via confirmation link     (must-have, Release 1)
├─ Sign up with Google OAuth              (should-have, Release 2)
├─ Sign up with SSO                       (nice-to-have, Release 3)
└─ Invite from existing account           (nice-to-have, Release 3)
```

Each task should be a user-visible capability, not a technical subtask.

### Step 5: Draw Release Slices

Draw horizontal lines across the map to define releases:

**Release 1 — Walking Skeleton (MVP):**
Top-priority task from every activity. Minimal end-to-end functionality.
A user can complete the entire workflow, but with the simplest version of each step.

**Release 2 — Enhanced Functionality:**
Second-priority tasks. Improves the core workflow with key enhancements.

**Release 3 — Polish and Expansion:**
Nice-to-haves, edge cases, optimizations, additional platforms.

## Output Template

```markdown
# User Story Map: [Scope]

**Users:** [Personas]
**Date:** [Date]

## Backbone

[Activity 1] → [Activity 2] → [Activity 3] → [Activity 4] → [Activity 5]

## Full Map

### [Activity 1: Name]
- **[Task 1.1]** — Must-have (Release 1)
- **[Task 1.2]** — Should-have (Release 2)
- **[Task 1.3]** — Nice-to-have (Release 3)

### [Activity 2: Name]
- **[Task 2.1]** — Must-have (Release 1)
- **[Task 2.2]** — Should-have (Release 2)
- **[Task 2.3]** — Nice-to-have (Release 3)

[...repeat for all activities...]

## Release 1: Walking Skeleton
**Goal:** Minimal end-to-end functionality
- [Task 1.1] — [Activity 1]
- [Task 2.1] — [Activity 2]
- [Task 3.1] — [Activity 3]
**Why:** Delivers complete workflow with simplest version of each step.

## Release 2: Enhanced
**Goal:** Priority enhancements to core workflow
[...tasks...]

## Release 3: Polish
**Goal:** Nice-to-haves, edge cases, optimizations
[...tasks...]

## Next Steps
1. Write detailed user stories for Release 1 tasks
2. Estimate effort (story points or t-shirt sizes)
3. Walk stakeholders through map left-to-right for validation
4. Post map as physical information radiator
```

## Worked Example: E-Commerce Checkout

**Backbone:**
```
Browse → Add to Cart → Review Cart → Enter Shipping → Enter Payment → Confirm → Receive Confirmation
```

**Release 1 (Walking Skeleton):**
- View product list, Add single item, View line items + total,
  Enter name/address, Enter credit card, See order summary, Get email

**Release 2 (Enhanced):**
- Search/filter products, Adjust quantity, Apply promo code,
  Multiple shipping options, Multiple payment methods, Order tracking

**Release 3 (Polish):**
- Product recommendations, Save for later, Estimate shipping cost,
  Gift wrapping, Guest checkout, Post-purchase survey

## Common Failure Modes

| Failure Mode                    | Symptom                                        | Fix                                                    |
|---------------------------------|------------------------------------------------|--------------------------------------------------------|
| Flat backlog in disguise        | Vertical list, no horizontal narrative         | Force backbone first — activities across the top       |
| Technical architecture backbone | "Frontend → Backend → Database"                | Map user workflow, not system layers                   |
| Feature-complete waterfall      | Release 1 = complete Activity 1 only           | Walking skeleton = thin slice across ALL activities    |
| Too much detail too soon        | Every edge case mapped before validating scope | Start with backbone + high-level tasks; refine later   |
| Map hidden in a tool            | Lives in Jira/Miro, never displayed            | Print/post physically as information radiator          |
| No walking skeleton identified  | All tasks seem equally important               | Force-rank: "If we could only ship one task per activity, which?" |

## Quality Checklist

- [ ] Backbone follows user narrative order (not technical architecture)
- [ ] Each activity has 3-5 tasks arranged by priority (top = must-have)
- [ ] Walking skeleton delivers end-to-end value (not one activity fully done)
- [ ] Release slices are horizontal cuts, not vertical columns
- [ ] Each task is user-visible (not "set up database" or "write API")
- [ ] Personas identified and referenced in task descriptions
- [ ] Stakeholders walked through left-to-right and validated backbone
- [ ] Map is displayed physically or shared visually (not buried in a tool)

## Relationship to Other Frameworks

1. Proto-Persona — defines the users for the map
2. Jobs-to-be-Done — informs backbone activities
3. User Story Map (this document) — organizes work visually
4. User Story — converts map tasks into detailed stories with acceptance criteria
5. User Story Splitting — breaks down large tasks from the map into sprint-sized work
