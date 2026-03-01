## Read Existing Specifications

**Impact: CRITICAL**

If `openspec/specs/{domain}/spec.md` exists, read it. Delta specs describe CHANGES to existing behavior. If no existing spec, you'll write a FULL spec instead.

### Why This Matters

Delta specs show what CHANGED — they make reviews easy by highlighting:
- What's being ADDED (new requirements)
- What's being MODIFIED (changed requirements)
- What's being REMOVED (deprecated requirements)

Full specs are only written when there's no existing spec for that domain.

### Check for Each Domain

For each domain identified:

1. Check if `openspec/specs/{domain}/spec.md` exists
2. If YES → read it, prepare to write a DELTA spec
3. If NO → prepare to write a FULL spec

### Output

```
Domain: auth
  Existing spec: openspec/specs/auth/spec.md (found)
  Type: DELTA

Domain: notifications
  Existing spec: openspec/specs/notifications/spec.md (not found)
  Type: FULL
```
