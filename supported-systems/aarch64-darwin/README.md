# 🍏 aarch64-darwin (Apple Silicon)

This directory contains system configurations for Apple Silicon (M1/M2) Macs. The configurations are managed using [nix-darwin](https://github.com/LnL7/nix-darwin) and integrated with the main flake.

## 📁 Directory Structure

```
aarch64-darwin/
├── default.nix    # Entry point that loads all host configurations
└── src/           # Host-specific configurations
    └── wang-lin.nix  # Configuration for 'wang-lin' host
```

## 🎯 Purpose

This directory manages configurations for Apple Silicon Macs, providing:

- System-wide settings and services
- Package management through nix-darwin
- Integration with Home Manager for user environments
- Host-specific customizations

## 🛠️ Configuration Files

### `default.nix`

The entry point that uses Haumea to dynamically load all host configurations from the `src/` directory. It:

1. Imports Haumea for dynamic module loading
2. Loads all `.nix` files from `src/`
3. Merges the `darwinConfigurations` from all hosts

### `src/*.nix`

Each file in the `src/` directory represents a physical host. The filename should match the hostname (e.g., `wang-lin.nix` for host 'wang-lin').

## 🖥️ Adding a New Host

Follow these steps to add a new Apple Silicon (aarch64-darwin) host to the system:

1. **Create a new host configuration file** in the `src/` directory named after your host (e.g., `my-macbook.nix`)

2. **Use the following template** as a starting point, adjusting the `name` and configurations as needed:

   ```nix
   # src/my-macbook.nix
   {
     # Required arguments (passed by Haumea)
     inputs,
     lib,
     libraries,
     system,
     genSpecialArgs,
     ...
   } @ args: let
     # Host identifier - should match the filename (without .nix)
     name = "my-macbook";

     # Module imports organized by category
     modules = {
       # System-level modules (nix-darwin configuration)
       darwin-modules =
         (map libraries.relativeTo [
           # Common system modules
           # "modules/darwin/common.nix"
           
           # Host-specific system configuration
           # "hosts/darwin-${name}/system.nix"
         ])
         ++ [
           # Inline system configuration
           ({ config, pkgs, ... }: {
             system.stateVersion = 4;
             networking.hostName = name;
             # Add other system configurations here
           })
         ];

       # User-level modules (Home Manager configuration)
       home-modules = map libraries.relativeTo [
         # Common user modules
         # "home/common.nix"
         
         # Host-specific user configuration
         # "hosts/darwin-${name}/home.nix"
       ];
     };

     # Combine modules with all other arguments
     systemArgs = modules // args // {
       # Add any additional arguments needed by modules
       hostName = name;
     };
   in {
     # The final darwin configuration for this host
     darwinConfigurations.${name} = libraries.macosSystem systemArgs;
   }
   ```

3. **Apply the configuration** to your host:
   ```bash
   darwin-rebuild switch --flake .#my-macbook
   ```

### Key Points

- The hostname in the file (e.g., `my-macbook`) should match the filename (without .nix)
- System configurations go in `darwin-modules`
- User configurations go in `home-modules`
- Use `libraries.relativeTo` for importing modules relative to the project root
- The configuration will be automatically picked up by the flake's outputs

## 🔄 Applying Changes

To apply the configuration to a host:

```bash
darwin-rebuild switch --flake .#hostname
```

## 🧩 Module Structure

For better organization, consider this module structure:

```
hosts/
└── hostname/
    ├── default.nix    # Main system configuration
    ├── system.nix     # System packages and settings
    └── home.nix       # User environment
```

## 🛠️ Development

### Linting

```bash
# Check Nix syntax
nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt --check ."

# Format Nix files
alejandra .
```

### Testing

1. Build the configuration:
   ```bash
   nix build .#darwinConfigurations.hostname.system
   ```

2. Check for evaluation errors:
   ```bash
   nix flake check
   ```

## 📚 Related Documentation

- [nix-darwin Manual](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)

## 🤝 Contributing

When making changes:

1. Keep host-specific configurations in their respective files
2. Document any non-obvious configurations
3. Test changes before committing
4. Update this README if the structure changes
