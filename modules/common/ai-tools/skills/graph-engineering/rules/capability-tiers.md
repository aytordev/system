---
title: Assign Capability Tiers Honestly
impact: HIGH
impactDescription: Tier gates and the requested-versus-applied ledger
tags: graph-engineering, model-policy, ledger
---

## Assign Capability Tiers Honestly

**Impact: HIGH**

The graph chooses a capability tier, and the host mapping resolves that tier to
a concrete model. Keep the concerns separate: a new model changes the mapping,
not the policy.

### Capability tiers

| Tier | Use | Default effort | Gate |
|---|---|---|---|
| `economical` | Mechanical work such as path resolution, deduplication, formatting, or schema cleanup | `low` | The node must not be making a substantive judgment |
| `balanced` | Ordinary lenses and ordinary finding verification | `medium` | Default for review work |
| `strong` | Genuinely difficult or high-impact verification | `high` | The caller names the difficult question or impact being checked |
| `top-tier` | An explicitly named unresolved high-stakes escalation | `max` | Requires a named escalation (`findingId`, name, reason); never inferred from `thorough` or roster size |

Selection rules:

1. Start every ordinary lens and verifier at `balanced`.
2. Use `economical` only for mechanical stages.
3. Promote a verifier to `strong` only for a named difficult or high-impact
   question. More votes do not promote the model tier.
4. Use `top-tier` only for the named unresolved high-stakes escalation. If the
   escalation is resolved or unnamed, stay at `balanced` or `strong`.
5. Never inherit the authoring session's current model or effort implicitly.

The provider-to-model mapping is deployment data, not policy: resolve each tier
against the host at run time and validate the mapping when a provider launches
or retires a model. A provider may reuse one model ID for adjacent tiers when
effort is the only available capability difference; the tier gate still
applies.

### Runtime contract

Resolve a tier before dispatch and pass the mapped model, effort, and the
smaller of the caller's per-node cap and the remaining run budget whenever the
runtime accepts those options:

- For parallel fan-out, reserve each node's cap before dispatch when the
  runtime offers reservation; a per-call cap alone is not proof of an aggregate
  budget. Record `budget: "best-effort"` when reservation is unsupported.
- If the resolved model is unavailable, fall back to the host's mapped
  `balanced` entry, record the reason, and stop rather than falling through to
  the ambient session if that entry is also unavailable.

The runtime records a ledger entry for every node. `requested` is the resolved
request; `applied` and `usage` come from the runtime response and are never
copied from the request:

```json
{
  "runtime": "workflow",
  "provider": "claude",
  "node": "verify:finding-1",
  "tier": "balanced",
  "requested": { "model": "sonnet", "effort": "medium", "max_tokens": 4000 },
  "applied": { "model": "sonnet", "effort": "medium", "max_tokens": 4000 },
  "fallback": null,
  "usage": { "input_tokens": 0, "output_tokens": 0 }
}
```

If a field is not reported, record `unreported`; do not claim that the
requested model or budget was applied. An unsupported option is an explicit
fallback with an honest ledger entry, not permission to inherit an uncontrolled
session default silently — and never use an uncontrolled default for a
top-tier escalation.

Never economize on verification merely to reduce cost; false positives that
survive verification are the product failing. For cross-provider independence,
prefer a reviewer from a different provider starting cold over re-running the
same lenses in one context.
