# Maintainer Approval Workflow

```
1. New issue arrives with status:needs-review
2. Review — is it valid, clear, and in scope?
3. YES → add status:approved label
4. NO → comment with reason, close if needed
5. Contributor can now open a PR linking this issue
```

## Priority Labels

| Label | When to apply |
|-------|--------------|
| `status:approved` | Issue accepted — PRs can now be opened |
| `priority:high` | Critical bug or urgent feature |
| `priority:medium` | Important but not blocking |
| `priority:low` | Nice to have |

## Commands

```bash
gh issue edit <number> --add-label "status:approved"
gh issue edit <number> --add-label "priority:high"
```
