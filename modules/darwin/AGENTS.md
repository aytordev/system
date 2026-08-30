# nix-darwin macOS Configuration

macOS-specific system configuration using nix-darwin. These modules configure
macOS system preferences and services.

## Module Contract V1

- Darwin modules are platform adapters or privileged system capabilities.
- User programs, LaunchAgents, and writes under `$HOME` belong in Home Manager.
- Capabilities expose `enable` and `package` when they own a primary package.
- Suites and archetypes compose with `lib.mkDefault`, never `lib.mkForce`.
- Keep activation scripts idempotent and limited to state that requires system
  privileges.

See `docs/decisions/0008-module-contract-v1.md` for the complete contract.

## Module Categories

### Archetypes (`archetypes/`)

System profiles for different macOS use cases.

**Available:**

- `personal`: Personal Mac configuration
- `workstation`: Development workstation setup

**Pattern:**

```nix
aytordev.archetypes.workstation.enable = true;
```

### Desktop (`programs/desktop/`)

macOS-specific desktop integration and logging.

**Modules:**

- `sketchybar`: Log rotation for the macOS status bar via newsyslog
- User-facing desktop apps (aerospace, etc.) live in Home Manager under
  `modules/home/programs/desktop/`

### Nix (`nix/`)

Nix-specific macOS configuration.

**Important modules:**

- `nix-rosetta-builder`: Use Rosetta 2 for x86_64 builds on Apple Silicon

**Pattern for Apple Silicon:**

```nix
aytordev.nix.nix-rosetta-builder.enable = true;
# Enables fast x86_64 emulation via Rosetta 2
```

### System (`system/`)

macOS system preferences and configuration.

**Modules:**

- `env`: macOS environment configuration
- `input`: Keyboard, mouse, trackpad settings
- `interface`: Dock, menu bar, finder preferences
- `networking`: Network configuration
- `logging`: System logging
- `fonts`: System fonts
- `rosetta`: Rosetta 2 setup

**Key patterns:**

```nix
# Use nix-darwin's system.defaults
system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
system.defaults.dock.autohide = true;

# Wrap in aytordev options for consistency
aytordev.system.interface.enable = true;
```

### Tools (`tools/`)

macOS-specific tools and utilities.

**Homebrew (`tools/homebrew/`):** Use Homebrew for:

- GUI apps not in nixpkgs
- Apps that require macOS-specific integration
- Apps that self-update (browsers, etc.)

**Pattern:**

```nix
aytordev.tools.homebrew.enable = true;
aytordev.tools.homebrew.casks = [ "firefox" "discord" ];
```

**Avoid Homebrew for:**

- CLI tools available in nixpkgs
- Development tools
- Things that can be managed declaratively in Nix

### Services (`services/`)

macOS-specific system services and daemons.

**Available:**

- `openssh`: SSH server
- `jankyborders`: Window border highlighting

User-facing services (launchd agents) belong in Home Manager under
`modules/home/services/`, per the home-first principle.

**Service patterns:**

```nix
# Privileged daemons remain system-owned.
aytordev.services.openssh.enable = true;
```

### Suites (`suites/`)

Bundled configurations for common macOS workflows.

**Available:**

- `common`: Essential system tools
- `desktop`: Full desktop setup
- `development`: Dev environment
- `music`: Music workflow
- `business`: Business programs
- `networking`: Network and VPN tooling

User-facing workflow suites (programs) belong in `modules/home/suites/`.

## macOS-Specific Patterns

### System Preferences

nix-darwin uses `system.defaults.*` for macOS preferences. Wrap these in
`aytordev.*` options for consistency:

```nix
# modules/darwin/system/interface/dock.nix
config = lib.mkIf cfg.enable {
  system.defaults.dock = {
    autohide = true;
    tilesize = 43;
    orientation = "left";
    persistent-apps = [
      "/System/Applications/Apps.app"
      "/Applications/Ghostty.app"
    ];
  };
};
```

> `cfg` here is `config.aytordev.system.interface` (the module owns the whole
> `interface` namespace); there is no per-app `dock.autohide` option.

### Activation Scripts

Use activation scripts only for system settings not covered by nix-darwin:

```nix
system.activationScripts.postActivation.text = ''
  # Example: Set hidden preferences
  defaults write com.apple.finder ShowPathbar -bool true
'';
```

**Caution:** Activation scripts run on every rebuild. Keep them idempotent and
never use them to create, chown, or mutate files under a user's home directory.

### SIP (System Integrity Protection)

Some tools require disabling SIP to interact with other applications. If a
module needs this, document it clearly and keep it off production machines:

```nix
# ⚠️  WARNING: This module requires SIP to be disabled
# Only use on non-production machines
```

## Cross-Platform Considerations

### Sharing with NixOS

Common configs go in `modules/common/`, macOS-specific in `modules/darwin/`.
Home Manager user config (including most user programs and services) lives in
`modules/home/`, following the home-first principle. A future `modules/nixos/`
tree would hold Linux-only system adapters; none is configured yet.

**Example: Git config**

- Git lives in Home Manager: `modules/home/programs/terminal/tools/git`

### Path Differences

macOS uses different paths:

- Home: `/Users/$USER` (not `/home/$USER`)
- Homebrew: `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)

Use `pkgs.stdenv.hostPlatform.isDarwin` for conditional logic (never the
deprecated `pkgs.stdenv.isDarwin`):

```nix
xdg.configFile."app/config".source =
  if pkgs.stdenv.hostPlatform.isDarwin
  then ./darwin-config
  else ./linux-config;
```

## Testing Darwin Changes

```bash
# Build without switching
nix build .#darwinConfigurations.${host}.system

# Build and check
nix flake check

# Apply configuration
darwin-rebuild switch --flake .#${host}

# Check for activation errors
sudo launchctl list | grep nix-darwin
```

## Common Gotchas

1. **Homebrew state:** Homebrew installs are stateful. Remove old casks manually
   if needed.
2. **Sudo password:** Some activation scripts may prompt for sudo password.
3. **SIP conflicts:** Tools requiring SIP disabled won't work on locked-down
   systems.
4. **File permissions:** macOS is strict about file permissions in certain
   directories.
5. **Rosetta 2:** Must be installed separately:
   `softwareupdate --install-rosetta`
