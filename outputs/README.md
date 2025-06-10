# 📦 System Outputs

This directory contains the main Nix flake outputs that define the system configurations, packages, and development environments for the infrastructure.

## 🏗️ System Architecture

The system uses a modular approach to manage configurations across different platforms and architectures. The key components are:

1. **System Definitions**: In `supported-systems/`, containing platform-specific configurations
2. **Shared Modules**: Reusable components in `modules/`
3. **Home Manager**: User environment configurations in `home/`
4. **Development Shells**: Pre-configured environments in `dev-shells/`

## 🧩 Core Components

### System Management

The `default.nix` implements a flexible system management approach with these features:

- **Multi-nixpkgs Support**: Multiple nixpkgs versions (stable, unstable)
- **Cross-platform**: Support for NixOS and macOS (via nix-darwin)
- **Modular Design**: Reusable configurations through modules
- **Developer Experience**: Consistent environments with development shells

### Special Arguments

A key feature is the `genSpecialArgs` function that provides:
- Access to all flake inputs
- Custom libraries and utilities
- Multiple nixpkgs versions (stable, unstable)
- System-specific configurations

## 🚀 Usage

### List Available Systems
```bash
nix flake show
```

### Build a System Configuration
```bash
# NixOS
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# macOS
nix build .#darwinConfigurations.hostname.system
```

### Enter Development Shell
```bash
# Default shell
nix develop

# Specific shell
nix develop .#devShells.x86_64-linux.just
```

## 🏗️ Output Categories

### `nixosConfigurations.*`
NixOS system configurations. Each host should have its own configuration file in `supported-systems/`.

### `darwinConfigurations.*`
macOS system configurations managed by nix-darwin.

### `devShells.*`
Development environments with all necessary tools and dependencies.

### `packages.*`
Custom Nix packages and overlays.

### `checks.*`
Automated checks for code quality and correctness.

## 🛠️ Development

### Adding a New System

1. Create a new file in `supported-systems/` (e.g., `x86_64-linux/myhost.nix`)
2. Import and use the appropriate modules
3. Add the system to the appropriate configuration set in `default.nix`

Example:
```nix
# In supported-systems/x86_64-linux/myhost.nix
{ config, pkgs, ... }: {
  # System configuration here
  system.stateVersion = "23.11";
}
```

### Using Multiple nixpkgs Versions

The configuration provides access to multiple nixpkgs versions:

```nix
# In a module or configuration
{ pkgs, pkgs-unstable, pkgs-stable, ... }: {
  environment.systemPackages = [
    pkgs.keepassxc       # From main nixpkgs
    pkgs-unstable.helix  # Latest version from unstable
    pkgs-stable.firefox  # Stable version
  ];
}
```

## 📚 Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Documentation](https://github.com/LnL7/nix-darwin)

## 🔗 Related

- [Development Shells](../dev-shells/README.md)
- [Checks](../checks/README.md)
- [Modules](../modules/README.md)
