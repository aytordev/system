## Analyze Design to Identify Implementation Components

**Impact: CRITICAL**

Before writing tasks, analyze the design artifact to extract all concrete implementation requirements.

### What to Extract

1. **File Changes Table** — The design's "File Changes" section lists every file to create, modify, or delete:
   - Map each file to one or more tasks
   - Identify dependency order (what must be built first)

2. **Component Breakdown** — For each component in the design:
   - What files does it span?
   - What are its dependencies (internal and external)?
   - What testing is required?

3. **Integration Points** — Identify:
   - Where components wire together
   - Configuration updates needed
   - Database migrations or schema changes

4. **Testing Requirements** — Per component:
   - Unit test files needed
   - Integration test scenarios
   - Test data or fixtures required

### Output

Create a mental map (or notes) like:

```
Foundation phase:
- Create base types in types.ts
- Create database schema in migrations/001_init.sql

Core phase:
- Implement auth service in services/auth.ts
- Implement user repository in repositories/user.ts

Integration phase:
- Wire auth middleware in middleware/auth.ts
- Update API routes in routes/api.ts

Testing phase:
- Unit tests for auth service
- Integration tests for auth flow

Cleanup phase:
- Update API documentation
- Add migration notes to README
```

This map becomes the source for writing tasks.md.
