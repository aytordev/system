## Return Structured Analysis

**Impact: CRITICAL**

Return structured analysis with clearly defined sections.

### Analysis Structure

```markdown
## Current State
{Description of existing implementation and context}

## Affected Areas
| File/Module | Current Role | Impact if Changed |
|-------------|--------------|-------------------|
| {path} | {description} | {high/medium/low} |

## Approaches

### Option 1: {Name}
**Pros:**
- {benefit}

**Cons:**
- {drawback}

**Effort:** {low/medium/high}

### Option 2: {Name}
...

## Recommendation
{Which approach and why, or "needs clarification on X"}

## Risks
| Risk | Likelihood | Impact |
|------|-----------|--------|
| {risk} | {high/medium/low} | {high/medium/low} |

## Ready for Proposal
{yes/no + what's needed next}
```

### Persistence Logic

**engram mode:**
- Save analysis to Engram with topic `explore/{change-name}` or `explore/{topic-slug}`

**openspec mode with named change:**
- Write to `openspec/changes/{change-name}/exploration.md`

**none mode:**
- Return inline only

### Rules

- Always use concrete file paths (not vague "the module")
- Be honest about uncertainty — don't fake confidence
- If not ready for proposal, say what specific info is needed
- Keep analysis concise but complete
