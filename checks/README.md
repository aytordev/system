# 🔍 System Checks

This directory contains Nix expressions for various system checks that ensure code quality, formatting, and correctness across the repository. The checks are organized in a modular way, with each check in its own subdirectory.

## 📁 Directory Structure

```
checks/
├── default.nix    # Main entry point that discovers and imports all checks
├── README.md      # This documentation
├── deadnix/       # Dead code detection for Nix
│   └── default.nix
├── eval/          # Nix expression evaluation checks
│   └── default.nix
├── format/        # Code formatting checks
│   └── default.nix
└── statix/        # Linting and code quality
    └── default.nix
```

## 🎯 Purpose

These checks are automatically run during CI/CD pipelines and can be executed locally to verify the health of the Nix expressions and configurations. They help maintain code quality and catch issues early.

## 🛠️ Available Checks

### `format`
Verifies that all Nix files in the repository follow the project's formatting guidelines using `alejandra`.

### `eval`
Ensures that all Nix expressions in the repository can be evaluated successfully, checking for syntax errors and invalid references.

### `deadnix`
Identifies unused variable bindings in Nix code, helping to keep the codebase clean and maintainable.

### `statix`
Performs static analysis on Nix code to identify common issues, anti-patterns, and potential improvements.

## 💻 Usage

### Run All Checks
```bash
nix flake check
```

### Run Checks for Current System
```bash
nix build .#checks.$(uname -m)-linux.all
```

### Run a Specific Check
```bash
# Example: Run format check
nix build .#checks.$(uname -m)-linux.format

# Example: Run deadnix check
nix build .#checks.$(uname -m)-linux.deadnix
```

## ➕ Adding New Checks

1. Create a new directory for your check
2. Add a `default.nix` file that exports a derivation
3. The check will be automatically discovered and included

Example structure for a new check:
```
checks/
└── my-check/
    └── default.nix  # Must evaluate to a derivation
```

### Check Requirements
- Must be in its own subdirectory
- Must contain a `default.nix` file
- Must evaluate to a valid Nix derivation
- Should be focused on a single responsibility

## 📦 Dependencies

- [Nix](https://nixos.org/) (≥ 2.4)
- [alejandra](https://github.com/kamadorueda/alejandra) (for formatting)
- [deadnix](https://github.com/astro/deadnix) (for dead code detection)
- [statix](https://github.com/nerdypepper/statix) (for linting)

## 🔗 Related Documentation

- [Development Shells](../dev-shells/README.md) - For setting up the development environment
- [Outputs](../outputs/README.md) - For understanding how checks integrate with the build system
- [NixOS Manual](https://nixos.org/manual/nix/stable/) - For Nix language reference
