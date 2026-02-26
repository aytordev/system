# aytordev Dotfiles Guidelines

**Version 1.0.0**  
aytordev  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when creating,  
> maintaining, or refactoring AI agent skills. Humans may also find  
> it useful, but guidance here is optimized for automation and  
> consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for the aytordev dotfiles system. Covers architecture, code patterns, options design, flake structure, secrets management, theming, and maintenance workflows.

---

## Table of Contents

1. [Architecture](#1-architecture) — **CRITICAL**
   - 1.1 [7-Level Configuration Hierarchy](#11-7-level-configuration-hierarchy)
   - 1.2 [Auto-Discovery](#12-auto-discovery)
   - 1.3 [Home Module Categories](#13-home-module-categories)
   - 1.4 [Module Organization & Platform Separation](#14-module-organization--platform-separation)
2. [Code Patterns](#2-code-patterns) — **CRITICAL**
   - 2.1 [Helper Patterns](#21-helper-patterns)
   - 2.2 [Library Usage Rules](#22-library-usage-rules)
   - 2.3 [Naming Conventions](#23-naming-conventions)
   - 2.4 [Options Namespace & Design](#24-options-namespace--design)
   - 2.5 [osConfig Usage](#25-osconfig-usage)
   - 2.6 [Standard Module Structure](#26-standard-module-structure)
3. [Flake Architecture](#3-flake-architecture) — **HIGH**
   - 3.1 [Input Management](#31-input-management)
   - 3.2 [Output Organization](#32-output-organization)
   - 3.3 [Package List Convention](#33-package-list-convention)
4. [Specialization](#4-specialization) — **HIGH**
   - 4.1 [Host & User Customization](#41-host--user-customization)
   - 4.2 [Secrets Management](#42-secrets-management)
   - 4.3 [Theme System](#43-theme-system)
5. [Maintenance](#5-maintenance) — **MEDIUM**
   - 5.1 [Code Quality Tools](#51-code-quality-tools)
   - 5.2 [Development Templates](#52-development-templates)

---

## 1. Architecture

**Impact: CRITICAL**

Module organization, platform separation, and configuration layering.

### 1.1 7-Level Configuration Hierarchy

**Impact: MEDIUM**

The system uses a strict 7-level priority hierarchy. Higher levels override lower levels. Place configuration at the correct level to maintain overridability.

**Incorrect: Wrong Level**

```nix
# Defining user-specific packages in a shared common module
# modules/common/tools/default.nix
{ pkgs, ... }:
{
  # BAD: This forces spotify on ALL users on ALL hosts
  home.packages = [ pkgs.spotify ];
  programs.git.userName = "aytordev";
}
```

**Correct: Proper Layering**

```nix
# Level 3 (module) — set overridable defaults
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.terminal.tools.git;
  user = config.aytordev.user;
in
{
  options.aytordev.programs.terminal.tools.git = {
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = lib.mkDefault user.fullName;
      userEmail = lib.mkDefault user.email;
    };
  };
}

# Level 7 (user config) — per-user-per-host overrides
# homes/aarch64-darwin/aytordev@wang-lin/default.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.spotify ];
}
```

### 1.2 Auto-Discovery

**Impact: MEDIUM**

Modules are automatically imported via `importModulesRecursive`. Never add manual imports for modules already in the discovery tree. Just place the file correctly and enable it via options.

**Incorrect: Manual Imports**

```nix
# Adding explicit imports for auto-discovered modules
{ ... }:
{
  imports = [
    ../../modules/home/programs/terminal/tools/git/default.nix
    ../../modules/home/programs/graphical/browsers/firefox/default.nix
  ];

  # These are already auto-discovered!
}
```

**Correct: Option Enablement**

```nix
# Just enable the module - it's already imported
{ ... }:
{
  aytordev.programs.terminal.tools.git.enable = true;
  aytordev.programs.graphical.browsers.firefox.enable = true;

  # Only use manual imports for modules/common/ from platform modules
}
```

### 1.3 Home Module Categories

**Impact: MEDIUM**

Organize user modules (Home Manager) into semantic categories: `programs/graphical/`, `programs/terminal/`, `services/`, `desktop/`, or `suites/`. The auto-discovery system expects this structure.

**Incorrect: Flat Structure**

```nix
# Everything dumped in modules/home/
# modules/home/firefox.nix
# modules/home/git.nix
# modules/home/yabai.nix
# No distinction between GUI, CLI, services
```

**Correct: Semantic Categories**

```nix
# modules/home/
# ├── programs/
# │   ├── graphical/        # GUI: browsers, editors, tools
# │   │   └── browsers/firefox/default.nix
# │   └── terminal/         # CLI: editors, shells, tools
# │       └── tools/git/default.nix
# ├── services/             # User services
# ├── desktop/              # Desktop environment config
# └── suites/               # Grouped functionality

# Correct: terminal tool in the right category
# modules/home/programs/terminal/tools/git/default.nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.terminal.tools.git;
in
{
  options.aytordev.programs.terminal.tools.git = {
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf cfg.enable {
    programs.git.enable = true;
  };
}
```

### 1.4 Module Organization & Platform Separation

**Impact: MEDIUM**

Modules are strictly separated by platform. Never mix platform-specific code across directories. Auto-discovery via `importModulesRecursive` means you only need to place files correctly.

**Incorrect: Mixed Platforms**

```nix
# Putting macOS config in nixos directory
# modules/nixos/services/yabai/default.nix  <-- WRONG
{ config, lib, ... }:
{
  # yabai is macOS-only, doesn't belong in nixos/
  services.yabai.enable = true;
  system.defaults.dock.autohide = true;
}
```

**Correct: Strict Isolation**

```nix
# Platform-correct placement:
# modules/nixos/   → NixOS system-level (Linux only)
# modules/darwin/  → macOS system-level (nix-darwin)
# modules/home/    → Home Manager user-space (cross-platform)
# modules/common/  → Shared functionality (imported by others)

# modules/darwin/services/yabai/default.nix  <-- CORRECT
{ config, lib, ... }:
let
  cfg = config.aytordev.services.yabai;
in
{
  options.aytordev.services.yabai = {
    enable = lib.mkEnableOption "yabai window manager";
  };

  config = lib.mkIf cfg.enable {
    services.yabai.enable = true;
  };
}
```

---

## 2. Code Patterns

**Impact: CRITICAL**

Library usage, module structure, options design, helpers, and naming conventions.

### 2.1 Helper Patterns

**Impact: MEDIUM**

Use `enabled`/`disabled` shorthands instead of `{ enable = true; }`. Use `mkOpt` instead of verbose `mkOption`. Combine with `mkDefault`/`mkForce` when needed.

**Incorrect: Verbose**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.dev;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = { enable = true; };
    programs.vim = { enable = true; };
    programs.tmux = { enable = false; };

    # Verbose option definition
    options.aytordev.programs.dev.port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Development server port";
    };
  };
}
```

**Correct: Helpers**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault mkForce;
  inherit (lib.aytordev) mkOpt enabled disabled;
  cfg = config.aytordev.programs.dev;
in
{
  options.aytordev.programs.dev = {
    enable = mkEnableOption "dev tools";
    port = mkOpt lib.types.port 8080 "Development server port";
  };

  config = mkIf cfg.enable {
    programs.git = enabled;
    programs.vim = enabled;
    programs.tmux = disabled;

    # Override patterns
    programs.bash = mkDefault enabled;   # User can override
    programs.zsh = mkForce enabled;      # Cannot override
  };
}
```

### 2.2 Library Usage Rules

**Impact: MEDIUM**

NEVER use `with lib;` — it is completely banned. For 1-2 functions use `lib.` prefix inline. For 3+ functions use `inherit (lib)`. For aytordev helpers always use `inherit (lib.aytordev)`.

**Incorrect: with lib**

```nix
{ config, lib, ... }:
with lib;
{
  # Where does mkIf come from? Unclear!
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
  };
  config = mkIf config.aytordev.foo.enable { };
}
```

**Correct: Explicit Access**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  inherit (lib.aytordev) mkOpt enabled;
  cfg = config.aytordev.foo;
in
{
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
    name = mkOpt types.str "default" "Display name";
  };

  config = mkIf cfg.enable {
    programs.bar = enabled;
  };
}
```

### 2.3 Naming Conventions

**Impact: MEDIUM**

Variables use strict camelCase. Files and directories use kebab-case. Always use `cfg = config.aytordev.{path}` pattern. Constants use UPPER_CASE in let blocks.

**Incorrect: Mixed Styles**

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

**Correct: Consistent Conventions**

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

### 2.4 Options Namespace & Design

**Impact: MEDIUM**

ALL options must be under the `aytordev.*` namespace. Use `mkOpt` for concise option definitions. Use `mkEnableOption` for enable flags. Access user context via `config.aytordev.user`.

**Incorrect: Global Namespace**

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

**Correct: aytordev Namespace**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.aytordev) mkOpt;
  cfg = config.aytordev.programs.myApp;
  user = config.aytordev.user;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "My App";
    userName = mkOpt lib.types.str user.fullName "Display name";
  };

  config = mkIf cfg.enable {
    programs.git.userName = cfg.userName;
    programs.git.userEmail = user.email;
  };
}
```

### 2.5 osConfig Usage

**Impact: MEDIUM**

Add `osConfig ? { }` to function args ONLY when a home module needs to read system configuration. Always guard access with `or` fallback to prevent eval errors when Home Manager runs standalone.

**Incorrect: Unsafe Access**

```nix
{ config, lib, osConfig, ... }:
let
  cfg = config.aytordev.programs.myApp;
in
{
  config = lib.mkIf cfg.enable {
    # Crashes if osConfig is missing (standalone HM)
    programs.myApp.sopsEnabled = osConfig.aytordev.security.sops.enable;
  };
}
```

**Correct: Guarded Access**

```nix
{
  config,
  lib,
  osConfig ? { },  # Default to empty set
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.aytordev.programs.myApp;
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
in
{
  options.aytordev.programs.myApp = {
    enable = mkEnableOption "my app";
  };

  config = mkIf cfg.enable {
    programs.myApp.extraConfig = optionalString sopsEnabled ''
      secrets-backend = sops
    '';
  };
}
```

### 2.6 Standard Module Structure

**Impact: MEDIUM**

All modules must follow the standard pattern: function args with destructuring, `let` bindings for cfg, separate `options` and `config` blocks, guard with `mkIf cfg.enable`.

**Incorrect: No Structure**

```nix
{ config, lib, pkgs, ... }:
{
  # No options, no enable guard, hardcoded values
  environment.systemPackages = [ pkgs.hello ];
  services.myapp = {
    enable = true;
    config = "hardcoded";
  };
}
```

**Correct: Standard Pattern**

```nix
{
  config,
  lib,
  pkgs,
  osConfig ? { },  # Only when home module needs system config
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.aytordev) mkOpt enabled;

  cfg = config.aytordev.{namespace}.{module};
in
{
  options.aytordev.{namespace}.{module} = {
    enable = mkEnableOption "{description}";
  };

  config = mkIf cfg.enable {
    # All configuration here
  };
}
```

---

## 3. Flake Architecture

**Impact: HIGH**

Flake-parts structure, input management, and output organization.

### 3.1 Input Management

**Impact: MEDIUM**

Inputs are categorized: core (nixpkgs, home-manager), system (hardware, sops), programs (overlays, tools). Most inputs follow `nixpkgs` via `follows`. Dev dependencies are isolated in a separate flake partition.

**Incorrect: Uncategorized Inputs**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:Mic92/sops-nix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    # No follows, no categorization, duplicated nixpkgs
  };
}
```

**Correct: Categorized with Follows**

```nix
{
  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Programs
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### 3.2 Output Organization

**Impact: MEDIUM**

Use `flake-parts` for organized outputs. System configurations use builder functions (`mkSystem`, `mkDarwin`, `mkHome`) that handle platform abstraction. Auto-discovery recursively finds systems, homes, packages, and templates.

**Incorrect: Manual Outputs**

```nix
{
  outputs = { self, nixpkgs, ... }: {
    # Hardcoded systems, no abstraction
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/my-host/configuration.nix
        ./modules/nixos/services/docker.nix
        ./modules/nixos/services/nginx.nix
        # Manually listing every module...
      ];
    };
  };
}
```

**Correct: Flake-parts with Builders**

```nix
{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      flake = {
        # Auto-discovered via recursive directory scan
        nixosConfigurations = lib.mkSystem {
          inherit inputs;
          # Modules auto-imported via importModulesRecursive
        };

        darwinConfigurations = lib.mkDarwin {
          inherit inputs;
        };

        homeConfigurations = lib.mkHome {
          inherit inputs;
        };
      };
    };
}
```

### 3.3 Package List Convention

**Impact: MEDIUM**

For 2+ packages use `with pkgs;` for readability. For a single package use explicit `pkgs.name`. This avoids unnecessary `with` scope while keeping multi-package lists clean.

**Incorrect: Inconsistent**

```nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aytordev.dev.enable {
    # Verbose for many packages
    home.packages = [
      pkgs.git
      pkgs.ripgrep
      pkgs.fd
      pkgs.jq
      pkgs.yq
      pkgs.htop
    ];
  };
}
```

**Correct: Contextual with**

```nix
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aytordev.dev.enable {
    # 2+ packages: use with pkgs for cleanliness
    home.packages = with pkgs; [
      git
      ripgrep
      fd
      jq
      yq
      htop
    ];

    # Single package: explicit prefix
    programs.editor.package = pkgs.neovim;
  };
}
```

---

## 4. Specialization

**Impact: HIGH**

Theme system, secrets management, and host/user customization.

### 4.1 Host & User Customization

**Impact: MEDIUM**

Host configs live in `systems/{arch}/{hostname}/`. User configs live in `homes/{arch}/{user@host}/`. This enables per-host hardware config and per-user-per-host customization at the highest priority levels.

**Incorrect: Host Logic in Modules**

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

**Correct: Layered Configs**

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

### 4.2 Secrets Management

**Impact: MEDIUM**

Use `sops-nix` for secrets management. Host-specific keys are auto-discovered. Always check `sops.enable` conditionally since not all hosts have secrets configured.

**Incorrect: Unconditional Secrets**

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

**Correct: Conditional Secrets**

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

### 4.3 Theme System

**Impact: MEDIUM**

`aytordev.theme` is the single source of truth for all theming. Use the semantic palette API (`cfg.palette.accent.hex`, `cfg.palette.red.rgb`). Never hardcode colors or use variant-specific color names. Use `appTheme` accessors for named themes.

**Incorrect: Hardcoded Colors**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
in
{
  config = lib.mkIf cfg.enable {
    # BAD: hardcoded colors
    programs.myApp.accentColor = "#7e9cd8";

    # BAD: variant-specific names
    programs.myApp.theme =
      if config.aytordev.theme.variant == "wave"
      then "Kanagawa Wave"
      else "Kanagawa Lotus";
  };
}
```

**Correct: Semantic Palette**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
  theme = config.aytordev.theme;
in
{
  config = lib.mkIf cfg.enable {
    programs.myApp = {
      # Semantic colors — work with any theme/variant
      accentColor = theme.palette.accent.hex;
      errorColor = theme.palette.red.hex;
      bgColor = theme.palette.bg.hex;

      # Pre-calculated theme name formats
      theme = theme.appTheme.capitalized;  # "Kanagawa Wave"

      # Polarity detection
      lightMode = theme.isLight;
    };
  };
}
```

---

## 5. Maintenance

**Impact: MEDIUM**

Code quality tools, formatting, and development workflows.

### 5.1 Code Quality Tools

**Impact: MEDIUM**

Use `treefmt` with `nixfmt`, `statix`, and `deadnix` for automated code health. Run `nix fmt` before committing. Validate builds with `nix flake check`.

**Incorrect: No Tooling**

```nix
# Committing unformatted code with unused variables
{config,lib,pkgs,...}:
let
  unused_var = "never used";
  cfg=config.aytordev.foo;
in {
  options.aytordev.foo={
    enable=lib.mkEnableOption "foo";
  };
  config=lib.mkIf cfg.enable {
      programs.git.enable=true;
  };
}
```

**Correct: Formatted & Clean**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.foo;
in
{
  options.aytordev.foo = {
    enable = mkEnableOption "foo";
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;
  };
}
```

### 5.2 Development Templates

**Impact: MEDIUM**

Use the project template system for new development environments. Templates live in `templates/` and are accessible via `nix flake init -t .#template-name`. Each template defines a devShell with appropriate tooling.

**Incorrect: Manual Shells**

```nix
# Creating ad-hoc devShells without using the template system
{
  devShells.x86_64-linux.default = pkgs.mkShell {
    buildInputs = [ pkgs.nodejs pkgs.pnpm ];
    # No structure, no reusability
  };
}
```

**Correct: Template System**

```nix
# templates/node/flake.nix
{
  description = "Node.js development template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux" "aarch64-linux" "aarch64-darwin"
      ];
    in
    {
      devShells = forEachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nodejs_22
            nodePackages.pnpm
          ];
        };
      });
    };
}
```

---

