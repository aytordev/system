## Return Design Summary

**Impact: CRITICAL**

Return a summary with approach, key decisions, files affected, testing strategy, and next recommended step.

### Template

```markdown
## Design Complete

**Approach**: Add OAuth2 authentication via Passport.js, refactor session management for dual auth modes

**Key Decisions**: 3
- Use Passport.js for OAuth2 (matches existing auth pattern)
- Store encrypted refresh tokens (enables persistent sessions)
- Feature flag rollout (reduces deployment risk)

**Files Affected**:
- Create: 2 files
- Modify: 5 files
- Delete: 0 files

**Testing Strategy**:
- Unit: OAuthService methods (mock strategies and HTTP)
- Integration: OAuth2 flow with stubbed provider
- E2E: Full flow with Playwright

**Open Questions**: 4 items need resolution
- OAuth2 scopes for Google
- Account linking strategy
- Token refresh cadence
- Offline access requirement

### Artifacts

- `openspec/changes/{change-name}/design.md`

### Next Recommended

`sdd-tasks` — Break design into implementation tasks

### Risks

- **BLOCKING**: Open questions about OAuth2 scopes must be resolved before implementation
- **MEDIUM**: Account linking not designed (may need follow-up change)
```

### Guidelines

- Summarize approach in one line
- Count key decisions
- Count files by action (create/modify/delete)
- Highlight testing layers
- Count open questions
- Flag BLOCKING issues if open questions prevent implementation
- Recommend `sdd-tasks` as next step
