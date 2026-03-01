## Standard Implementation Workflow

**Impact: CRITICAL**

When TDD mode is NOT active, follow this standard implementation workflow.

### The Standard Workflow

For **each assigned task**, execute:

#### 1. Read Task Context

- **Task description** — What specific functionality is being added?
- **Relevant spec scenarios** — What are the success criteria?
- **Design decisions** — How should it be structured?

#### 2. Read Existing Code Patterns

Read files in the same area to understand:
- Naming conventions
- Code organization patterns (classes, functions, modules)
- Error handling patterns
- Import/export patterns
- Comment style

**Example:**

```typescript
// Reading services/user.ts to understand patterns:
// - Exports async functions (not classes)
// - Uses try/catch with AppError for errors
// - Imports db from '@/lib/db'
// - Uses TypeScript types from '@/types'
```

#### 3. Write Implementation Code

Write the code following:
- The design's architectural decisions
- The patterns identified in existing code
- The spec's requirements

**Example:**

Task: "2.1 Implement hashPassword in services/auth.ts"

```typescript
// services/auth.ts
import bcrypt from 'bcrypt';
import { AppError } from '@/lib/errors';

const BCRYPT_ROUNDS = 10;

/**
 * Hash a password using bcrypt
 * @param password - Plain text password to hash
 * @returns Promise resolving to hashed password
 * @throws AppError if hashing fails
 */
export async function hashPassword(password: string): Promise<string> {
  try {
    return await bcrypt.hash(password, BCRYPT_ROUNDS);
  } catch (error) {
    throw new AppError('Failed to hash password', { cause: error });
  }
}
```

Matches existing patterns:
- ✓ Async function export
- ✓ Try/catch with AppError
- ✓ JSDoc comments
- ✓ Constant for magic numbers

#### 4. Mark Task Complete

Update `tasks.md`:

```diff
- - [ ] 2.1 Implement hashPassword in services/auth.ts
+ - [x] 2.1 Implement hashPassword in services/auth.ts
```

### Note Deviations

If you deviate from the design, **note it explicitly**:

```
DEVIATION: Design specified using SHA-256 for hashing, but existing code uses bcrypt
consistently. Changed to bcrypt to match project patterns (rules.apply.match_existing_patterns: true).
```

### Standard Output Format

For each task, record:

| Task | File | Action | Status |
|------|------|--------|--------|
| 2.1 | services/auth.ts | Added hashPassword function | Complete |
| 2.2 | services/auth.ts | Added verifyPassword function | Complete |
| 2.3 | services/auth.ts | Added generateToken function | Complete |

This table goes in the detailed report.
