# Shared Modules

This directory contains modules that are shared across different system types (Darwin, Linux, etc.). These modules provide common functionality and configurations that can be reused across different environments.

## Structure

- `nix/`: Nix-specific configurations and utilities that are not specific to any particular OS

## Usage

These modules are designed to be imported and used by other system configurations. They provide common functionality that can be leveraged across different environments.

## Adding New Shared Modules

1. Create a new directory for your shared functionality
2. Add a `default.nix` file that exports your module
3. Ensure your module is OS-agnostic or properly handles different operating systems
4. Document any platform-specific considerations

## Code Quality

All shared modules should follow the project's code quality standards:
- Use `alejandra` for consistent Nix formatting
- Run `statix` to catch common Nix antipatterns
- Use `deadnix` to find and remove unused code
- Include appropriate type annotations where necessary

## Best Practices

- Keep shared modules focused on a single responsibility
- Document any assumptions about the host system
- Use conditional logic to handle platform differences when necessary
- Include appropriate error messages for unsupported platforms
- Keep dependencies minimal to maintain broad compatibility
