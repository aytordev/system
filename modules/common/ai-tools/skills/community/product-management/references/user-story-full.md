# User Story — Full Framework

## Core Format (Mike Cohn)

```
As a [role]
I want [capability]
So that [benefit / business value]
```

Every element is mandatory. The "so that" clause makes the business value explicit and
prevents stories from becoming feature specifications without purpose.

## INVEST Criteria Checklist

Apply all six before accepting a story into a sprint.

| Criterion    | Test Question                                                  | Fail Signal                              |
|--------------|----------------------------------------------------------------|------------------------------------------|
| Independent  | Can this ship without another story being complete first?      | "Depends on the API ticket"              |
| Negotiable   | Can scope be adjusted without losing the core value?           | "Must have all 8 fields"                 |
| Valuable     | Does a stakeholder care if this ships or not?                  | "The DB layer for the feature"           |
| Estimable    | Can the team size it (even roughly)?                           | "We don't know enough to estimate"       |
| Small        | Can it complete within one sprint?                             | "This is basically an epic"              |
| Testable     | Is there a clear pass/fail condition?                          | "The user experience should feel smooth" |

If any criterion fails, the story must be rewritten or split before it enters a sprint.

## Acceptance Criteria: Gherkin Format

Acceptance criteria must be written in Gherkin so they are unambiguous and directly
executable as automated tests. Prose AC ("The user should see a confirmation") is
not acceptable — it is untestable and creates room for interpretation.

```
Given [precondition / system state]
When  [user action or event]
Then  [expected outcome — specific, measurable]
```

Each scenario covers exactly one path. Write separate scenarios for:
- The happy path (main success case)
- Each unhappy path (error, edge case, boundary)
- Any time-dependent or conditional state

## Complete Story Template

```markdown
## Story: [Short imperative title]

As a [role]
I want [capability]
So that [benefit]

### Acceptance Criteria

**Scenario: [Happy path name]**
Given [precondition]
When  [action]
Then  [outcome]

**Scenario: [Unhappy path name]**
Given [precondition]
When  [action]
Then  [outcome]

### Out of Scope
- [What is explicitly NOT included in this story]

### Open Questions
- [Unresolved decisions that may affect implementation]

### Notes
- [Links to designs, API specs, data models]
```

## Worked Example

```markdown
## Story: Reset forgotten password

As a registered user
I want to reset my password using my email address
So that I can regain access to my account if I forget my credentials

### Acceptance Criteria

**Scenario: Successful reset link delivery**
Given I am on the login page
When  I click "Forgot password" and submit a valid registered email
Then  I receive a reset link within 2 minutes

**Scenario: Password update via valid link**
Given I click a reset link received within the last 24 hours
When  I enter and confirm a new password meeting complexity requirements
Then  my password is updated and I am redirected to the dashboard

**Scenario: Expired link**
Given a reset link older than 24 hours
When  I attempt to use it
Then  I see an error message and am prompted to request a new link

**Scenario: Unregistered email**
Given I submit an email address not associated with any account
When  the request is processed
Then  I see the same confirmation message as a registered email (no enumeration)

### Out of Scope
- Social login password reset (handled by OAuth provider)
- Admin-forced password reset (separate story)

### Open Questions
- Token expiry: 24 hours confirmed or adjustable per environment?
```

## Quality Checklist (Run Before Story Sign-Off)

- [ ] Written from the user's perspective, not the system's
- [ ] Role is a specific persona or user type, not "user" or "person"
- [ ] "So that" clause names a business outcome, not a feature
- [ ] Passes all six INVEST criteria
- [ ] Acceptance criteria in Gherkin, not prose
- [ ] Happy path and at least one unhappy path covered
- [ ] Out of scope section present
- [ ] Story can be demonstrated to a stakeholder in isolation
- [ ] Sized: team can complete within one sprint without heroics

## Story Splitting Guidance

Split when a story fails the Small or Estimable criterion. Use these patterns
(in order of preference for preserving value):

| Pattern           | When to Use                                       | Example Split                                              |
|-------------------|---------------------------------------------------|------------------------------------------------------------|
| Workflow steps    | Story covers an end-to-end process                | "Search" and "Filter results" as separate stories          |
| Happy/Unhappy path| Core flow is clear but edge cases are large       | Success path now; error handling next sprint               |
| Data types        | Story handles multiple formats or input types     | CSV export; PDF export as separate stories                 |
| Operations (CRUD) | Story combines create, read, update, delete       | "View report" now; "Edit report" later                     |
| Business rules    | Multiple rule variations drive complexity         | One pricing rule per story                                 |
| Roles             | Same capability for different user types varies   | Manager view; Analyst view as separate stories             |
| Platforms         | Web and mobile implementations differ             | Web now; mobile after web validated                        |
| Input variations  | Story handles many distinct input configurations  | Single file upload now; bulk upload next sprint            |

**Anti-pattern to avoid:** Never split by technical layer (UI / API / DB). Each
layer has no standalone value. If a story's sub-parts cannot each be demonstrated
to a stakeholder, the split is wrong.
