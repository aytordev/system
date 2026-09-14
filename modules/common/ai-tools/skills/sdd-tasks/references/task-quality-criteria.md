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

Each task line records the focused `check:`, the applicable `scenario:` (or an
explicit `N/A — {reason}`), and the `rollback:` boundary — see
`rules/execution-write-tasks.md`.

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
- Documentation (that's Phase 4)

### Tests Attach to Their Unit

Do not create a standalone testing phase. Each unit's focused test/scenario is
part of that unit (Phases 1–3). Phase 4 only holds cross-cutting checks that no
single unit owns.

**Examples (attached to a unit):**
- Unit test for `services/auth.ts` in the same task that implements it
- Integration test for a flow attached to the wiring task
- Test data/fixtures created alongside their consumer

### Phase 4: Verification / Cleanup / Documentation

Finalize the change for merging and future maintenance. Tests stay with the unit
they verify — Phase 4 MUST NOT be the only place a unit is covered.

**Examples:**
- Update API documentation
- Add migration notes to README
- Remove deprecated code
- Update changelog
- Cross-cutting integration/E2E checks not owned by a single unit

**Anti-examples:**
- Bug fixes (should be in the phase where the bug was introduced)
- New features (out of scope)
- The first test for a Phase 1–3 unit (attach it to that unit)

## Review Workload Forecast

The tasks artifact MUST end with a `Review Workload Forecast` block whose
decision fields the orchestrator consumes. See `rules/execution-write-tasks.md`.

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
