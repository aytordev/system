# Code Style Guide

## 📜 Introduction

This document defines the coding standards and best practices for the `system` repository, which manages system and environment configurations using Nix Flakes, nix-darwin, and home-manager. These guidelines ensure consistency, maintainability, and reliability across the codebase.

## 🔄 Versioning and Updates

This is a living document that evolves with the project. Major changes should be documented in the [CHANGELOG.md](CHANGELOG.md).

---

## 🐚 Bash Style Guide

## 🎯 General Principles

### Shebang

```bash
#!/usr/bin/env bash
```

**Why**: Uses `env` to find bash in the user's PATH, making scripts more portable across different systems.

### Error Handling

```bash
set -euo pipefail
```

- `-e`: Exit immediately if a command exits with a non-zero status
- `-u`: Treat unset variables as an error
- `-o pipefail`: The return value of a pipeline is the status of the last command to exit non-zero

### Debugging

```bash
# For debugging
set -x
# ...
set +x
```

## 📝 Variable Usage

### Naming Conventions

```bash
# UPPERCASE for environment and global variables
readonly CONFIG_FILE="${HOME}/.config/app/config"

# lowercase for local variables
local temp_file
local counter=0
```

### Quoting

```bash
# Good
name="$username"
echo "Hello, ${name}!"

# Bad - word splitting and globbing issues
echo Hello, $name!
```

## 🛠 Functions

### Definition

```bash
# Preferred
function_name() {
    local var1="$1"
    local var2="${2:-default}"
    # ...
}

# Alternative (less preferred)
function function_name {
    # ...
}
```

### Best Practices

1. Always use `local` for function variables
2. Return status codes (0 for success, non-zero for failure)
3. Document functions with comments
4. Keep functions small and focused

## 🔄 Control Structures

### If Statements

```bash
if [[ -f "$file" ]]; then
    # ...
elif [[ -d "$dir" ]]; then
    # ...
else
    # ...
fi
```

### Loops

```bash
# Iterate over files
for file in *.txt; do
    [[ -f "$file" ]] || continue
    # ...
done

# While loop with read
while IFS= read -r line; do
    # ...
done < <(command)
```

## 🧪 Testing and Debugging

### Linting

```bash
# Install shellcheck
nix-shell -p shellcheck

# Run on a file
shellcheck script.sh
```

### Unit Testing with BATS

```bash
# test/example.bats
@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}
```

---

## ❄️ Nix Style Guide

## 🏗️ Project Structure

```
.
├── flake.nix
├── flake.lock
├── hosts/               # System configurations
│   ├── default.nix
│   └── darwin/         # macOS specific
├── modules/            # Reusable modules
│   ├── default.nix
│   └── my-module/
├── home/               # home-manager configs
│   ├── default.nix
│   └── modules/
└── pkgs/              # Custom packages
    └── default.nix
```

## 📝 Flake Structure

```nix
# flake.nix
{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    darwinConfigurations = {
      my-macbook = nixpkgs.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.username = import ./home/darwin.nix;
          }
        ];
      };
    };
  };
}
```

## 🧩 Module System

### Basic Module

```nix
# modules/my-module/default.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModule;
in {
  options.myModule = {
    enable = mkEnableOption "my module";
    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port to listen on";
    };
  };

  config = mkIf cfg.enable {
    # Implementation
  };
}
```

### Best Practices

1. Use `mkEnableOption` for features
2. Document all options with `description`
3. Use proper types from `types`
4. Keep modules focused and small

## 🔧 Nix Language

### Formatting

Use `alejandra` for consistent formatting:

```bash
# Format all Nix files
alejandra .
```

### Linting

```bash
# Check for common issues
statix check

# Fix issues
statix fix

# Find dead code
deadnix .
```

## 🔒 Secrets Management

Use `sops-nix` for secrets:

```nix
# flake.nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  # ...
  modules = [
    sops-nix.nixosModules.sops
    # ...
  ];
}
```

```nix
# Configuration
sops.defaultSopsFile = ./secrets.yaml;
sops.age.keyFile = "${config.users.users.username.home}/.config/sops/age/keys.txt";

# Example secret usage
users.users.myuser = {
  passwordFile = config.sops.secrets."user-password".path;
};
```

---

## 🛠 Tooling

### Required Tools

The following tools are recommended for development:

- `alejandra`: Nix formatter
- `statix`: Nix linter
- `deadnix`: Dead code detector
- `shellcheck`: Bash linter
- `shfmt`: Bash formatter
- `bats`: Bash testing

### Manual Formatting and Linting

Before committing changes, please run the following commands:

```bash
# Format all Nix files
alejandra .

# Check for Nix issues
statix check

# Check for dead code
deadnix .

# Fix dead code (interactive)
deadnix --edit .

# Lint shell scripts
find . -name '*.sh' -exec shellcheck {} \;

# Format shell scripts
shfmt -i 2 -w .
```

### Editor Integration

#### VS Code

For the best development experience, we recommend using VS Code with these settings:

```json
{
  "[nix]": {
    "editor.defaultFormatter": "kamadorueda.alejandra",
    "editor.formatOnSave": true
  },
  "shellcheck.enable": true,
  "shellcheck.exclude": ["SC1090", "SC1091"],
  "shellformat.flag": "-i 2 -ci"
}
```

#### Neovim

For Neovim users, you can use the following plugins:

1. `nvim-lspconfig` with `rnix-lsp` for Nix LSP support
2. `null-ls.nvim` for formatting with `alejandra` and `shfmt`
3. `mason.nvim` for easy installation of language servers

#### JetBrains IDEs

1. Install the "Nix IDE Support" plugin
2. Enable "Show NixOS Options" in Settings > Languages & Frameworks > Nix
3. Configure external tools for formatting with `alejandra` and `shfmt`

---

## 🔄 Continuous Improvement

This document should evolve with the project. When making changes:

1. Update this file with new patterns or best practices
2. Update the CHANGELOG.md for significant changes
3. Consider running `nix flake update` to update dependencies
4. Run all linters and tests before committing changes

## 📝 Documentation Guidelines

### 🐚 Bash Documentation

#### Comment Types and Usage

**Single-line Comments**
```bash
# This is a single-line comment
variable="value"  # Inline comment explaining the variable
```

**Multi-line Comments**
```bash
# This is a multi-line comment
# spanning multiple lines
# to explain complex logic
command
```

**Function Documentation**
```bash
# Performs a specific operation with detailed explanation
#
# Usage: function_name [OPTIONS] ARG1 ARG2
#
# Options:
#   -h, --help    Show this help message and exit
#   -v, --verbose Enable verbose output
#
# Arguments:
#   ARG1  Description of first argument
#   ARG2  Description of second argument
#
# Returns:
#   0 on success, non-zero on failure
#
# Environment Variables:
#   ENV_VAR  Description of environment variable usage
function_name() {
    # Function implementation
}
```

**File Headers**
```bash
#!/usr/bin/env bash
#
# Filename: example.sh
# Description: Brief description of script's purpose
# Author: Your Name <your.email@example.com>
# Version: 1.0.0
# Usage: ./example.sh [OPTIONS] ARGUMENTS
#
# Dependencies:
#   - jq
#   - curl
#
# Environment Variables:
#   REQUIRED_VAR - Description of required variable
#   OPTIONAL_VAR - Description of optional variable (default: value)
```

#### Best Practices

1. **Be concise but complete**
   - Good: `# Calculate total by summing array`
   - Bad:  `# This function calculates the total` (redundant with function name)

2. **Document why, not what**
   - Good: `# Using process substitution for better performance`
   - Bad:  `# Loop through files` (obvious from code)

3. **Document edge cases**
   ```bash
   # Handle case where input contains spaces
   [[ "$input" =~ [[:space:]] ]] && input="\"$input\""
   ```

4. **Use TODO/FIXME markers**
   ```bash
   # TODO: Implement error handling for network failures
   # FIXME: This breaks with filenames containing newlines
   ```

### ❄️ Nix Documentation

#### Comment Types

**Single-line Comments**
```nix
# This is a single-line comment
{ pkgs, ... }:  # Inline comment about the parameter
```

**Multi-line Comments**
```nix
/*
  This is a multi-line comment
  that can span multiple lines
  and preserves indentation
*/
```

#### Module Documentation

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  # Internal variable documentation
  #
  # Type: string
  # Default: "default-value"
  # Description: Explanation of what this variable represents
  internalVar = "value";
in {
  options = {
    # Option documentation follows NixOS module system conventions
    services.myService = {
      enable = mkEnableOption "my-service" // {
        description = ''
          Whether to enable the my-service daemon.
          
          This service provides important functionality for X and Y.
          When enabled, it will start automatically at boot.
        '';
      };
      
      port = mkOption {
        type = types.port;
        default = 3000;
        example = 8080;
        description = ''
          TCP port on which the service should listen.
          
          Must be a valid port number (1-65535).
          Use 0 to automatically select an available port.
        '';
      };
      
      extraConfig = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          Additional configuration options as key-value pairs.
          These will be added to the configuration file as-is.
          
          Example:
          ```nix
          {
            "log.level" = "debug";
            "cache.enabled" = "true";
          }
          ```
        '';
      };
    };
  };
  
  config = mkIf config.services.myService.enable {
    # Implementation details with comments explaining non-obvious logic
    systemd.services.my-service = {
      description = "My Service Daemon";
      
      serviceConfig = {
        ExecStart = "${pkgs.my-package}/bin/my-service \
          --port ${toString config.services.myService.port} \
          --config ${pkgs.writeText "my-service.conf" 
            (lib.generators.toKeyValue {} config.services.myService.extraConfig)}";
      };
    };
  };
}
```

#### Function Documentation

```nix
/* Create a service configuration with common defaults

   Example:
   ```nix
   mkService {
     name = "my-service";
     description = "My Cool Service";
     exec = "${pkgs.my-service}/bin/start";
   }
   ```

   Type:
     mkService :: {
       name :: String,
       description :: String,
       exec :: String,
       user :: String,
       group :: String,
       environment :: AttrsOf String,
       serviceConfig :: Attrs,
     } -> Attrs
*/
{ name
, description
, exec
, user = name
, group = user
, environment = {}
, serviceConfig = {}
, ...
} @ args:
let
  baseService = {
    inherit (args) description;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      ExecStart = exec;
      Restart = "on-failure";
      
      # Security
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      
      # Resource limits
      LimitNOFILE = 65536;
    } // serviceConfig;
    
    environment = {
      # Default environment variables
      PATH = "${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin";
    } // environment;
  };
in
  baseService // (removeAttrs args [ "name" ])
```

#### Flake Documentation

```nix
{
  description = "My NixOS and Home Manager configurations";
  
  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Additional modules
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # Documentation for NixOS configurations
    nixosConfigurations = {
      # Desktop configuration
      my-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.john = import ./home/desktop.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      
      # Laptop configuration (example of another system)
      my-laptop = nixpkgs.lib.nixosSystem {
        # ...
      };
    };
    
    # Documentation for Home Manager configurations
    homeConfigurations = {
      # Work profile
      "john@work" = home-manager.lib.homeManagerConfiguration {
        # ...
      };
      
      # Personal profile
      "john@personal" = home-manager.lib.homeManagerConfiguration {
        # ...
      };
    };
    
    # Development shell for this flake
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        # Development tools
        nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt
        nixpkgs.legacyPackages.x86_64-linux.shellcheck
        
        # Documentation tools
        nixpkgs.legacyPackages.x86_64-linux.mdbook
        nixpkgs.legacyPackages.x86_64-linux.nixdoc
      ];
    };
  };
}
```

### 📚 Documentation Generation

#### Bash Documentation Tools

1. **Bashly**
   - Generates CLI applications with automatic help
   - Integrates with existing bash scripts
   - Example usage:
     ```bash
     # Install
     nix-shell -p bashly
     
     # Initialize new project
     bashly init
     
     # Generate documentation
     bashly generate
     ```

2. **Docopt**
   - Creates beautiful command-line interfaces
   - Parses help messages to define the CLI
   - Example:
     ```bash
     #!/usr/bin/env bash
     
     # Usage:
     #   my_script <name>
     #   my_script -h | --help
     #   my_script --version
     #
     # Options:
     #   -h --help    Show this screen.
     #   --version    Show version.
     
     source docopts.sh --auto "$@"
     
     # Your script here
     echo "Hello, ${_arg_name}!"
     ```

#### Nix Documentation Tools

1. **nixdoc**
   - Generates API documentation from Nix expressions
   - Example usage:
     ```bash
     # Install
     nix-shell -p nixdoc
     
     # Generate documentation
     nixdoc -c my-configuration.nix -d "My Module" -f docbook
     ```

2. **nmd** (NixOS Module Docs)
   - Generates documentation for NixOS modules
   - Example usage:
     ```nix
     # flake.nix
     {
       inputs.nmd.url = "gitlab:rycee/nmd";
       
       outputs = { self, nixpkgs, nmd }: {
         docs = nmd.genModulesDocs {
           modules = [ ./modules/my-module.nix ];
           moduleRoot = ./.;
         };
       };
     }
     ```

3. **mdBook with mdbook-nix**
   - Creates beautiful documentation websites
   - Integrates Nix code examples
   - Example usage:
     ```bash
     # Install
     nix-shell -p mdbook mdbook-nix
     
     # Initialize new book
     mdbook init docs
     
     # Serve with live reload
     mdbook serve docs
     ```

## 📝 Documentation Best Practices

### General Guidelines

1. **Be Consistent**
   - Follow the same style throughout the project
   - Use consistent formatting for similar elements

2. **Keep It Updated**
   - Update documentation when modifying code
   - Remove outdated information
   - Use version control to track documentation changes

3. **Make It Accessible**
   - Use clear, simple language
   - Include examples for complex concepts
   - Document assumptions and prerequisites

4. **Document the Why**
   - Explain design decisions
   - Document trade-offs
   - Note any limitations or known issues

### Review Process

1. **Self-Review**
   - Read your documentation as if you're a new contributor
   - Check for clarity and completeness
   - Verify all examples work as described

2. **Peer Review**
   - Have others review your documentation
   - Check for technical accuracy
   - Ensure it's understandable for the target audience

3. **Automated Checks**
   - Use linters and validators
   - Check for broken links
   - Verify code examples compile/run

## 🔄 Documentation Maintenance

### Versioning

- Include version numbers in documentation
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update documentation when making breaking changes

### Changelog

Maintain a `CHANGELOG.md` with:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- New features and improvements

### Changed

- Changes in existing functionality

### Deprecated

- Soon-to-be removed features

### Removed

- Removed features

### Fixed

- Bug fixes

### Security

- Security-related changes
```

### Documentation Testing

Test your documentation by:

1. Verifying all code examples work
2. Checking all links are valid
3. Ensuring the documentation builds correctly
4. Validating the structure and readability

## 🔗 Additional Resources

- [NixOS Manual: Writing NixOS Documentation](https://nixos.org/manual/nixos/stable/#sec-writing-documentation)
- [Bash Style Guide and Coding Standards](https://github.com/bahamas10/bash-style-guide)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Nixpkgs Manual: Contributing to Documentation](https://github.com/NixOS/nixpkgs/blob/master/doc/contributing/documentation/contributing-to-doc.chapter.md)

## Contributing

When contributing to this repository, please ensure your code adheres to these guidelines. If you find patterns that could be improved, please open an issue to discuss potential updates to this document.
