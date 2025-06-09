# 🔍 Checks

This directory contains Nix expressions for various system checks that ensure code quality and correctness in the repository.

## 📁 Directory Structure

```
checks/
├── default.nix    # Main entry point combining all checks
├── eval.nix      # Nix expression evaluation checks
└── format.nix    # Code formatting checks with alejandra
```

## 🎯 Purpose

The checks defined in this directory are automatically run during CI/CD pipelines and can also be executed locally to verify the health of the Nix expressions and configurations.

## 🛠️ Available Checks

### `eval.nix`
Verifies that all Nix expressions in the repository can be evaluated successfully. This ensures that the Nix code is syntactically correct and all references are valid.

### `format.nix`
Checks that all Nix files in the repository are properly formatted according to the project's style guidelines using `alejandra`.

### `default.nix`
The main entry point that combines all available checks into a single attribute set for easy execution.

## 💻 Usage

### Run All Checks
```bash
nix flake check
```

### Run a Specific Check
```bash
# Example: Run format check for x86_64-linux
nix build .#checks.x86_64-linux.format
```

### Example: Check Formatting
```bash
# Check formatting without applying changes
nix build .#checks.$(uname -m)-linux.format
```

## ➕ Adding New Checks

1. Create a new `.nix` file in this directory with your check logic
2. Import and add it to the `allChecks` set in `default.nix`
3. Document the check in this README with:
   - Purpose and behavior
   - Example usage
   - Any dependencies or requirements

## 📦 Dependencies

- [Nix](https://nixos.org/) (≥ 2.4)
- [alejandra](https://github.com/kamadorueda/alejandra) (≥ 3.0.0, for formatting)

## 🔗 Related Documentation

- [Development Shells](../dev-shells/README.md) - For setting up the development environment
- [Outputs](../outputs/README.md) - For understanding how checks integrate with the build system
