## Host & User Customization

**Impact:** MEDIUM

Host configs live in `systems/{arch}/{hostname}/`. User configs live in `homes/{arch}/{user@host}/`. This enables per-host hardware config and per-user-per-host customization at the highest priority levels.

**Incorrect (Host Logic in Modules):**

```nix
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
{
  config = lib.mkIf config.aytordev.programs.terminal.tools.git.enable {
    # BAD: checking hostname inside a generic module
    programs.git.signing.key =
      if config.networking.hostName == "wang-lin"
      then "key-for-wang-lin"
      else "key-for-other";
  };
}
```

**Correct (Layered Configs):**

```nix
# Module provides overridable defaults
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.terminal.tools.git;
  user = config.aytordev.user;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      userName = lib.mkDefault user.fullName;
      userEmail = lib.mkDefault user.email;
    };
  };
}

# Host-specific override at the correct layer
# homes/aarch64-darwin/aytordev@wang-lin/default.nix
# { ... }:
# {
#   programs.git.signing.key = "key-for-wang-lin";
# }
```
