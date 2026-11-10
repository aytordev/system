---
title: Choose the Task Path
impact: HIGH
impactDescription: Design, implementation, and review each carry distinct obligations
tags: secure-oauth-oidc, workflow, incidents
---

## Choose the Task Path

### Design or migration

1. Produce the security profile and trust-boundary diagram or flow trace.
2. State each transaction binding and token validation invariant.
3. Remove insecure grants before adding optional hardening.
4. Choose interoperable controls and confirm provider/library support from
   current primary documentation.
5. Define negative tests and observability before implementation.
6. For migrations, inventory every client and callback, stage compatibility
   deliberately, define rollback, and time-box any weaker transitional mode.

### Implementation

1. Use a maintained OAuth/OIDC library rather than hand-rolling protocol or
   cryptography.
2. Inspect the exact library version and configuration path; defaults and
   method names are not evidence.
3. Put validation at the trust boundary and fail closed before creating a
   session or forwarding a token.
4. Keep secrets and raw tokens out of telemetry. Record safe identifiers,
   decision reasons, issuer, client ID, audience, grant type, and replay
   events instead. Delete an existing line that logs or hands back a raw
   token, code, or verifier as soon as you touch the file it sits in — an
   exposure you edited around is one you shipped — and never write a test that
   asserts a token appears in a URL, a response body, or a log.
5. Add behavior-driven positive and negative tests. When production code
   changes, use the repository's testing/TDD workflow where available.

### Review or incident diagnosis

1. Follow an attack path from attacker capability to asset and impact; do not
   report parameter absence without proving applicability.
2. Distinguish **normative non-compliance**, **exploitable weakness**,
   **defense-in-depth gap**, and **unknown**.
3. Give file/line, configuration path, metadata field, HTTP trace, or
   reproducible scenario as evidence. Redact all credentials and token values.
4. During an incident, preserve evidence, contain token/code/credential
   exposure, revoke affected grants or token families, rotate compromised
   keys, and then fix the enabling control. Do not destroy evidence or probe
   systems outside authorization.
5. Use `references/review-and-delivery.md` for the report and completion
   contract.
