---
name: nix
description: "Idiomatic, performant Nix authoring (style, module system, option types, conditionals, overlays, flakes, validation) plus operational diagnosis: build failures, package/output diffing, closures and dependencies, evaluation cost, IFD, and activation verification."
compatibility: "Requires file access; operational methods need a terminal, Nix, Git, and Python 3 for the bundled report helper."
license: MIT
metadata:
  author: aytordev
  version: "1.1.0"
---

# Nix

Guide for authoring idiomatic Nix and for diagnosing Nix operations. The caller
retains lifecycle ownership: a diagnosis does not authorize code changes.

Use the host's equivalent file and terminal tools. Without those capabilities,
provide knowledge guidance and state which operational checks cannot run.
Bundled paths are relative to this skill folder; repository command examples
refer to the target checkout, not the skill's installation location.

## Operational Routing

Read only the reference that matches the requested result. These methods are
read-only until a change is authorized; load the rules below before editing.

| Requested result                                    | Read                                                                             |
| --------------------------------------------------- | -------------------------------------------------------------------------------- |
| Diagnose why a build failed                         | [Build diagnosis](references/build-diagnosis.md)                                 |
| Compare two packages or their outputs               | [Package diffing](references/package-diffing.md)                                 |
| Explain closure contents or trace a dependency      | [Closure and dependency analysis](references/closure-and-dependency-analysis.md) |
| Measure evaluation cost or validate an optimization | [Evaluation cost](references/evaluation-cost.md)                                 |
| Diagnose import-from-derivation (IFD)               | [IFD diagnosis](references/ifd-diagnosis.md)                                     |
| Verify activation or loaded runtime state           | [Activation verification](references/activation-verification.md)                 |

Authoring rules below own construction and semantic choices; evaluation cost
owns profiling, measurement, and optimization acceptance. Report the target,
exact command, observed result, and any unverified behavior.

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

## Operational References

The six references in `references/` are independently authored aytordev
documentation, written for this repository's platforms (aarch64-darwin and
x86_64-linux), `just` entry points, profile/gcroots paths, and Nix 2.35. Their
methods were inspired only at the behavior level by the unlicensed khanelinix
`nix-toolkit`, pinned at commit
`8f0ca0dbfa35c1cfc13ccf99b3edafe0f742ccfd`; no upstream text, headings,
examples, or structure is reused, so no upstream license is implicated.

The `scripts/package-diff-report.py` helper is likewise an independent local
implementation. Its only debt is the behavior-level idea: build without linking,
compare output manifests and closures, bound the report. It shares no code with
the pinned toolkit and records that design note in its module docstring.

These references are read on demand and are not compiled into the authoring
guide.

## Full Compiled Document

Read all files in `rules/` for the complete guide with all rules expanded.
