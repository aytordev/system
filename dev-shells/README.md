# 🛠️ Development Shells

This directory contains Nix development shell configurations that provide consistent development environments across different systems.

## 📁 Directory Structure

```
dev-shells/
├── default.nix    # Main development shell with all tools
└── just.nix       # Specialized shell for just command runner
```

## 🎯 Purpose

Development shells ensure that all developers and CI systems have access to the same tools and dependencies, making the development process more reliable and reproducible.

## 🚀 Available Development Shells

### `default.nix`
The main development shell that includes essential development tools and dependencies required for working with this repository.

### `just.nix`
A specialized development shell containing the `just` command runner and related tools. This shell is used for running common development tasks defined in the `Justfile`.

## 💻 Usage

### Enter the Default Development Shell
```bash
# Enter interactive shell with all development tools
nix develop
```

### Run a Specific Command
```bash
# Run a single command in the development environment
nix develop -c <command>
```

### Using with direnv (Recommended)

1. Install [direnv](https://direnv.net/)
2. Add the following to your shell configuration:
   ```bash
   eval "$(direnv hook bash)"  # For bash
   # or
   eval "$(direnv hook zsh)"   # For zsh
   ```
3. Add a `.envrc` file to your project root:
   ```bash
   use flake .#devShells.$(uname -m)-linux.default
   ```
4. Run `direnv allow` to activate the environment

## ➕ Adding New Development Shells

1. Create a new `.nix` file with your shell configuration
2. Update `default.nix` to include or re-export your new shell
3. Document the new shell in this README with:
   - Purpose and intended use case
   - Included tools and their versions
   - Any special configuration requirements

## 🧰 Included Tools

### Core Development
- Git and version control tools
- Nix development tools (nixpkgs-fmt, nix-diff, etc.)
- Build essentials (gcc, make, etc.)

### Code Quality
- Linters and formatters
- Static analysis tools

### Project-Specific
- `just` command runner (in `just.nix`)
- Other project-specific tools

## 📦 Dependencies

- [Nix](https://nixos.org/) (≥ 2.4)
- [direnv](https://direnv.net/) (≥ 2.32.0, optional but recommended)
- [just](https://github.com/casey/just) (≥ 1.12.0, for just.nix)

## 🔗 Related Documentation

- [Checks](../checks/README.md) - For running code quality checks
- [Outputs](../outputs/README.md) - For understanding the build system
- [Justfile](../Justfile) - For available development commands
