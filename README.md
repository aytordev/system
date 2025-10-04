<div align="center">
<h1>
🏗️ aytordev's Nix System Configuration
</h1>
</div>

# aytordev's Nix System Configuration

This is aytordev's comprehensive Nix-based system configuration repository, providing declarative management for both NixOS and macOS systems. The repository integrates with a private [Nix-Secrets](https://github.com/aytordev/secrets) repository to automate provisioning of private information, passwords, and keys across hosts while maintaining security and reproducibility.

This implementation follows modern Nix flakes architecture and is designed for multi-platform deployment with a focus on developer experience, security, and maintainability.

## What is Nix System Configuration?

This repository represents a complete system configuration using Nix, the purely functional package manager. It provides:

- **Declarative System Management**: Define your entire system configuration as code
- **Reproducible Environments**: Ensure consistent setups across different machines
- **Atomic Updates**: Safe system upgrades with rollback capabilities
- **Cross-Platform Support**: Unified configuration for NixOS and macOS (via nix-darwin)
- **Modular Architecture**: Reusable components and clean separation of concerns

The configuration is split into several key areas:

- **System Configurations**: Platform-specific system settings and packages
- **Home Management**: User environment configurations via Home Manager
- **Development Environments**: Pre-configured shells for different workflows
- **Secrets Management**: Secure handling of sensitive information via SOPS

## System Requirements

To work with this repository, you'll need the following tools installed:

### Core Dependencies
- **Nix Package Manager** (≥ 2.4) with flakes enabled
- **Git** - For repository management and flake inputs

### Platform Requirements
- **NixOS** - For Linux systems
- **nix-darwin** - For macOS systems  
- **Home Manager** - For user environment management

### Development Tools (Optional)
- **just** - Task runner for convenient commands
- **direnv** - Automatic environment loading
- **age/sops** - For secrets management (if using private secrets repo)

You can quickly enter a development environment with all tools:

```bash
nix develop
```

For permanent installation, the repository includes system-level package definitions.