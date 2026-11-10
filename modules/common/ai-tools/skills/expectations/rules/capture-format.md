---
title: Write the Capture Entry
impact: MEDIUM
impactDescription: Keeps a recorded learning readable and scannable
tags: documentation, format, communication
---

## Write the Capture Entry

**Impact: MEDIUM**

A future reader must grasp context, issue, and solution in under ten seconds.
Match the surrounding document's structure rather than importing this shape where
the owner already has one.

### Gotcha entry

```markdown
#### Gotcha: [Descriptive Title]

**Context**: When this occurs
**Issue**: What goes wrong
**Solution**: How to handle it
```

```typescript
// CORRECT - the approach that works
const example = "correct approach";

// WRONG - what causes the problem
const wrong = "incorrect approach";
```

### Decision entry

Record the decision, the alternatives considered, and why they lost. A decision
entry without its rejected alternatives is a changelog line, not rationale.

### Pattern or anti-pattern entry

State the situation the pattern applies to, the pattern itself as one concrete
rule, and the failure it prevents. Link to the file that demonstrates it rather
than pasting the whole implementation.

## Keep It Scannable

- One heading per entry, named for the problem rather than the solution.
- Short labelled fields, not paragraphs of narrative.
- A code block only when the shape matters. Two blocks (correct and incorrect)
  beat a paragraph explaining both.
- No duplication of what the code or its tests already state.

## Communication While Doing This

- Be explicit about trade-offs between approaches.
- Explain the reasoning behind significant decisions.
- Flag deviations from repository guidelines with justification.
- Suggest improvements that align with these principles.
- When unsure where a fact belongs, ask rather than assuming.
- Always state whether the recommendation is a reusable principle or local
  policy.
