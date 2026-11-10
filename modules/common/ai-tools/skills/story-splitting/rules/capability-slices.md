---
name: capability-slices
impact: CRITICAL
impactDescription: Core principles for capability slicing
---

# Capability Slices

**Impact: CRITICAL**

## Stories Are Conversations, Not Requirements

Treat a story as a placeholder for collaboration between people with the
problem and people who can solve it. Do not optimize for perfect written
requirements or a handoff from Product to Engineering.

When a story seems too large, bring product, engineering, design, QA, and
operations perspectives into the split. Product knows value and trade-offs.
Engineers know where effort and uncertainty hide. Splitting without both
viewpoints usually creates either low-value fragments or technical
dependencies.

## Slice Capabilities, Not Components

Every child story should describe a change in behavior from a real user's or
external system's point of view. If the "user" in the story is an internal
component, layer, queue, database, API, or service, it is probably a task,
not a story.

Prefer:

```text
Buyer can pay one invoice by card and receive a confirmation.
```

Avoid:

```text
Backend exposes payment endpoint.
Frontend calls payment endpoint.
Database stores payment rows.
```

Tasks can exist inside a story. Do not relabel tasks as stories to make a
plan look incremental.

## Stay In The Problem Space First

Ask:

```text
What are the simplest options for delivering value to the customer as soon as possible?
```

Do not start with:

```text
What is the simplest way to build this already-imagined solution?
```

The first question reveals customer-capability options. The second often
jumps straight to portals, apps, services, vendors, and architecture before
the team has chosen the narrow valuable capability.

## Start With A Primitive Whole

Prefer a tiny, end-to-end whole over a polished part. Useful first versions
include an under-featured vertical slice, a structurally uncomposed path, an
internal-only capability, or an explicitly labelled disposable tracer.

This first slice should exercise the real behavior path as far as practical.
State its release constraint honestly. Whether it uses a feature flag,
another release mechanism, or no hiding mechanism at all is a project policy
decision. Disposable work must be explicitly labelled as a spike or tracer
experiment.

## Hunt For Bargains

A bargain is high value at a fraction of full cost. Look for slices where
one-fourth of the imagined feature gives most of the value or learning. Treat
the parent story as a draft idea; be willing to discover a cheaper or better
version through conversation.
