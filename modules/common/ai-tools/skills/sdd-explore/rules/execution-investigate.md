## Read and Search Codebase

**Impact: CRITICAL**

Read entry points and key files, search for related functionality, check existing tests, look for patterns, identify dependencies and coupling.

### Investigation Steps

1. **Read entry points**:
   - Main files related to the exploration topic
   - Configuration files that might be affected
   - Existing implementations of similar features

2. **Search for patterns**:
   - Use grep/search to find related functionality
   - Identify naming conventions
   - Find existing tests that exercise similar areas
   - Look for error handling patterns

3. **Identify dependencies**:
   - What modules/packages are involved?
   - What external dependencies exist?
   - Where is coupling tight vs loose?
   - What interfaces exist?

4. **Check test coverage**:
   - What tests exist in this area?
   - What test patterns are used?
   - Where are gaps in coverage?

### Rules

- **ALWAYS read REAL code** — never guess or assume implementation details
- Read at least 3-5 relevant files before drawing conclusions
- Note any surprising or non-obvious behaviors
- Track file paths for later reference in analysis
