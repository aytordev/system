## Sync Delta Specs to Main Specs (deterministic, via the engine)

**Impact: CRITICAL**

Step 1: promote the change's domain deltas into the canonical specs
(`openspec/specs/{domain}/spec.md`). This is a **deterministic compose through
the engine**, never a hand merge and never model-regenerated prose.

`openspec` and `hybrid` only. `engram` has no canonical file tree, and `none`
writes nothing.

### Locate

- Delta: `openspec/changes/{change-name}/specs/{domain}/spec.md`
- Canonical: `openspec/specs/{domain}/spec.md`

Requirement identity is the exact heading `### Requirement: {name}`. Names must
be unique within a domain; IDs/names are matched literally.

### Existing canonical spec → compose with the engine

For each domain, compose to a **staged output** (do not write the canonical path
yet):

```sh
aytordev-sdd compose \
  --canonical openspec/specs/{domain}/spec.md \
  --delta     openspec/changes/{change-name}/specs/{domain}/spec.md \
  --output    openspec/changes/{change-name}/.archive-staging/{domain}.spec.md
```

The engine guarantees:

- **Unrelated requirements survive**: canonical requirements not named by the
  delta are preserved byte-for-byte.
- **Refusal before writing**: unknown/ambiguous `MODIFIED`/`REMOVED` targets,
  duplicate `ADDED` names, a malformed section, or a malformed `RENAMED` refuse
  with a typed error naming the section and requirement. On refusal the output
  is left untouched.
- `ADDED` appends; `MODIFIED` replaces the named requirement and its scenarios;
  `REMOVED` deletes it; `RENAMED` renames `Old → New`.

### Rename semantics

A rename is admitted only as:

```markdown
## RENAMED Requirements

### Requirement: Old Name → New Name
(Reason: why the rename is safe)
```

A missing `→` or a missing `(Reason: ...)` note is refused. A rename whose
target already exists is ambiguous and must be resolved by the author, not
guessed by the archive phase.

### New domain (no canonical spec)

If `openspec/specs/{domain}/spec.md` does not exist, the change spec must be a
**full spec** (no `## ADDED|MODIFIED|REMOVED|RENAMED Requirements` section).
Install it verbatim. If it still carries delta sections, **refuse**: the
archive cannot tell whether the author intended a full spec or a delta with a
missing canonical, and stripping markers silently is forbidden.

### Stage all, then publish

1. Compose every domain to `.archive-staging/`. If **any** domain refuses, stop:
   discard staging, leave all canonical specs byte-identical, and preserve the
   prior verify report and change artifacts.
2. Confirm the archive destination is collision-free (Step 2 pre-flight).
3. Move staged files into place (`openspec/specs/{domain}/spec.md`).
4. Remove `.archive-staging/` only after the archive move succeeds.

If a mechanical move fails after promotion (rare), the promoted canonical specs
are correct and the change source is restored by Step 2's recovery; re-run the
archive move. Never re-run the compose from stale input.

### Output

Report per domain: action(s) applied (added/modified/removed/renamed counts), or
`created from full spec`, or the refusal reason.

### Engram-only closure

`engram`: do not create `openspec/`; closure records references to the change's
observations and the final evidence, not filesystem copies. `hybrid`: compose
the filesystem canonical specs as above and persist the archive report reference
to Engram, using the partial-write/retry rules in `persistence-contract.md`.
