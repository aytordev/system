## Read Existing Context and Specs

**Impact: CRITICAL**

Read existing specs from the artifact store if available. Load exploration analysis if exists. Understand current state of the project relevant to this change.

### Context Retrieval by Mode

**engram mode:**
1. Use `mem_search` for topic `explore/{change-name}` to retrieve exploration analysis
2. Use `mem_search` for topic `spec/` to retrieve existing specifications
3. Use `mem_search` for topic `project-context` to get project setup

**openspec mode:**
1. Read `openspec/config.yaml` for project context and rules
2. Read `openspec/specs/` directory for existing specifications
3. Read `openspec/changes/{change-name}/exploration.md` if exists
4. Check for existing `openspec/changes/{change-name}/proposal.md`

**none mode:**
- Use only context passed in the prompt
- No file reading or memory retrieval

### What to Extract

From exploration analysis (if exists):
- Current state summary
- Affected areas and files
- Recommended approach
- Identified risks

From project context:
- Tech stack and conventions
- Test patterns
- Build and deployment approach

From existing specs:
- Related specifications that might be affected
- Naming conventions
- Pattern consistency

### Output

Produce an internal context summary:

```
Change: {change-name}
Exploration: {found | not found}
Existing proposal: {found | not found}
Related specs: {list or "none"}
Project context: {stack, test patterns, conventions}
```
