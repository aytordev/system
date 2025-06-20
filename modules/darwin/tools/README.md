# 🛠 Darwin Tools

This directory contains modules for managing various tools on Darwin (macOS) systems.

## 📋 Table of Contents

- [Available Modules](#-available-modules)
  - [Homebrew](#-homebrew)
- [Adding New Tools](#-adding-new-tools)

## 🧩 Available Modules

### 🍺 Homebrew (`homebrew/`)

Manages Homebrew package manager configuration.

#### 📋 Prerequisites

Before using this module, ensure Homebrew is installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow the post-installation instructions to add Homebrew to your PATH
```

#### 🚀 Usage

Enable Homebrew in your host configuration:

```nix
{
  tools.homebrew.enable = true;
}
```

#### ✨ Features

- Configures Homebrew environment variables
- Manages Homebrew analytics settings
- Controls auto-update behavior
- Configures cleanup and upgrade policies

#### ⚙️ Configuration

All available options are documented in the module's inline documentation (`homebrew/default.nix`).

## ➕ Adding New Tools

1. **Create Module Directory**
   ```bash
   mkdir -p modules/darwin/tools/new-tool
   ```

2. **Implement Module**
   - Create `default.nix` with your module implementation
   - Follow Nix module conventions
   - Include comprehensive documentation

3. **Update Documentation**
   - Add a section in this README
   - Document prerequisites
   - Include usage examples
   - List configuration options

4. **Test Thoroughly**
   - Test on all supported systems
   - Verify documentation accuracy
   - Check for side effects

## 🤝 Contributing

See the main [CONTRIBUTING.md](../../../../CONTRIBUTING.md) for contribution guidelines.
