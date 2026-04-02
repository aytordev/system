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
  test_runner: {detected test command or null}
  build_command: {detected build command or null}
  strict_tdd: {true | false | unavailable}
  artifact_store_mode: {engram | hybrid}
  skill_registry: .atl/skill-registry.md
  initialized: {ISO 8601 date}

  ## Testing Capabilities
  {paste the full testing capabilities table from Step 2}

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
- In `hybrid` mode: report `status: partial`, log the failure, continue with filesystem artifacts (openspec bootstrap already completed in Step 4)

### Recovery

Downstream phases retrieve this context with:
```
mem_search(query: "sdd-init/{project-name}", project: "{project-name}")
```

This eliminates the need to re-scan the project on every phase invocation.
