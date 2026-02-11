# Justfile - Nix System Management
# A self-contained task runner for Nix system management

############################################################################
# Core Nix Commands
############################################################################

# List all available commands
default:
    @just --list

# Update all flake inputs
[group('nix')]
up:
    nix flake update --extra-experimental-features "nix-command flakes"
    nix flake update --flake ./flake/dev --extra-experimental-features "nix-command flakes"

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
    nix flake update {{input}} --extra-experimental-features "nix-command flakes"

# Format Nix files using the flake's formatter
# Usage: just fmt [path]  # Format files or directories (default: .)
[group('nix')]
fmt path=".":
    nix run .#formatter.aarch64-darwin -- "{{path}}"

# Check Nix formatting without making changes
# Usage: just fmt-check [path]  # Check files or directories (default: .)
[group('nix')]
fmt-check path=".":
    nix run .#formatter.aarch64-darwin -- --check "{{path}}"

# Garbage collection
[group('nix')]
gc:
    sudo nix-collect-garbage --delete-older-than 7d
    nix-collect-garbage --delete-older-than 7d

# Run tests
[group('nix')]
test:
    nix eval .#evalTests --show-trace --print-build-logs --verbose

############################################################################
# System Management
############################################################################

# Switch NixOS configuration (Linux)
# Usage: just switch <hostname> [debug]
[linux]
[group('system')]
switch hostname mode="":
    if [ -z "{{mode}}" ]; then \
        nixos-rebuild switch --use-remote-sudo --flake ".#{{hostname}}"; \
    else \
        nix build ".#nixosConfigurations.{{hostname}}.config.system.build.toplevel" --show-trace --verbose; \
        nixos-rebuild switch --use-remote-sudo --flake ".#{{hostname}}" --show-trace --verbose; \
    fi

# Make directory editable (fix permissions)
# Usage: just make-editable <path>
[group('system')]
make-editable path:
    tmpdir=$$(mktemp -d) && \
    rsync -avz --copy-links "{{path}}/" "$$tmpdir" && \
    rsync -avz --copy-links --chmod=D2755,F744 "$$tmpdir/" "{{path}}"

############################################################################
# macOS Management
############################################################################

# Build Darwin system
# Usage: just darwin-build <hostname> [debug]
[macos]
[group('darwin')]
darwin-build name mode="":
    if [ "{{mode}}" = "debug" ]; then \
        nix build ".#darwinConfigurations.{{name}}.system" --extra-experimental-features "nix-command flakes" --show-trace --verbose; \
    else \
        nix build ".#darwinConfigurations.{{name}}.system" --extra-experimental-features "nix-command flakes"; \
    fi

# Switch Darwin configuration
# Usage: just darwin-switch <hostname> [debug]
[macos]
[group('darwin')]
darwin-switch name mode="":
    if [ "{{mode}}" = "debug" ]; then \
        sudo -E ./result/sw/bin/darwin-rebuild switch --flake ".#{{name}}" --show-trace --verbose; \
    else \
        sudo -E ./result/sw/bin/darwin-rebuild switch --flake ".#{{name}}"; \
    fi

# Rollback last Darwin generation
[macos]
[group('darwin')]
darwin-rollback:
    ./result/sw/bin/darwin-rebuild --rollback

############################################################################
# VM Management
############################################################################

# Build and upload VM image
# Usage: just upload-vm <vm-name> [debug]
[group('vm')]
upload-vm name mode="":
    if [ "{{mode}}" = "debug" ]; then \
        nix build ".#{{name}}" --show-trace --verbose; \
    else \
        nix build ".#{{name}}"; \
    fi && \
    rsync -avz --progress --copy-links --checksum result "ryan@rakushun:/data/caddy/fileserver/vms/kubevirt-{{name}}.qcow2"

############################################################################
# Development
############################################################################

# Enter development shell
[group('dev')]
shell:
    nix shell nixpkgs#git nixpkgs#neovim nixpkgs#colmena

# Install pre-commit hooks
# Usage: just install-hooks
[group('dev')]
install-hooks:
    mkdir -p .git/hooks
    ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    chmod +x scripts/pre-commit.sh
    echo "✅ Pre-commit hook installed manually!"

############################################################################
# Git Helpers
############################################################################

# Clean up git repository
[group('git')]
clean:
    git reflog expire --expire-unreachable=now --all
    git gc --prune=now

# Amend last commit without changing message
[group('git')]
amend:
    git commit --amend -a --no-edit

############################################################################
# System Info
############################################################################

# Show system information
[group('info')]
system-info:
    echo "System: $(uname -a)"
    echo "Nix version: $(nix --version)"
    echo "Just version: $(just --version)"
