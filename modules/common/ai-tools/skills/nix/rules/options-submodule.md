## Submodule Pattern

**Impact:** HIGH

Use `types.submodule` for complex nested configurations (like creating a list of accounts or services with their own options).

**Incorrect (Attrs of attrs):**

```nix
{
  config,
  lib,
  ...
}:
{
  options.users = lib.mkOption {
    # Wrong: No validation on inner structure
    type = lib.types.attrsOf lib.types.attrs;
    default = { };
  };

  config = {
    # Can't validate uid is a number, shell is valid, etc.
    users.alice = {
      uid = "not a number"; # Should fail but doesn't
      shell = 12345; # Should be path but isn't
    };
  };
}
```

**Correct (Submodule):**

```nix
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  userModule = types.submodule {
    options = {
      uid = mkOption {
        type = types.int;
        description = "User ID";
      };

      shell = mkOption {
        type = types.path;
        default = /bin/bash;
        description = "User shell";
      };

      groups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional groups";
      };

      isAdmin = mkOption {
        type = types.bool;
        default = false;
        description = "Whether user has admin privileges";
      };
    };
  };
in
{
  options.users = mkOption {
    type = types.attrsOf userModule;
    default = { };
    description = "User configurations";
    example = {
      alice = {
        uid = 1000;
        shell = /bin/zsh;
        groups = [
          "wheel"
          "docker"
        ];
        isAdmin = true;
      };
    };
  };

  config = {
    # Now fully validated!
    users.alice = {
      uid = 1000;
      shell = /bin/zsh;
      groups = [ "wheel" ];
      isAdmin = true;
    };
  };
}
```
