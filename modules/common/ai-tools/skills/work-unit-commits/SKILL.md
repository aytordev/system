---
name: work-unit-commits
description: "Plan commits as reviewable work units. Trigger: implementation, commit splitting, chained PRs, or keeping tests and docs with code."
---

## When to Use

Load this skill when deciding what belongs in each commit or PR:

- Splitting a feature into reviewable work
- Preparing commits before opening a PR
- Turning a large change into chained or stacked PRs
- Applying SDD tasks without exceeding 400 changed lines

## Quick Reference

- `constraints-rules` — Critical rules and Work Unit Checklist
- `execution-split-patterns` — Split examples and PR relationship
- `execution-sdd-integration` — SDD workload forecast and delivery strategy

## Rules

- MUST commit by work unit — one deliverable behavior, fix, migration, or docs unit
- MUST NOT commit by file type (models, then services, then tests)
- Keep tests with the behavior they verify
- Keep docs with the user-visible change they explain
- Each commit MUST be rollback-safe without unrelated work

See `rules/constraints-rules.md` for complete rules and checklist.

## Commands

```bash
git diff --stat
git diff --cached --stat
git log --oneline -5
```
