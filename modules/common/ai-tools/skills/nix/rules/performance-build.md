## Build Performance

**Impact:** MEDIUM

Profile evaluation and tune build parameters for your hardware.

**Incorrect (Blind Defaults):**

Running builds without tuning parallelism or profiling evaluation time.

```bash
# BAD - no profiling, no idea where time is spent
nix build .#nixosConfigurations.hostname

# BAD - default settings may not match your hardware
# Defaults to max jobs = 1, cores = all available
nix build .#nixosConfigurations.hostname

# BAD - no visibility into what's happening
nix eval .#nixosConfigurations.hostname
```

**Correct (Profiled Build):**

Profile evaluation, tune parameters, leverage caching.

```bash
# Profile evaluation to find bottlenecks
NIX_SHOW_STATS=1 nix eval .#nixosConfigurations.hostname

# Generate flamegraph for detailed profiling (requires nix 2.20+)
nix eval --eval-profiler flamegraph .#nixosConfigurations.hostname

# Tune build parallelism for your hardware
# max-jobs: number of parallel derivations
# cores: CPU cores per derivation
nix build --max-jobs 4 --cores 8 .#nixosConfigurations.hostname

# Use remote builders for heavy compilation
nix build \
  --max-jobs 4 \
  --cores 8 \
  --builders "ssh://buildhost x86_64-linux /etc/nix/signing-key.sec 8" \
  .#nixosConfigurations.hostname

# Leverage binary cache to avoid rebuilding
nix build \
  --substituters "https://cache.nixos.org https://nix-community.cachix.org" \
  --trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
  .#nixosConfigurations.hostname

# Set up automatic garbage collection
nix-collect-garbage --delete-older-than 30d

# Profile store size
nix path-info -rsSh .#nixosConfigurations.hostname.config.system.build.toplevel

# Optimize store (deduplicate identical files)
nix-store --optimize

# Check what's keeping a path alive
nix-store --query --roots /nix/store/...-package

# Trace dependency graph
nix-store --query --graph .#nixosConfigurations.hostname.config.system.build.toplevel | dot -Tpng > graph.png
```

Configuration for persistent optimizations:

```nix
{
  nix.settings = {
    # Tune for your hardware
    max-jobs = 4;
    cores = 8;

    # Enable flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Auto-optimize store
    auto-optimise-store = true;

    # Configure substituters
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
```
