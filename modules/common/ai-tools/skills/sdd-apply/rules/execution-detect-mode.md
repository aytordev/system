## Detect Implementation Mode (TDD vs Standard)

**Impact: CRITICAL**

Read cached testing capabilities to determine the implementation mode and the
per-unit checks this unit must run.

### Read Testing Capabilities

Read from the change's **own** backend locator (never another store):

```
├── engram:  mem_search("sdd/{project}/testing-capabilities") → mem_get_observation(id)
├── openspec: openspec/config.yaml → testing section (requested/effective/roots)
├── hybrid:  Engram first, then openspec/config.yaml
├── none:    only the capabilities the orchestrator passed inline
└── If absent: re-discover project roots directly (package.json, flake.nix, etc.)
    — do NOT read another persistence store
```

The record separates `Strict TDD requested` from `Strict TDD effective`
(`enabled | disabled | blocked`) and lists per-root commands.

### Resolve Applicable Per-Unit Checks

A unit is scoped by its target path (a file or directory from the task). Resolve
the checks that actually cover it:

```
applicable = commands where
  ├── surface == runtime AND covers_workspace == true, or
  └── surface == runtime AND some covered target is a prefix of the unit path
```

Never substitute a sibling root's runner for the unit's own checks. Nix surfaces
(`nix-eval`, `nix-build`) are collected separately and are never reported as a
unit suite.

### Mode Resolution

```
effective: enabled
└── STRICT TDD MODE → load and follow modules/strict-tdd.md
    Run the applicable per-unit runtime checks during the cycle.

effective: blocked
└── Do NOT load any strict module and do NOT pretend a runner exists.
    Surface the recorded blocker to the orchestrator (missing prerequisite
    coverage for an explicit request). If implementation must still proceed,
    use the standard workflow with the blocker visible — do not downgrade the
    request or borrow another root's command.

effective: disabled
└── STANDARD MODE → use execution-standard-workflow.md (no TDD module loaded)
    Still run the applicable per-unit checks as focused verification.
```

**Key principle**: if Strict TDD is not effective, ZERO TDD instructions are
loaded. The `strict-tdd.md` module is never read, never processed, never
consumes tokens.

### Fallback Detection

If capabilities are not cached, discover project roots and associate commands
with their working directory and covered targets before resolving mode. There is
no single global `npm test`/`pytest` fallback: a command is used only for the
root it belongs to.

### Result

```
Mode: Strict TDD | Standard | Blocked
Requested: true | false | unset
Effective: enabled | disabled | blocked
Unit: {target path}
Applicable runtime checks: {working_dir} → {command}
Blocker: {reason or —}
```
