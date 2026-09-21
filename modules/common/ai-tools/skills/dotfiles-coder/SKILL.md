---
name: dotfiles-coder
description: "aytordev configuration specialist and maintainer - knows complete module structure, patterns, and conventions"
compatibility: "Designed for aytordev/system. Needs repository file access; edits and checks require write access and a Nix-capable terminal."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Dotfiles Coder

aytordev configuration specialist and maintainer - knows complete module structure, patterns, and conventions.

These are domain facts for `aytordev/system`, not universal conventions for every
repository. Use the host's equivalent filesystem/terminal capabilities; report
missing capabilities before claiming edits or verification. `rules/` is bundled
with this skill. Paths such as `modules/`, `checks/`, and `docs/` inside the rules
refer to the target repository root, not to files beside the installed skill.

## Rule Categories by Priority

| Priority | Category           | Impact   | Prefix           |
| -------- | ------------------ | -------- | ---------------- |
| 1        | Architecture       | CRITICAL | `architecture`   |
| 2        | Code Patterns      | CRITICAL | `patterns`       |
| 3        | Flake Architecture | HIGH     | `flake`          |
| 4        | Specialization     | HIGH     | `specialization` |
| 5        | Maintenance        | MEDIUM   | `maintenance`    |

## Quick Reference

### 1. Architecture (CRITICAL)

- `architecture-discovery` - Auto-Discovery
- `architecture-layering` - Configuration Layering (ADR-0001)
- `architecture-modules` - Module Organization & Platform Separation
- `architecture-placement` - Home Module Categories

### 2. Code Patterns (CRITICAL)

- `patterns-helpers` - Helper Patterns
- `patterns-lib` - Library Usage Rules
- `patterns-module` - Standard Module Structure
- `patterns-naming` - Naming Conventions
- `patterns-options` - Options Namespace & Design
- `patterns-osconfig` - osConfig Usage

### 3. Flake Architecture (HIGH)

- `flake-inputs` - Input Management
- `flake-outputs` - Output Organization
- `flake-packages` - Package List Convention

### 4. Specialization (HIGH)

- `specialization-hosts` - Host & User Customization
- `specialization-secrets` - Secrets Management
- `specialization-themes` - Theme System

### 5. Maintenance (MEDIUM)

- `maintenance-quality` - Code Quality Tools
- `maintenance-templates` - Development Templates

## Full Compiled Document

Read all files in `rules/` for the complete guide with all rules expanded.
