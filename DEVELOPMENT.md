# Development Environment Setup

This guide will help you set up your development environment for working with this repository.

## Prerequisites

- [Nix](https://nixos.org/download.html) installed on your system
- [Home Manager](https://nix-community.github.io/home-manager/) (optional but recommended)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone git@github.com:aytordev/system.git
   cd system
   ```

2. **Enter the development shell**
   This will provide you with all the necessary tools:
   ```bash
   nix develop
   ```
   Or if you're using direnv:
   ```bash
   echo "use flake" > .envrc
   direnv allow
   ```

## Available Tools

The development shell includes the following tools:

- `alejandra` - Nix code formatter
- `statix` - Nix code linter
- `deadnix` - Find dead code in Nix files
- `shellcheck` - Shell script analysis
- `shfmt` - Shell script formatter
- `nixpkgs-fmt` - Alternative Nix formatter
- `nix-linter` - Additional Nix linter
- `shellharden` - Shell script hardening
- `git` - Version control
- `jq` - JSON processor
- `yq` - YAML processor (Go implementation)

## Code Style and Formatting

### Nix Files

Format all Nix files:
```bash
alejandra .
```

Lint Nix files:
```bash
statix check
```

Find dead code:
```bash
deadnix .
# Interactive fix
deadnix --edit .
```

### Shell Scripts

Lint shell scripts:
```bash
find . -name '*.sh' -exec shellcheck {} \;
```

Format shell scripts:
```bash
shfmt -i 2 -w .
```

## Editor Setup

### VS Code

1. Install the following extensions:
   - [Nix IDE](https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide)
   - [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
   - [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)

2. Recommended settings (add to your `settings.json`):
   ```json
   {
     "nix.enableLanguageServer": true,
     "nix.serverPath": "nil",
     "nix.serverSettings": {
       "nil": {
         "formatting": {
           "command": ["alejandra", "--quiet"]
         }
       }
     },
     "[nix]": {
       "editor.defaultFormatter": "kamadorueda.alejandra",
       "editor.formatOnSave": true
     },
     "shellcheck.enable": true,
     "shellcheck.exclude": ["SC1090", "SC1091"],
     "shellformat.flag": "-i 2 -ci"
   }
   ```

### Neovim

1. Install the following plugins:
   ```lua
   -- LSP
   'neovim/nvim-lspconfig',
   'williamboman/mason.nvim',
   'williamboman/mason-lspconfig.nvim',
   
   -- Nix
   'LnL7/vim-nix',
   
   -- Formatting
   'jose-elias-alvarez/null-ls.nvim',
   'nvim-lua/plenary.nvim'
   ```

2. Configure LSP for Nix:
   ```lua
   require('lspconfig').nil_ls.setup({
     settings = {
       ['nil'] = {
         formatting = {
           command = { 'alejandra' },
         },
       },
     },
   })
   ```

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification with Gitmoji. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Testing

Run the test suite:

```bash
# Run all tests
nix flake check
```

## Updating Dependencies

To update dependencies:

```bash
# Update flake inputs
nix flake update

# Or update specific input
nix flake lock --update-input nixpkgs
```

## Troubleshooting

### Nix Build Issues

If you encounter build issues, try:

1. Update your flake inputs:
   ```bash
   nix flake update
   ```

2. Clear the Nix store (be careful, this will remove all build caches):
   ```bash
   nix-collect-garbage
   ```

3. If using a specific system (e.g., aarch64-darwin):
   ```bash
   nix develop .#devShells.aarch64-darwin.default
   ```
