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

## First Install

This section provides a comprehensive guide for first-time installation and deployment of the system configuration. The process involves setting up encryption keys, configuring access to the private secrets repository, and deploying your system configuration.

### Prerequisites

Before beginning, ensure you have:
- A machine running NixOS or macOS with Nix installed
- Internet connection for downloading packages
- Administrative access to your system

### Step 1: Generate SSH Keys for Git Access

The secrets repository is private and requires SSH authentication. Generate an SSH key pair if you don't already have one:

```bash
# Generate a new SSH key pair
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519

# Start the SSH agent and add your key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy the public key to add to your GitHub account
cat ~/.ssh/id_ed25519.pub
```

**Why this is needed**: The private secrets repository uses SSH authentication for secure access. Without proper SSH keys configured with your GitHub account, you won't be able to clone the repository or access encrypted secrets during system builds.

Add the public key to your GitHub account under Settings → SSH and GPG keys.

### Step 2: Generate Age Keys for SOPS Encryption

Age keys are used to encrypt and decrypt secrets. You'll need both user and host keys:

```bash
# Install age if not already available
nix-shell -p age

# Generate your personal age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Display your public key (you'll need this for the secrets repository)
age-keygen -y ~/.config/sops/age/keys.txt

# Generate a host-specific age key
sudo mkdir -p /etc/sops/age
sudo age-keygen -o /etc/sops/age/keys.txt

# Display the host public key
sudo age-keygen -y /etc/sops/age/keys.txt
```

**Why this is needed**: SOPS (Secrets OPerationS) encrypts sensitive information using age encryption. Each user and host needs their own keys to decrypt secrets. The public keys are added to the `.sops.yaml` configuration in the secrets repository to grant access, while private keys remain on your local system for decryption.

### Step 3: Configure Access to Secrets Repository

Before cloning the main system repository, you need to add your public keys to the private secrets repository:

1. **Clone the secrets repository** (you'll need to be granted access first):
   ```bash
   git clone git@github.com:aytordev/secrets.git
   cd secrets
   ```

2. **Add your public keys** to `.sops.yaml`:
   ```yaml
   # Add your user and host public keys to the keys section
   keys:
     - &aytordev-user age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     - &aytordev-host age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
     - &your-user age1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz  # Your user key
     - &your-host age1wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww  # Your host key
   ```

3. **Create or update your user and host secret files**:
   ```bash
   # Create your user secrets file
   sops hard-secrets/your-username.yaml
   
   # Create your host secrets file  
   sops hard-secrets/your-hostname.yaml
   ```

4. **Test decryption** to ensure keys are working:
   ```bash
   sops -d hard-secrets/your-username.yaml
   ```

**Why this is needed**: The secrets repository maintains encrypted files that contain sensitive information like API keys, SSH keys, and passwords. Your public keys must be registered in the SOPS configuration before you can decrypt these files during system builds.

### Step 4: Clone the System Repository

Now clone this system configuration repository:

```bash
# Clone the repository
git clone https://github.com/aytordev/system.git
cd system

# Enter the development environment
nix develop
```

**Why this step is separate**: We clone the system repository after configuring secrets access because the system build process will attempt to decrypt secrets during evaluation. Having the keys configured first prevents build failures.

### Step 5: Review and Customize Configuration

Before deploying, review the configuration for your specific needs:

1. **Check available systems**:
   ```bash
   nix flake show
   ```

2. **Review platform-specific configurations**:
   ```bash
   # For macOS
   ls supported-systems/aarch64-darwin/src/
   
   # For Linux  
   ls supported-systems/x86_64-linux/src/
   ```

3. **Customize for your hardware** by either:
   - Modifying an existing host configuration
   - Creating a new host configuration (see "Adding New Systems" section)

**Why this matters**: Each host has specific hardware requirements, user preferences, and software needs. Reviewing configurations before deployment helps identify necessary customizations and prevents build failures.

### Step 6: Initial System Deployment

Deploy your system configuration:

#### For macOS (nix-darwin):
```bash
# Build the configuration first to check for errors
just darwin-build your-hostname

# If build succeeds, switch to the new configuration
just darwin-switch your-hostname

# Or with debug output if there are issues
just darwin-build your-hostname debug
just darwin-switch your-hostname debug
```

#### For NixOS:
```bash
# Build and switch in one command
just switch your-hostname

# Or with debug output for troubleshooting
just switch your-hostname debug
```

**Why this approach**: Building first without switching allows you to catch configuration errors without affecting your current system. The switch operation is atomic - if it fails, your system remains in the previous working state.

### Step 7: Verification and Post-Install

After successful deployment, verify your system:

1. **Check system information**:
   ```bash
   just system-info
   ```

2. **Verify secrets are accessible**:
   ```bash
   # Test that encrypted secrets can be read
   systemctl --user status sops-nix  # On NixOS
   ```

3. **Test development environments**:
   ```bash
   # Enter different development shells
   nix develop .#devShells.$(nix eval --impure --raw --expr 'builtins.currentSystem').nix
   ```

4. **Run quality checks**:
   ```bash
   nix flake check
   just test
   ```

**Why verification matters**: Post-install verification ensures all components are working correctly, secrets are accessible, and the system is ready for daily use. Catching issues early prevents problems during regular usage.

### Troubleshooting Common Issues

- **SSH clone failures**: Verify SSH keys are added to GitHub and SSH agent is running
- **SOPS decryption errors**: Check that your age keys are properly configured and added to `.sops.yaml`
- **Build failures**: Use debug mode (`debug` flag) and check flake inputs are up to date (`just up`)
- **Permission issues**: Ensure proper file permissions for age keys (`chmod 600 ~/.config/sops/age/keys.txt`)

### Next Steps

After successful installation:
- Explore available development environments
- Customize your user configuration via Home Manager
- Set up additional hosts using the same process
- Read the [Development Guide](DEVELOPMENT.md) for ongoing maintenance

## Common Commands

This repository includes a `Justfile` with convenient commands:

### System Management
```bash
just darwin-build wang-lin    # Build macOS configuration
just darwin-switch wang-lin   # Apply macOS configuration
just switch hostname          # Switch NixOS configuration (Linux)
```

### Development
```bash
just fmt                     # Format Nix files
just fmt-check              # Check formatting
just up                     # Update all flake inputs  
just upp nixpkgs            # Update specific input
just test                   # Run evaluation tests
```

### Maintenance
```bash
just gc                     # Garbage collect old generations
just clean                  # Clean git repository
just system-info           # Show system information
```

## Architecture Overview

### Multi-Platform Support

The repository supports multiple platforms through a unified configuration approach:

- **aarch64-darwin**: Apple Silicon Macs (M1/M2/M3)
- **x86_64-linux**: Intel/AMD Linux systems
- **Extensible**: Easy addition of new architectures

### Modular Design

Configuration is split into focused, reusable modules:

- **Platform modules**: OS-specific configurations
- **Shared modules**: Cross-platform components  
- **Home modules**: User environment settings
- **Host-specific**: Individual machine customizations

### Development Experience

- **Multiple nixpkgs versions**: Access to stable, unstable, and platform-specific packages
- **Pre-configured environments**: Ready-to-use development shells
- **Quality checks**: Automated linting, formatting, and evaluation
- **Documentation**: Comprehensive guides and examples

## Adding New Systems

### 1. Create Host Configuration

```bash
# For macOS (Apple Silicon)
touch supported-systems/aarch64-darwin/src/new-host.nix
```

### 2. Define System Configuration

```nix
# In supported-systems/aarch64-darwin/src/new-host.nix
{ config, pkgs, lib, inputs, ... }: {
  
  # Import shared modules
  imports = [
    ../../modules/darwin/default.nix
    ../../modules/shared/default.nix
  ];

  # Host-specific configuration
  networking.hostName = "new-host";
  networking.computerName = "New Host";

  # User configuration  
  users.users.username = {
    name = "username";
    home = "/Users/username";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages
  ];

  system.stateVersion = 4;
}
```

### 3. Register in Architecture Default

The configuration will be automatically discovered and registered.

### 4. Build and Switch

```bash
just darwin-build new-host
just darwin-switch new-host
```

## Secrets Management

This repository integrates with a private secrets repository for sensitive information:

- **Integration**: Automatic secrets loading via flake input
- **Security**: SOPS-based encryption with age keys
- **Separation**: Clean separation between public config and private secrets
- **Documentation**: See private repository for secrets-specific guidance

## Development Environments

Pre-configured development shells for different workflows:

### Available Shells

- **Default**: Basic development tools (git, neovim, etc.)
- **Nix**: Nix development with formatters and linters
- **Node.js 22 LTS**: Long-term support Node.js with npm/pnpm
- **Node.js 24**: Latest Node.js with modern tooling

### Usage

```bash
# Enter specific shell
nix develop .#devShells.aarch64-darwin.nix

# Or use direnv for automatic loading
echo "use flake" > .envrc
direnv allow
```

## Quality Assurance

Automated checks ensure code quality and consistency:

- **deadnix**: Detects unused Nix code
- **statix**: Nix code linting and best practices  
- **format**: Code formatting validation
- **eval**: Configuration evaluation testing

Run all checks:
```bash
nix flake check
```

## Documentation

- **[Development Guide](DEVELOPMENT.md)** - Setup and development workflow
- **[Contributing](CONTRIBUTING.md)** - How to contribute to the project
- **[Code Style](CODE_STYLE.md)** - Coding standards and conventions
- **[Outputs Guide](outputs/README.md)** - Flake outputs documentation
- **[Systems Guide](supported-systems/README.md)** - Platform-specific documentation

## Acknowledgements

This configuration is built upon the excellent work of the Nix community. Special thanks to:

### Community & Inspiration
- **[Ryan Yin](https://github.com/ryan4yin)** - For foundational configuration patterns and inspiration
- **[EmergentMinds](https://github.com/emergentminds)** - For secrets management guidance and mentorship
- **[khanneliman](https://github.com/khaneliniman)** - For innovative Nix configuration approaches and [khannelinix](https://github.com/khaneliman/khannelinix) repository inspiration

### Essential Projects
We're grateful for these projects and their maintainers:
- **[nixpkgs](https://github.com/NixOS/nixpkgs)** - The foundation of the Nix ecosystem
- **[Home Manager](https://github.com/nix-community/home-manager)** by nix-community - Declarative user environments
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** by [LnL7](https://github.com/LnL7) - Nix-based macOS management
- **[sops-nix](https://github.com/Mic92/sops-nix)** by [Mic92](https://github.com/Mic92) - Secure secrets management
- **[just](https://github.com/casey/just)** by [Casey Rodarmor](https://github.com/casey) - Command runner

### Community
To the broader Nix community - your documentation, discussions, and support make declarative system management accessible and powerful.

---

[Return to top](#aytordevs-nix-system-configuration)