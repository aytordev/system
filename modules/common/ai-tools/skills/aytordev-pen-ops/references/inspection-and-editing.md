# Inspection, Authorization, Batching, and Verification

The session-by-session method. The tooling inside a Pen session changes between
versions and hosts, so this reference describes a capability-agnostic
procedure, never a fixed tool list or call syntax.

## Manual skill loading

Pen has no documented automatic discovery of this skill, so its SKILL.md must
be added manually. Keep the complete skill folder stable at
`$XDG_DATA_HOME/aytordev/skills/aytordev-pen-ops` (normally
`~/.local/share/aytordev/skills/aytordev-pen-ops`), or at your own catalog
source location. Pen's **Add SKILL.md file…** menu action accepts either a
single file or a containing folder; preserve the chosen location. After edits
to the skill files, re-add the same file in Pen to reload it. Removing a
custom entry in Pen (trash icon) does not delete the folder or its SKILL.md
from disk. Loading this skill never implicitly loads any sibling skill.
(Per https://docs.pen.dev/core-concepts/ai-agents.)

## Phase 0: Observe the session

Before choosing any operation:

1. **Enumerate the exposed tool schemas** available in this session (host
   product, extension, or CLI). Note which operations exist and the exact
   parameters they accept *as observed here*.
2. **Identify the target**: which document is open, whether it is the intended
   one, and any session state the user must confirm (unsaved changes, active
   page or frame, collaborative state).
3. If the session exposes no usable inspection surface, or the target cannot
   be confirmed, stop and report. Do not fall back to another client, CLI, or
   environment on your own initiative.

Treat every documented recipe — official docs, upstream skills, or a previous
session — as a hypothesis. If a documented tool is absent, renamed, or rejects
its documented arguments, that is a stop-and-report condition. Never infer an
API from a name, a memory, or an example; never replay a call recorded
elsewhere.

## Phase 1: Read-only inspection

With read-only operations only:

- Record the current selection and the identifiers of the nodes in scope.
- Record the current state of those nodes (properties, structure, styles) so
  any proposed change can be stated as a narrow diff against observed reality.
- Inspect library or shared components in scope by reading them, never by
  assuming their shape from names or prior projects.

Deliverable: a concise observed-state summary. If the user only asked for
review, this summary plus a proposal is the final output; no mutating call has
been made.

## Phase 2: Propose, then wait for authorization

State the intended change as a bounded plan: which identifiers change, which
properties, the expected verification after each step, and what will *not* be
touched. Wait for explicit authorization. A general "make it better" is not
authorization for a specific diff; confirm the scope.

## Phase 3: Authorized edits in bounded batches

- Prefer the narrowest operation that achieves the change: property-level
  updates over node replacement, replacement only with an explicit decision.
- Keep batches small. Each batch should be individually explainable and
  individually reversible-by-report (you can say precisely what it contained).
- Within one batch, order operations so a mid-batch failure leaves an
  interpretable state; avoid chains where step N silently depends on step N-1
  succeeding invisibly.
- Never rewrite an entire file, silently replace a component, or extend the
  scope beyond the confirmed diff. A discovered adjacent problem is reported
  and proposed separately, not fixed in passing.

## Phase 4: Verify each batch

- **Readback**: re-read the changed nodes and confirm the applied state matches
  the intended diff, including that surrounding properties were preserved.
- **Visual verification**: when the session offers screenshots or rendered
  previews, check the affected scope visually after each batch that changes
  rendered output.
- If the session offers neither readback nor visual confirmation for a change,
  say so explicitly: the result is unverified, and the user decides whether to
  accept it.

## Stopping conditions

Stop and report, with observed evidence, when any of these occurs:

- A required operation is missing from the exposed capabilities, or its
  observed schema does not match the documented one.
- A batch fails, or lands with uncertain partial state.
- Verification is unavailable and the change is not safely reviewable by the
  user on the canvas.
- Session behavior contradicts the proposal in a way that suggests a different
  document, version, or mode than assumed.

The report names: what was observed, what was authorized, what was applied,
what was verified, and what remains uncertain. Recovery is a fresh decision by
the user, not a blind retry.
