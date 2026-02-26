## Manual Checks

**Impact:** HIGH

Use `nix eval` and `nix build --dry-run` to validate logic before pushing. This catches option type errors and evaluation failures that linters miss.

**Incorrect (Blind Push):**

Pushing changes without checking if the module actually evaluates.

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    # Type mismatch - will fail at evaluation
    count = lib.mkOption {
      type = lib.types.int;
      default = "not an integer";  # ERROR
    };
  };

  config = mkIf cfg.enable {
    # Referencing non-existent attribute - will fail
    programs.nonexistent.enable = true;
  };
}
```

**Correct (Dry Run):**

Validate before pushing to catch evaluation errors.

```bash
# Parse check - catches syntax errors
nix-instantiate --parse file.nix > /dev/null

# Evaluation check - catches type errors and missing attributes
nix eval .#nixosConfigurations.hostname.config.system.build.toplevel

# Build check without actually building - catches missing derivations
nix build .#nixosConfigurations.hostname.config.system.build.toplevel --dry-run

# Check all flake outputs
nix flake check

# Evaluate specific option to test
nix eval .#nixosConfigurations.hostname.config.aytordev.example.module.enable

# Test home-manager configurations
nix build .#homeConfigurations."user@hostname".activationPackage --dry-run

# Quick syntax validation for a single file
nix-instantiate --parse modules/example.nix
```

After fixing the code:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    count = mkOption {
      type = types.int;
      default = 5;  # Correct type
    };
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;  # Valid attribute
  };
}
```
