# ❄️ aytordev/system

> aytordev's nix configuration for both NixOS & macOS.

![NixOS](https://img.shields.io/badge/NixOS-Unstable-5277C3?style=for-the-badge&logo=nixos&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Sequoia-000000?style=for-the-badge&logo=apple&logoColor=white)
![Nix](https://img.shields.io/badge/Nix-Flakes-5277C3?style=for-the-badge&logo=nix&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 📖 About

This repository contains my personal declarative system configurations managed by **Nix**. It serves as a monorepo for my infrastructure, supporting both **NixOS** (x86_64-linux) and **macOS** (aarch64-darwin).

## 🗂️ Structure

The project follows a modular structure empowered by `flake-parts`:

```
.
├── flake/          # Core flake configuration & partitions
├── modules/        # Reusable Nix modules
│   ├── home/       # Home Manager modules (terminal, editors, desktop)
│   ├── darwin/     # macOS-specific modules
│   └── nixos/      # NixOS-specific modules
├── systems/        # Host configurations
├── packages/       # Custom packages
├── overlays/       # Nixpkgs overlays
├── scripts/        # Automation scripts
└── Justfile        # Task runner configuration
```

## 🚀 Usage

This project uses [`just`](https://github.com/casey/just) to simplify common management tasks.

### Prerequisites

- [Nix](https://nixos.org/download.html) (Flakes enabled)
- [Just](https://github.com/casey/just) (recommended)

### Quick Start

```bash
# List all available commands
just

# Update dependencies
just up
```

### 🍎 macOS (Darwin)

```bash
# Build the system configuration
just darwin-build <hostname>

# Apply the configuration
just darwin-switch <hostname>

# Apply with debug logs
just darwin-switch <hostname> debug
```

### 🐧 NixOS

```bash
# Apply configuration
just switch <hostname>
```

### 🛠️ Development & QA

```bash
# Format nix files
just fmt

# Install pre-commit hooks (Statix linter)
just install-hooks
```

## 🧩 Features

- **Multi-Platform**: Unified config for Linux and macOS.
- **Terminal**: Zsh/Bash/Fish integration with modern tools (`zoxide`, `eza`, `starship`).
- **Desktop**:
  - **macOS**: Aerospace window manager, Sketchybar.
  - **Editors**: Antigravity (VSCode), Neovim.
- **Security**: Secret management via `sops-nix`.
- **Development**: Atomic commits, automated formatting (`treefmt`), and linting (`statix`).

## Acknowledgements

Inspired by [Khanelinix](https://github.com/khaneliman/khanelinix) and the Nix community.
