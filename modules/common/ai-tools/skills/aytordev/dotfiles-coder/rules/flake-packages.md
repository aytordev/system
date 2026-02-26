## Package List Convention

**Impact:** MEDIUM

For 2+ packages use `with pkgs;` for readability. For a single package use explicit `pkgs.name`. This avoids unnecessary `with` scope while keeping multi-package lists clean.

**Incorrect (Inconsistent):**

```nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aytordev.dev.enable {
    # Verbose for many packages
    home.packages = [
      pkgs.git
      pkgs.ripgrep
      pkgs.fd
      pkgs.jq
      pkgs.yq
      pkgs.htop
    ];
  };
}
```

**Correct (Contextual with):**

```nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aytordev.dev.enable {
    # 2+ packages: use with pkgs for cleanliness
    home.packages = with pkgs; [
      git
      ripgrep
      fd
      jq
      yq
      htop
    ];

    # Single package: explicit prefix
    programs.editor.package = pkgs.neovim;
  };
}
```
