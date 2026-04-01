---
title: Assertion Quality Audit
impact: HIGH
impactDescription: Catches trivial tests that provide false confidence
tags: testing, assertions, quality
---

## Assertion Quality Audit

**Impact: HIGH**

Scan ALL test files created or modified by this change for trivial or meaningless assertions.

### Banned Patterns to Detect

```
FOR EACH test file:
├── Tautologies: expect(true).toBe(true), assert True, expect(1).toBe(1)
│   └── Severity: CRITICAL — proves nothing
│
├── Ghost loops: assertions inside for/forEach over queryAll/filter results
│   └── Check if collection could be empty → assertions NEVER RUN
│   └── Severity: CRITICAL — always passes
│
├── Assertions without production code call
│   └── No function call, no render, no request before assertion
│   └── Severity: CRITICAL — exercises nothing
│
├── Empty collection without companion non-empty test
│   └── expect(result).toEqual([]) or assert len(result) == 0
│   └── ONLY valid if setup SHOULD produce empty AND companion test exists
│   └── Severity: WARNING
│
├── Type-only assertions alone: toBeDefined(), not.toBeNull()
│   └── OK if COMBINED with value assertions in same test
│   └── Severity: WARNING
│
├── Smoke-test-only: render() + toBeInTheDocument() without behavioral check
│   └── Severity: WARNING — does not count toward coverage
│
├── CSS class / implementation detail assertions
│   └── expect(el.className).toContain("text-xs")
│   └── Severity: WARNING — tests behavior, not implementation
│
└── Mock/assertion ratio
    └── If mocks > 2× assertions → WARNING (wrong test layer)
```

### Valid Assertions MUST

1. Call production code
2. Assert a specific expected value
3. Would FAIL if the production code were wrong

### Output

```markdown
### Assertion Quality
| File | Line | Assertion | Issue | Severity |
|------|------|-----------|-------|----------|
| path/test.ts | 15 | expect(true).toBe(true) | Tautology | CRITICAL |

**Assertion quality**: {N} CRITICAL, {N} WARNING
```

If no issues: "**Assertion quality**: All assertions verify real behavior"
