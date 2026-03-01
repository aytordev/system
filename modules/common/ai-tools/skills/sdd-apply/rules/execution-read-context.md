## Read Specs, Design, Tasks, and Existing Code

**Impact: CRITICAL**

Before implementing, read all context needed to write correct code that matches the project.

### What to Read

1. **Specs** — Describes **WHAT** to implement:
   - User scenarios and expected behavior
   - API contracts and data formats
   - Success criteria and validation rules

2. **Design** — Describes **HOW** to implement:
   - Architecture decisions and rationale
   - File structure and module boundaries
   - Component interactions and data flow
   - Technology choices (libraries, patterns)

3. **Tasks** — Describes **WHICH TASKS** to implement:
   - The specific task numbers assigned to you (e.g., "Phase 1, tasks 1.1-1.3")
   - File paths affected by each task
   - Dependencies between tasks

4. **Existing Code** — Understand the project patterns:
   - Read files in the same directory as your target files
   - Identify naming conventions (camelCase, snake_case, PascalCase)
   - Identify code organization patterns (class-based, functional, etc.)
   - Identify error handling patterns (exceptions, result types, etc.)
   - Identify testing patterns (test file naming, assertion style)

5. **Coding Conventions** from `config.yaml`:
   - Check `rules.apply` for project-specific rules
   - Check `rules.apply.tdd` to see if TDD is required
   - Check `rules.apply.match_existing_patterns` preference

### Example: Reading Context

```bash
# Specs (WHAT)
Read: openspec/changes/add-auth/specs/user-scenarios.md
      → User must be able to login with email/password
      → Invalid credentials return 401

# Design (HOW)
Read: openspec/changes/add-auth/design.md
      → Use JWT tokens in Authorization header
      → Store hashed passwords with bcrypt
      → Implement in services/auth.ts

# Tasks (WHICH)
Read: openspec/changes/add-auth/tasks.md
      → Assigned: Phase 2, tasks 2.1-2.3
      → 2.1: Implement hashPassword in services/auth.ts
      → 2.2: Implement verifyPassword in services/auth.ts
      → 2.3: Implement generateToken in services/auth.ts

# Existing Code (PATTERNS)
Read: services/user.ts
      → Uses async/await pattern
      → Exports functions (not classes)
      → Imports from '@/lib/db' for database access
      → Error handling with try/catch and custom AppError

# Config (RULES)
Read: openspec/config.yaml
      → rules.apply.tdd: true (use TDD workflow)
      → rules.apply.match_existing_patterns: true
```

### Output

Mental model of:
- What the code should do (from specs)
- How it should be structured (from design)
- What patterns to follow (from existing code)
- Which specific tasks to complete (from tasks.md)
- Whether to use TDD (from config)
