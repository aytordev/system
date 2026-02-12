# Skill Creator Guidelines

**Version 2.0.0**  
aytordev  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when creating,  
> maintaining, or refactoring AI agent skills. Humans may also find  
> it useful, but guidance here is optimized for automation and  
> consistency by AI-assisted workflows.

---

## Abstract

Guide for consuming the centralized aytordev.theme module and its semantic palette API.

---

## Table of Contents

1. [Core Principles](#1-core-principles) — **CRITICAL**
   - 1.1 [Centralized SOT (Source Of Truth)](#11-centralized-sot-source-of-truth)
2. [Consumption](#2-consumption) — **HIGH**
   - 2.1 [App Themes & Variants](#21-app-themes--variants)
   - 2.2 [Using the Palette](#22-using-the-palette)
3. [Implementation](#3-implementation) — **MEDIUM**
   - 3.1 [Color Formats](#31-color-formats)
   - 3.2 [Polarity Logic](#32-polarity-logic)

---

## 1. Core Principles

**Impact: CRITICAL**

Centralized source of truth and provider/consumer pattern.

### 1.1 Centralized SOT (Source Of Truth)

**Impact: MEDIUM**

The `aytordev.theme` module is the single source of truth for all theming data. It abstracts the underlying theme (Kanagawa, or any future theme) and provides a unified semantic palette API for all other modules to consume. Never hardcode colors or imports in individual modules.

**Incorrect:**

**Fragmented definitions**

Importing `colors.nix` directly in module files, defining local color variables like `blue = "#..."`, or using variant-specific color names with `or` fallback chains.

**Correct:**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.theme;
in
{
  # Access semantic colors through the central config
  programs.foo.color = cfg.palette.accent.hex;
  programs.foo.errorColor = cfg.palette.red.hex;
  programs.foo.bgColor = cfg.palette.bg.sketchybar;
}
```

**Provider Consumption**

Consume `config.aytordev.theme` to access all theme data. The semantic palette provides theme-agnostic color names that work regardless of which theme or variant is active.

---

## 2. Consumption

**Impact: HIGH**

Consuming the palette, variants, and application-specific theme names.

### 2.1 App Themes & Variants

**Impact: MEDIUM**

For applications that need a named theme (e.g., "Kanagawa Wave" vs "kanagawa-wave"), use the convenience accessors in `config.aytordev.theme.appTheme`. For apps that need both dark and light theme names, use `appThemeLight`.

**Incorrect:**

**String Interpolation**

Manually constructing theme names like `"Kanagawa ${config.aytordev.theme.variant}"`.

**Correct:**

```nix
# Active theme name in various formats
theme = config.aytordev.theme.appTheme.capitalized;  # "Kanagawa Wave"
theme = config.aytordev.theme.appTheme.kebab;         # "kanagawa-wave"
theme = config.aytordev.theme.appTheme.underscore;     # "kanagawa_wave"
theme = config.aytordev.theme.appTheme.raw;            # "kanagawa/wave" (for plugin paths)

# Light variant name (for apps needing both dark and light)
lightTheme = config.aytordev.theme.appThemeLight.capitalized;  # "Kanagawa Lotus"
```

**Standardized Names**

Use the pre-calculated formats provided by the module.

### 2.2 Using the Palette

**Impact: MEDIUM**

The palette is exposed at `config.aytordev.theme.palette`. It provides 26 semantic colors that are resolved based on the active theme and variant. Always use semantic color names (`red`, `green`, `accent`, `bg`, etc.) — never reference theme-specific color names (like `autumnRed`, `dragonBlue`, `lotusGreen`).

**Incorrect:**

**Variant-specific fallback chains**

Using `palette.autumnRed or palette.dragonRed or palette.lotusRed` or switching on variants inside modules.

**Correct:**

```nix
# BAD — theme-specific, breaks with other themes
color = (palette.autumnRed or palette.dragonRed or palette.lotusRed).hex;

# BAD — manual variant switching
color = if config.aytordev.theme.variant == "lotus" then "#..." else "#...";

# GOOD — semantic palette access
color = config.aytordev.theme.palette.red.hex;
```

**Semantic Access**

Trust `theme.palette` to provide the correct color for any theme/variant combination.

Available semantic colors: `bg`, `bg_dim`, `bg_gutter`, `bg_float`, `bg_visual`, `fg`, `fg_dim`, `fg_reverse`, `accent`, `accent_dim`, `border`, `selection`, `overlay`, `red`, `red_bright`, `red_dim`, `green`, `yellow`, `yellow_bright`, `blue`, `blue_bright`, `orange`, `violet`, `pink`, `cyan`, `transparent`.

Each color provides four formats: `.hex`, `.rgb`, `.sketchybar`, `.raw`.

---

## 3. Implementation

**Impact: MEDIUM**

Using library helpers and handling polarity logic.

### 3.1 Color Formats

**Impact: MEDIUM**

Each color in the semantic palette provides four output formats: `.hex` (`#RRGGBB`), `.rgb` (`rgb(r, g, b)`), `.sketchybar` (`0xffRRGGBB`), and `.raw` (`RRGGBB`). Use the appropriate format for your target application instead of manual string manipulation.

**Incorrect:**

**String Manipulation**

Manually replacing `#` with `0xff` or extracting RGB components from hex strings.

**Correct:**

```nix
let
  palette = config.aytordev.theme.palette;
in
{
  # Each color has all four formats
  hexColor = palette.accent.hex;         # "#7e9cd8"
  sketchyColor = palette.accent.sketchybar; # "0xff7e9cd8"
  rgbColor = palette.accent.rgb;         # "rgb(126, 156, 216)"
  rawColor = palette.accent.raw;         # "7e9cd8"
}
```

**Built-in Formats**

Access the pre-computed format directly from the palette.

### 3.2 Polarity Logic

**Impact: MEDIUM**

When you explicitly need to know if the theme is light or dark (e.g. for boolean flags), use `config.aytordev.theme.isLight`. This is derived from the active variant's metadata — each variant declares whether it's light or dark.

**Incorrect:**

**Fragile Checks**

Checking variant names directly to determine polarity (e.g., `variant == "lotus"`).

**Correct:**

```nix
programs.bat.config = {
  # Some apps need a boolean flag for light mode
  "--light" = lib.mkIf config.aytordev.theme.isLight;
};
```

**Computed Boolean**

Use the robust computed value.

---

