## Collection Types

**Impact:** HIGH

Use `listOf`, `attrsOf`, and `enum` to validate collections. `enum` is especially useful for constrained string choices.

**Incorrect (Untyped lists):**

```nix
{
  config,
  lib,
  ...
}:
{
  options.myService = {
    # Wrong: No validation on list items
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.any;
      default = [ ];
    };

    # Wrong: String instead of enum
    logLevel = lib.mkOption {
      type = lib.types.str;
      default = "info";
    };

    # Wrong: Unstructured attrs
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
```

**Correct (Typed collections):**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.myService = {
    # Validated list of packages
    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to include";
    };

    # Enum restricts to specific values
    logLevel = mkOption {
      type = types.enum [
        "debug"
        "info"
        "warn"
        "error"
      ];
      default = "info";
      description = "Logging level";
    };

    # List of specific strings
    allowedHosts = mkOption {
      type = types.listOf types.str;
      default = [ "localhost" ];
      description = "Allowed host patterns";
    };

    # Structured attrs with type validation
    environmentVars = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Environment variables for the service";
      example = {
        API_KEY = "secret";
        DEBUG = "false";
      };
    };
  };
}
```
