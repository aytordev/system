# SDD Phase Common — Artifact Retrieval Protocol

This file documents **Section B** of the executor protocol: how each SDD phase retrieves prior artifacts before executing its own work.

For skill loading, see `skill-loading.md` (Section A).
For persistence rules, see `persistence-contract.md` (Section C).
For return envelope format, see `return-envelope.md` (Section D).

---

## Section B — Artifact Retrieval

Before executing your phase, retrieve prior artifacts in this order:

### engram mode
1. `mem_search(query: "sdd/{change-name}/{artifact-type}", project: "{project}")`
2. `mem_get_observation(id)` on the best match
3. If no result: check filesystem fallback path (openspec convention)

### openspec mode
1. Read files from `openspec/changes/{change-name}/` per `openspec-convention.md`
2. If file missing: report as blocker, do not fabricate content

### hybrid mode
1. Try Engram first (steps as in engram mode)
2. If Engram returns no results, fall back to filesystem (steps as in openspec mode)

### none mode
1. Use only what the orchestrator passed in the launch prompt context
2. Do not attempt to read any files or search Engram

### Dependency map (what to retrieve per phase)

| Phase | Needs |
|-------|-------|
| sdd-spec | proposal |
| sdd-design | proposal |
| sdd-tasks | proposal + spec + design |
| sdd-apply | spec + design + tasks |
| sdd-verify | all prior artifacts |
| sdd-archive | all prior artifacts |
