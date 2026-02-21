# User Story Splitting — Full Framework

## Purpose

Break down large user stories, epics, or features into smaller, independently
deliverable stories using systematic splitting patterns. Smaller stories ship
faster, are easier to estimate, reduce risk, and enable faster feedback cycles.
Based on Richard Lawrence and Peter Green's "Humanizing Work Guide to Splitting
User Stories."

## When to Use

- Story is too large for a single sprint
- Acceptance criteria contain multiple "When" or "Then" statements
- Epic needs decomposition into deliverable increments
- Team cannot reach consensus on story size or scope
- Story bundles multiple personas or workflows

## When Not to Use

- Story is already small and well-scoped (do not over-split)
- Splitting would create hard dependencies that slow delivery
- The item is a technical task, not a user story (use engineering task breakdown)

## The Eight Splitting Patterns

Work through these patterns in order. Stop when you find one that applies.

### Pattern 1: Workflow Steps

**Test:** Does this story contain multiple sequential steps?

Original: "As a user, I want to sign up, verify email, and complete onboarding"

Split:
1. "As a user, I want to sign up with email/password"
2. "As a user, I want to verify my email via a confirmation link"
3. "As a user, I want to complete onboarding by answering 3 profile questions"

### Pattern 2: Business Rule Variations

**Test:** Does this story have different rules for different scenarios?

Original: "As a user, I want to apply discounts"

Split:
1. "As a member, I want to apply a 10% discount at checkout"
2. "As a VIP, I want to apply a 20% discount at checkout"
3. "As a first-time buyer, I want to apply a 5% discount at checkout"

### Pattern 3: Data Variations

**Test:** Does this story handle different types of data or inputs?

Original: "As a user, I want to upload files"

Split:
1. "As a user, I want to upload image files (JPG, PNG)"
2. "As a user, I want to upload PDF documents"
3. "As a user, I want to upload video files (MP4, MOV)"

### Pattern 4: Acceptance Criteria Complexity

**Test:** Does this story have multiple "When" or "Then" statements?

This is the most common splitting indicator.

Original: "As a user, I want to manage my cart"
- When I add an item, Then it appears in my cart
- When I remove an item, Then it disappears
- When I update quantity, Then the total updates

Split:
1. "As a user, I want to add items to my cart"
2. "As a user, I want to remove items from my cart"
3. "As a user, I want to update item quantities in my cart"

### Pattern 5: Major Effort

**Test:** Does this require significant work that can be delivered incrementally?

Original: "As a user, I want real-time collaboration on documents"

Split:
1. "As a user, I want to see who else is viewing the document" (presence)
2. "As a user, I want to see live cursor positions of other editors"
3. "As a user, I want to see live edits from other users in real-time"

### Pattern 6: External Dependencies

**Test:** Does this story depend on multiple external systems or APIs?

Original: "As a user, I want to log in with Google, Facebook, or Twitter"

Split:
1. "As a user, I want to log in with Google OAuth"
2. "As a user, I want to log in with Facebook OAuth"
3. "As a user, I want to log in with Twitter OAuth"

### Pattern 7: DevOps Steps

**Test:** Does this require complex deployment or infrastructure work?

Original: "As a user, I want to upload large files to cloud storage"

Split:
1. "As a user, I want to upload small files (<10MB)"
2. "As a user, I want to upload large files (10MB-1GB) with progress tracking"
3. "As a user, I want to resume interrupted uploads"

### Pattern 8: Tiny Acts of Discovery (TADs)

**Test:** Are there too many unknowns to write concrete stories?

Use TADs when none of the above patterns apply. TADs are not stories — they are
small experiments to de-risk and clarify before writing stories.

Original: "As a user, I want AI-powered recommendations" (too vague)

TADs:
1. Prototype 3 recommendation algorithms and test with 10 users
2. Define success criteria (click-through rate, satisfaction score)
3. Build simplest recommendation engine (collaborative filtering)
4. Measure and iterate

## Split Story Template

Each split must be a complete user story with its own acceptance criteria:

```markdown
## Split [N] using [Pattern Name]

### User Story
As a [persona]
I want [specific capability]
So that [distinct outcome]

### Acceptance Criteria
**Scenario: [Name]**
Given [precondition]
When  [action]
Then  [outcome]

### Out of Scope
- [What is NOT included in this split]
```

## Validation Checklist for Splits

Run these five questions against every split:

| Question                                    | Pass Condition                                |
|---------------------------------------------|-----------------------------------------------|
| Does it deliver user value on its own?      | Not "front-end done" — user sees a result     |
| Can it be developed independently?          | No hard dependency on another split           |
| Can it be tested independently?             | Clear acceptance criteria, demonstrable       |
| Is it small enough for a sprint?            | 1-5 days of work                              |
| Do all splits combined equal the original?  | Nothing lost in translation                   |

If any answer is "no," revise the split.

## Worked Example

```markdown
### Original Story
As a team admin, I want to manage team members so that I can control access.

Acceptance Criteria:
- When I invite a member, Then they receive an email invitation
- When I remove a member, Then their access is revoked immediately
- When I change a member's role, Then their permissions update

### Split using Pattern 4 (Acceptance Criteria Complexity)

**Split 1:** As a team admin, I want to invite new members
  so that they can join my team.
  Given I enter a valid email, When I click invite,
  Then they receive an email invitation with a join link.

**Split 2:** As a team admin, I want to remove team members
  so that former employees lose access.
  Given a member is active, When I click remove,
  Then their access is revoked immediately.

**Split 3:** As a team admin, I want to change member roles
  so that permissions match responsibilities.
  Given a member exists, When I change their role to "viewer,"
  Then they can no longer edit resources.
```

## Common Failure Modes

| Failure Mode              | Example                                       | Fix                                                           |
|---------------------------|-----------------------------------------------|---------------------------------------------------------------|
| Horizontal slicing        | "Story 1: Build API. Story 2: Build UI."      | Split vertically — each story includes full stack for one capability |
| Over-splitting            | "Story 1: Add button. Story 2: Wire to API."  | Only split when story is too large; 2-day stories need no split|
| Meaningless splits        | "Story 1: First half. Story 2: Second half."  | Use a named pattern — each split needs a clear rationale      |
| Creating hard dependencies| "Story 2 blocked until Story 1 deploys"       | Split for independent development; sequence only if unavoidable|
| Identical "so that"       | All splits share the same outcome clause      | Each split needs a distinct user outcome                      |
| Task decomposition        | "Set up database," "Write migration"          | These are tasks, not stories — no standalone user value       |

## Anti-Pattern: Horizontal Slicing

Never split by technical layer:

Bad:
- Story 1: "Build the database schema for user profiles"
- Story 2: "Build the API endpoints for user profiles"
- Story 3: "Build the UI for user profiles"

None of these delivers user value independently. A stakeholder cannot demo
"the database schema" and get feedback.

Good:
- Story 1: "As a user, I want to create a profile with name and email"
- Story 2: "As a user, I want to upload a profile photo"
- Story 3: "As a user, I want to set notification preferences"

Each is demonstrable and valuable on its own.

## Pattern Selection Guide

| Situation                                        | Best Pattern              |
|--------------------------------------------------|---------------------------|
| Story is an end-to-end process                   | Workflow Steps            |
| Multiple if/else rules drive complexity          | Business Rule Variations  |
| Story handles many formats or input types        | Data Variations           |
| Multiple When/Then pairs in acceptance criteria  | Acceptance Criteria       |
| Large technical effort, incrementally shippable  | Major Effort              |
| Multiple third-party integrations                | External Dependencies     |
| Infrastructure or deployment complexity          | DevOps Steps              |
| Too many unknowns to write concrete stories      | Tiny Acts of Discovery    |

## Relationship to Other Frameworks

1. User Story — format for writing split stories (As a / I want / So that)
2. User Story Splitting (this document) — patterns for decomposition
3. Epic Hypothesis — epics often need splitting before becoming stories
4. User Story Mapping — story maps reveal which stories need splitting
5. INVEST Criteria — each split must pass Independent, Valuable, Small, Testable
