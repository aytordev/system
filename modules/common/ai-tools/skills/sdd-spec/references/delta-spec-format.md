# Delta Spec Format Reference

Delta specs describe CHANGES to existing specifications. They make reviews easy by highlighting what's different.

## Structure

```markdown
# Delta Spec: {domain}
**Change**: {change-name}

## ADDED Requirements

### Requirement: {Name}
{Description using RFC 2119 keywords}

#### Scenarios

**Scenario: {name}**
- Given: {precondition}
- When: {action}
- Then: {expected result}

**Scenario: {another scenario}**
- Given: {precondition}
- When: {action}
- Then: {expected result}

## MODIFIED Requirements

### Requirement: {Name}
{Updated description using RFC 2119 keywords}

(Previously: {old description or key change})

#### Scenarios

**Scenario: {name}**
- Given: {precondition}
- When: {action}
- Then: {expected result}

## REMOVED Requirements

### Requirement: {Name}
(Reason: {why this requirement is being removed})
```

## Example: Authentication Change

```markdown
# Delta Spec: auth
**Change**: oauth2-support

## ADDED Requirements

### Requirement: OAuth2 Provider Support
The system MUST support OAuth2 authentication with Google and GitHub providers.

#### Scenarios

**Scenario: Successful Google OAuth2 login**
- Given: A user with a valid Google account
- When: They click "Sign in with Google"
- Then: They are redirected to Google, authorize, and return with a valid session

**Scenario: OAuth2 state mismatch**
- Given: An OAuth2 callback with invalid state parameter
- When: The system validates the callback
- Then: The request is rejected with a 400 error

### Requirement: OAuth2 Token Refresh
The system MUST automatically refresh OAuth2 tokens before expiry.

#### Scenarios

**Scenario: Token refresh before expiry**
- Given: A user session with a token expiring in 5 minutes
- When: The user makes an authenticated request
- Then: The system refreshes the token transparently

## MODIFIED Requirements

### Requirement: Session Duration
User sessions MUST expire after 24 hours of inactivity.

(Previously: Sessions expired after 1 hour of inactivity)

#### Scenarios

**Scenario: Session timeout after 24 hours**
- Given: A user session inactive for 24 hours
- When: The user attempts an authenticated action
- Then: They are redirected to login with a "session expired" message

## REMOVED Requirements

### Requirement: Password Complexity Rules
(Reason: Replaced by OAuth2-only authentication — no passwords stored)
```

## When to Use Delta vs Full Spec

- **Delta spec**: When `openspec/specs/{domain}/spec.md` already exists
- **Full spec**: When no existing spec exists for that domain

## Benefits of Delta Specs

1. **Easy review**: Reviewers see only what changed
2. **History**: "Previously:" notes preserve context
3. **Clarity**: ADDED/MODIFIED/REMOVED sections are unambiguous
4. **Merge-friendly**: Changes are localized to specific sections
