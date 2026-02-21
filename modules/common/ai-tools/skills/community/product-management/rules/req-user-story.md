---
title: User Story
impact: HIGH
impactDescription: Poorly written stories create ambiguous acceptance criteria and untestable deliverables
tags: user story, acceptance criteria, gherkin, invest, mike cohn
---

## User Story

**Impact: HIGH (Poorly written stories create ambiguous acceptance criteria and untestable deliverables)**

Write stories using Mike Cohn's format — "As a [role] I want [capability] so that [benefit]" — and validate each against the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, Testable. Acceptance criteria must be written in Gherkin format (Given / When / Then) so they are unambiguous and directly executable as tests. Do not write stories from the system's perspective ("The system shall...") — this removes user context and makes the business value invisible.

**Incorrect (system-centric, acceptance criteria are prose, not testable):**

```markdown
Story: Password reset

The system shall allow users to reset their password via email.
The reset link should expire after some time.
The user should see a confirmation message.
```

**Correct (role-centric, Gherkin AC, INVEST-compliant):**

```markdown
Story: Reset forgotten password

As a registered user
I want to reset my password using my email address
So that I can regain access to my account if I forget my credentials

Acceptance Criteria:

Given I am on the login page
When I click "Forgot password" and submit my email
Then I receive a reset link within 2 minutes

Given I click a valid reset link
When I enter and confirm a new password
Then my password is updated and I am redirected to the dashboard

Given a reset link older than 24 hours
When I attempt to use it
Then I see an error message and am prompted to request a new link
```

Reference: [Full framework](../references/user-story-full.md)
