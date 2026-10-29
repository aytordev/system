# upstream-bump-gentle-ai-engram

Bump the two Nix-owned upstream pins — the Gentle AI engine and the Engram engine — and investigate, read-only, whether the unowned Gentle Shell pin fits this harness.

## Specs

S1. Move the Gentle AI engine pin in `packages/gentle-ai/package.nix` from `4.2.0` to upstream release `v4.3.1`, replacing all four per-platform SRI hashes with values derived from the release's own `checksums.txt` cross-checked against a local download, and updating the installer cross-reference comment.

S2. Move the Engram engine pin in `packages/engram/package.nix` from `3.1.0` to upstream release `v3.6.0`, replacing both `hash` and `vendorHash`, and re-verifying the sandbox-incompatible-test comment at the new version rather than carrying it over unverified.

S3. Keep every version statement honest: the three assertions in `checks/gentle-ai-engine/default.nix` (`4.2.0` at the `packageVersion` regression, `4.2.0` at the `gentle-ai version` grep, `3.1.0` at the `engramPackageVersion` regression) and the three mentions in `modules/common/ai-tools/README.md` (CLI `4.2.0`, Engram `3.1.0`, and "Shell 4.3 pins its private engine at Gentle AI **4.2.0**") must agree with the delivered pins.

S4. Deliver as one approved issue and one PR with two commits, one per package, after the operator selected "Una PR con dos commits, uno por paquete".

S5. Investigate, read-only, whether Gentle Shell `4.5.1` fits this harness: its release notes, the contracts this repository already patches (`modules/home/programs/terminal/tools/pi/startup-header.nix`, `.../pi/agent-profiles.nix`), and what `pi install npm:gentle-pi@4.5.1` plus the version-keyed `npm install-scripts approve` would do. Install nothing and report a recommendation.

## Tasks

- [ ] **UB-1 — Bump gentle-ai to 4.3.1.** Route: delegated writer. Commit: `chore(gentle-ai): bump to 4.3.1`. Surfaces: `packages/gentle-ai/package.nix`, `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`. Covers S1, and its share of S3.
- [ ] **UB-2 — Bump engram to 3.6.0.** Route: same delegated writer, after UB-1 (shared check and README surfaces). Commit: `chore(engram): bump to 3.6.0`. Surfaces: `packages/engram/package.nix`, `checks/gentle-ai-engine/default.nix`, `modules/common/ai-tools/README.md`. Covers S2, and its share of S3.
- [ ] **UB-3 — Verify both builds and the engine check.** Route: parent, independent of the writer's own runs. Covers S1-S3.
- [x] **UB-4 — Gentle Shell 4.5.1 compatibility investigation.** Route: `gentle-ai-explore`, read-only, parallel to UB-1/UB-2. Covers S5. Verdict: fits with caveats; evidence in L5. Install order constraint: the Shell may only be installed **after** UB-1 is merged and activated, because Shell 4.4.0+ bundles engine v4.3.1 and self-update is disabled, so installing first would leave the session engine ahead of the Nix CLI. Not installed; the operator decides separately.
- [ ] **UB-5 — Publish issue and PR.** Route: parent. Covers S4.

## Log

L1 (operator, verbatim): "Podemos subir el upstream de gentle-ai, gentle-shell y engram?"

L2 (operator, delivery shape, verbatim option choice): "Una PR con dos commits, uno por paquete" — commit 1 `chore(gentle-ai): bump to 4.3.1` → package.nix, checks/gentle-ai-engine, README; commit 2 `chore(engram): bump to 3.6.0` → package.nix, checks, README; una issue aprobada, una PR, un gate de CI con builds.

L3 (operator, Shell scope, verbatim option choice): "Investigar primero si 4.5.1 encaja con el arnés" — solo lectura: notas de `v4.5.1` y releases intermedias, compatibilidad con `startup-header.nix` y `agent-profiles.nix`, qué instalaría `pi install` y qué aprueba `install-scripts`. Después el operador decide si se instala.

L4 (parent evidence, upstream state at plan time): `Gentleman-Programming/gentle-ai` latest release `v4.3.1` (2026-10-27T18:35:33Z); `Gentleman-Programming/engram` latest release `v3.6.0` (2026-10-24T21:49:06Z); `Gentleman-Programming/gentle-pi` latest tag `v4.5.1` and npm `gentle-pi` latest `4.5.1`. Repository pins at that moment: `packages/gentle-ai/package.nix` `4.2.0`, `packages/engram/package.nix` `3.1.0`. Gentle Shell is not pinned anywhere in this repository; it lives in the operator's Pi profile.

L5 (UB-4 evidence, read-only, verdict "fits with caveats"): Shell release trail is only v4.4.0 (2026-10-27T19:12Z), v4.5.0 (2026-10-28T00:05Z) and v4.5.1 (2026-10-28T10:19Z); there is no v4.3.1 Shell tag. Every release instructs "Restart Pi". Both repository patches survive: `startup-header.nix:82,84` matches `^npm:gentle-pi(@.+)?\z` regardless of version and `:157` still filters the shipped `extensions/startup-banner.ts`; `agent-profiles.nix:22,23,25,77-79,241,257,271-279` keep their envelope kinds, entry keys, config paths and orchestrator keys, and `assets/agents/` lists the same ten role files at v4.3.0 and v4.5.1 (matching `checks/gentle-ai-engine/default.nix:103-113`), so 4.4.0's unmatched-key notices should not fire. npm 4.5.1 keeps the same `scripts.postinstall = node scripts/install-gentle-ai.mjs`, `engines.node >=22.19.0` and peer `@earendil-works/pi-coding-agent >=1.2.0`. The version-keyed gate is stale on purpose: `~/.pi/agent/npm/package.json` allows only `gentle-pi@4.3.0`, so 4.5.1's postinstall is unreviewed until re-approved, and the recorded 4.3.0 order (install first, then `npm install-scripts approve`) holds because approval fails ENOMATCH before the version exists. Shell 4.4.0+ pins Gentle AI **v4.3.1** as its bundled engine, so after UB-1 the session engine and the Nix CLI converge for the first time. Forward-compat threads for later work, not this delivery: `agent-profiles.nix:137-143` still writes `effort`, which 4.5.1 treats as a legacy spelling of `thinking`; and `/gentle:models` was retired in 4.5.0 in favor of `/gentle:profiles`. Two unknowns were left unresolved and must not be asserted: the engine directory name/SHA inside the 4.5.1 tarball, and whether `startup-banner.ts` internals still register through the header slot the filter releases.
