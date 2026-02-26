## Secrets Management

**Impact:** HIGH

Use `sops-nix` for secrets management. Host-specific keys are auto-discovered. Always check `sops.enable` conditionally since not all hosts have secrets configured.

**Incorrect (Unconditional Secrets):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.services.myService;
in
{
  config = lib.mkIf cfg.enable {
    # BAD: crashes on hosts without sops configured
    sops.secrets.my-api-key = {
      sopsFile = ./secrets.yaml;
    };

    services.myService.apiKeyFile = config.sops.secrets.my-api-key.path;
  };
}
```

**Correct (Conditional Secrets):**

```nix
{
  config,
  lib,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalAttrs;
  cfg = config.aytordev.services.myService;
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
in
{
  options.aytordev.services.myService = {
    enable = mkEnableOption "my service";
  };

  config = mkIf cfg.enable {
    # Only configure secrets when sops is available
    sops.secrets = optionalAttrs sopsEnabled {
      my-api-key = {
        sopsFile = ./secrets.yaml;
      };
    };

    services.myService.apiKeyFile =
      if sopsEnabled
      then config.sops.secrets.my-api-key.path
      else null;
  };
}
```
