---
name: issue-creation
description: "Create Gentle AI issues with issue-first checks. Trigger: creating GitHub issues, bug reports, or feature requests."
---

## When to Use

Use this skill when:
- Creating a GitHub issue (bug report or feature request)
- Helping a contributor file an issue
- Triaging or approving issues as a maintainer

## Critical Rules

1. **Blank issues are disabled** — MUST use a template (bug report or feature request)
2. **Every issue gets `status:needs-review` automatically** on creation
3. **A maintainer MUST add `status:approved`** before any PR can be opened
4. **Questions go to Discussions**, not issues

## Workflow

```
1. Search existing issues for duplicates
2. Choose the correct template (Bug Report or Feature Request)
3. Fill in ALL required fields
4. Submit → issue gets status:needs-review automatically
5. Wait for maintainer to add status:approved
6. Only then open a PR linking this issue
```

## Decision Tree

```
Is it a bug?                     → Bug Report template
Is it a new feature/improvement? → Feature Request template
Is it a question?                → Discussions, NOT issues
Is it a duplicate?               → Link to existing, close
```

## Label System

| Template | Auto-applied labels |
|----------|-------------------|
| Bug Report | `bug`, `status:needs-review` |
| Feature Request | `enhancement`, `status:needs-review` |

Maintainers add: `status:approved`, `priority:high/medium/low`

## Commands

```bash
gh issue list --search "keyword"
gh issue create --template "bug_report.yml" --title "fix(scope): description"
gh issue create --template "feature_request.yml" --title "feat(scope): description"
gh issue edit <number> --add-label "status:approved"
```

## References

- [references/bug-report-template.md](references/bug-report-template.md) — required fields and CLI example
- [references/feature-request-template.md](references/feature-request-template.md) — required fields and CLI example
- [references/maintainer-workflow.md](references/maintainer-workflow.md) — approval workflow
