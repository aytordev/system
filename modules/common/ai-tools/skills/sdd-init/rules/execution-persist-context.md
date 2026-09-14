## Persist Context to Engram (Step 7)

**Impact: CRITICAL**

After the skill registry is built (Step 6), save the full project context snapshot to Engram. This enables cross-session recovery without re-scanning the project.

**Applies to modes**: `engram`, `hybrid`
**Skip for modes**: `openspec`, `none`

---

### What to Persist

Call `mem_save` with the following structure:

```
mem_save(
  title: "sdd-init/{project-name}",
  topic_key: "sdd-init/{project-name}",
  type: "architecture",
  project: "{project-name}",
  content: """
  project: {project-name}
  path: {absolute project path}
  stack: {detected stack summary}
  testing:
    requested: {true | false | unset}
    effective: {enabled | disabled | blocked}
    blocker: {reason or null}
  artifact_store_mode: {engram | hybrid}
  skill_registry: engram:skill-registry
  initialized: {ISO 8601 date}

  ## Testing Capabilities
  {paste the full testing capabilities record from Step 2, including project
   roots, per-root commands, covered targets, and surfaces}

  ## Conventions
  {list of convention files detected}
  """
)
```

### Testing Capabilities Key

Also persist the testing capabilities separately for downstream consumption by `sdd-apply` and `sdd-verify`:

```
mem_save(
  title: "sdd/{project-name}/testing-capabilities",
  topic_key: "sdd/{project-name}/testing-capabilities",
  type: "architecture",
  project: "{project-name}",
  content: {testing capabilities table from Step 2}
)
```

### Failure Handling

If the `mem_save` call fails:
- In `engram` mode: report `status: blocked` — Engram is the only persistence backend
- In `hybrid` mode: report `status: partial`, name the failed store, keep the
  filesystem artifacts (the bootstrap completed in Step 4), and retry the missing
  Engram write with upsert semantics on the next launch. Never report success while
  the two stores disagree (`persistence-contract.md`).

### Recovery

Downstream phases retrieve this context with:
```
mem_search(query: "sdd-init/{project-name}", project: "{project-name}")
```

This eliminates the need to re-scan the project on every phase invocation.
