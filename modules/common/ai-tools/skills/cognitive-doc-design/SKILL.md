---
name: cognitive-doc-design
description: "Design docs that reduce cognitive load. Trigger: writing guides, READMEs, RFCs, onboarding, architecture, or review-facing docs."
---

## When to Use

Load this skill when creating or editing documentation that people need to understand quickly, retain, or use during review:

- PR descriptions and review notes
- Contributor or maintainer guides
- Architecture, workflow, or onboarding docs
- Any doc that feels long, dense, or hard to scan

## Critical Patterns

| Pattern | Rule |
|---------|------|
| Lead with the answer | Put the decision, action, or outcome first. Context comes after. |
| Progressive disclosure | Start with the happy path, then add details, edge cases, and references. |
| Chunking | Group related information into small sections. Keep flat lists short. |
| Signposting | Use headings, labels, callouts, and summaries so readers know where they are. |
| Recognition over recall | Prefer tables, checklists, examples, and templates over prose that must be remembered. |
| Review empathy | Design docs so reviewers can verify intent without reconstructing the whole story. |

## PR and Review Docs

- State what to review first.
- State what is intentionally out of scope.
- Link the previous and next PR when work is chained.
- Keep each section focused on one decision or unit of work.
- Use checklists for acceptance criteria and verification.

## Commands

```bash
git diff --name-only -- '*.md'
gh pr view <PR_NUMBER> --json additions,deletions,changedFiles
```

## References

- [references/doc-template.md](references/doc-template.md) — default documentation structure template
