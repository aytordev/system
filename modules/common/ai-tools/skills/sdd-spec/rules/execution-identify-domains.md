## Identify Domains from Proposal

**Impact: CRITICAL**

From the proposal's "Affected Areas", group changes by domain. Each domain gets its own spec file.

### What is a Domain?

A domain is a logical grouping of related functionality. Examples:
- `auth` — authentication and authorization
- `api` — API endpoints and contracts
- `ui` — user interface components
- `storage` — data persistence layer
- `notifications` — notification system

### How to Identify Domains

1. Read the proposal's "Affected Areas" section
2. Group related changes together
3. Each domain should be cohesive (changes that belong together)
4. Avoid creating too many tiny domains (prefer 2-5 domains per change)

### Output

Produce a list of domains:

```
Domains identified:
- auth (login flow, session management)
- api (new endpoint /api/users)
- ui (login form, error messages)
```
