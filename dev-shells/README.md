# 🛠️ Development Shells

This directory contains Nix development shell configurations that provide consistent development environments across different systems. Each shell is automatically discovered and loaded from its own subdirectory.

## 📁 Directory Structure

```
dev-shells/
├── default.nix       # Main development shell with dynamic shell discovery
├── README.md         # This documentation
└── just/             # Just command runner shell
    └── default.nix   # Just shell configuration
```

## 🎯 Purpose

Development shells ensure that all developers and CI systems have access to the same tools and dependencies, making the development process more reliable and reproducible. The shell system is designed to be:

- **Modular**: Each shell is self-contained in its own directory
- **Discoverable**: Shells are automatically discovered
- **Consistent**: Common tools are included in all shells
- **Documented**: Each shell should document its purpose and usage

## 🚀 Available Development Shells

### Default Shell (`default`)
The default development shell that includes common development tools and a list of available shells.

### Just Shell (`just`)
A specialized development shell containing the `just` command runner and related tools. This shell is used for running common development tasks defined in the `Justfile`.

## 💻 Usage

### List Available Shells
```bash
nix flake show | grep -A 10 'devShells'
```

### Enter a Development Shell
```bash
# Enter the default shell
nix develop

# Enter a specific shell (e.g., just)
nix develop .#just
```

### Run a Command Without Entering the Shell
```bash
# Run a single command in the development environment
nix develop -c <command>

# Example: Run just with arguments
nix develop .#just -c just <task>
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
   use flake .#devShells.$(uname -m)-linux.default  # Default shell
   # or
   use flake .#just                               # Just shell
   ```
4. Run `direnv allow` to activate the environment

## ➕ Adding a New Development Shell

1. Create a new directory under `dev-shells/` for your shell:
   ```bash
   mkdir -p dev-shells/my-new-shell
   ```

2. Create a `default.nix` file in your shell's directory:
   ```nix
   # dev-shells/my-new-shell/default.nix
   { pkgs, system, inputs, ... }:
   
   {
     name = "my-new-shell";
     
     # List of packages to include
     packages = with pkgs; [
       # Add your packages here
     ];
     
     # Optional: Shell initialization script
     shellHook = ''
       echo "Welcome to my-new-shell!"
     '';
   }
   ```

3. The shell will be automatically discovered and available via:
   ```bash
   nix develop .#my-new-shell
   ```

## 🧰 Common Packages

All shells automatically include these common tools:

### Version Control
- `git` - Distributed version control
- `git-lfs` - Git extension for large files
- `gh` - GitHub CLI tool

### Nix Development
- `nixpkgs-fmt` - Nix code formatter
- `statix` - Lints and suggestions for Nix code
- `deadnix` - Find and remove unused code in .nix files

### Shell Tools
- `jq` - Command-line JSON processor
- `yq-go` - Portable YAML/XML/TOML processor
- `htop` - Interactive process viewer
- `file` - File type identification
- `tree` - Directory structure viewer

## 📦 Dependencies

- [Nix](https://nixos.org/) (≥ 2.4)
- [direnv](https://direnv.net/) (≥ 2.32.0, optional but recommended)

## 🔗 Related Documentation

- [Checks](../checks/README.md) - For running code quality checks
- [Outputs](../outputs/README.md) - For understanding the build system
- [Justfile](../Justfile) - For available development commands
