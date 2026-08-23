# Home Manager User Configuration

User-space configuration using Home Manager. These modules configure user
programs, dotfiles, and user services.

## Core Principle: Home-First

**Prefer home modules over system modules whenever possible.** User-space
configuration is:

- Easier to test (no sudo required)
- More portable across systems
- Faster to apply changes
- Better for multi-user systems

Only use system modules when you need root privileges or system-level
configuration.

## Module Contract V1

- Capability modules own one program or user service. They expose `enable` and
  `package`, then guard all outputs with `lib.mkIf`.
- Suites compose capabilities with `lib.mkDefault`. Every suite flag must change
  a real output; remove flags with no consumer.
- Foundational modules publish identity or shared metadata only. Workflow
  packages, aliases, and application choices belong in suites.
- Pure-data modules have no activation side effects and do not need an `enable`
  option. `aytordev.theme` is the reference pattern.
- Platform-only outputs use explicit `pkgs.stdenv.hostPlatform.isDarwin` or
  `isLinux` guards.
- Large capabilities may use contained sibling files, but the directory's
  `default.nix` remains the only discovered module and owns the option namespace.

For the full contract and runtime rules, see
`docs/decisions/0008-module-contract-v1.md`.

## Module Categories

### programs (`programs/`)

Application configuration and dotfiles. **This is the largest category.**

#### Terminal programs (`programs/terminal/`)

CLI tools and terminal programs.

**Key categories:**

- **Shells:** bash, zsh, fish, nushell
- **Multiplexers:** tmux, zellij
- **Editors:** neovim, helix, emacs
- **Tools:** git, gh, lazygit, fzf, ripgrep, bat, eza, zoxide
- **Development:** direnv, devenv, language servers
- **File managers:** yazi, ranger, lf
- **Monitoring:** btop, htop, bottom

**Pattern:**

```nix
aytordev.programs.terminal.tools.{tool}.enable = true;
aytordev.programs.terminal.editors.{editor}.enable = true;
aytordev.programs.terminal.shells.{shell}.enable = true;
```

#### Desktop programs (`programs/desktop/`)

GUI programs and desktop programs.

**Key categories:**

- **Browsers:** firefox, chrome, chrome-dev
- **Communication:** thunderbird, discord, slack
- **Editors:** vscode, antigravity, zed, neovim
- **Launchers:** alfred, raycast
- **Security:** bitwarden
- **Bar/clipboard/window tooling:** sketchybar, mac-mouse-fix, alt-tab (macOS)

**macOS desktop:** on `aarch64-darwin`, desktop programs are macOS GUI apps
rather than Linux compositor components.

**Pattern:**

```nix
aytordev.programs.desktop.browsers.firefox.enable = true;
aytordev.programs.desktop.editors.vscode.enable = true;
```

### Services (`services/`)

User services and daemons (launchd agents or systemd user units).

**Available services:**

- `jankyborders`: macOS window border highlighting
- `protonmail-bridge`: Proton Mail bridge daemon

**Pattern:**

```nix
aytordev.services.{service}.enable = true;

# Creates a platform-appropriate user unit.
```

### Suites (`suites/`)

Bundled configurations for workflows.

**Available:**

- `common`: Essential user tools (git, shell, editor)
- `desktop`: Desktop programs and services
- `development`: Development workflow
- `networking`: VPN and network tooling
- `business`: Business programs
- `social`: Communication apps

**Pattern:**

```nix
aytordev.suites.development.enable = true;
# Enables: git, gh, neovim, language servers, direnv, etc.
```

### Theme (`theme/`)

Theming and visual customization.

The pure-data theme module publishes the active Kanagawa palette and application
theme names. Select `aytordev.theme.variant`; there is no `theme.enable` switch.
Capabilities consume the shared palette and may expose a module-specific
override when an application needs one.

### System (`system/`)

User-level system configuration.

**Modules:**

- `xdg`: XDG base directory specification
- `input`: Keyboard/mouse user preferences (complement to system-level)

### User (`user/`)

User identity metadata only. Workflow preferences belong in suites or program
capabilities.

**Example:**

```nix
aytordev.user = {
  name = "username";
  email = "username@example.com";
  fullName = "Example User";
};
```

## Configuration Patterns

### Option Structure

All home options follow:

```
aytordev.{category}.{subcategory}.{program}.{option}
```

**Examples:**

```nix
aytordev.programs.terminal.shells.zsh.enable = true;
aytordev.programs.desktop.bars.sketchybar.enable = true;
aytordev.services.jankyborders.enable = true;
```

### Enable Patterns

Three common patterns for enabling features:

**1. Simple enable:**

```nix
aytordev.programs.terminal.tools.git.enable = true;
```

**2. Suite enable (bundles multiple programs):**

```nix
aytordev.suites.development.enable = true;
# Implicitly enables: git, neovim, direnv, etc.
```

**3. Conditional enable:**

```nix
aytordev.programs.desktop.bars.sketchybar.enable =
  lib.mkIf config.aytordev.programs.desktop.window-manager-system.aerospace.enable true;
```

### XDG Configuration Files

Use `xdg.configFile` for application configs:

```nix
xdg.configFile."app/config.toml".source = ./config.toml;

# Or generate from Nix:
xdg.configFile."app/config.json".text = builtins.toJSON {
  setting = "value";
};
```

### Dotfile Management

**Prefer built-in Home Manager modules when available:**

```nix
# Good: Use programs.git
programs.git.enable = true;
programs.git.userName = "username";

# Bad: Manual dotfile copying
home.file.".gitconfig".source = ./gitconfig;
```

**Only use manual dotfiles for:**

- Apps without Home Manager modules
- Complex configs better managed as files
- Configs shared across multiple machines

### Shell Integration

Many tools integrate with shells:

```nix
programs.zoxide.enable = true;
programs.zoxide.enableZshIntegration = true;
programs.zoxide.enableBashIntegration = true;
```

**Pattern:** Always enable shell integrations when available.

## Application-Specific Patterns

### Window Management (aerospace)

macOS uses a tiling window manager:

```nix
aytordev.programs.desktop.window-manager-system.aerospace.enable = true;
```

### Status Bar (sketchybar)

Sketchybar is configured through Home Manager:

```nix
aytordev.programs.desktop.bars.sketchybar.enable = true;
```

### Terminal Emulators

Terminal emulators (ghostty, etc.) should:

- Use theme from `aytordev.theme.appTheme`
- Configure fonts from the shared palette
- Enable shell integration where available

## Testing Home Changes

```bash
# Build without switching
nix build .#homeConfigurations.${user}@${host}.activationPackage

# Switch to new config
home-manager switch --flake .#${user}@${host}

# Or use the wrapper (if configured)
home-manager switch
```

## Common Gotchas

1. **File collisions:** Multiple modules writing to same XDG config file. Use
   `lib.mkMerge` or priorities.
2. **Service ordering:** User services may start before system services are
   ready. Use `After=` directives.
3. **Theme inconsistency:** Ensure all themed apps use the same theme source
   (`config.aytordev.theme`).
4. **Shell rc files:** Don't mix manual and managed shell configs - choose one
   approach.
5. **Dotfile links:** Home Manager creates symlinks to /nix/store - don't expect
   to edit them in place.

## When to Create New Modules

Create a new module when:

- Configuring an application not covered by existing modules
- Building a reusable configuration pattern
- Grouping related configuration options

**Module template:**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.category.program;
in
{
  options.aytordev.programs.category.program = {
    enable = mkEnableOption "program description";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.program ];

    xdg.configFile."program/config".source = ./config;
  };
}
```
