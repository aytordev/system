# Nix Guidelines

**Version 1.0.0**  
nix  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when creating,  
> maintaining, or refactoring AI agent skills. Humans may also find  
> it useful, but guidance here is optimized for automation and  
> consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide for writing idiomatic, performant Nix code. Covers code style, module system, option types, conditional configuration, overlays, flakes, validation, and performance optimization.

---

## Table of Contents

1. [Code Style](#1-code-style) — **CRITICAL**
   - 1.1 [Attribute Organization](#11-attribute-organization)
   - 1.2 [Avoid High-Scope With](#12-avoid-high-scope-with)
   - 1.3 [Explicit Destructuring](#13-explicit-destructuring)
   - 1.4 [File Naming](#14-file-naming)
   - 1.5 [Inherit Pattern](#15-inherit-pattern)
   - 1.6 [Inline Prefix](#16-inline-prefix)
   - 1.7 [Prefer let-in over rec](#17-prefer-let-in-over-rec)
   - 1.8 [Variable Naming](#18-variable-naming)
2. [Module System](#2-module-system) — **CRITICAL**
   - 2.1 [Home Manager Module](#21-home-manager-module)
   - 2.2 [nix-darwin Module](#22-nix-darwin-module)
   - 2.3 [NixOS System Module](#23-nixos-system-module)
   - 2.4 [Standard Module Structure](#24-standard-module-structure)
3. [Option Types](#3-option-types) — **HIGH**
   - 3.1 [Basic Types](#31-basic-types)
   - 3.2 [Collection Types](#32-collection-types)
   - 3.3 [Package Options](#33-package-options)
   - 3.4 [Submodule Pattern](#34-submodule-pattern)
4. [Conditional Configuration](#4-conditional-configuration) — **HIGH**
   - 4.1 [mkIf - Conditional Config Blocks](#41-mkif---conditional-config-blocks)
   - 4.2 [mkMerge - Combine Conditionals](#42-mkmerge---combine-conditionals)
   - 4.3 [optionals - Conditional List Items](#43-optionals---conditional-list-items)
   - 4.4 [optionalString - Conditional Strings](#44-optionalstring---conditional-strings)
5. [Overlays & Overrides](#5-overlays-&-overrides) — **HIGH**
   - 5.1 [Overlay Structure](#51-overlay-structure)
   - 5.2 [Override Functions](#52-override-functions)
6. [Flakes](#6-flakes) — **HIGH**
   - 6.1 [Input Follows](#61-input-follows)
   - 6.2 [Standard Flake Structure](#62-standard-flake-structure)
7. [Validation](#7-validation) — **MEDIUM**
   - 7.1 [Automated Tools](#71-automated-tools)
   - 7.2 [Common Errors](#72-common-errors)
   - 7.3 [Manual Checks](#73-manual-checks)
8. [Performance](#8-performance) — **MEDIUM**
   - 8.1 [Build Performance](#81-build-performance)
   - 8.2 [Closure Size Minimization](#82-closure-size-minimization)

---

## 1. Code Style

**Impact: CRITICAL**

Fundamental code style rules for idiomatic Nix.

### 1.1 Attribute Organization

**Impact: MEDIUM**

Organize module attributes logically: `imports`, `options`, then `config`. Inside `config`, group settings by module. Use the `cfg` pattern.

**Incorrect: Scattered configs**

```nix
{ config, lib, pkgs, ... }:
{
  options.services.myService.enable = lib.mkEnableOption "My Service";

  home.packages = [ pkgs.git ];

  options.services.myService.port = lib.mkOption {
    type = lib.types.port;
  };

  programs.vim.enable = true;

  config = lib.mkIf config.services.myService.enable {
    home.packages = [ pkgs.curl ];
  };
}
```

**Correct: Structured**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.myService;
in
{
  imports = [
    ./submodule.nix
  ];

  options.services.myService = {
    enable = mkEnableOption "My Service";
    port = mkOption {
      type = types.port;
      default = 8080;
    };
  };

  config = mkIf cfg.enable {
    # Group related settings together
    programs.git.enable = true;
    programs.vim.enable = true;

    # Keep package lists consolidated
    home.packages = with pkgs; [
      curl
      wget
    ];

    # Service-specific config
    systemd.services.my-service = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.myService}/bin/start --port ${toString cfg.port}";
    };
  };
}
```

### 1.2 Avoid High-Scope With

**Impact: MEDIUM**

Avoid using `with lib;` at the top of a module or file. It breaks static analysis, IDE autocompletion, and makes the origin of symbols unclear. Use it ONLY for tight, single-line scopes.

**Incorrect: Global With**

```nix
{ config, lib, ... }:
with lib;
{
  # types, mkIf, etc. are now magical
  options.example = mkOption {
    type = types.str;
  };

  config = mkIf config.example.enable {
    # Where does mkIf come from? Unclear!
  };
}
```

**Correct: Safe With**

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
in
{
  options.example = mkOption {
    type = types.str;
  };

  config = mkIf config.example.enable {
    # Single-line usage for lists is acceptable
    environment.systemPackages = with pkgs; [ git vim curl ];
  };
}
```

### 1.3 Explicit Destructuring

**Impact: MEDIUM**

Always use explicit destructuring in function arguments. This makes dependencies self-documenting and tooling-friendly.

**Incorrect: Opaque Arguments**

```nix
args:
args.stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0";

  src = args.fetchurl {
    url = "https://example.com/file.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  buildInputs = [ args.openssl args.zlib ];
}
```

**Correct: Self-Documenting**

```nix
{
  stdenv,
  fetchurl,
  lib,
  openssl,
  zlib,
}:

stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0";

  src = fetchurl {
    url = "https://example.com/file.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  buildInputs = [
    openssl
    zlib
  ];

  meta = {
    description = "Example package";
    license = lib.licenses.mit;
  };
}
```

### 1.4 File Naming

**Impact: MEDIUM**

Use `kebab-case` for all files and directories. This is standard in the Nix community and avoids case-sensitivity issues on some filesystems.

**Incorrect: Camel or Snake**

```nix
# File structure:
# modules/home/myApp/default.nix
# modules/nixos/services/my_service.nix
# modules/darwin/programs/MyProgram/config.nix

# Inconsistent naming across the codebase
```

**Correct: kebab-case**

```nix
# File structure:
# modules/home/programs/my-app/default.nix
# modules/nixos/services/my-service.nix
# modules/darwin/programs/my-program/config.nix

# Consistent, readable, and avoids filesystem issues
{
  imports = [
    ./modules/home/programs/my-app
    ./modules/nixos/services/my-service
  ];
}
```

### 1.5 Inherit Pattern

**Impact: MEDIUM**

When using 3 or more `lib` functions, use `inherit (lib) ...` in a `let` block. This keeps the scope clean while reducing verbosity.

**Incorrect: Repetitive Prefixing**

```nix
{ config, lib, pkgs, ... }:
{
  options.myModule = {
    enable = lib.mkEnableOption "My Module";
    name = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
  };

  config = lib.mkIf config.myModule.enable {
    services.foo = lib.mkDefault { };
  };
}
```

**Correct: Clean Inherit**

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption mkDefault types;
in
{
  options.myModule = {
    enable = mkEnableOption "My Module";
    name = mkOption {
      type = types.str;
      default = "default";
    };
  };

  config = mkIf config.myModule.enable {
    services.foo = mkDefault { };
  };
}
```

### 1.6 Inline Prefix

**Impact: MEDIUM**

When using only 1 or 2 `lib` functions, just use the `lib.` prefix inline. It's explicit and avoids the boilerplate of a let block.

**Incorrect: Over-optimization**

```nix
{ config, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  config.foo = mkDefault "bar";
}
```

**Correct: Direct Access**

```nix
{ config, lib, ... }:
{
  config.foo = lib.mkDefault "bar";
  config.baz = lib.mkForce "qux";
}
```

### 1.7 Prefer let-in over rec

**Impact: MEDIUM**

Use `let-in` instead of `rec` attribute sets. `rec` can cause infinite recursion and shadowing issues. `let-in` provides clear separation of definitions and result.

**Incorrect: Recursive Cycle**

```nix
rec {
  x = y;
  y = x;
  # This causes infinite recursion!
}
```

**Correct: Clear Separation**

```nix
let
  version = "1.0";
  pname = "my-app";
in
{
  inherit pname version;
  fullName = "${pname}-${version}";

  # Dependencies are clear and evaluated in order
  buildCommand = "echo Building ${fullName}";
}
```

### 1.8 Variable Naming

**Impact: MEDIUM**

Use `camelCase` for standard variables and `UPPER_CASE` for constants.

**Incorrect: Mixed styles**

```nix
let
  user_name = "aytordev";
  UserName = "Aytor Dev";
  enable_auto_start = true;
  MAX_retries = 5;
in
{
  # Inconsistent naming makes code harder to read
}
```

**Correct: camelCase**

```nix
let
  userName = "aytordev";
  fullName = "Aytor Dev";
  enableAutoStart = true;
  MAX_RETRIES = 5;
  DEFAULT_PORT = 8080;
in
{
  # Clear distinction between variables and constants
  services.myapp = {
    user = userName;
    autoStart = enableAutoStart;
    maxRetries = MAX_RETRIES;
    port = DEFAULT_PORT;
  };
}
```

---

## 2. Module System

**Impact: CRITICAL**

Standard module structure and platform-specific templates.

### 2.1 Home Manager Module

**Impact: MEDIUM**

For user-level applications and dotfiles.

**Incorrect: System-level syntax**

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myApp;
in
{
  options.programs.myApp.enable = lib.mkEnableOption "My App";

  config = lib.mkIf cfg.enable {
    # Wrong: These are system-level options
    environment.systemPackages = [ pkgs.myApp ];
    networking.hostName = "my-host";
  };
}
```

**Correct: User Application**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.programs.myApp;
in
{
  options.programs.myApp = {
    enable = mkEnableOption "My App";

    theme = mkOption {
      type = types.enum [
        "light"
        "dark"
      ];
      default = "dark";
      description = "Color theme for the application";
    };
  };

  config = mkIf cfg.enable {
    # User-level package installation
    home.packages = [ pkgs.myApp ];

    # XDG configuration file
    xdg.configFile."myapp/config.toml".text = ''
      theme = "${cfg.theme}"
      auto_save = true
    '';

    # Environment variables
    home.sessionVariables = {
      MYAPP_CONFIG = "${config.xdg.configHome}/myapp/config.toml";
    };
  };
}
```

### 2.2 nix-darwin Module

**Impact: MEDIUM**

For macOS system configurations.

**Incorrect: Linux assumptions**

```nix
{ config, lib, ... }:
let
  cfg = config.system.defaults.custom;
in
{
  options.system.defaults.custom.enable = lib.mkEnableOption "macOS tweaks";

  config = lib.mkIf cfg.enable {
    # Wrong: These are Linux-specific
    services.xserver.enable = true;
    boot.loader.systemd-boot.enable = true;
  };
}
```

**Correct: MacOS Defaults**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.system.defaults.custom;
in
{
  options.system.defaults.custom = {
    enable = mkEnableOption "macOS system tweaks";

    dockAutohide = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically hide and show the Dock";
    };
  };

  config = mkIf cfg.enable {
    # macOS system defaults
    system.defaults = {
      dock = {
        autohide = cfg.dockAutohide;
        mru-spaces = false;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
      };

      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    # macOS-specific services
    services.nix-daemon.enable = true;
  };
}
```

### 2.3 NixOS System Module

**Impact: MEDIUM**

For system-level services (systemd, hardware, networking).

**Incorrect: Home-manager syntax**

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.myService;
in
{
  options.services.myService.enable = lib.mkEnableOption "My Service";

  config = lib.mkIf cfg.enable {
    # Wrong: This is Home Manager syntax
    home.packages = [ pkgs.myService ];
    xdg.configFile."myservice/config".text = "example";
  };
}
```

**Correct: Systemd Service**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.myService;
in
{
  options.services.myService = {
    enable = mkEnableOption "My Service";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/myservice";
      description = "Directory for service data";
    };
  };

  config = mkIf cfg.enable {
    # System-level package installation
    environment.systemPackages = [ pkgs.myService ];

    # System user for the service
    users.users.myservice = {
      isSystemUser = true;
      group = "myservice";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.myservice = { };

    # Systemd service definition
    systemd.services.myservice = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "myservice";
        Group = "myservice";
        ExecStart = "${pkgs.myService}/bin/myservice --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "myservice";
        WorkingDirectory = cfg.dataDir;
      };
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
```

### 2.4 Standard Module Structure

**Impact: MEDIUM**

Modules must follow the standard pattern: separate option declarations (`options`) from configuration implementation (`config`). Usage should always be guarded by a single `cfg.enable` flag.

**Incorrect: Mixing logic**

```nix
{ config, lib, pkgs, ... }:
let
  myPackage = pkgs.hello;
in
{
  # No options defined
  # No enable flag

  environment.systemPackages = [ myPackage ];

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
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.services.myapp;
in
{
  options.services.myapp = {
    enable = mkEnableOption "My Application";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };

    configFile = mkOption {
      type = types.path;
      description = "Path to configuration file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myapp ];

    systemd.services.myapp = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myapp}/bin/myapp --port ${toString cfg.port} --config ${cfg.configFile}";
        Restart = "on-failure";
      };
    };
  };
}
```

---

## 3. Option Types

**Impact: HIGH**

Selecting and defining Nix option types properly.

### 3.1 Basic Types

**Impact: MEDIUM**

Use strict types for basic options to get free validation. Use `mkEnableOption` for boolean enable flags.

**Incorrect: Loose types**

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

**Correct: Strict types**

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

### 3.2 Collection Types

**Impact: MEDIUM**

Use `listOf`, `attrsOf`, and `enum` to validate collections. `enum` is especially useful for constrained string choices.

**Incorrect: Untyped lists**

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

**Correct: Typed collections**

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

### 3.3 Package Options

**Impact: MEDIUM**

Use `lib.mkPackageOption` for options that accept a package. It automatically searches `pkgs` and generates a good default description.

**Incorrect: Manual Default**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.myEditor = {
    enable = lib.mkEnableOption "My Editor";

    # Works but verbose
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vim;
      description = "The vim package to use";
    };
  };

  config = lib.mkIf config.programs.myEditor.enable {
    environment.systemPackages = [ config.programs.myEditor.package ];
  };
}
```

**Correct: Helper**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.programs.myEditor;
in
{
  options.programs.myEditor = {
    enable = mkEnableOption "My Editor";

    # Cleaner and generates better documentation
    package = mkPackageOption pkgs "git" { };

    # Can specify alternative package names
    compiler = mkPackageOption pkgs "gcc" {
      default = "clang";
      example = "gcc13";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      cfg.compiler
    ];
  };
}
```

### 3.4 Submodule Pattern

**Impact: MEDIUM**

Use `types.submodule` for complex nested configurations (like creating a list of accounts or services with their own options).

**Incorrect: Attrs of attrs**

```nix
{
  config,
  lib,
  ...
}:
{
  options.users = lib.mkOption {
    # Wrong: No validation on inner structure
    type = lib.types.attrsOf lib.types.attrs;
    default = { };
  };

  config = {
    # Can't validate uid is a number, shell is valid, etc.
    users.alice = {
      uid = "not a number"; # Should fail but doesn't
      shell = 12345; # Should be path but isn't
    };
  };
}
```

**Correct: Submodule**

```nix
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  userModule = types.submodule {
    options = {
      uid = mkOption {
        type = types.int;
        description = "User ID";
      };

      shell = mkOption {
        type = types.path;
        default = /bin/bash;
        description = "User shell";
      };

      groups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional groups";
      };

      isAdmin = mkOption {
        type = types.bool;
        default = false;
        description = "Whether user has admin privileges";
      };
    };
  };
in
{
  options.users = mkOption {
    type = types.attrsOf userModule;
    default = { };
    description = "User configurations";
    example = {
      alice = {
        uid = 1000;
        shell = /bin/zsh;
        groups = [
          "wheel"
          "docker"
        ];
        isAdmin = true;
      };
    };
  };

  config = {
    # Now fully validated!
    users.alice = {
      uid = 1000;
      shell = /bin/zsh;
      groups = [ "wheel" ];
      isAdmin = true;
    };
  };
}
```

---

## 4. Conditional Configuration

**Impact: HIGH**

Idiomatic conditional configuration using lib functions.

### 4.1 mkIf - Conditional Config Blocks

**Impact: MEDIUM**

Use `lib.mkIf` for conditional configuration blocks. It pushes the condition down to the leaves of the configuration, allowing accurate merging. Avoid Python-style `if condition then { ... } else { ... }` for top-level config blocks, as it breaks module merging.

**Incorrect: Top-level if-else**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = lib.mkEnableOption "example module";
  };

  # This breaks merging - other modules cannot add to programs.git if this condition is false
  config = if cfg.enable then {
    programs.git.enable = true;
    programs.git.userName = "user";
  } else {
    programs.git.enable = false;
  };
}
```

Wraps the entire config set in a conditional, preventing other modules from merging into it unless the condition matches perfectly for everyone.

**Correct: mkIf**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  # This allows proper merging - other modules can still contribute to programs.git
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "user";
    };
  };
}
```

Use `lib.mkIf` to guard the configuration.

### 4.2 mkMerge - Combine Conditionals

**Impact: MEDIUM**

Use `lib.mkMerge` to combine multiple conditional blocks into a single definition. This is clearer than repeating `config = ...` multiple times or nesting if-else structures deeply.

**Incorrect: Nested spaghetti**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableGit = mkEnableOption "git support";
    enableVim = mkEnableOption "vim support";
  };

  # Hard to read with deeply nested conditionals
  config = mkIf cfg.enable (
    if cfg.enableGit then
      {
        programs.bash.enable = true;
        programs.git.enable = true;
      } // (
        if cfg.enableVim then
          { programs.vim.enable = true; }
        else
          { }
      )
    else
      { programs.bash.enable = true; }
  );
}
```

Deeply nested `mkIf` calls or split config definitions that are hard to read.

**Correct: Clean Merge**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableGit = mkEnableOption "git support";
    enableVim = mkEnableOption "vim support";
  };

  # Clean separation of concerns with mkMerge
  config = mkMerge [
    # Always enabled when module is active
    (mkIf cfg.enable {
      programs.bash.enable = true;
    })

    # Conditional git support
    (mkIf (cfg.enable && cfg.enableGit) {
      programs.git.enable = true;
    })

    # Conditional vim support
    (mkIf (cfg.enable && cfg.enableVim) {
      programs.vim.enable = true;
    })
  ];
}
```

Use `lib.mkMerge` to combine multiple conditional blocks cleanly.

### 4.3 optionals - Conditional List Items

**Impact: MEDIUM**

Use `lib.optionals` (plural) to conditionally include a list of items. It returns an empty list `[]` if the condition is false, making it safe to concatenate `++`.

**Incorrect: Ternary for lists**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableTools = mkEnableOption "development tools";
  };

  config = mkIf cfg.enable {
    # Verbose and hard to read
    home.packages = [ pkgs.coreutils ]
      ++ (if cfg.enableTools then [ pkgs.ripgrep pkgs.fd ] else [ ])
      ++ (if pkgs.stdenv.hostPlatform.isLinux then [ pkgs.strace ] else [ ]);
  };
}
```

Using if-then-else for lists is verbose and error-prone.

**Correct: optionals**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionals;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableTools = mkEnableOption "development tools";
  };

  config = mkIf cfg.enable {
    # Clean and readable with optionals
    home.packages = [
      pkgs.coreutils
    ]
    ++ optionals cfg.enableTools [
      pkgs.ripgrep
      pkgs.fd
    ]
    ++ optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.strace
    ];
  };
}
```

Use `lib.optionals` for clean conditional list concatenation.

### 4.4 optionalString - Conditional Strings

**Impact: MEDIUM**

Use `lib.optionalString` to generate a string only if a condition is true. Returns `""` otherwise. Ideal for shell scripts or config files.

**Incorrect: If-then-else null**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableAliases = mkEnableOption "shell aliases";
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      export EDITOR=vim
    ''
    # This throws type error - cannot concatenate null to string
    + (if cfg.enableAliases then ''
      alias ll='ls -la'
      alias gs='git status'
    '' else null);
  };
}
```

Using null or if-then-else for strings causes type errors.

**Correct: optionalString**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    enableAliases = mkEnableOption "shell aliases";
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      export EDITOR=vim
    ''
    + optionalString cfg.enableAliases ''
      alias ll='ls -la'
      alias gs='git status'
    '';
  };
}
```

Use `lib.optionalString` for clean conditional string concatenation.

---

## 5. Overlays & Overrides

**Impact: HIGH**

Overlay and override patterns for customizing packages.

### 5.1 Overlay Structure

**Impact: MEDIUM**

Use the `final:prev` naming convention for overlay arguments. `prev` is the original package set, `final` is the set after all overlays are applied.

**Incorrect: Deprecated names**

```nix
{
  nixpkgs.overlays = [
    # Old naming convention - deprecated
    (self: super: {
      myPackage = super.myPackage.overrideAttrs (old: {
        version = "2.0.0";
        src = super.fetchurl {
          url = "https://example.com/mypackage-2.0.0.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000";
        };
      });

      # This is confusing - which "self" are we referring to?
      customTool = super.stdenv.mkDerivation {
        name = "custom-tool";
        buildInputs = [ self.myPackage ];
      };
    })
  ];
}
```

Using `self:super` is deprecated and confusing.

**Correct: Modern Naming**

```nix
{
  nixpkgs.overlays = [
    # Modern naming convention - clear and explicit
    (final: prev: {
      myPackage = prev.myPackage.overrideAttrs (old: {
        version = "2.0.0";
        src = prev.fetchurl {
          url = "https://example.com/mypackage-2.0.0.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000";
        };
      });

      # Clear: we want the final version of myPackage (after all overlays)
      customTool = prev.stdenv.mkDerivation {
        name = "custom-tool";
        buildInputs = [
          final.myPackage  # Gets the overridden version
          prev.git         # Gets original version
        ];
      };
    })
  ];
}
```

Use `prev` to reference the unmodified package, `final` when you need the fully composed set.

### 5.2 Override Functions

**Impact: MEDIUM**

Use the right override function for the job. Never use `.overrideDerivation` (deprecated).

**Incorrect: overrideDerivation**

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # DEPRECATED - do not use overrideDerivation
      myPackage = prev.myPackage.overrideDerivation (old: {
        buildInputs = old.buildInputs ++ [ prev.newDependency ];
      });
    })
  ];
}
```

This function is deprecated and should never be used.

**Correct: override vs overrideAttrs**

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      # Use .override to change function arguments (dependencies)
      # This replaces the openssl dependency with libressl
      nginxWithLibreSSL = prev.nginx.override {
        openssl = prev.libressl;
      };

      # Use .overrideAttrs to change derivation attributes (most common)
      # This adds patches, changes build inputs, modifies build phases, etc.
      patchedNginx = prev.nginx.overrideAttrs (old: {
        # Add custom patches
        patches = (old.patches or [ ]) ++ [
          ./custom-nginx.patch
        ];

        # Add build-time dependencies
        buildInputs = old.buildInputs ++ [
          prev.pcre2
        ];

        # Modify version string
        version = "${old.version}-custom";

        # Add post-install hook
        postInstall = (old.postInstall or "") + ''
          echo "Custom nginx build" > $out/share/doc/nginx/BUILD_INFO
        '';
      });
    })
  ];
}
```

`override` changes inputs, `overrideAttrs` changes derivation attributes.

---

## 6. Flakes

**Impact: HIGH**

Nix flake structure and dependency management.

### 6.1 Input Follows

**Impact: MEDIUM**

Use `follows` to deduplicate shared inputs (typically `nixpkgs`). This reduces closure size and ensures consistency across all inputs.

**Incorrect: Duplicated Inputs**

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # BAD - home-manager brings its own nixpkgs
    # Now you have TWO nixpkgs instances, doubling evaluation time and closure size
    home-manager.url = "github:nix-community/home-manager";

    # BAD - Each input has its own nixpkgs copy
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly }: {
    # Configuration here - but with duplicated inputs
  };
}
```

Without `follows`, you get multiple copies of nixpkgs.

**Correct: Deduplicated**

```nix
{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # GOOD - home-manager follows our nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GOOD - All overlays use the same nixpkgs
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GOOD - Chain follows for nested dependencies
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly, sops-nix }: {
    # Configuration with single nixpkgs instance
  };
}
```

Always check `nix flake metadata` to audit for duplicated inputs.

### 6.2 Standard Flake Structure

**Impact: MEDIUM**

Follow the standard flake schema. Keep `description` meaningful, use `inputs.url` for all dependencies, and structure `outputs` with explicit system parameters.

**Incorrect: Hardcoded System**

```nix
{
  description = "My project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # BAD - hardcoded system breaks on other architectures
    packages.myPkg = nixpkgs.legacyPackages.x86_64-linux.hello;

    # BAD - only works on x86_64-linux
    devShells.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.git ];
    };
  };
}
```

Missing system parameter breaks multi-arch support.

**Correct: Multi-System**

```nix
{
  description = "My project flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Helper to generate attributes for all systems
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.hello;

          myApp = pkgs.stdenv.mkDerivation {
            name = "my-app";
            src = ./.;
            buildInputs = [ pkgs.git ];
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.git
              pkgs.nixpkgs-fmt
            ];
          };
        }
      );
    };
}
```

Full flake with proper system abstraction.

---

## 7. Validation

**Impact: MEDIUM**

Validating Nix code using automated tools and manual checks.

### 7.1 Automated Tools

**Impact: MEDIUM**

Use `nixfmt`, `statix`, and `deadnix` to maintain code health. Integrate them via `treefmt` or `pre-commit` hooks to prevent bad code from entering the repo.

**Incorrect: Unformatted Code**

```nix
{config,lib,pkgs,...}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg=config.aytordev.example.module;
  # Unused variable
  unused = "this is never used";
in {
  options.aytordev.example.module={
    enable=mkEnableOption "example module";
  };

  config=mkIf cfg.enable {
    # Inconsistent spacing and formatting
    programs.git.enable=true;
      programs.bash.enable =  true;
  };
}
```

Committing code with inconsistent indentation or unused variables.

**Correct: Automated Pipeline**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;
    programs.bash.enable = true;
  };
}
```

Use automated tools to catch formatting and code quality issues.

After formatting, the code becomes:

### 7.2 Common Errors

**Impact: MEDIUM**

Recognize common errors like missing semicolons, undefined variables (often missing `lib` argument), or infinite recursion in `rec` sets.

**Incorrect: Infinite Recursion**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # Infinite recursion - x depends on y, y depends on x
  settings = rec {
    x = y;
    y = x;
  };

  # Another common mistake - self-referencing in rec
  paths = rec {
    prefix = "/usr/local";
    binDir = "${prefix}/bin";
    # This creates infinite recursion
    fullPath = "${fullPath}/extra";
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.variables.PATH = paths.fullPath;
  };
}
```

Creating circular dependencies in `rec` attribute sets.

**Correct: Broken Cycle**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # Fixed - no circular dependency
  settings = {
    x = "value";
    y = "value";
  };

  # Fixed - use let binding for dependent values
  paths =
    let
      prefix = "/usr/local";
    in
    {
      inherit prefix;
      binDir = "${prefix}/bin";
      libDir = "${prefix}/lib";
      # Build path without self-reference
      fullPath = "${prefix}/bin:${prefix}/lib";
    };

  # Or avoid rec entirely by using explicit references
  otherPaths = {
    prefix = "/usr/local";
    binDir = "${otherPaths.prefix}/bin";  # Reference outer attribute
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.variables.PATH = paths.fullPath;

    # Other common error - missing semicolon
    programs.git.enable = true;  # Don't forget the semicolon

    # Undefined variable - forgot to add lib to function args
    # Would fail with: undefined variable 'lib'
    # Fix: Add lib to function arguments at top
  };
}
```

Use let bindings or fix the circular reference.

### 7.3 Manual Checks

**Impact: MEDIUM**

Use `nix eval` and `nix build --dry-run` to validate logic before pushing. This catches option type errors and evaluation failures that linters miss.

**Incorrect: Blind Push**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    # Type mismatch - will fail at evaluation
    count = lib.mkOption {
      type = lib.types.int;
      default = "not an integer";  # ERROR
    };
  };

  config = mkIf cfg.enable {
    # Referencing non-existent attribute - will fail
    programs.nonexistent.enable = true;
  };
}
```

Pushing changes without checking if the module actually evaluates.

**Correct: Dry Run**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.aytordev.example.module;
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
    count = mkOption {
      type = types.int;
      default = 5;  # Correct type
    };
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;  # Valid attribute
  };
}
```

Validate before pushing to catch evaluation errors.

After fixing the code:

---

## 8. Performance

**Impact: MEDIUM**

Optimization techniques for Nix evaluation and build performance.

### 8.1 Build Performance

**Impact: MEDIUM**

Profile evaluation and tune build parameters for your hardware.

**Incorrect: Blind Defaults**

```bash
# BAD - no profiling, no idea where time is spent
nix build .#nixosConfigurations.hostname

# BAD - default settings may not match your hardware
# Defaults to max jobs = 1, cores = all available
nix build .#nixosConfigurations.hostname

# BAD - no visibility into what's happening
nix eval .#nixosConfigurations.hostname
```

Running builds without tuning parallelism or profiling evaluation time.

**Correct: Profiled Build**

```nix
{
  nix.settings = {
    # Tune for your hardware
    max-jobs = 4;
    cores = 8;

    # Enable flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Auto-optimize store
    auto-optimise-store = true;

    # Configure substituters
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
```

Profile evaluation, tune parameters, leverage caching.

Configuration for persistent optimizations:

### 8.2 Closure Size Minimization

**Impact: MEDIUM**

Minimize closure size to reduce disk usage and deployment times. Split outputs and use minimal builders for simple scripts.

**Incorrect: Heavy Builder**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # BAD - pulls in entire stdenv (gcc, binutils, etc.) for a simple script
  myScript = pkgs.stdenv.mkDerivation {
    name = "my-script";
    buildCommand = ''
      mkdir -p $out/bin
      cat > $out/bin/hello <<'EOF'
      #!/bin/sh
      echo "Hello, World!"
      EOF
      chmod +x $out/bin/hello
    '';
  };

  # BAD - includes massive dev dependencies in runtime closure
  myPackage = pkgs.stdenv.mkDerivation {
    name = "my-package";
    buildInputs = [
      pkgs.llvm
      pkgs.clang
      pkgs.cmake
    ];
    # These are only needed at build time, not runtime!
  };
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      myScript
      myPackage
    ];
  };
}
```

Using stdenv for simple scripts pulls in unnecessary dependencies.

**Correct: Minimal Builder**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.example.module;

  # GOOD - minimal closure with writeShellApplication
  myScript = pkgs.writeShellApplication {
    name = "hello";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      echo "Hello, World!"
      date
    '';
  };

  # GOOD - split outputs to separate dev dependencies
  myPackage = pkgs.stdenv.mkDerivation {
    name = "my-package";
    outputs = [ "out" "dev" "doc" "lib" ];

    nativeBuildInputs = [
      pkgs.llvm
      pkgs.clang
      pkgs.cmake
    ];

    buildInputs = [
      # Only runtime dependencies here
      pkgs.openssl
    ];

    # Move headers to dev output
    postInstall = ''
      moveToOutput "include" "$dev"
      moveToOutput "share/doc" "$doc"
      moveToOutput "lib/*.a" "$dev"
    '';
  };

  # GOOD - use writeText for pure data files
  configFile = pkgs.writeText "myconfig.json" (builtins.toJSON {
    setting1 = "value1";
    setting2 = "value2";
  });

  # GOOD - use writers for scripts in various languages
  pythonScript = pkgs.writers.writePython3 "myscript" {
    libraries = [ pkgs.python3Packages.requests ];
  } ''
    import requests
    print(requests.get("https://example.com").text)
  '';
in
{
  options.aytordev.example.module = {
    enable = mkEnableOption "example module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      myScript
      myPackage  # Only includes 'out', not 'dev'
    ];

    environment.etc."myconfig.json".source = configFile;
  };
}
```

Minimal closure, only bash and necessary runtime dependencies.

---

