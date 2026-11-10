---
name: xstate
description: "Trigger: ordinary React code that is already a hand-rolled statechart — a submitting or isLoading useState, a then/catch chain that sets state in sequence, a double-submit guard, an error cleared just before a retry, a useEffect needing an ignore flag, a timer something must clear, or a gesture handler binding document listeners it must unbind — as well as wizards, checkout/auth/upload flows, async orchestration with retries or timeouts, boolean-flag state bugs, or any XState or state-machine code. Models front-end and workflow logic as XState v5 statecharts and actors: the two lifetime tests that decide ownership, event-first machine design, guards/actions/delays, invoke vs spawn, actor systems, persistence, @xstate/react integration, headless machine testing including model-based paths, and a Mermaid stateDiagram-v2 render regenerated into a repository file whenever a machine is designed or changed."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# XState

State machines and statecharts (XState v5) turn front-end flow logic from
scattered event handlers into one explicit, verifiable model. That trade is
unusually good in AI-assisted development: headless testability (events in,
snapshots out, with `xstate/graph` covering paths); impossible states are
unrepresentable (guarded transitions delete the `isLoading && isError` bug
class); one reviewable artifact for every state × event combination; and
humans get the diagram for free.

**Default stance**: model front-end *flow logic* — wizards, checkout, auth,
uploads, anything with modes, sequencing, cancellation, timeouts, retries —
as statecharts. Keep trivial state honest: data-shaped state with no modes
goes to `@xstate/store` or a plain discriminated union, never a ceremonial
machine.

**The failure mode this skill exists to catch is under-modeling, not
over-modeling.** Model training data is overwhelmingly ordinary React —
`useState` and `useEffect` for everything — so the realistic risk is quietly
hand-rolling a statechart. Read `rules/before-you-write-state.md` *before*
reaching for `useState`.

**Version guardrail**: XState **v5** only (`setup()`, `createActor`, actors).
Most tutorials, old blog posts, and model training data are v4 — if you see
`Machine()`, `interpret()`, `cond:`, `services:`, or typegen, you are looking
at v4; translate via the migration table in
`references/typescript-and-migration.md` before any of it ships.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Building or reviewing wizards, checkout/auth/upload flows, async
  orchestration with retries or timeouts, canvas and editor interactions, or
  anything sent to a server — the flow, not the server contract.
- Ordinary React code shows a hand-rolled statechart (the smell table in
  `rules/before-you-write-state.md`), whether or not the file imports xstate.
- Writing, testing, persisting, or reviewing any XState or state-machine code.

Do not use it for store-only state before reading `references/when-to-model.md`
first — the ladder there may honestly answer "not a machine".

## Hard Rules

1. **Events first, then modes.** List what the world can do; states fall out
   of "when does the same event mean something different?" Never design states
   off the UI tree.
2. **Finite state = mode, context = data.** If a value gates which events are
   legal, it is a state; if it is unbounded, it is context. A context flag
   checked by guards on every transition is a state in hiding — promote it.
   Classify by what *changes* a value, never by what it renders.
3. **Context is JSON data.** No class instances, promises, or DOM nodes —
   persistence, inspection, and the editor all depend on it. Spawned actor
   refs are the sanctioned exception.
4. **Effects are actors, not actions.** Anything with a result, a lifetime, or
   a failure mode is invoked or spawned; actions are fire-and-forget. `invoke`
   when the lifetime belongs to a state, `spawn` for dynamic counts — every
   spawn has an owner that stops it.
5. **Name everything in `setup()`.** Named actions, guards, actors, and delays
   make string references type-checked and `machine.provide()` the universal
   test seam.
6. **All v5 transitions are internal by default.** Targetless self-transitions
   for "update and stay"; `reenter: true` only when you truly want exit/entry
   re-run and invocations restarted.
7. **Machines complete like functions.** Flows that end declare final states
   and `output`; parents consume `onDone`/`onError`. Error paths are modeled
   states, not console noise.
8. **One machine per flow — and one owner per lifecycle.** Cross-flow
   coordination is an actor system, never a god machine. A lifecycle already
   owned by an actor does not get a second copy in a component's `useState`.
9. **Test the machine headlessly, the component through the DOM.** The
   snapshot is the machine module's contract; from a component test it is
   private wiring. Never assert machine state from a component test.
10. **Validate at the trust boundary.** Events from outside the process
    (sockets, storage, URLs) are schema-parsed before `send`; persisted
    snapshots are restored only after validation, with a versioning story.
11. **Render the diagram whenever a machine is designed or changed.** A
    Mermaid `stateDiagram-v2` file in the repository, regenerated from the
    final definition — never a chart pasted into the reply
    (`rules/render-the-diagram.md`).

## Execution Steps

1. **CHECK THE REPOSITORY FIRST** — architecture or boundary tests, import
   rules, existing machine directories, or layout guidance outrank this
   skill's default colocation advice. Establish the allowed home for machines
   before writing, not after CI rejects it.
2. **CLASSIFY** — run the two lifetime tests over every piece of state
   (`rules/before-you-write-state.md`); report the verdict in one line and
   ask on genuine ties. Check for an existing owner: if an actor already owns
   the lifecycle, the state goes in that actor — the ladder does not reopen.
3. **PICK THE RUNG** — component-local value, `@xstate/store`, discriminated
   union, machine, or actor system (`references/when-to-model.md`).
4. **DESIGN EVENTS-FIRST** — then wire transitions, hierarchy, and effects
   (`references/machine-design.md`); compose with invoke vs spawn and the
   `systemId` receptionist (`references/actors-and-systems.md`); integrate
   with `createActorContext` and StrictMode semantics (`references/react-integration.md`).
5. **TEST HEADLESSLY** — `provide()` as the seam, `SimulatedClock`, pure
   `transition`, model-based paths, persistence round-trips (`references/testing.md`).
6. **TYPE IT** — `setup()` typing, `assertEvent`, v4→v5 translation
   (`references/typescript-and-migration.md`).
7. **RENDER THE DIAGRAM** — regenerate from the final definition into a
   repository file and name its path in the reply.

## Output Contract

Report: the ownership verdict per piece of state (what changes it — machine,
store, or React — with the lifetime test that decided it), where the machine
lives and why the repository rule allows it, the machine file path, the
diagram file path with the validation result stated honestly, and the
headless test coverage (guards, ignored events, error paths, timeouts). A
changed machine with a stale committed diagram, or a claimed render that was
not checked, is an incomplete hand-off.

## References

- `rules/before-you-write-state.md` — hand-rolled statechart smells, the two lifetime tests, existing owners, sweeping.
- `rules/render-the-diagram.md` — the Mermaid render contract.
- `references/when-to-model.md` — machine vs store vs union, the ladder, where machines live.
- `references/machine-design.md` — event-first workflow, naming, transitions, actions, guards, delays, anti-patterns.
- `references/actors-and-systems.md` — actor logic, invoke vs spawn, systems, persistence, inspection.
- `references/react-integration.md` — hooks, `createActorContext`, StrictMode, `@xstate/store`.
- `references/testing.md` — layered testing, seams, `SimulatedClock`, model-based testing.
- `references/typescript-and-migration.md` — `setup()` typing and the v4→v5 table.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. Where a testing, component-testing,
typescript-strict, functional, event-sourcing, structure-codebase, or
diagrams skill is not installed, apply the rule directly: behaviour-driven
tests through the public API with no module mocks, schema-parsed events at
the door, immutable context, no domain event log in machine context,
repository layer rules first, and committed diagrams validated and
parser-safe.
