# 🖥️ Supported Systems

This directory contains system configurations for different architectures and operating systems supported by this repository. Each subdirectory represents a specific system architecture and contains the necessary configurations for that platform.

## 📁 Directory Structure

```
supported-systems/
├── aarch64-darwin/      # Apple Silicon (M1/M2) Macs
│   ├── default.nix     # System entry point and module loader
│   └── src/            # Host-specific configurations
│       └── wang-lin.nix # Configuration for host 'wang-lin'
└── x86_64-linux/        # 64-bit Intel/AMD Linux systems
    └── ...
```

## 🎯 Purpose

The `supported-systems` directory provides a modular way to organize system configurations by architecture and host. This structure allows for:

- Clear separation of concerns between different architectures
- Easy addition of new hosts and architectures
- Reuse of common configurations through the module system
- Simplified maintenance and updates

## 🏗️ Architecture Structure

Each architecture directory (e.g., `aarch64-darwin`) follows this pattern:

1. `default.nix`: The entry point that loads all host configurations
2. `src/`: Contains host-specific configuration files
   - Each `.nix` file in this directory should export a `darwinConfigurations` attribute set

## 🖥️ Adding a New Host

To add a new host, follow the instructions in the architecture-specific README for your target platform:

- [Apple Silicon (aarch64-darwin)](./aarch64-darwin/README.md#-adding-a-new-host)
- [Intel/AMD Linux (x86_64-linux)](./x86_64-linux/README.md#-adding-a-new-host)

Each architecture may have specific requirements and configurations. The host configuration will be automatically picked up by the flake's outputs once created.

## 🔄 Updating System Configurations

To update a system configuration:

```bash
# For NixOS
sudo nixos-rebuild switch --flake .#hostname

# For macOS
darwin-rebuild switch --flake .#hostname
```

## 🧩 Module System

This repository uses a modular approach to system configuration:

- **Common modules**: Shared across all systems in `modules/`
- **Architecture-specific modules**: In each architecture directory
- **Host-specific overrides**: In the host's `.nix` file

## 🛠️ Development

### Linting

```bash
# Check Nix files for common mistakes
nix flake check

# Format Nix files
nix fmt .
```

### Testing Changes

1. Test the configuration in a VM (NixOS only):
   ```bash
   nixos-rebuild build-vm --flake .#hostname
   ./result/bin/run-hostname-vm
   ```

2. Build the system configuration:
   ```bash
   nix build .#nixosConfigurations.hostname.config.system.build.toplevel
   ```

## 📚 Related Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin Manual](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)

## 🤝 Contributing

When adding new system configurations:

1. Follow the existing directory structure
2. Document any architecture-specific considerations
3. Test configurations in a VM or on a test machine before applying to production
4. Update this README if you add new architectures or make structural changes
