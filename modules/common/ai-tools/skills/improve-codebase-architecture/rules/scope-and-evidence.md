---
title: Fix the Target and Gather Evidence
impact: CRITICAL
impactDescription: Keeps the audit scoped, evidence-led, and read-only
tags: architecture, scoping, evidence
---

## Fix the Target and Gather Evidence

**Impact: CRITICAL**

An unscoped audit produces a generic cleanup list. Fix one review area first,
then let evidence — not aesthetics — drive the findings.

### Fix the review target

Use the user's named scope when provided. Otherwise infer a useful review area
from several signals:

- recent and repeated changes, excluding generated and vendored files;
- files that co-change for one behavior;
- defects, incidents, TODOs, and repeated review comments;
- dependency cycles, forbidden imports, or provider leakage;
- tests that are brittle, absent, slow, or dominated by collaborator setup;
- high fan-in or fan-out and repeated caller orchestration;
- ownership, runtime, trust, transaction, and deployment seams;
- product or delivery work likely to revisit the area.

Walk enough history to distinguish an active hotspot from a one-off migration.
When evidence is scattered, state the uncertainty and widen only as much as
needed.

### Read intent before judging shape

Inspect:

- repository and directory-level agent instructions;
- architecture decisions and design docs using the project's own conventions;
- applicable domain glossaries, if the project has them;
- routes, commands, jobs, public exports, callers, tests, and composition;
- package manifests, build/test discovery, generated-code boundaries, and
  runtime units;
- the current working-tree diff and relevant recent commits.

Do not invent a global context file, coin an architecture-decision-record path
the project does not use, or silently add domain terms. Route a terminology
decision through the project's own glossary mechanism only when a real
terminology decision arises.

### Trace behavior through modules

Follow representative behavior from entrypoint to observable outcome. Record:

- which callers know policy, sequencing, configuration, provider shapes, and
  failure recovery;
- where decisions and invariants actually live;
- which modules are intentionally thin translation or composition edges;
- which files, tests, and owners change together;
- which seams and adapters are real versus ceremonial;
- what the current tests prove and what they cannot prove.

When the host allows parallel exploration, independent repository areas may be
inspected concurrently without duplicating work. Give explorers raw scope and
evidence, not a preferred diagnosis; the orchestrator synthesizes.
