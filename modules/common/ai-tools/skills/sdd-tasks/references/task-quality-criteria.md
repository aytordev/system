# Task Quality Criteria

Every task in the task breakdown must meet these quality criteria.

## The Four Criteria

### 1. Specific

The task must clearly state:
- What file(s) will be modified
- What specific functionality is being added/changed
- What the scope is (no ambiguity)

**Good:**
- "Create internal/auth/middleware.go with JWT validation logic"
- "Add user login endpoint to routes/api.ts with POST /api/login"
- "Update types.ts to add UserRole enum with Admin, User, Guest"

**Bad:**
- "Add auth"
- "Update types"
- "Fix the API"

### 2. Actionable

The task must describe something that can be done immediately with clear action verbs.

**Good:**
- "Write test for login failure scenario in auth_test.go"
- "Implement getUserById in repositories/user.ts"
- "Create database migration 002_add_roles.sql"

**Bad:**
- "Consider testing"
- "Think about error handling"
- "Maybe add validation"

### 3. Verifiable

The task must have clear completion criteria. You should be able to check if it's done.

**Good:**
- "Run `go test ./internal/auth/...` — expect all tests pass"
- "Verify API responds with 401 for invalid tokens"
- "Confirm migration runs without errors with `npm run migrate:up`"

**Bad:**
- "Make sure it works"
- "Ensure quality"
- "Check everything"

### 4. Small

The task must be completable in ONE session (typically 15-60 minutes of work).

**Good:**
- One file, one concern
- One function or small group of related functions
- One test file or test suite

**Bad:**
- "Implement entire authentication system"
- "Build user management feature"
- "Create all CRUD endpoints"

## Phase Organization Guidelines

### Phase 1: Foundation / Infrastructure

Build the base upon which everything else depends.

**Examples:**
- Create base types and interfaces
- Database schema and migrations
- Configuration files
- Utility functions with no dependencies

**Anti-examples:**
- Business logic (that's Phase 2)
- API endpoints (that's Phase 3)

### Phase 2: Core Implementation

Implement the main business logic and internal components.

**Examples:**
- Services (auth, user, payment)
- Repositories (data access layer)
- Core algorithms
- Internal utilities

**Anti-examples:**
- Wiring/middleware (that's Phase 3)
- Tests (that's Phase 4)

### Phase 3: Integration / Wiring

Connect components together and expose functionality.

**Examples:**
- Middleware registration
- API route registration
- Component dependency injection
- External service integrations

**Anti-examples:**
- Core logic implementation (that's Phase 2)
- Documentation (that's Phase 5)

### Phase 4: Testing

Validate that everything works as specified.

**Examples:**
- Unit tests for services
- Integration tests for flows
- E2E tests if applicable
- Test data creation

**Organization:** Group by component being tested, not by test type.

### Phase 5: Cleanup / Documentation

Finalize the change for merging and future maintenance.

**Examples:**
- Update API documentation
- Add migration notes to README
- Remove deprecated code
- Update changelog

**Anti-examples:**
- Bug fixes (should be in the phase where the bug was introduced)
- New features (out of scope)

## Size Guidelines

- **Max 10 tasks per phase** (configurable via `rules.tasks.max_phase_size` in config.yaml)
- **If a phase exceeds 10 tasks**, consider:
  - Splitting complex tasks into sub-tasks (use 1.1a, 1.1b)
  - Moving some tasks to a different phase
  - Questioning if the change is too large (should it be split?)

## TDD Integration

If `rules.apply.tdd: true` in config.yaml, create task triplets:

```markdown
- [ ] 4.1 RED: Write failing test for user login in auth_test.go
- [ ] 4.2 GREEN: Implement login function to pass test
- [ ] 4.3 REFACTOR: Extract validation logic to separate function
```

Each triplet follows the RED → GREEN → REFACTOR cycle.
