# 📦 Outputs

This directory contains the main Nix flake outputs that define the system configurations, packages, and development environments provided by this repository.

## 📁 Directory Structure

```
outputs/
└── default.nix    # Primary entry point for all flake outputs
```

## 🎯 Purpose

The `outputs` directory serves as the central location for all Nix flake outputs, making it easy to discover and use the various configurations and packages defined in this repository.

## 🏗️ Main Components

### `default.nix`
The primary entry point that defines all flake outputs, including:
- System configurations for different platforms
- Development environments
- Custom packages and overlays
- CI/CD checks and formatters
- Home Manager configurations

## 💻 Usage

### List All Available Outputs
```bash
# Show tree of all available outputs
nix flake show
```

### Build a Specific Output
```bash
# Example: Build a NixOS configuration
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Example: Build a specific package
nix build .#packages.x86_64-linux.hello
```

### Enter a Development Environment
```bash
# Enter the default development shell
nix develop

# Or a specific shell
nix develop .#devShells.x86_64-linux.just
```

## 📂 Output Categories

### System Configurations (`nixosConfigurations.*`)
Pre-configured system setups for different environments and use cases.

### Development Shells (`devShells.*`)
Consistent development environments with all necessary tools and dependencies.

### Packages (`packages.*`)
Custom Nix packages and overlays for various platforms.

### Checks (`checks.*`)
Automated checks for code quality and correctness.

### Home Manager (`homeConfigurations.*`)
User environment configurations managed by Home Manager.

## ➕ Adding New Outputs

1. Add your new output to the appropriate section in `default.nix`
2. Document the new output in this README with:
   - Purpose and intended use case
   - Example usage
   - Any dependencies or requirements
3. Include any necessary tests or examples

## 📦 Dependencies

- [Nix](https://nixos.org/) (≥ 2.4)
- [nix-darwin](https://github.com/LnL7/nix-darwin) (≥ 1.11.0, for macOS configurations)
- [home-manager](https://github.com/nix-community/home-manager) (≥ 23.11, for user environment management)

## 🔗 Related Documentation

- [Checks](../checks/README.md) - For running code quality checks
- [Development Shells](../dev-shells/README.md) - For development environment setup
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - For NixOS configuration reference
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - For user environment configuration
