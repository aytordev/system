# OpenSpec File Convention (shared across all SDD skills)

This convention describes the **filesystem** layout for the `openspec` and
`hybrid` backends. Per-backend layouts:

- `openspec` / `hybrid`: the full tree below.
- `engram`: only `openspec/config.yaml` (the `artifact_store` declaration plus
  optional `project`/`rules` metadata); never `specs/`, `changes/`, or
  `archive/` — planning artifacts live in Engram
  (`_shared/persistence-contract.md`).
- `none`: nothing on disk.

## Directory Structure (openspec / hybrid)

```
openspec/
├── config.yaml              <- Project-specific SDD config
├── specs/                   <- Source of truth (main specs)
│   └── {domain}/
│       └── spec.md
└── changes/                 <- Active changes
    ├── archive/             <- Completed changes (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       <- Active change folder
        ├── exploration.md   <- (optional) from sdd-explore
        ├── proposal.md      <- from sdd-propose
        ├── specs/           <- from sdd-spec
        │   └── {domain}/
        │       └── spec.md  <- Delta spec
        ├── design.md        <- from sdd-design
        ├── tasks.md         <- from sdd-tasks (updated by sdd-apply)
        └── verify-report.md <- from sdd-verify
```

## Artifact File Paths (openspec / hybrid)

| Skill | Creates / Reads | Path |
|-------|----------------|------|
| sdd-init | Creates | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/` |
| sdd-explore | Creates (optional) | `openspec/changes/{change-name}/exploration.md` |
| sdd-propose | Creates | `openspec/changes/{change-name}/proposal.md` |
| sdd-spec | Creates | `openspec/changes/{change-name}/specs/{domain}/spec.md` |
| sdd-design | Creates | `openspec/changes/{change-name}/design.md` |
| sdd-tasks | Creates | `openspec/changes/{change-name}/tasks.md` |
| sdd-apply | Updates | `openspec/changes/{change-name}/tasks.md` (marks `[x]`) |
| sdd-verify | Creates | `openspec/changes/{change-name}/verify-report.md` |
| sdd-archive | Moves | `openspec/changes/{change-name}/` → `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| sdd-archive | Updates | `openspec/specs/{domain}/spec.md` (merges deltas into main specs) |

## Reading Artifacts (openspec / hybrid)

Each skill reads its dependencies from the filesystem:

```
Proposal:  openspec/changes/{change-name}/proposal.md
Specs:     openspec/changes/{change-name}/specs/  (all domain subdirectories)
Design:    openspec/changes/{change-name}/design.md
Tasks:     openspec/changes/{change-name}/tasks.md
Verify:    openspec/changes/{change-name}/verify-report.md
Config:    openspec/config.yaml
Main specs: openspec/specs/{domain}/spec.md
```

For `engram`, the same artifacts are read from Engram by topic key
(`_shared/engram-convention.md`); `openspec/config.yaml` is the only filesystem
file read there (the store declaration).

## Writing Rules (openspec / hybrid)

- ALWAYS create the change directory (`openspec/changes/{change-name}/`) before writing artifacts
- If a file already exists, READ it first and UPDATE it (don't overwrite blindly)
- If the change directory already exists with artifacts, the change is being CONTINUED
- Use the `openspec/config.yaml` `rules` section to apply project-specific constraints per phase

For `engram`, the only permitted filesystem write is the `openspec/config.yaml`
declaration itself (`_shared/persistence-contract.md`); `none` writes nothing.

## Config File Reference

```yaml
# openspec/config.yaml
schema: spec-driven

# Flat, same-line declaration of the resolved backend. The pinned engine reads
# this key; a nested mapping is NOT a declaration.
artifact_store: openspec

context: |
  Tech stack: {detected}
  Architecture: {detected}
  Testing: {detected}
  Style: {detected}

rules:
  proposal:
    - Include rollback plan for risky changes
  specs:
    - Use Given/When/Then for scenarios
    - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
  design:
    - Include sequence diagrams for complex flows
    - Document architecture decisions with rationale
  tasks:
    - Group by phase, use hierarchical numbering
    - Keep tasks completable in one session
  apply:
    - Follow existing code patterns
    tdd: false           # Set to true to enable RED-GREEN-REFACTOR
    test_command: ""     # e.g., "npm test", "pytest"
  verify:
    test_command: ""     # Override for verification
    build_command: ""    # Override for build check
    coverage_threshold: 0  # Set > 0 to enable coverage check
  archive:
    - Warn before merging destructive deltas
```

The canonical schema — the `engram | openspec | hybrid | none` enum,
substitution rules, and a minimal `engram` example — lives in
`sdd-init/references/config-format.md`.

## Archive Structure (openspec / hybrid)

When archiving, the change folder moves to:
```
openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Use today's date in ISO format. The archive is an AUDIT TRAIL — never delete or modify archived changes.
