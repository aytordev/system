# Darwin System Configuration

This directory contains system-level configurations for Darwin (macOS) systems. It includes modules for customizing various system aspects while maintaining consistency across different Darwin machines.

## Structure

- `fonts/`: System font configurations and custom font installations
- `input/`: Input device configurations (keyboard, trackpad, etc.)
- `interface/`: User interface customizations (dock, menu bar, etc.)
- `networking/`: Network-related configurations and settings

## Usage

These modules are automatically included in the system configuration. To modify any system settings, edit the corresponding module in its respective subdirectory.

## Adding New Configurations

1. Create a new directory for your configuration if it doesn't fit existing categories
2. Add a `default.nix` file that exports your configuration
3. Update the parent module to import your new configuration

## Quality Checks

This module includes the following code quality tools:
- `alejandra` for Nix formatting
- `statix` for Nix linting
- `deadnix` for dead code detection

Run `nix flake check` to verify your changes pass all quality checks.
