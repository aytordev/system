# Activation Tool-Path Integrity

## Goal and authorized scope

Repair the Docker socket activation failure, add a regression guard, and audit
absolute host-tool paths in repository activation/shell snippets. The user
selected fix + guard + repository-wide audit and subsequently explicitly
requested atomic work-unit commits. Publishing, PR creation, and merge remain
unauthorized.

Branch: `fix/activation-tool-path-integrity`.

## Incident and evidence

The attempted `civislend` generation
`/nix/store/6yihnypi800a5i4q08p6cdgq7iqg9lnp-darwin-system-26.11.4cff07d`
failed at `activate:3219`, calling `/usr/bin/ln`, which does not exist on the
affected macOS host. `/bin/ln` exists. `activate` uses `set -e`, and its final
`/run/current-system` publication follows that failure point.

At diagnosis, `/run/current-system` still pointed to generation `527xzmjd…`
and `/var/run/docker.sock` was absent. Home Manager and SOPS had already run.
Other earlier activation steps may also have applied: the old generation link
does **not** prove all system services remained unchanged. A successful repeat
switch and host readback are required to reconcile the partially applied state.

Darwin's tool layout is split; filesystem probes established `/bin/ln`,
`/bin/echo`, `/bin/bash`, `/bin/sh`, `/bin/launchctl`, `/usr/bin/readlink`,
`/usr/bin/arch`, `/usr/bin/true`, `/usr/bin/env`, `/usr/bin/find`,
`/usr/bin/touch`, `/usr/bin/hidutil`, `/usr/bin/tccutil`,
`/usr/bin/sw_vers`, and `/usr/sbin/softwareupdate` exist on this host.
In particular, `/usr/bin/ln` and `/bin/readlink` are not interchangeable with
their real counterparts. An unvetted path is not necessarily nonexistent.

The audit found `/usr/bin/ln` as the invalid invocation among the inspected
repository snippets: Docker socket adapter, Rosetta, Darwin Nix sandbox paths,
AeroSpace, Proton Mail Bridge, desktop suite and theme regeneration script.
These were path-existence probes, not functional executions of every service.

## Tasks and progress

- [x] T1 — Audit absolute host-tool paths. Results above; the initial exploration
      is recorded in planning commit `6db2fbdd`.
- [x] T2 — Repair Docker socket activation to `/bin/ln`. Commit `ff18fb8d`;
      generated `civislend` activation now contains the corrected invocation.
- [x] T3 — Derive the container-runtime sandbox translation from fragment tokens
      and assert no `/bin/` or `/sbin/` reference survives. Targeted check passes.
      This validates translation completeness, **not** host-path existence;
      `activation-dry-run` supplies the independent vetting gate. Delivered in
      work-unit commit `341d33b2`.
- [x] T4 — Add a vetted Darwin path guard and positive/negative fixtures to
      `checks/activation-dry-run`. An isolated working-tree copy with the original
      `/usr/bin/ln` invocation fails (RED); the live `/bin/ln` version passes
      (GREEN). Real source was not mutated for the completed regression run.
      Delivered with its sandbox counterpart in `341d33b2`.
- [x] T5 — Document the tool layout, guard maintenance and actual scope in
      `modules/darwin/AGENTS.md` and `checks/AGENTS.md`. Read-only verifier examined
      these changes; they accompany their behavior in `341d33b2`.
- [x] T6 — Verify targeted checks, Darwin flake checks with fixture secrets, and
      the generated `civislend` activation. Evidence below. Native review is a
      separate pending step; Linux build execution was not performed.
- [ ] T7 — Repeat `just darwin-switch civislend` and verify the resulting
      `/run/current-system` generation and Docker socket link. Blocked on user
      password: `sudo -n true` exits 1. No host activation was performed here.

## Guard scope and limitations

The guard scans explicitly enumerated Darwin system fragments (Docker socket and
Rosetta) on both build platforms, plus activation entries of the synthetic home
on Darwin. That includes upstream Home Manager entries enabled in this home.
New system fragments must be added to the inventory; disabled home capabilities,
launchd program paths, and upstream nix-darwin's full activation body are not
automatically covered. Token scanning is not a complete shell parser and cannot
prove paths dynamically constructed at runtime.

The state-machine sandbox translates host paths into portable PATH lookups;
that translation deliberately cannot reject a nonexistent Darwin path. Vetting
must inspect the original fragment before translation. Adding a path to the
allow-list requires verification on a real macOS host.

## Verification evidence

Read-only verifier observed exact exit codes:

- `nix build .#checks.aarch64-darwin.integration-container-runtime
  .#checks.aarch64-darwin.integration-activation-dry-run --no-link
  --print-out-paths`: exit 0.
- Isolated bad-path copy: `integration-activation-dry-run` exits 1 with
  `FAIL: docker-socket/postActivation calls tool path(s) outside the vetted
  Darwin tool list: /usr/bin/ln`. This is the completed RED evidence; the prior
  interrupted live mutation did not establish RED and was restored on resume.
- `nix flake check --override-input secrets path:./checks/fixtures/secrets`:
  exit 0, all checks passed for the current Darwin platform. Incompatible
  `x86_64-linux` checks were omitted, not executed.
- `nix build .#darwinConfigurations.civislend.system --no-link
  --print-out-paths`: exit 0, generation
  `/nix/store/7vcn7w3b5wix0kxi9ldabcm61zsdphal-darwin-system-26.11.4cff07d`.
  Its `activate:3219` invokes `/bin/ln`; `/usr/bin/ln` is absent.
- Parent spot check: `git diff --check` passes, `/bin/ln` is executable, and
  readback of the built activation confirms its corrected line 3219.
- Two writer attempts timed out. Their partial changes were inspected and
  independently verified; timeout is not completion evidence.
- RDD switch is on. After earlier consent expirations, fresh human consent
  created `review-650ebc94588139d0` for frozen target
  `sha256:4b25eb37232dfe6463782457ca25ca0a3b35152f7272c86605fbf14817506830`.
  Three bound `review-reliability` captures produced empty output with
  `stopReason: length`, without timeout or admitted verdict. Final bound STATUS
  remained `reviewing`; no approval or acknowledgement exists. The effective
  reviewer is `nan/deepseek-v4-flash` with high reasoning. Output exhaustion is
  a likely explanation, not confirmed token-usage evidence. The user chose to
  preserve model routing; no further identical captures or configuration changes
  are planned. The independent functional verification above remains valid.
- Work-unit commits are explicitly user-authorized, independent of native review
  closure. They do not approve the frozen candidate or repair review authority.

## Non-goals and next step

Rosetta's custom activation entry reachability remains T13 of
`odd/tasks/docker-runtime.md`; this feature does not repair it. No Docker VM
startup or daemon connectivity was asserted.

Preserve the open native review and unchanged reviewer routing; review is not
approved. Do not create another transaction or silently replay a failed capture.
To apply the repair, the user must run `just darwin-switch civislend` from this
branch and enter sudo credentials locally. Then verify the published generation
and socket symlink. No push, PR, or merge is authorized.

## Atomic work-unit delivery

Existing commits are preserved:

- `6db2fbdd` — initial ODD audit and plan.
- `ff18fb8d` — fix the privileged Docker socket invocation to `/bin/ln`.

Authorized work-unit delivery:

- [x] W1 — `341d33b2` (`test(activation): validate Darwin tool paths before
  sandbox translation`) includes both regression checks and their related
  guidance. The translation layer cannot validate the paths it normalizes,
  so these changes form one coherent protection. Precommit verification
  confirmed exactly these four paths were staged, no unstaged source changes,
  whitespace checks passing and both targeted Nix builds exiting 0. Commit hooks
  passed conflict-marker, deadnix, statix, treefmt and typos checks; ESLint and
  luacheck were inapplicable and skipped.
- W2 — This document is the reconciled ODD evidence unit, with commit subject
  `docs(odd): record atomic activation work units and review blockers`.
  It records verified outcomes and blockers without claiming native review
  approval. Its identity is recorded in session memory after Git confirms the
  commit; this document cannot contain its own commit hash.
