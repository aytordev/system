# Activation Verification

Confirm that a switch deployed what was intended. A successful build proves the
derivation is valid; it does not prove activation ran. Running activation is a
privileged step, so do it only through the repository entry points and only after
an explicit decision.

## Build Is Not Activation

- `just darwin-build wang-lin` (or
  `nix build .#darwinConfigurations.wang-lin.system`) evaluates and builds only.
- `just darwin-switch wang-lin` runs the activation:
  `sudo -H ./result/sw/bin/darwin-rebuild switch --flake .#wang-lin`.
- A quick switch is not proof of a no-op. An interrupted earlier run can leave
  the built paths in the store, so a retry only activates them.

On Linux the entry point is `just switch <host>`, which calls
`nixos-rebuild switch` (see the repository `Justfile`).

## Compare Generations

```bash
ls -t /nix/var/nix/profiles/system-*-link | head
readlink -f /nix/var/nix/profiles/system-<previous>-link
readlink -f /nix/var/nix/profiles/system-<new>-link
readlink /run/current-system
```

Different targets prove the system moved; identical targets prove the switch was
a no-op, whatever the summary said.

## Confirm the Artifact Is Live

```bash
gen=/nix/var/nix/profiles/system-<new>-link
nix path-info -r "$gen" | rg '<package>'
nix derivation show "$(nix path-info --derivation '<store-path>')" |
  rg '<expected-input>'
```

Inspect the derivation when the change is an input (an added patch, an overridden
dependency) rather than a version bump.

## Home Manager on This Repository

Home Manager runs as part of the Darwin generation here, with
`useGlobalPkgs = true`. The live integrated closure is recorded by the gcroots
link:

```bash
readlink -f ~/.local/state/home-manager/gcroots/current-home
```

A separate `~/.local/state/nix/profiles/home-manager-*-link` can be stale on an
integrated host; do not treat it as recovery evidence without proving it matches
the current generation. Consecutive system generations that reference the same
Home Manager closure leave the link unchanged.

Activation collisions are backed up with the `hm.old` suffix configured in
`libraries/system/mk-darwin/default.nix`; keep those files until the result is
reviewed.

## Safety

Do not run an activation package under your normal desktop account. Activation
reaches live user state and can restart or stop services; a temporary `HOME`
does not isolate it. Use the repository entry point, a VM, or a separate account.

## Evidence to Report

- Previous and new generation store paths.
- Proof that the intended artifact is in the new closure.
- Units restarted, still stale, or left for you.
- Any `hm.old` backups produced, kept until reviewed.
