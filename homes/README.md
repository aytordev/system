# Home Configurations

This directory contains system-specific home configurations for different users and systems. Each subdirectory follows the pattern `architecture-system/username@hostname/`.

## Directory Structure

```
homes/
├── aarch64-darwin/          # ARM64 macOS systems
│   └── aytordev@wang-lin/   # User 'aytordev' on host 'wang-lin'
│       └── default.nix     # Home configuration
└── x86_64-linux/            # x86_64 Linux systems
    └── user@hostname/
        └── default.nix
```

## Creating a New Home Configuration

1. Create a new directory structure following the pattern: `architecture-system/username@hostname/`
2. Add a `default.nix` file with your home configuration
3. Import the configuration in the appropriate system configuration

## Example Configuration

```nix
# homes/aarch64-darwin/username@hostname/default.nix
{
  config,
  lib,
  ...
}:

let
  cfg = config.home;
in {
  options.home = with lib.types; {
    enable = lib.mkEnableOption "home configuration";
  };

  config = lib.mkIf cfg.enable {
    # Your home configuration here
    home.stateVersion = "25.11";
  };
}
```

## Best Practices

- Keep configurations modular and focused
- Use descriptive option names
- Document all options and configurations
- Follow the NixOS module system patterns
- Use `lib.mkEnableOption` for features
- Set appropriate types for all options

## Linting and Formatting

All Nix files should be formatted with `alejandra` and checked with `statix` and `deadnix`:

```bash
# Format files
alejandra .

# Check for issues
statix check

# Find dead code
deadnix .
```

## Versioning

- Update the `stateVersion` when making breaking changes
- Document any breaking changes in the project's CHANGELOG.md
- Follow semantic versioning for modules

## See Also

- [NixOS Wiki - Home Manager](https://nixos.wiki/wiki/Home_Manager)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
