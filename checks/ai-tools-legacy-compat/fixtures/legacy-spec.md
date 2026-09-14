# Delta Spec: auth (redacted legacy fixture)

## ADDED Requirements

### Requirement: Login

Users MUST log in.

#### Scenarios

**Scenario: Valid login**
- Given: a registered user
- When: they submit valid credentials
- Then: a session is created

**Scenario: Invalid login**
- Given: a registered user
- When: they submit a wrong password
- Then: the request is rejected
