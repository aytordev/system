## Naming Conventions

**Impact:** MEDIUM

Variables use strict camelCase. Files and directories use kebab-case. Always use `cfg = config.aytordev.{path}` pattern. Constants use UPPER_CASE in let blocks.

**Incorrect (Mixed Styles):**

```nix
# File: modules/home/programs/MyApp/Default.nix  <-- WRONG
{ config, lib, ... }:
let
  my_config = config.aytordev.programs.myApp;  # snake_case
  AppName = "My App";  # PascalCase
  max_retries = 3;  # snake_case
in
{
  options.aytordev.programs.myApp = {
    enable = lib.mkEnableOption AppName;
  };

  config = lib.mkIf my_config.enable { };
}
```

**Correct (Consistent Conventions):**

```nix
# File: modules/home/programs/terminal/tools/my-app/default.nix  <-- kebab-case
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.myApp;  # cfg pattern
  appName = "My App";  # camelCase
  MAX_RETRIES = 3;  # UPPER_CASE constant
in
{
  options.aytordev.programs.terminal.tools.myApp = {
    enable = mkEnableOption appName;
  };

  config = mkIf cfg.enable { };
}
```
