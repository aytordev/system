## Phase Selection — Codebase Scan and Option Presentation

**Impact: CRITICAL**

Before starting the SDD cycle, find a real improvement in the user's codebase. Do NOT use a toy example.

### Step 1: Welcome the User

```
"Welcome to SDD! I'll walk you through a complete cycle using your actual codebase.
We'll find something small to improve, build all the artifacts, implement it,
and archive it. Each step I'll explain what we're doing and why.

Let me scan your codebase for opportunities..."
```

### Step 2: Scan for Improvement Opportunities

Read the codebase to find 2-3 real candidates. Use these criteria:

```
Good onboarding change criteria:
├── Small scope — completable in one session
├── Low risk — no breaking changes, no data migrations
├── Real value — genuinely useful, not artificial
├── Spec-worthy — at least 1 clear requirement + 2 scenarios
└── Examples:
    ├── Missing input validation on a function or module option
    ├── Inconsistent error handling in a module
    ├── A utility that could be extracted and reused
    ├── Missing documentation for a complex option
    └── A TODO/FIXME comment with clear intent
```

### Step 3: Present Options

Present 2-3 options with a brief description and why each fits:

```markdown
## Onboarding Options

I found these improvement opportunities:

**Option A**: {description} — {why it's a good fit}
**Option B**: {description} — {why it's a good fit}
**Option C** (if found): {description} — {why it's a good fit}

Which would you like to use for the walkthrough? Or suggest your own.
```

### Step 4: Wait for User Choice

STOP and wait for the user to pick an option. Do NOT proceed until they respond.

If they pick their own improvement, validate it meets the criteria before proceeding. If it doesn't fit (too large, too risky), explain why and suggest adjusting scope.

### Step 5: Derive Change Name

From the chosen improvement, derive a kebab-case change name:
- `add-validation-to-option-x`
- `extract-shared-helper`
- `fix-error-handling-in-module-y`

Confirm the name with the user: `"I'll name this change '{name}'. OK to proceed?"`
