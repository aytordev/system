---
name: nix
description: "Comprehensive guide for writing idiomatic, performant Nix code covering code style, module system, option types, conditionals, overlays, flakes, validation, and performance."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Nix

Comprehensive guide for writing idiomatic, performant Nix code.

## Rule Categories by Priority

| Priority | Category                  | Impact   | Prefix         |
| -------- | ------------------------- | -------- | -------------- |
| 1        | Code Style                | CRITICAL | `style`        |
| 2        | Module System             | CRITICAL | `module`       |
| 3        | Option Types              | HIGH     | `options`      |
| 4        | Conditional Configuration | HIGH     | `conditionals` |
| 5        | Overlays & Overrides      | HIGH     | `overlays`     |
| 6        | Flakes                    | HIGH     | `flakes`       |
| 7        | Validation                | MEDIUM   | `validation`   |
| 8        | Performance               | MEDIUM   | `performance`  |

## Quick Reference

### 1. Code Style (CRITICAL)

- `style-no-with` - Avoid High-Scope `with`
- `style-inherit` - Use `inherit (lib)` for 3+ Functions
- `style-inline-prefix` - Use `lib.` Prefix for 1-2 Functions
- `style-let-in` - Prefer `let-in` over `rec`
- `style-destructuring` - Explicit Function Destructuring
- `style-var-naming` - camelCase Variables, UPPER_CASE Constants
- `style-file-naming` - kebab-case Files and Directories
- `style-attr-org` - Organize: imports, options, config

### 2. Module System (CRITICAL)

- `module-structure` - Standard Module Structure
- `module-home-manager` - Home Manager Module Template
- `module-darwin` - nix-darwin Module Template
- `module-nixos` - NixOS System Module Template

### 3. Option Types (HIGH)

- `options-basic` - Use Strict Basic Types
- `options-collection` - Typed Collections (listOf, attrsOf, enum)
- `options-submodule` - Submodule Pattern for Nested Config
- `options-package` - mkPackageOption Helper

### 4. Conditional Configuration (HIGH)

- `conditionals-mkif` - mkIf for Conditional Config Blocks
- `conditionals-mkmerge` - mkMerge for Combining Conditionals
- `conditionals-optionals` - optionals for Conditional Lists
- `conditionals-optionalstring` - optionalString for Conditional Strings

### 5. Overlays & Overrides (HIGH)

- `overlays-structure` - Overlay Structure (final:prev)
- `overlays-overrides` - Override Functions (override vs overrideAttrs)

### 6. Flakes (HIGH)

- `flakes-structure` - Standard Flake Structure
- `flakes-follows` - Input Follows for Deduplication

### 7. Validation (MEDIUM)

- `validation-automated` - Automated Tools (nixfmt, statix, deadnix)
- `validation-manual` - Manual Checks (nix eval, dry-run)
- `validation-errors` - Common Error Patterns

### 8. Performance (MEDIUM)

- `performance-closure` - Closure Size Minimization
- `performance-build` - Build Performance Optimization

## Full Compiled Document

Read all files in `rules/` for the complete guide with all rules expanded.
