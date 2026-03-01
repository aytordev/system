## Parse Exploration Request

**Impact: CRITICAL**

Parse what the user wants to explore and identify the scope and depth needed.

### What to Identify

1. **Type of exploration**:
   - New feature investigation
   - Bug fix analysis
   - Refactor planning
   - Domain/architecture exploration
   - Integration analysis

2. **Scope boundaries**:
   - Which parts of the codebase are relevant?
   - What depth is needed (surface-level vs deep dive)?
   - Are there specific constraints or concerns?

3. **Expected outcome**:
   - Quick comparison of approaches?
   - Deep architectural analysis?
   - Feasibility assessment?
   - Risk identification?

### Output

Produce a concise summary of the exploration parameters:

```
Exploration Type: {feature | bug | refactor | domain | integration}
Scope: {affected areas}
Depth: {surface | moderate | deep}
Focus: {what specifically to investigate}
```
