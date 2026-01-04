---
name: nix-naming
description: "Nix naming conventions and code style. Use when naming variables, files, or organizing attributes in Nix code."
---

# Naming Conventions

## Quick Reference

| Element     | Style      | Examples                            |
| ----------- | ---------- | ----------------------------------- |
| Variables   | camelCase  | `cfg`, `userName`, `enableFeature`  |
| Files/dirs  | kebab-case | `my-module.nix`, `window-managers/` |
| Constants   | UPPER_CASE | `MAX_RETRIES`, `DEFAULT_PORT`       |
| Cfg pattern | Always use | `cfg = config.namespace.module;`    |

## Variables

```nix
let
  # Correct - camelCase
  userName = "khaneliman";
  serverHostname = "myserver";
  enableAutoStart = true;

  # Wrong
  user_name = "...";      # snake_case
  UserName = "...";       # PascalCase
in
```

## The cfg Pattern

Always use this pattern:

```nix
let
  cfg = config.aytordev.applications.myApp;
in
{
  config = lib.mkIf cfg.enable { ... };
}
```

## File Naming

```
# Correct - kebab-case
modules/home/applications/my-app/default.nix
modules/nixos/services/my-service.nix

# Wrong
modules/home/applications/myApp/default.nix   # camelCase
modules/nixos/services/my_service.nix    # snake_case
```

## Attribute Organization

Group by function, then alphabetical:

```nix
{
  # Options first
  options.namespace.module = { ... };

  # Config second
  config = {
    # Group related settings
    applications.git = { ... };
    applications.vim = { ... };

    # Then packages
    home.packages = [ ... ];
  };
}
```

## Formatting

- Use `nixfmt` for consistent formatting
- Prefer flat dot-notation: `services.nginx.enable = true`
- Avoid deep nesting when flat works
