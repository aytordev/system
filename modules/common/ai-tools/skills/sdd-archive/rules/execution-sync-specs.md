## Sync Delta Specs to Main Specs

**Impact: CRITICAL**

Step 1: Merge delta specs from the change into the main spec files. Delta specs describe changes to requirements; main specs are the source of truth.

### For Each Domain's Delta Spec

Locate all delta spec files in the change:

- `openspec/changes/{change-name}/specs/{domain}/delta.md`

For each delta spec, process as follows:

### If Main Spec Exists

Main spec path: `openspec/specs/{domain}/spec.md`

If the main spec exists:

1. **Read the delta spec** and identify all requirement entries with their actions:
   - **ADDED** — New requirement to append
   - **MODIFIED** — Existing requirement to replace
   - **REMOVED** — Existing requirement to delete

2. **Read the main spec** to get current state

3. **Apply changes**:
   - **ADDED**: Append new requirements to the end of the main spec
   - **MODIFIED**: Find matching requirement by name/ID and replace its content
   - **REMOVED**: Find matching requirement by name/ID and delete it
   - **PRESERVE**: All requirements not mentioned in the delta remain unchanged

4. **Match requirements by**:
   - Requirement ID (e.g., `REQ-01`)
   - Requirement name (e.g., `## User Authentication`)
   - Heading level and text pattern

5. **Write updated main spec** back to `openspec/specs/{domain}/spec.md`

### If Main Spec Does NOT Exist

If `openspec/specs/{domain}/spec.md` does NOT exist:

1. **Create the directory** `openspec/specs/{domain}/` if needed
2. **Copy the delta spec content** as the new full spec
3. **Strip the ADDED/MODIFIED/REMOVED markers** (delta format becomes full spec)
4. **Write** to `openspec/specs/{domain}/spec.md`

### Critical Rule

**Be careful not to lose existing requirements that aren't part of this change.** Only modify/remove requirements explicitly mentioned in the delta.

### Output

Return a summary of changes:

```
Specs Synced:
- {domain}: {added_count} added, {modified_count} modified, {removed_count} removed
- {domain}: created new spec from delta
```
