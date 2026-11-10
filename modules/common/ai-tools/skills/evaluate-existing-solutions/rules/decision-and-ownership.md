---
title: Decide, Route Ownership, and Plan Re-evaluation
impact: HIGH
impactDescription: Turns comparison into an owned, revisitable decision
tags: evaluate-existing-solutions, decision, ownership
---

## Decide, Route Ownership, and Plan Re-evaluation

**Impact: HIGH**

### Decision classes

Classify the resulting decision as:

- **Adopt** — use an existing solution substantially as designed.
- **Adapt** — configure, extend, fork, or wrap one solution with clearly owned
  deltas.
- **Combine** — compose a small set of complementary capabilities with an
  explicit integration owner.
- **Build** — implement the bespoke baseline because its total trade-off is
  better.
- **Defer** — evidence or timing is insufficient; preserve optionality and
  name the next trigger.
- **Do nothing** — the current state satisfies the job and change would add
  more ownership than value.

### Resolve uncertainty safely

For a material unknown, propose the smallest proof-of-fit that can change the
decision: a temporary spike, contract test, compatibility build,
representative benchmark, operational exercise, license/security review, or
migration rehearsal.

- Define the question, success/failure boundary, representative workload,
  timebox, and disposable outputs first.
- Use a disposable, least-privilege execution sandbox — not merely a temporary
  directory. Deny home and repository mounts, network, credentials, and host
  services by default; mount only disposable inputs and grant each exception
  explicitly.
- Do not install or execute untrusted packages, post-install scripts,
  containers, binaries, or remote installers without authority and inspection.
- Disable lifecycle/install scripts where the ecosystem allows it, verify the
  exact artifact and available checksum/signature/provenance before execution,
  and record every authorized network, mount, credential, or permission
  exception.
- Never send secrets, personal data, proprietary code, or production payloads
  to a candidate service without explicit authorization and an approved data
  path.
- Test the actual version and supported usage, not only a toy API.

Proof-of-fit evidence reduces uncertainty; it does not erase ongoing
maintenance, security, or operational obligations.

### Write the decision

Use `assets/solution-decision-template.md`. Every agent-produced result starts
as **proposed**; only the named decision owner can accept it, with accepter and
date recorded. Use an existing story, design, or active plan convention; if
none exists, write a fresh timestamped temporary file rather than inventing a
permanent documentation path. A consequential proposal is written as clear,
structured prose in the project's own documentation convention; an accepted
durable decision moves through the project's existing expectations or ADR
convention.

If adopting or adapting:

- name the exact supported version/range or service tier and update policy;
- state who owns upgrades, advisories, incidents, renewals, and removal;
- define the narrowest useful dependency boundary, without wrapping by reflex;
- keep domain policy in local language rather than leaking a vendor model
  through the codebase;
- record an exit path, data export path, and re-evaluation triggers.

If building:

- state why established options lost on explicit constraints or total
  ownership;
- distinguish domain advantage from generic plumbing;
- bound the mechanism, maintenance promise, security work, and operational
  surface now owned;
- identify any standards or small primitives still reused inside the bespoke
  design.

### Route the implementation

Implementation is separately authorized. Route each concern to its owning
discipline directly: module responsibility and dependency hiding go through a
module-design step; public protocols and cross-team compatibility through a
protocol-design review; source/package placement through the project's
structure conventions; replacing custom machinery with net subtraction through
a reduction plan; delivery sequencing through the project's planning
convention. New or changed behavior gets a failing test written first
(test-first), behaviour-preserving restructuring only after a passing baseline
(refactoring discipline), and mutation evidence once for the accumulated
change at PR readiness. A final high-stakes decision review uses an
independent reviewer. Companion skills may carry these methods when installed;
the routing rules stand without them.

### Re-evaluation triggers

Every durable decision should say when to revisit it, for example:

- major release, deprecation, EOL, maintenance slowdown, or compatibility
  break;
- security advisory, ownership/governance change, or license change;
- pricing, SLA, data-residency, procurement, or platform-policy change;
- repeated integration pain, missing observability, reliability incidents, or
  upgrade burden;
- new scale, latency, portability, accessibility, or compliance requirement;
- a platform primitive now satisfies the job with materially less ownership.
