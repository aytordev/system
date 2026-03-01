## Write Structured Proposal

**Impact: CRITICAL**

Write `proposal.md` with all required sections using the template from `references/proposal-template.md`.

### Required Sections

1. **Intent** — What this change does and why it matters (2-3 sentences)

2. **Scope** — Two subsections:
   - In Scope: What IS included in this change
   - Out of Scope: What is explicitly NOT included

3. **Approach** — High-level description of how the change will be implemented

4. **Affected Areas** — Table format:
   - Column 1: File/module (use concrete paths)
   - Column 2: Impact (high/medium/low)
   - Column 3: Description of what changes

5. **Risks** — Table format:
   - Column 1: Risk description
   - Column 2: Likelihood (high/medium/low)
   - Column 3: Mitigation strategy

6. **Rollback Plan** — How to revert this change if needed

7. **Dependencies** — External dependencies or "None"

8. **Success Criteria** — Checklist of measurable criteria

### Writing Rules

- Use concrete file paths (not "the authentication module")
- Keep Intent concise — this is executive summary level
- Rollback plan MUST be actionable (not "revert the commit")
- Success criteria MUST be checkboxes with measurable outcomes
- Apply `rules.proposal` from `openspec/config.yaml` if available

### Persistence Logic

**openspec mode:**
- Write to `openspec/changes/{change-name}/proposal.md`
- Create directory if it doesn't exist

**engram mode:**
- Save as Engram artifact with topic `proposal/{change-name}`

**none mode:**
- Return inline only (no file writing)

### Existing Proposal

If `proposal.md` already exists:
1. READ the existing proposal first
2. UPDATE it (don't replace from scratch)
3. Preserve sections that are still accurate
4. Note what changed in your summary
