---
title: Reject False Assurances
impact: CRITICAL
impactDescription: Presence is not enforcement; a happy path is not evidence
tags: secure-oauth-oidc, assurance, review
---

## Reject False Assurances

**Impact: CRITICAL**

Each of these claims is a failure to prove the control it gestures at. When
you hear or are about to make one, stop and verify the missing property.

- **Presence of `state` is not protection** unless it is unpredictable,
  one-time, validated, and bound to the initiating session.
- **PKCE is not client authentication**, does not validate the issuer, and
  does not repair arbitrary authorization-request tampering.
- **OIDC `nonce` is not a generic pure-OAuth defense** and does not stop a
  thief redeeming a public client's stolen code.
- **TLS does not stop endpoint mix-up, browser history, Referer leakage, open
  redirects, or a compromised endpoint.**
- **A valid JWT signature does not establish** the expected issuer, audience,
  token type, freshness, nonce, or authorization.
- **DPoP or mTLS cannot help when the attacker obtains both token and usable
  key material**; XSS or a compromised client can collapse that boundary.
- **CORS, SameSite cookies, client secrets in browser code, and hiding
  parameters are not substitutes for protocol bindings.**
- **A provider's successful happy path is not security evidence.** Exercise
  hostile redirects, replay, issuer substitution, and validation failures.

The companion detail lives in the bundled references: the applicability traps
and normative-strength distinctions in `references/rfc9700-control-catalog.md`,
the false-assurance list for identity and discovery in
`references/oidc-validation.md`, and the safe testing rules in
`references/attack-and-test-catalog.md`. A negative test passes only when the
system fails closed before the protected action; a later error after a session
or API call was already authorized is not a pass.
