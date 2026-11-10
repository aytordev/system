---
title: Establish the Profile and Build the Transaction Ledger
impact: CRITICAL
impactDescription: The evidence base every recommendation rests on
tags: secure-oauth-oidc, profile, ledger
---

## Establish the security profile first

Before recommending code or configuration, identify:

1. **Goal** — delegated API access, user authentication, both,
   machine-to-machine access, device authorization, or token exchange.
2. **Parties** — authorization server / OpenID Provider, client / relying
   party, resource server, resource owner / end-user, browser or system user
   agent, and TLS-terminating intermediaries.
3. **Client type and execution context** — confidential or public;
   server-side web app, browser app, native app, service, CLI, or device.
   Classify by whether credentials can actually remain confidential, not by a
   registration label.
4. **Flows and response modes** — enumerate every grant, response type,
   response mode, callback, token exchange, refresh path, logout path, and
   back-channel call that is enabled, including legacy paths.
5. **Trust topology** — single issuer or multiple; static or dynamic
   discovery/registration; one or many resource servers; same-party or
   third-party components; proxies and service meshes.
6. **Applicable profile** — RFC 9700 baseline plus OIDC Core, native-app BCP,
   DPoP, mTLS, PAR/JAR/JARM, FAPI, or another deployment profile. A stricter
   profile adds requirements; it does not erase the baseline.
7. **Evidence** — exact code, config, metadata, library and version, tests,
   and runtime behavior. Mark anything not inspected as unknown.

If the task is underspecified, inspect the repository and deployed metadata
first. Ask only for choices that materially change the profile and cannot be
discovered safely.

## Build a transaction ledger

Trace each flow from initiation through callback, token use, refresh,
revocation, and logout. Record who creates, stores, transmits, validates,
consumes, expires, and invalidates each artifact:

| Artifact | Required binding or validation |
|---|---|
| Authorization request | intended issuer, client, exact redirect URI, response type/mode, requested resource and privilege |
| `state` | high-entropy, one-time, securely bound to the initiating user-agent session; integrity-protected when it carries application state |
| PKCE verifier/challenge | transaction-specific; verifier secret retained by the initiating client instance; `S256`; authorization server records whether a challenge was present |
| OIDC `nonce` | transaction-specific and bound to the initiating session; validated in the correct ID Token before any returned token is used |
| Authorization response | expected session, issuer, redirect endpoint, response mode, and error/success semantics |
| Authorization code | client, redirect URI, transaction/PKCE challenge, single use, short lifetime |
| Access token | issuer, intended resource/audience, privilege, lifetime, token type, and sender key when constrained |
| Refresh token | client instance, grant, consented scope/resources, replay-detection family or sender key, expiry/revocation state |
| ID Token | expected issuer, relying-party audience, signature/algorithm, time claims, nonce and flow-specific hashes |

Missing or implicit bindings are where mix-up, CSRF, code injection, token
substitution, and replay attacks hide.
