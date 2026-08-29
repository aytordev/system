# Home User Configuration

Per-user Home Manager configurations. User-specific overrides only - shared
defaults belong in `modules/home/`.

## Directory Structure

```
homes/
├── x86_64-linux/
│   └── {username}@{hostname}/
│       └── default.nix
├── aarch64-darwin/
│   └── {username}@{hostname}/
│       └── default.nix
```

**Example:** `aytordev@wang-lin/default.nix`

## Basic Structure

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib.aytordev) enabled disabled;
in
{
  aytordev = {
    user = {
      enable = true;
      name = "username";
    };

    # User-specific overrides
    programs.desktop.bars.sketchybar.enable = true;

    suites = {
      common = enabled;
      desktop = enabled;
      development.enable = true;
    };

    theme.variant = "wave"; # kanagawa theme variant
  };

  home.stateVersion = "25.11";
}
```

## What Belongs Here

**User-specific configuration:**

- Username and identity
- Monitor layouts and workspace assignments
- Per-user secrets (sops paths)
- Suite selections for this user
- Program overrides specific to this user's workflow
- User-specific packages (`home.packages`)
- Email accounts, SSH keys, Git identities

**Example - User-specific overrides:**

```nix
aytordev.programs.desktop = {
  # User's window manager integration
  window-manager-system.aerospace.enable = true;

  # User's bar configuration
  bars.sketchybar.enable = true;

  # User's browser settings
  browsers.firefox = {
    enable = true;
  };
};
```

## What Does NOT Belong Here

**Shared configuration** (belongs in `modules/home/`):

- Program defaults and shared settings
- Application configurations used by multiple users
- Module implementations
- Theme definitions
- Reusable patterns

**System configuration** (belongs in `systems/`):

- Hardware settings
- System services
- Network configuration
- Boot configuration

## Common Patterns

### Minimal User

```nix
{
  aytordev = {
    user = {
      enable = true;
      name = "username";
    };
    suites.common = enabled;
  };
  home.stateVersion = "25.11";
}
```

### Power User

```nix
{
  aytordev = {
    user = {
      enable = true;
      name = "username";
    };

    programs.desktop.bars.sketchybar.enable = true;

    suites = {
      common = enabled;
      desktop = enabled;
      development = {
        enable = true;
        aiEnable = true;
        nixEnable = true;
        podmanEnable = true;
      };
      business = enabled;
      social = enabled;
    };

    theme.variant = "wave"; # kanagawa theme variant
  };

  home.stateVersion = "25.11";
}
```

### Disabling Unwanted programs

```nix
aytordev.programs.terminal = {
  # Disable tools not needed by this user
  emulators.ghostty.enable = false;
  tools.jujutsu.enable = false;
};
```

## Suites

Suites enable groups of related programs. Common suites:

- `common` - Essential CLI tools
- `desktop` - Desktop programs
- `development` - Dev tools (with aiEnable, nixEnable, podmanEnable, etc.)
- `business` - Business programs
- `networking` - Network and VPN tooling
- `social` - Communication apps

```nix
aytordev.suites = {
  common = enabled;
  development = {
    enable = true;
    aiEnable = true;
    nixEnable = true;
    podmanEnable = true;
  };
};
```

## Key Decisions

### When to add configuration to homes/ vs modules/

**Add to homes/ when:**

- User-specific value (monitor layout, personal preferences)
- Applies only to this user on this host
- User-specific secrets or identities

**Add to modules/ when:**

- Shared default for all users
- Reusable configuration pattern
- Program defaults and common settings

### State Version

Set once during initial setup, never change:

```nix
home.stateVersion = "25.11";
```

## Testing

Home-manager is integrated as a module in system configuration.

```bash
# Build without switching (macOS)
nix build .#homeConfigurations.aytordev@wang-lin.activationPackage

# Run system checks (validates all hosts + homes)
nix flake check

# Apply changes (macOS)
just darwin-switch wang-lin
```
