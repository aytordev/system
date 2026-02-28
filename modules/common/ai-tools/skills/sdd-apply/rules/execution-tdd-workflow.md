## TDD Workflow (RED → GREEN → REFACTOR)

**Impact: CRITICAL**

When TDD mode is detected, follow the RED → GREEN → REFACTOR cycle for each task.

### The TDD Cycle

For **each assigned task**, execute this workflow:

#### 1. UNDERSTAND

Read and internalize:
- **Task description** — What specific functionality is being added?
- **Relevant spec scenarios** — What are the success criteria?
- **Design decisions** — How should it be structured?
- **Existing code** — What patterns should be followed?

#### 2. RED (Write Failing Test)

Write a test that:
- Describes the expected behavior from the spec
- Calls the function/method that doesn't exist yet (or doesn't have the new behavior)
- Asserts the expected outcome

**Run the test** — Confirm it **FAILS** (RED).

**Example:**

```typescript
// auth.test.ts
describe('hashPassword', () => {
  it('should return a bcrypt hash different from the input', async () => {
    const password = 'mySecurePassword123';
    const hash = await hashPassword(password);

    expect(hash).not.toBe(password);
    expect(hash).toMatch(/^\$2[aby]\$/); // bcrypt format
  });
});
```

Run: `npm test -- auth.test.ts`

Expected output: **FAIL** (hashPassword is not defined)

#### 3. GREEN (Write Minimum Code)

Write **just enough code** to make the test pass. No more, no less.

**Example:**

```typescript
// services/auth.ts
import bcrypt from 'bcrypt';

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}
```

**Run the test** — Confirm it **PASSES** (GREEN).

#### 4. REFACTOR (Clean Up)

Improve the code without changing behavior:
- Extract magic numbers to constants (e.g., `10` → `BCRYPT_ROUNDS`)
- Improve variable names
- Remove duplication
- Add comments if needed

**Example:**

```typescript
// services/auth.ts
import bcrypt from 'bcrypt';

const BCRYPT_ROUNDS = 10;

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, BCRYPT_ROUNDS);
}
```

**Run the test again** — Confirm tests still **PASS**.

#### 5. Mark Task Complete

Update `tasks.md`:

```diff
- - [ ] 2.1 Implement hashPassword in services/auth.ts
+ - [x] 2.1 Implement hashPassword in services/auth.ts
```

### Test Running Strategy

**ONLY run the relevant test file or suite**, not the entire test suite.

**Good:**
```bash
npm test -- auth.test.ts
go test ./internal/auth/...
pytest tests/auth/
```

**Bad (slow, noisy):**
```bash
npm test  # runs everything
pytest    # runs everything
```

### TDD Output Format

For each task, record:

| Task | RED | GREEN | REFACTOR |
|------|-----|-------|----------|
| 2.1 hashPassword | ✓ (test failed as expected) | ✓ (test passes) | ✓ (extracted BCRYPT_ROUNDS) |
| 2.2 verifyPassword | ✓ | ✓ | — (no refactor needed) |

This table goes in the detailed report.
