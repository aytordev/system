---
name: secure-oauth-oidc
description: "Trigger: designing, implementing, auditing, testing, troubleshooting, or migrating secure OAuth 2.0 and OpenID Connect (OIDC) systems against RFC 9700 / BCP 240 — authorization servers and OpenID Providers, OAuth clients and OIDC relying parties, resource servers, native apps, browser-based apps, multi-issuer login, redirect URIs, authorization code and PKCE flows, state and nonce handling, ID Token validation, token storage and replay, refresh-token rotation, sender-constrained tokens (DPoP or mTLS), mix-up and injection attacks, discovery and metadata, reverse proxies, or migration away from implicit and resource-owner-password grants."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Secure OAuth and OpenID Connect

Treat OAuth security as a set of end-to-end protocol invariants, not a
checklist of parameters. Use RFC 9700 / BCP 240 as the baseline, then add the
requirements of the selected OAuth extension, OpenID Connect, platform
profile, and deployment. OAuth delegates access; OpenID Connect adds
authentication. Never infer a login identity from OAuth alone, and never use
an access token as an ID Token.

This skill owns the OAuth/OIDC protocol layer. The application session that
results in a browser-facing BFF — session cookies, CSRF and browser-request
policy, endpoint classification, keeping tokens out of the browser — is a
separate layer: restate the rule inline (tokens stay out of the browser and
behind server-side sessions; browser-facing endpoints follow the repository's
session/CSRF policy) and, where a bff-entry-points skill is installed, load
it as an optional companion.

`rules/` is bundled with this skill. Repository paths refer to the target
repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Designing, implementing, auditing, testing, troubleshooting, or migrating
  any OAuth 2.0 or OIDC surface listed in the trigger.
- Threat-modeling, incident-diagnosing, or reviewing an authorization flow.
- Deciding whether a standard, draft, or profile applies (`references/standards-map.md`).

## Hard Rules

1. **Bring the flow you touch up to baseline.** Any change that adds, extends,
   reroutes, or re-points part of an authorization-code flow brings that
   flow's whole transaction to the RFC 9700 baseline in the same change:
   `S256` PKCE with a per-transaction verifier, a fresh one-time `state`
   (and, for OIDC, a `nonce`) both bound to the browser that started the
   sign-in, exact redirect-URI matching, issuer and audience validated on
   every token you consume, and no token in a URL, a log, or anything the
   browser can read.
2. **No exceptions by inheritance.** A narrowly worded request, a handover
   note, an existing test that pins the current shape, or a defect that
   predates you is not permission to leave that flow short of the baseline.
   Do not build a new flow to match an insecure one beside it, and do not
   leave an exposure sitting in a file you are already editing. List as
   residual risk only what this change did not touch.
3. **Do not rely on memory for normative wording.** Use
   `references/rfc9700-control-catalog.md` for requirement strength and
   section provenance; follow the linked RFC section when wording or an
   exception is disputed.
4. **Apply every boundary control in `rules/rfc9700-boundaries.md`** —
   redirect/authorization, authorization-code, token, and deployment
   boundaries — with no check softened or dropped.
5. **Reject false assurances** (`rules/false-assurances.md`): presence is not
   enforcement, a valid signature is not the right issuer or audience, and a
   provider's happy path is not security evidence.
6. **Keep raw secrets and tokens out of telemetry**, and never write a test
   that asserts a token appears in a URL, a response body, or a log. Delete an
   existing line that logs or hands back a raw token, code, or verifier as
   soon as you touch the file it sits in.
7. **Fail closed.** No session, account link, token use, or API call before
   every required validation completes. Do not silently convert missing
   evidence into compliance — mark it unknown.

## Execution Steps

1. **ESTABLISH THE SECURITY PROFILE FIRST** — goal, parties, client type and
   execution context (classified by whether credentials can actually remain
   confidential, not by a registration label), every enabled flow and
   response mode including legacy paths, trust topology, applicable profile,
   and the evidence actually inspected — marking anything not inspected as
   unknown. Full checklist: `rules/security-profile-and-ledger.md`. If the
   task is underspecified, inspect the repository and deployed metadata
   first; ask only for choices that materially change the profile and cannot
   be discovered safely.
2. **BUILD A TRANSACTION LEDGER** — trace each flow from initiation through
   callback, token use, refresh, revocation, and logout, recording who
   creates, stores, transmits, validates, consumes, expires, and invalidates
   each artifact. The required bindings per artifact are the ledger table in
   `rules/security-profile-and-ledger.md`. Missing or implicit bindings are
   where mix-up, CSRF, code injection, token substitution, and replay attacks
   hide.
3. **APPLY THE RFC 9700 BOUNDARY CONTROLS** — verify the redirect and
   authorization, authorization-code, token, and deployment boundaries in
   `rules/rfc9700-boundaries.md`, with the control catalog for exact wording.
4. **ADD THE OIDC IDENTITY LAYER** — load `references/oidc-validation.md`;
   keep three concerns separate: `state` correlates the authorization
   response and protects the callback; PKCE binds an authorization code to
   the initiating client instance and can protect against CSRF when support
   is assured; `nonce` binds an ID Token to an authentication transaction and
   can, under RFC 9700's stated conditions, protect a confidential OIDC
   client against code injection. Validate an ID Token as a protocol object,
   not merely a signed JWT: bind the local account to `(iss, sub)`, validate
   the relying-party audience and authorized party, enforce time and nonce
   semantics, validate flow-specific token hashes when required, and require
   UserInfo `sub` to match the ID Token `sub`. Do not parse an access token
   for identity at a client unless a specific access-token profile makes that
   a supported contract — even a valid JWT access token is addressed to a
   resource server, not the relying party.
5. **CHOOSE THE TASK PATH** — design/migration, implementation, or
   review/incident diagnosis, each with its own obligations in
   `rules/task-paths.md`: stated invariants and negative tests before
   implementation; a maintained library and fail-closed validation; attack
   paths from capability to impact with findings classified (normative
   non-compliance / exploitable weakness / defense-in-depth gap / unknown),
   evidence redacted, and evidence-preserving incident response.

## Output Contract

Return: scope and profile (parties, client types, flows, issuers, resources,
standards applied); flow and trust boundaries (artifact bindings and
validation points); findings or design decisions (requirement strength,
evidence, attack scenario, remediation, verification); satisfied controls —
only those supported by evidence; unknowns and assumptions — never silently
converted into compliance; tests and runtime checks (positive, negative,
replay, failure-path coverage); and residual risk and migration constraints
with explicit exceptions, owners, and expiry dates.

Do not declare an OAuth/OIDC system secure merely because all happy-path tests
pass or all checklist rows are filled. Declare only what the inspected
evidence proves.

## References

- `rules/rfc9700-boundaries.md` — the redirect, authorization-code, token, and deployment boundary controls.
- `rules/false-assurances.md` — the assurances to refuse, with what is missing from each.
- `rules/security-profile-and-ledger.md` — the seven-point profile checklist and the artifact-binding ledger table.
- `rules/task-paths.md` — design/migration, implementation, and review/incident obligations.
- `references/rfc9700-control-catalog.md` — the full control table with normative strength and section provenance.
- `references/oidc-validation.md` — discovery trust, atomic ID Token validation, UserInfo, refresh, negative tests.
- `references/attack-and-test-catalog.md` — attacker model, attack-to-control matrix, adversarial test suites, safe testing rules.
- `references/review-and-delivery.md` — evidence collection, finding model, severity calibration, report template, completion gate.
- `references/standards-map.md` — source precedence, extension selection, OIDC/FAPI profiles, claim discipline.
- `references/provenance.md` — upstream source, revision, and licence notice.
