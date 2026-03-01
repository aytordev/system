## Read the Actual Codebase

**Impact: CRITICAL**

Read the actual codebase to understand existing patterns before designing. This is essential — never design without reading code first.

### What to Read

1. **Entry points** — Where does execution start?
   - `main.js`, `index.ts`, `main.go`, `__init__.py`, etc.
   - CLI entry points, HTTP server setup

2. **Module structure** — How is the code organized?
   - Directory layout
   - Package/module boundaries
   - Separation of concerns

3. **Existing patterns** — What patterns does this codebase use?
   - Error handling (return codes, exceptions, Result types)
   - Dependency injection vs global state
   - Testing patterns (mocks, fixtures, factories)
   - Naming conventions

4. **Dependencies** — What libraries/frameworks are in use?
   - Web framework (Express, FastAPI, Gin, Axum)
   - Database libraries
   - Testing frameworks
   - Build tools

5. **Test infrastructure** — How are tests organized?
   - Unit test location (`__tests__`, `*_test.go`, `tests/`)
   - Integration test setup
   - Test utilities and helpers

### Why This Matters

**Designs that ignore existing patterns create friction:**
- Code reviews get bogged down debating style
- New code feels alien in the existing codebase
- Tests don't match existing test structure
- Dependencies conflict with existing choices

**Designs that match existing patterns merge smoothly:**
- Reviews focus on logic, not style
- New code feels native
- Tests follow established patterns
- Dependencies are compatible

### Output

Produce a concise summary:

```
Codebase Context:
- Entry: src/index.ts (Express server)
- Structure: Layered (routes → services → repositories)
- Error handling: Throws exceptions, Express error middleware
- DI: Manual dependency injection via constructors
- Tests: Jest in src/__tests__/, mocks via jest.mock()
- Database: Prisma ORM
```
