# Skill Creator Guidelines

**Version 1.0.0**  
aytordev  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when creating,  
> maintaining, or refactoring AI agent skills. Humans may also find  
> it useful, but guidance here is optimized for automation and  
> consistency by AI-assisted workflows.

---

## Abstract

Guide for configuring theming in aytordev's system using Stylix and Catppuccin.

---

## Table of Contents

1. [Core Principles](#1-core-principles) — **CRITICAL**
   - 1.1 [Theme Hierarchy](#11-theme-hierarchy)
2. [Integration](#2-integration) — **HIGH**
   - 2.1 [Catppuccin Module Overrides](#21-catppuccin-module-overrides)
   - 2.2 [Stylix Base Configuration](#22-stylix-base-configuration)
3. [Implementation](#3-implementation) — **MEDIUM**
   - 3.1 [Manual Theme Paths](#31-manual-theme-paths)
   - 3.2 [Theme-Aware Conditionals](#32-theme-aware-conditionals)

---

## 1. Core Principles

**Impact: CRITICAL**

Hierarchy and key principles for theming.

### 1.1 Theme Hierarchy

**Impact: MEDIUM**

Understand the priority of theme configurations. Manual configuration always wins, followed by Catppuccin modules (if enabled), and finally Stylix defaults as the base.

**Incorrect:**

**Mixing Priorities without Intent**

Relying on Stylix for everything while manually hacking specific colors in random places, leading to inconsistent states.

**Correct:**

**Strict Hierarchy**

1.  **Manual theme config**: Explicit per-module settings (Highest Priority).

2.  **Catppuccin modules**: Catppuccin-specific integration (Medium Priority).

3.  **Stylix**: Base16 theming system (Lowest Priority / Default).

_Principle_: Prefer specific theme module customizations over Stylix defaults. Only drop to Stylix when no specific integration exists.

---

## 2. Integration

**Impact: HIGH**

Integrating Stylix and Catppuccin modules.

### 2.1 Catppuccin Module Overrides

**Impact: MEDIUM**

Many apps have dedicated Catppuccin modules that offer better fidelity than Stylix's generic Base16 generation. When available, prefer the native Catppuccin module and disable Stylix for that specific target.

**Incorrect:**

**Double Theming**

Enabling both Stylix and the Catppuccin module for the same app, causing conflicts or unpredictable behavior.

**Correct:**

```nix
programs.kitty = {
  enable = true;
  catppuccin.enable = true;  # Use dedicated module
};

# Explicitly disable stylix for this target
stylix.targets.kitty.enable = false;
```

**Exclusive Override**

Enable the specific module, disable the generic one.

### 2.2 Stylix Base Configuration

**Impact: MEDIUM**

Stylix provides the base theming substrate (Base16). Use it to set the global "mood" (polarity, wallpaper, base scheme).

**Incorrect:**

**Redundant Definitions**

Defining fonts and colors manually in every single module, ignoring the centralized Stylix configuration.

**Correct:**

```nix
stylix = {
  enable = true;
  image = ./wallpaper.png;
  base16Scheme = "catppuccin-mocha";
  polarity = "dark";
};
```

**Centralized Base**

Configure Stylix once to propagate defaults everywhere.

---

## 3. Implementation

**Impact: MEDIUM**

Practical implementation patterns and best practices.

### 3.1 Manual Theme Paths

**Impact: MEDIUM**

For applications without module support, rely on standard XDG paths and conditional sourcing.

**Incorrect:**

**Absolute Paths**

Linking to files outside the nix store or using non-reproducible paths.

**Correct:**

```nix
xdg.configFile."app/theme.conf".source =
  if config.stylix.polarity == "dark"
  then ./themes/dark.conf
  else ./themes/light.conf;
```

**Conditional Source**

Select the correct source file based on the system polarity.

### 3.2 Theme-Aware Conditionals

**Impact: MEDIUM**

Use `config.stylix.polarity` to drive logic for apps that need manual handling (e.g., loading different config files or setting flags based on "dark" vs "light").

**Incorrect:**

**Hardcoded Themes**

Hardcoding "dark" values in logic, requiring a code rewrite to switch to light mode.

**Correct:**

```nix
let
  isDark = config.stylix.polarity == "dark";
in
{
  # Dynamically switch theme string
  programs.bat.config.theme = lib.mkIf isDark "Catppuccin-mocha";
}
```

**Dynamic Logic**

Derive state from `config.stylix.polarity` using standard lib functions.

---

