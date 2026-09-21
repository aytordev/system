# Build Diagnosis

Narrow a failed build to one input, prove the cause, and record the evidence.
This is read-only work; editing an expression is a separate, authorized step.

## Pick the Smallest Failing Target

A failure in a whole host closure can come from any input. Reproduce against the
narrowest installable that still fails before reading logs:

```bash
nix build .#checks.aarch64-darwin.unit-ai-tools-dependencies --no-link
nix build .#darwinConfigurations.wang-lin.system --no-link --show-trace
```

For the host system itself, `just darwin-build wang-lin debug` adds
`--show-trace --verbose` to the same `nix build`.

## Tell Evaluation Apart From Building

Nix reports two different failures through the word "build":

```bash
nix eval .#darwinConfigurations.wang-lin.system.drvPath --show-trace  # evaluation
nix build .#darwinConfigurations.wang-lin.system --no-link            # building
```

If the expression does not evaluate, `nix log` has nothing to show. Fix the
evaluation error first: a missing option, a type mismatch, a failing assertion.
`--show-trace` is the primary tool for that class of failure.

## Read the Failing Log

```bash
nix log .#checks.aarch64-darwin.unit-ai-tools-dependencies
```

When the installable name no longer resolves, resolve the derivation and pass
the `.drv` path:

```bash
drv="$(nix build .#package --derivation --no-link --print-out-paths)"
nix log "$drv"
```

See the [nix log manual](https://nix.dev/manual/nix/2.35/command-ref/new-cli/nix3-log).

## Inspect the Builder

`nix derivation show` prints the builder, its arguments, and the environment the
build actually ran under. Select the fields instead of reading the whole
document:

```bash
nix derivation show .#package | jq '.derivations | to_entries[0].value | {
  builder, system, args,
  env: {
    name: .env.name, version: .env.version, src: .env.src,
    patches: .env.patches, configureFlags: .env.configureFlags
  }
}'
```

Add `--recursive` only when dependency derivations are relevant; the output is
large. See the
[nix derivation show manual](https://nix.dev/manual/nix/2.35/command-ref/new-cli/nix3-derivation-show).

## Control the Build

```bash
nix build .#package --no-link            # do not create ./result
nix build .#package --keep-failed        # keep the temporary build directory
nix build .#package --rebuild --no-link  # ignore cached outputs and substitutes
```

`--keep-failed` leaves the failed sandbox tree in place for inspection.
`--rebuild` confirms that a success did not come from a substituter or a stale
store path.

## When the Failure Is a Patch

- Replace text with `substituteInPlace` and `--replace-fail` so upstream drift
  aborts instead of silently missing.
- Prefer `fetchpatch2` over hand-rolled downloads.
- Start a fixed-output hash with `lib.fakeHash` and copy the `got:` SRI value
  from the mismatch.
- Match the build's own patcher (`patch -p1`), not `git apply`, which is
  stricter and rejects hunks the build would accept.

## Evidence to Report

- Target installable or host, and the exact command.
- Whether the failure was evaluation or building.
- The failing phase and a short, verbatim error excerpt.
- The suspected input and the smallest change that would test it.
- The command that verifies the fix.
