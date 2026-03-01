## Write Delta or Full Specifications

**Impact: CRITICAL**

Write delta specifications to `openspec/changes/{change-name}/specs/{domain}/delta.md`.

### Delta Spec Format

For changes to existing domains, use the delta format with three sections:

#### ADDED Requirements

New requirements with Given/When/Then scenarios:

```markdown
## ADDED Requirements

### Requirement: OAuth2 Support

The system MUST support OAuth2 authentication flow.

#### Scenarios

**Scenario: Successful OAuth2 login**

- Given: A user with valid OAuth2 credentials
- When: They initiate the OAuth2 flow
- Then: They are redirected to the provider and returned with a valid token

**Scenario: Invalid OAuth2 state parameter**

- Given: An OAuth2 callback with mismatched state
- When: The system validates the state parameter
- Then: The request is rejected with a 400 error
```

#### MODIFIED Requirements

Changed requirements with "Previously:" note showing what changed:

```markdown
## MODIFIED Requirements

### Requirement: Session Duration

User sessions MUST expire after 24 hours of inactivity.

(Previously: Sessions expired after 1 hour)

#### Scenarios

**Scenario: Session timeout after 24 hours**

- Given: A user session inactive for 24 hours
- When: The user attempts an authenticated action
- Then: They are redirected to login
```

#### REMOVED Requirements

Removed requirements with reason:

```markdown
## REMOVED Requirements

### Requirement: Password Complexity Rules

(Reason: Replaced by OAuth2-only authentication)
```

### Full Spec Format

For NEW domains (no existing spec), write a full spec with:

```markdown
# Spec: {domain}

## Purpose

Brief description of what this domain covers.

## Requirements

### Requirement: {Name}

{Description using RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)}

#### Scenarios

**Scenario: {name}**

- Given: {precondition}
- When: {action}
- Then: {expected result}
```

### Guidelines

- Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY, MUST NOT) for requirement strength
- Every requirement MUST have at least ONE Given/When/Then scenario
- Include happy path AND edge case scenarios
- Keep scenarios testable and specific
- Apply `rules.specs` from `config.yaml` if available
