# Evaluation Cost

Measure how long an expression takes to evaluate and decide whether an
optimization earns its complexity. Choosing constructs is authoring guidance;
this reference owns the experiment and the acceptance evidence.

## Controls

- Evaluate with `--option eval-cache false` so a previous run cannot answer.
- Warm up at least 3 times and take at least 10 runs.
- Never accept a single-run timing.
- Compare the same consumed output on both sides; timing an expression nobody
  uses proves nothing.

## Time One Installable

`hyperfine` comes from nixpkgs:

```bash
nix shell nixpkgs#hyperfine -c hyperfine --warmup 3 --runs 10 \
  'nix eval --raw ".#darwinConfigurations.wang-lin.system.drvPath" --option eval-cache false'
```

A standalone file evaluates the same way:

```bash
nix shell nixpkgs#hyperfine -c hyperfine --warmup 3 --runs 10 \
  'nix-instantiate --eval --option eval-cache false ./configuration.nix'
```

## Count Thunks and Allocations

`NIX_SHOW_STATS` writes a single-run report. Use it for shape, not for speed:

```bash
NIX_SHOW_STATS=1 NIX_SHOW_STATS_PATH=stats.json \
  nix eval ".#homeConfigurations.\"aytordev@wang-lin\".activationPackage.drvPath" \
  --option eval-cache false
jq '.nrThunks, .gc.totalBytes' stats.json
```

Fewer thunks alone is not a user-visible speedup; report it only alongside
timings.

## Profile the Hot Path

```bash
nix eval --eval-profiler flamegraph \
  ".#darwinConfigurations.wang-lin.config.system.build.toplevel"
```

Wide frames carry the most total time; deep stacks usually mean recursion or
expensive option merging. To confirm a suspected merge hotspot, count exact
calls with `--eval-profiler-frequency 0` before restructuring.

## Keep Evaluation Separate From Building

```bash
nix eval --raw ".#darwinConfigurations.wang-lin.system.drvPath" \
  --option eval-cache false
```

`nix build` time is evaluation evidence only when every path is already
substituted; otherwise it measures the builder.

## Where Time Usually Goes Here

- Documentation and manual generation dominate a full system evaluation.
- Home Manager with `useGlobalPkgs` reuses the host package set instead of
  evaluating nixpkgs a second time; check this setting before blaming modules.
- `specialisations` and NixOS `containers` re-evaluate the config graph once per
  instance.
- An overlay that imports nixpkgs internally multiplies cost; only the
  attributes it overrides re-evaluate.
- `flake-parts` and module helpers are not inherently the cost. Profile first.

## Accepting a Change

Report the mean, the spread, and the percentage change, and call out memory
regressions even when time improves. Keep feature reductions (for example
disabling documentation) separate from behavior-preserving changes, and require
an explicit decision before giving up a capability.
