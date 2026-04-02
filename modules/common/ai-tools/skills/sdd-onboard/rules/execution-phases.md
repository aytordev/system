## Guided Phase Execution

**Impact: CRITICAL**

Execute all 8 SDD phases in order. Before each phase, narrate what it is and why it matters (1-3 sentences max — teach, don't lecture).

### Phase 1: Explore

**Narration**:
```
"Step 1: Explore — Before committing to any change, we investigate.
 I'll look at the relevant code to understand what exists and what needs to change."
```

Behave inline as sdd-explore: read the relevant code, understand the current state, identify what needs to change. Explain findings in plain language. End with a 2-3 sentence summary of what was found.

### Phase 2: Propose

**Narration**:
```
"Step 2: Propose — We write down WHAT we're building and WHY.
 This becomes the contract for everything that follows."
```

Create the change folder and write `proposal.md` following sdd-propose format (see `~/.claude/skills/sdd-propose/`). After writing it:

```
"Here's the proposal. Notice the Capabilities section — it tells
 the next phases exactly what to specify."
```

**PAUSE**: Show the proposal to the user. Ask: "Does this look right? Any adjustments before I continue?" Wait for confirmation before proceeding past this point.

### Phase 3: Specs (parallel with Phase 4)

**Narration**:
```
"Step 3: Specs — We define WHAT the system should do, in testable terms.
 No implementation details — just observable behavior with Given/When/Then scenarios."
```

Write delta specs following sdd-spec format. After writing:
```
"Each scenario is a potential test case — the verify phase will check against these."
```

### Phase 4: Design (parallel with Phase 3)

**Narration**:
```
"Step 4: Design — We decide HOW to build it. Architecture decisions with rationale."
```

Write `design.md` following sdd-design format. Highlight the key decision:
```
"Notice the Decisions section — we document WHY we chose this approach.
 Future collaborators will thank you."
```

### Phase 5: Tasks

**Narration**:
```
"Step 5: Tasks — We break the work into concrete, checkable steps."
```

Write `tasks.md` following sdd-tasks format. Explain the structure:
```
"Each task is specific enough that you know when it's done.
 'Implement feature' is not a task. 'Create file X with function Y' is."
```

### Phase 6: Apply

**Narration**:
```
"Step 6: Apply — Now we write the actual code.
 The tasks guide us, the specs tell us what 'done' means."
```

Implement tasks following sdd-apply behavior. Narrate each task as it completes:
```
"Implementing task {N}: {description}
 ✓ Done — {brief note}"
```

### Phase 7: Verify

**Narration**:
```
"Step 7: Verify — We check that what we built matches what we specified.
 Every spec scenario gets a verdict."
```

Run sdd-verify behavior. Show the compliance matrix:
```
"COMPLIANT means a test passed proving the behavior.
 UNTESTED means no test covers that scenario — a gap to fill."
```

### Phase 8: Archive

**Narration**:
```
"Step 8: Archive — We merge the delta specs into the main specs and close the change.
 The specs now reflect the new behavior. The change becomes the audit trail."
```

Run sdd-archive behavior. Show the result:
```
"Done! The change is archived and the specs are updated."
```

### Phase 9: Summary

Close with a recap:

```markdown
## Onboarding Complete!

**Change**: {change-name}
**Artifacts created**:
- proposal.md — the WHY
- specs/{domain}/spec.md — the WHAT
- design.md — the HOW
- tasks.md — the STEPS

**The SDD cycle in one line**:
explore → propose → spec → design → tasks → apply → verify → archive

**When to use SDD**: Any change where you want to agree on WHAT before writing code.
Quick patches? Just code. Features, APIs, architecture decisions? SDD first.

**Next**: Try `/sdd-new <change-name>` for your next real feature.
```
