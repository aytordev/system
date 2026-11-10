---
title: Select and Configure the Reviewer
impact: HIGH
impactDescription: Keeps independence honest and the reviewer read-only
tags: double-check, reviewer, modes
---

## Select and Configure the Reviewer

**Impact: HIGH**

### Review modes

| Mode | Use when | Required label |
| --- | --- | --- |
| Cross-provider independent review | A read-only reviewer from a different model provider is available | `cross-provider independent review` |
| Same-provider fresh-context fallback | No different-provider reviewer is usable, but the host can launch an isolated fresh agent or process | `same-provider fresh-context fallback` |

This skill verifies *finished* work. Different executable names do not
establish independence if they route to the same underlying model provider.
Prefer provider diversity, then strong reasoning capability and genuine
read-only isolation. Never call a same-provider fallback independent or
cross-provider.

### Required capabilities

A usable reviewer must provide:

1. A context separate from the authoring conversation.
2. Read access to the named artifact and relevant repository context.
3. Enforceable read-only behavior for files and external systems.
4. Enough reasoning capability for the risk of the work.
5. A way to return complete textual findings and the exact verdict.

Reject a candidate that cannot guarantee read-only operation. Do not solve
missing isolation by granting broad permissions. Read-only means no file
writes, commits, pushes, messages, or external state mutation. It does not
forbid safe, non-destructive execution: a reviewer that can run the test
suite, a typecheck, or a build produces `executed` evidence instead of
inference, so prefer a sandboxed candidate that permits it.

### Selection order

1. Prefer a reviewer backed by a different model provider from the host.
2. Among independent choices, prefer stronger reasoning and safer isolation.
3. If no independent choice is usable, launch a fresh same-provider agent or
   process with zero inherited authoring context.
4. If neither mode is safe, report that the double-check could not run.

Discover capabilities from the host's available tools, installed integrations,
and current documentation. Do not maintain a fixed vendor ranking:
availability, model quality, and safety controls change. If a candidate is
installed but unavailable, try another safe independent capability before
falling back. If the user explicitly requires cross-provider independence, do
not substitute the fallback.

### Invocation

Use the host or provider's current tool schema/help to determine invocation
syntax. Configure:

- the strongest appropriate model or the user's configured default;
- the highest practical reasoning effort;
- read-only or plan-only access;
- a non-interactive input path when available;
- complete output capture.

Pass the brief through the host's safe artifact/input mechanism. A scratch
file or structured tool argument is preferable to a long shell argument. Do
not encode login instructions or attempt to alter authentication from this
skill; an unusable integration is simply skipped or reported.

### Fresh same-provider fallback

Round one must receive only the cold verifier brief and access to the named
artifact. Do not fork the authoring conversation or reuse an existing session.
Later rounds may receive the findings ledger and host responses because
convergence requires dialogue. Always report this mode as
`same-provider fresh-context fallback`: context isolation reduces anchoring
but does not create model-provider independence.

### Continuity

Prefer safe session continuity after round one so the reviewer can explicitly
accept or maintain each ledger item. When continuity is unavailable, include
the complete prior ledger, host responses, updated scope, and validation
evidence in a fresh round.
