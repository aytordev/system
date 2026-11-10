---
title: Group Parameters When the Call Site Is Ambiguous
impact: MEDIUM
impactDescription: Prevents swapped same-typed arguments and unclear option order
tags: composition, api-design, options
---

## Group Parameters When the Call Site Is Ambiguous

**Impact: MEDIUM**

Use an options object when parameters form a meaningful group, when several
values share the same type, or when optional arguments make the call order
unclear. Keep a small, stable function with obvious positional parameters
positional.

**Incorrect (two same-typed strings and two booleans; every call site is a guess):**

```typescript
createReport('report_123', 'pdf', 'en-GB', 'Europe/London', true, false);
```

**Correct (the call site states its intent):**

```typescript
type CreateReportOptions = {
  readonly reportId: string;
  readonly format: 'pdf' | 'csv';
  readonly locale: string;
  readonly timeZone: string;
  /** Defaults to false. */
  readonly includeCharts?: boolean;
  /** Defaults to true. */
  readonly sendEmail?: boolean;
};

function createReport(options: CreateReportOptions): Report {
  const {
    reportId,
    format,
    locale,
    timeZone,
    includeCharts = false,
    sendEmail = true,
  } = options;
  // ...
}

createReport({
  reportId: 'report_123',
  format: 'pdf',
  locale: 'en-GB',
  timeZone: 'Europe/London',
  includeCharts: true,
  // sendEmail omitted: the documented default applies
});
```

### Keep positional when the order is obvious

`add(a, b)`, `clamp(value, min, max)`, and familiar high-frequency utilities
become noisier with an options object. Parameter count is a signal, not a fixed
limit: three obvious positional parameters are clearer than an options literal.

### Options objects are contracts

- Type the object with a named, exported type when callers outside the module use
  it; otherwise keep it local and private.
- Mark every property `readonly` — the callee reads options, it does not own them.
- Destructure once, at the top, and apply defaults there so the defaults are
  visible in one place.
- Do not accept the options object and also positional parameters that belong in
  it.

### Adding a parameter to an existing function

Adding an optional positional parameter to a published function is a silent
breaking change for callers that already pass a later argument. Prefer an
options object, or a new function name, when the signature is consumed elsewhere.
