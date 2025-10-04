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

## Repository Structure

```
.
├── checks/                        # Automated quality checks and validations
│   ├── deadnix/                    # Dead code detection
│   │   └── default.nix             # Deadnix configuration
│   ├── eval/                       # Nix evaluation checks
│   │   └── default.nix             # Evaluation validation
│   ├── format/                     # Code formatting checks
│   │   └── default.nix             # Format checker setup
│   ├── statix/                     # Nix code linting
│   │   └── default.nix             # Statix linter configuration
│   └── default.nix                 # Main checks orchestration
│
├── dev-shells/                    # Development environment configurations
│   ├── default.nix                 # Development shell registry
│   ├── nix/                        # Nix development environment
│   │   └── default.nix             # Nix tooling and utilities
│   ├── node-22-lts/                # Node.js 22 LTS environment
│   │   └── default.nix             # Node.js 22 with npm/pnpm
│   └── node-24/                    # Node.js 24 environment
│       └── default.nix             # Latest Node.js with tooling
│
├── homes/                         # Home Manager configurations
│   ├── aarch64-darwin/             # macOS user configurations
│   └── README.md                   # Home Manager documentation
│
├── libraries/                     # Reusable Nix libraries and utilities
│   ├── default.nix                 # Library exports and utilities
│   └── relative-to-root/           # Path resolution helpers
│       └── default.nix             # Root-relative path functions
│
├── modules/                       # Modular system configurations
│   ├── darwin/                     # macOS-specific modules
│   ├── home/                       # Home Manager modules
│   └── shared/                     # Cross-platform shared modules
│
├── outputs/                       # Nix flake outputs configuration
│   ├── default.nix                 # Main flake outputs definition
│   └── README.md                   # Output system documentation
│
├── overlays/                      # Nixpkgs overlays and customizations
│   └── default.nix                 # Package overlays and modifications
│
├── supported-systems/             # Platform-specific system definitions
│   ├── aarch64-darwin/             # Apple Silicon Mac configurations
│   │   ├── default.nix             # Architecture entry point
│   │   ├── src/                    # Host-specific configurations
│   │   │   └── wang-lin.nix        # Individual host setup
│   │   └── README.md               # Platform documentation
│   └── README.md                   # Supported systems guide
│
├── .direnv/                       # Development environment cache
├── .gitignore                     # Git ignore patterns
├── CODE_OF_CONDUCT.md             # Community guidelines
├── CODE_STYLE.md                  # Code style and conventions
├── CONTRIBUTING.md                # Contribution guidelines
├── DEVELOPMENT.md                 # Development setup guide
├── flake.lock                     # Nix dependency lock file
├── flake.nix                      # Main flake definition
├── Justfile                       # Task runner with common commands
├── LICENSE                        # Project license (MIT)
└── README.md                      # This documentation
```

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `supported-systems/` | Platform and host-specific system configurations |
| `modules/` | Reusable system modules organized by platform |
| `homes/` | User environment configurations via Home Manager |
| `dev-shells/` | Pre-configured development environments for different workflows |
| `checks/` | Automated quality checks, linting, and validation |
| `libraries/` | Custom Nix libraries and utility functions |
| `outputs/` | Main flake outputs and system orchestration |
| `overlays/` | Package customizations and nixpkgs modifications |

### Important Files

- `flake.nix`: Central flake configuration defining inputs, outputs, and system configurations
- `Justfile`: Task runner with convenient commands for system management
- `supported-systems/*/default.nix`: Platform-specific system entry points
- `modules/`: Modular system components for different platforms
- `homes/*/`: User environment configurations
- `outputs/default.nix`: Main system outputs and configuration orchestration

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

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/aytordev/system.git
cd system
```

### 2. Review Available Systems

```bash
nix flake show
```

### 3. Build a System Configuration

```bash
# For NixOS
sudo nixos-rebuild switch --flake .#hostname

# For macOS  
just darwin-build hostname
just darwin-switch hostname
```

### 4. Enter Development Environment

```bash
# Default development shell
nix develop

# Specific development environment
nix develop .#devShells.aarch64-darwin.node-22-lts
```