---
title: Catch the Hand-Rolled Statechart Before Reaching for useState
impact: CRITICAL
impactDescription: Under-modeling, not over-modeling, is the common failure
tags: xstate, classification, ownership
---

## Catch the Hand-Rolled Statechart Before Reaching for useState

**Impact: CRITICAL**

This rule fires on ordinary React code. You do not have to be in a machine
file — or have decided to use XState at all — for it to apply.

### Step 0: Find out who owns machines in this repository

Before creating a machine, moving state into one, or deciding where a new
actor lives, check what this repository already says: architecture or boundary
tests, import-boundary rules such as `eslint-plugin-boundaries` or
`dependency-cruiser`, architecture decision records, the directory already
holding existing machines, `CLAUDE.md`, or the repository's layout guidance.
Repository convention outranks this skill's default colocation advice
(colocate with the feature it drives, absent a repository rule).

A correct machine in a forbidden layer still fails the build. Establish the
allowed home *before* writing, not after CI rejects it.

### If you just wrote one of these, stop — you are already at step 1

Each of these is a hand-rolled statechart: the states exist, they are just
implicit, scattered, and unverified. Treat any single hit as the trigger to
work through this skill.

| What you wrote | The statechart hiding in it |
|----------------|------------------------------|
| `useState` for `submitting`, `isLoading`, `saving`, `pending`, `inFlight` | A `submitting` state, with `SUBMIT` illegal while it holds |
| `.then(...)/.catch(...)` or `await` followed by two or three `setX` calls in sequence | Entry actions of the success and failure states |
| A double-submit guard — an early return, a disabled flag checked before dispatching | A transition the model would simply not define |
| Clearing an error immediately before retrying | A `retrying` transition that re-enters the invoking state |
| `useEffect` watching a flag to trigger the next step | A transition trying to escape from an effect |
| Two booleans that can contradict (`isLoading && isError`) | n booleans = 2ⁿ combinations, of which a handful are legal |
| A `status` string that handlers keep re-deriving from other fields | The finite state, denormalized |
| A ref or timer coordinating cancellation, debounce, or staleness by hand | Actor lifetime, `after`, and cancellation semantics |
| A `useEffect` that starts async work and needs an ignore flag in its cleanup | Actor lifetime — the machine cancels instead of ignoring |
| A `setTimeout`/`setInterval` for retry, debounce, or polling that something must clear | `after`, with cancellation tied to the state that owns it |
| A `pointerdown`, `dragstart`, or gesture handler binding document listeners it must unbind | An interaction with an interruptible middle — an invoked actor owns the listeners and disposes them |
| Handling for a response arriving after cancel, replacement, or unmount | Stale-result fencing by identity, which the machine makes structural |

Any one of them is the entry point, **however small the request**, and whether
or not the file imports `xstate`.

### The two lifetime tests

Classify state by what these two tests show, never by what the value renders.
Run both over every `useState` you write or keep.

**Test 1 — did an external answer change it?** A network response, a timer,
another actor, or the platform makes state temporal whatever it looks like on
screen. **A disabled button or a spinner is the *presentation of* temporal
state, not presentation state.** Anything sent to a BFF or server, and
everything the answer implies, is caught here.

**Test 2 — does the interaction have an interruptible middle?** Direct user
input still creates a lifecycle when there is a phase between start and end
that something can interrupt, cancel, or must dispose. A drag holds pointer
capture, cancels on Escape, and must release on unmount. A panel that animates
shut has a closing phase. A gesture that binds document listeners must unbind
them.

**State belongs to React only when both tests come back empty** — one event
sets the value completely, leaving no phase to interrupt and nothing to
dispose. A toolbar toggle, a controlled input's current text, a hover, a focus
flag, a plain open/closed disclosure: one event, no middle, nothing to clean
up.

| Example | Test 1 | Test 2 | Owner |
|---------|--------|--------|-------|
| `submitting` around a command | Yes — the response clears it | — | Machine |
| Spinner visibility | Yes — presentation *of* temporal state | — | Machine |
| Canvas node drag | No | Yes — capture, Escape, unmount | Machine |
| Panel with a closing animation | No | Yes — a closing phase | Machine |
| Toolbar open/closed | No | No | React |
| Controlled input text | No | No | React |

Test 2 is the one most often missed, because a drag is user-driven and test 1
alone would wrongly file it in React.

### State the verdict, and ask on genuine ties

Having run both tests, act on the answer and report the call in one line so
the user can overrule it: *"`isSubmitting` is set by the request, so it moved
into the machine as `submitting`."*

Where it is genuinely close — a real but small lifecycle, or a machine the
repository's layer rules would push far from the component that uses it —
**put the choice to the user before building**: name the state, name the phase
that makes it a lifecycle, and ask whether it belongs in the machine. A tie is
worth one question; it is not worth a silent guess in either direction.

### Ask whether an existing actor already owns this flow

The complexity ladder in `references/when-to-model.md` answers a *greenfield*
question. It is the wrong tool when a machine for this flow already exists.

**If an actor already owns the lifecycle this state belongs to, the state goes
in that actor — the ladder does not reopen the decision.** A submission flag
next to a machine that already sends the command, handles its errors, and owns
the retry policy is not a fresh rung-1 decision; it is one state that escaped
its machine. Splitting a single lifecycle across a machine and a component's
`useState` gives you two sources of truth that can disagree, which is the
exact bug class the machine was adopted to delete.

Before adding flow state to a component, search the feature for an existing
machine, actor, or `createActorContext` provider and check whether the
lifecycle you are about to hand-roll is one it already models.

When a new machine *is* justified, the boundary is **a distinct unit of
functionality with its own inputs and outputs** — typically its own
connection, resource, or authority. One machine per SSE stream, one for canvas
interaction, one for node-adding rules, one for media-connection management:
each owns a different external edge, so each fails and reconnects
independently.

The question to answer explicitly, and out loud, is not "does this deserve a
machine?" but **"why does this not belong to the machine that already owns
this edge?"** A small new machine sitting beside a larger one that shares its
inputs and outputs is usually a state that should have been added to the
larger one. Where the answer is genuinely close, ask rather than guess.

### Sweeping for the same violation elsewhere

Once one hand-rolled statechart is found, the same pattern is usually repeated
across the feature. To sweep: grep the feature for the smell list above —
`useState` initialized to `false` near an `await`, `setError(null)` before a
call, `if (<flag>) return` at the top of a handler — then, for each hit, apply
the cause-not-appearance table. Report each as *keep in React* or *belongs in
machine X*, with the reason stated as what changes the value. Fix them as
separate increments, each with its own failing machine test, rather than one
sweeping commit.
