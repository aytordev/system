## Automated Tools

**Impact:** CRITICAL

Use `nixfmt`, `statix`, and `deadnix` to maintain code health. Integrate them via `treefmt` or `pre-commit` hooks to prevent bad code from entering the repo.

**Incorrect (Unformatted Code):**

Committing code with inconsistent indentation or unused variables.

```nix
{config,lib,pkgs,...}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg=config.aytordev.example.module;
  # Unused variable
  unused = "this is never used";
in {
  options.aytordev.example.module={
    enable=mkEnableOption "example module";
  };

  config=mkIf cfg.enable {
    # Inconsistent spacing and formatting
    programs.git.enable=true;
      programs.bash.enable =  true;
  };
}
```

**Correct (Automated Pipeline):**

Use automated tools to catch formatting and code quality issues.

```bash
# Format all nix files
nixfmt --check .

# Check for linter warnings and antipatterns
statix check .

# Find and remove unused code
deadnix .

# Or use treefmt for all-in-one formatting
treefmt --check --fail-on-change

# Add to CI pipeline
nix flake check

# Set up pre-commit hooks
pre-commit install
```

After formatting, the code becomes:

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
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;
    programs.bash.enable = true;
  };
}
```
