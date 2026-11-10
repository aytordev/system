---
title: Ask Only Source-Unanswerable Decisions
impact: HIGH
impactDescription: Questions close gaps, not shift work
tags: parity, questions, interaction
---

## Ask Only Source-Unanswerable Decisions

**Impact: HIGH**

Use the harness's available ask-question facility when it exists:
`AskUserQuestion`, `request_user_input`, `ask_question`, or the equivalent in
the active agent harness. If no structured question tool is available, ask a
concise plain-text question.

Ask only after inspection. Ask only questions that change the generated skill
or required fixes.

Question rules:

- Ask one decision at a time unless two options are tightly coupled.
- Prefer structured options when the answer space is enumerable.
- Include the evidence that triggered the question.
- Recommend the safest option first, but name the tradeoff.
- Capture each answer into the generated skill; do not leave decisions only
  in chat.

Reusable question shapes (auth restriction, missing production truth,
intentional divergence, test boundary, heavy local dependency) and the
capture format live in `references/question-patterns.md`.

Example:

```markdown
Production appears to require authentik group `app-users` for login, but local and PR setup seed no equivalent restriction.
How should non-production enforce this?

1. Mirror production with seeded IdP group membership. Recommended: catches auth drift while keeping local deterministic.
2. Use a lightweight OIDC/authentik emulator with the same required claim. Good when running real authentik locally is too heavy.
3. Keep local unrestricted, but add contract/E2E tests that fail unless prod-only group enforcement is represented. Faster local login, higher residual drift risk.
```

If the answer is ambiguous, ask one follow-up that makes it testable.
