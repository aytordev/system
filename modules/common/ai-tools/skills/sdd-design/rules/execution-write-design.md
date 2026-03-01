## Write Technical Design Document

**Impact: CRITICAL**

Write `design.md` with architecture decisions, approach, and concrete implementation details.

### Location

Write to `openspec/changes/{change-name}/design.md` in openspec mode.

### Required Sections

#### 1. Technical Approach

One paragraph summary of the overall strategy.

```markdown
## Technical Approach

We'll implement OAuth2 authentication by adding a new `OAuthService` that handles provider registration, token exchange, and session creation. The existing session management will be refactored to support both password and OAuth2 flows. Database schema changes will add an `oauth_providers` table linked to users.
```

#### 2. Architecture Decisions

Each decision with: Choice / Alternatives Considered / Rationale

```markdown
## Architecture Decisions

### Decision: Use Passport.js for OAuth2

**Choice**: Integrate Passport.js with Google and GitHub strategies

**Alternatives Considered**:
- Manual OAuth2 implementation
- Auth0 / external service

**Rationale**: Passport.js is already used for password auth, adding OAuth2 strategies is low-risk. Manual implementation would increase maintenance burden. External services add cost and vendor lock-in.

### Decision: Store OAuth tokens encrypted

**Choice**: AES-256 encryption of refresh tokens in database

**Alternatives Considered**:
- Plain text storage (rejected for security)
- No refresh token storage (rejected for UX)

**Rationale**: Users expect persistent sessions. Storing encrypted refresh tokens allows automatic re-authentication without exposing tokens in breach scenarios.
```

#### 3. Data Flow

ASCII diagrams showing how data moves through the system.

```markdown
## Data Flow

### OAuth2 Login Flow

```
User → Frontend → Backend → OAuth Provider → Backend → Frontend → User
                    |                          |
                    v                          v
              /auth/google             /auth/google/callback
                                              |
                                              v
                                       Create/Update User
                                              |
                                              v
                                        Create Session
```
```

#### 4. File Changes

Table with concrete paths showing what will be created, modified, or deleted.

```markdown
## File Changes

| File | Action | Description |
|------|--------|-------------|
| `src/services/OAuthService.ts` | CREATE | OAuth2 provider logic |
| `src/routes/auth.ts` | MODIFY | Add OAuth2 endpoints |
| `src/models/User.ts` | MODIFY | Add oauth_provider field |
| `prisma/schema.prisma` | MODIFY | Add oauth_providers table |
| `src/middleware/auth.ts` | MODIFY | Support OAuth2 sessions |
| `src/__tests__/services/OAuthService.test.ts` | CREATE | Unit tests |
| `src/__tests__/routes/auth.test.ts` | MODIFY | Add OAuth2 endpoint tests |
```

#### 5. Interfaces / Contracts

Code blocks showing function signatures, types, API shapes.

```markdown
## Interfaces / Contracts

### OAuthService

```typescript
interface OAuthService {
  registerProvider(provider: 'google' | 'github'): void;
  initiateAuth(provider: string, callbackUrl: string): string;
  handleCallback(provider: string, code: string, state: string): Promise<User>;
  refreshToken(userId: string, provider: string): Promise<string>;
}
```

### API Endpoints

```
GET  /auth/:provider          - Initiate OAuth2 flow
GET  /auth/:provider/callback - Handle OAuth2 callback
POST /auth/logout             - (existing, no changes)
```
```

#### 6. Testing Strategy

Table showing what will be tested and how.

```markdown
## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Unit | OAuthService provider registration | Mock Passport strategies |
| Unit | OAuthService token refresh | Mock HTTP client |
| Integration | OAuth2 login flow | Stub OAuth provider responses |
| Integration | Session creation | Real database (test container) |
| E2E | Full OAuth2 flow | Playwright with mock provider |
```

#### 7. Migration / Rollout

Only if applicable. How will this be deployed?

```markdown
## Migration / Rollout

1. Run database migration (adds oauth_providers table)
2. Deploy backend with feature flag `OAUTH_ENABLED=false`
3. Enable for internal testing
4. Enable for 10% of users
5. Monitor error rates for 24 hours
6. Full rollout if no issues
```

#### 8. Open Questions

Checklist of unresolved items that need answers before implementation.

```markdown
## Open Questions

- [ ] Which OAuth2 scopes should we request from Google?
- [ ] Should we support account linking (same email, different providers)?
- [ ] What's the token refresh cadence? (currently: refresh 5min before expiry)
- [ ] Do we need offline access (refresh tokens) or just session tokens?
```

### Guidelines

- Use concrete file paths (not "auth module" but `src/routes/auth.ts`)
- Keep ASCII diagrams simple (box-and-arrow, not UML)
- Include ALL files that will be touched (even small changes)
- Every decision needs a rationale (not just what, but WHY)
- Apply `rules.design` from `config.yaml` if available
