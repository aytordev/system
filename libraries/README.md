# 📚 System Libraries

This directory contains reusable Nix library functions and utilities for the system configuration, including macOS system management and module loading.

## 🏗️ Directory Structure

```
libraries/
├── README.md        # This file
├── default.nix      # Main library entry point
├── macos-system.nix # macOS system configuration utilities
└── relative-to-root.nix  # Path manipulation utilities
```

## 📦 Available Libraries

### `default.nix`

Main entry point for the libraries module system. Dynamically imports all `.nix` files in this directory and provides a unified interface.

#### Features
- Automatic module discovery and loading
- Strategy pattern for module-specific argument passing
- Clean public API with internal functions exposed for testing

**Example from `supported-systems/aarch64-darwin/default.nix`**:
```nix
# Load all .nix files from the src/ directory using Haumea
# This dynamically discovers all host configurations
data = haumea.lib.load {
  src = ./src; # Source directory containing host configurations
  inputs = args; # Pass through all flake inputs and other arguments
};

# Merge all darwinConfigurations from all loaded files
outputs = {
  darwinConfigurations =
    lib.attrsets.mergeAttrsList
    (map (it: it.darwinConfigurations or {}) (builtins.attrValues data));
};
```

### `macos-system.nix`

Provides utilities for creating and managing macOS system configurations using nix-darwin and home-manager.

#### Features
- Creates complete darwinSystem configurations
- Optional home-manager integration
- Input validation and type checking
- Follows SOLID principles for maintainability

**Example from `supported-systems/aarch64-darwin/src/wang-lin.nix`**:
```nix
# Module imports are organized by category
modules = {
  # System-level modules (nix-darwin configuration)
  darwin-modules = (map libraries.relativeTo [
    # Paths to system modules
  ]);

  # User-level modules (Home Manager configuration)
  home-modules = map libraries.relativeTo [
    # Paths to home-manager modules
  ];
};

# Combine modules with all other arguments
systemArgs = modules // args // {
  hostName = name;  # Current hostname
};

# The final darwin configuration for this host
darwinConfigurations.${name} = libraries.macosSystem systemArgs;
```

### `relative-to-root.nix`

Provides utility functions for working with paths relative to the repository root.

#### Functions

##### `relativeToRoot`

Creates a path relative to the repository root.

**Type**: `String -> Path`

**Example**:
```nix
{ lib, ... }:
{
  # Import a file relative to the repository root
  myModule = import (libraries.relativeToRoot "path/to/module.nix");
}
```

## 🛠 Usage

Import and use the libraries in your Nix expressions:

### Basic Usage

```nix
# In your flake.nix or system configuration
{
  # ... other flake inputs ...

  outputs = { self, nixpkgs, ... } @ inputs: {
    # Import and use the libraries
    nixosConfigurations = {
      my-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Your system configuration
        ];
      };
    };

    # macOS configuration using macosSystem
    darwinConfigurations = let
      # Import the libraries
      libraries = import ./libraries {
        inherit inputs;
        lib = nixpkgs.lib;
      };
    in {
      # Import host configurations
      wang-lin = import ./supported-systems/aarch64-darwin/src/wang-lin.nix {
        inherit libraries inputs;
        system = "aarch64-darwin";
        variables = { username = "user"; };
      };
    };
  };
}
```

### Advanced Usage

Access internal functions for testing and advanced use cases:

```nix
{ lib, inputs, ... }:
let
  libraries = import ./libraries { inherit lib inputs; };
in {
  # Access internal functions (use with caution)
  _test = libraries._internal;
}
```

## ✨ Best Practices

1. **Keep It Focused**: Each library file should have a single responsibility.
2. **Documentation**: Always document exported functions with:
   - Description
   - Type signature
   - Example usage
3. **Testing**: Add tests for new library functions in the `checks` directory.
4. **Backward Compatibility**: Maintain backward compatibility when possible.

## 🤝 Contributing

1. Create a new file for each logical group of functions
2. Follow the existing code style
3. Add comprehensive documentation
4. Include examples
5. Update this README with any new functionality

## 📜 License

This project is licensed under the terms of the [MIT License](../LICENSE).

---

📅 Last Updated: 2025-06-10

[⬆ Back to Top](#-system-libraries)
