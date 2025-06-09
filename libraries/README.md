# 📚 System Libraries

This directory contains reusable Nix library functions and utilities for the system configuration.

## 🏗️ Directory Structure

```
libraries/
├── README.md        # This file
├── default.nix      # Main library entry point
└── relative-to-root.nix  # Path manipulation utilities
```

## 📦 Available Libraries

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

Import the libraries in your Nix expressions:

```nix
{ lib, ... }:

let
  # Import the libraries
  libraries = import ./libraries { inherit lib; };

in {
  # Use the relativeToRoot function
  myPath = libraries.relativeToRoot "path/from/root";
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

📅 Last Updated: 2025-06-09

[⬆ Back to Top](#-system-libraries)
