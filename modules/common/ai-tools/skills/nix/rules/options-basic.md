## Basic Types

**Impact:** CRITICAL

Use strict types for basic options to get free validation. Use `mkEnableOption` for boolean enable flags.

**Incorrect (Loose types):**

```nix
{
  config,
  lib,
  ...
}:
{
  options.myService = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable my service";
    };

    # Wrong: Port as string
    port = lib.mkOption {
      type = lib.types.str;
      default = "8080";
    };

    # Wrong: Path as string
    configPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/config";
    };
  };
}
```

**Correct (Strict types):**

```nix
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.myService = {
    # mkEnableOption is idiomatic for boolean flags
    enable = mkEnableOption "my service";

    # Port type validates range (0-65535)
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    # Path type ensures it's a valid path
    configPath = mkOption {
      type = types.path;
      default = /etc/config;
      description = "Path to configuration file";
    };

    # Int type for numbers
    workers = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "Number of worker processes";
    };

    # Bool for explicit true/false
    enableMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Enable metrics collection";
    };
  };
}
```
