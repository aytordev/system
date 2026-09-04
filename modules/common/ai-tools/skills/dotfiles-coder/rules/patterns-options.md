## Options Namespace & Design

**Impact:** CRITICAL

ALL options must be under the `aytordev.*` namespace. Use `lib.mkOption` for option definitions. Use `mkEnableOption` for enable flags. Access user context via `config.aytordev.user`.

**Incorrect (Global Namespace):**

```nix
{ config, lib, ... }:
{
  # Pollutes the global namespace
  options.programs.myApp.customSetting = lib.mkOption {
    type = lib.types.str;
    default = "value";
    description = "My custom setting";
  };

  # Hardcoded user values
  config.programs.git.userName = "aytordev";
}
```

**Correct (aytordev Namespace):**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.myApp;
  user = config.aytordev.user;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "My App";
    userName = lib.mkOption {
      type = lib.types.str;
      default = user.fullName;
      description = "Display name";
    };
  };

  config = mkIf cfg.enable {
    programs.git.userName = cfg.userName;
    programs.git.userEmail = user.email;
  };
}
```
