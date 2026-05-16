# SDD Integration

When `sdd-tasks` produces a Review Workload Forecast:

| Risk level | Action |
|------------|--------|
| Low | Keep work-unit commits inside one PR. |
| Medium | Commit by work unit and monitor changed lines before PR creation. |
| High | Follow SDD `delivery_strategy`: `ask-on-risk`, `auto-chain`, `single-pr` (requires `size:exception`), or `exception-ok`. |

## Work Unit Properties (per SDD task)

Each SDD work unit must map cleanly to a commit or PR with:

- clear start state
- clear finished state
- verification in the same unit
- rollback that does not remove unrelated work
