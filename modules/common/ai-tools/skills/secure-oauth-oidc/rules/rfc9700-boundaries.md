---
title: Apply Every RFC 9700 Boundary Control
impact: CRITICAL
impactDescription: No check is softened, dropped, or summarized away
tags: secure-oauth-oidc, rfc9700, boundaries
---

## Apply Every RFC 9700 Boundary Control

**Impact: CRITICAL**

Use `references/rfc9700-control-catalog.md` for exact wording, normative
strength, and section provenance. At minimum, verify these boundaries:

### Redirect and authorization boundary

- Require exact string matching against pre-registered redirect URIs. Allow
  only the native loopback port exception defined by RFC 8252; do not
  generalize it to host, path, scheme, or other clients.
- Reject open redirectors at both client and authorization server boundaries.
- Never send authorization responses over unencrypted connections except the
  narrowly defined native loopback case.
- Prevent CSRF with a transaction-bound mechanism. PKCE can carry this burden
  only after support is known; otherwise use a one-time session-bound `state`,
  or OIDC `nonce` where its guarantees apply.
- For clients using multiple issuers, bind the chosen issuer to the user-agent
  session and validate the issuer in the authorization response. Prefer RFC
  9207 `iss` or an equivalent signed response; distinct redirect URIs are the
  fallback.
- Do not use HTTP 307 after credential-bearing form submission; use 303 for an
  HTTP redirect.

### Authorization-code boundary

- Require PKCE for public clients and recommend it for confidential clients.
  Default to PKCE for all authorization-code clients unless an applicable
  profile says otherwise.
- Use `S256`, keep verifier/challenge transaction-specific, enforce the
  verifier, and reject a token request that supplies a verifier when the
  authorization request had no challenge.
- Make authorization codes short-lived and single-use. Treat a second
  redemption as a compromise signal; the authorization server SHOULD revoke
  all tokens previously issued based on that code.
- Do not mistake client authentication for protection against code injection;
  the legitimate confidential client can redeem an injected code.

### Token boundary

- Do not use the resource-owner-password grant. Avoid implicit or any response
  that returns access tokens from the authorization endpoint unless every
  specified injection and leakage vector is demonstrably mitigated.
- Never put access tokens in URI query parameters.
- Restrict access tokens by resource/audience and least privilege; require
  each resource server to enforce both.
- Prefer sender-constrained access tokens using DPoP or mTLS. Verify both
  token binding and proof at the resource server; possession of a bound token
  alone is insufficient.
- For public clients, sender-constrain refresh tokens or rotate them with
  reuse detection. Bind every refresh token to the consented scope and
  resource servers.
- Treat tokens as secrets in storage, transit, logs, traces, errors, URLs,
  analytics, and test fixtures. Do not make a storage claim more absolute than
  the applicable platform/profile supports; explain the threat and evidence.

### Deployment boundary

- Publish and consume authorization-server metadata; validate the issuer and
  do not mix endpoints or keys across issuers.
- At TLS-terminating proxies, strip or overwrite attacker-supplied security
  headers and protect the proxy-to-application hop against eavesdropping,
  injection, and replay.
- Prevent clickjacking across authorization, login, consent, device, and error
  pages with CSP `frame-ancestors` plus appropriate compatibility defenses.
- Keep third-party resources off authorization and callback pages where they
  can receive Referer data; set an intentional Referrer Policy.
- For `postMessage` flows, use exact registered target origins, never `*`,
  validate the sender origin exactly, and apply every ordinary
  authorization-response control.
- Do not enable CORS at the authorization endpoint. CORS is not an OAuth CSRF
  defense.
