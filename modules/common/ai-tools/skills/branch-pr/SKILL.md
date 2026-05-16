---
name: branch-pr
description: "Create Gentle AI pull requests with issue-first checks. Trigger: creating, opening, or preparing PRs for review."
---

## When to Use

Use this skill when:
- Creating a pull request for any change
- Preparing a branch for submission
- Helping a contributor open a PR

## Critical Rules

1. **Every PR MUST link an approved issue** — no exceptions
2. **Every PR MUST have exactly one `type:*` label**
3. **Automated checks must pass** before merge is possible
4. **Blank PRs without issue linkage will be blocked** by GitHub Actions

## Workflow

```
1. Verify issue has `status:approved` label
2. Create branch following type/description convention
3. Implement changes with conventional commits
4. Run shellcheck on modified scripts
5. Open PR using the template, link the issue, add one type:* label
6. Wait for all automated checks to pass
```

## Automated Checks (all must pass)

| Check | Job name | What it verifies |
|-------|----------|-----------------|
| PR Validation | `Check Issue Reference` | Body contains `Closes/Fixes/Resolves #N` |
| PR Validation | `Check Issue Has status:approved` | Linked issue has `status:approved` |
| PR Validation | `Check PR Has type:* Label` | PR has exactly one `type:*` label |
| CI | `Shellcheck` | Shell scripts pass `shellcheck` |

## Commands

```bash
git checkout -b feat/my-feature main
shellcheck scripts/*.sh
gh pr create --title "feat(scope): description" --body "Closes #N"
gh pr edit <pr-number> --add-label "type:feature"
```

## References

- [references/branch-naming.md](references/branch-naming.md) — branch naming regex and type table
- [references/pr-body-format.md](references/pr-body-format.md) — PR body sections and contributor checklist
- [references/conventional-commits.md](references/conventional-commits.md) — commit format, type-to-label mapping, examples
