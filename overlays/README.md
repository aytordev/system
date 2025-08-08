# 🎨 Overlays

This directory contains Nix overlays that provide custom packages and modifications to existing packages across the system configurations.

## 🏗️ Structure

The overlay system follows the same modular pattern as dev-shells:

```
overlays/
├── default.nix              # Overlay loader (scans subdirectories)
├── google-chrome-dev/       # Example overlay
│   └── default.nix
└── README.md               # This file
```

## 📝 Usage

### Accessing Overlays

Overlays are available as flake outputs:

```bash
# List available overlays
nix eval .#overlays --apply builtins.attrNames

# Check specific overlay
nix eval .#overlays.google-chrome-dev --apply "overlay: builtins.isFunction overlay"
```

### Using Overlays in Configurations

To use overlays in your system configurations:

```nix
# In a system configuration
{ config, pkgs, ... }: {
  nixpkgs.overlays = [
    inputs.self.overlays.google-chrome-dev
  ];
  
  environment.systemPackages = [
    pkgs.google-chrome-dev  # Now available from overlay
  ];
}
```

### Using Overlays in Home Manager

```nix
# In a home configuration
{ config, pkgs, ... }: {
  nixpkgs.overlays = [
    inputs.self.overlays.google-chrome-dev
  ];
  
  home.packages = [
    pkgs.google-chrome-dev
  ];
}
```

## 🛠️ Creating New Overlays

### Basic Overlay Structure

Create a new directory in `overlays/` with a `default.nix` file:

```nix
# overlays/my-overlay/default.nix
final: prev: {
  my-custom-package = prev.stdenv.mkDerivation {
    pname = "my-custom-package";
    version = "1.0.0";
    
    src = prev.fetchurl {
      url = "https://example.com/package.tar.gz";
      sha256 = "...";
    };
    
    meta = with prev.lib; {
      description = "My custom package";
      homepage = "https://example.com";
      license = licenses.mit;
    };
  };
}
```

### Overlay Best Practices

1. **Use Modern Parameter Names**: Use `final` and `prev` instead of `self` and `super`
2. **Keep Overlays Focused**: Each overlay should have a specific purpose
3. **Document Dependencies**: Include comments about external dependencies
4. **Handle Platforms**: Use `meta.platforms` to specify supported systems
5. **Version Management**: Include version information and update instructions

### Example: Package Override

```nix
# overlays/firefox-custom/default.nix
final: prev: {
  firefox = prev.firefox.override {
    # Custom configuration
    extraPolicies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
    };
  };
}
```

### Example: New Package

```nix
# overlays/custom-tool/default.nix
final: prev: {
  custom-tool = prev.writeShellScriptBin "custom-tool" ''
    #!${prev.bash}/bin/bash
    echo "Custom tool running!"
  '';
}
```

## 🧪 Testing Overlays

### Manual Testing

```bash
# Test overlay import
nix eval --impure --expr 'import ./overlays { pkgs = (import <nixpkgs> {}); system = "aarch64-darwin"; inputs = {}; }'

# Test specific overlay
nix eval .#overlays.my-overlay --apply "overlay: builtins.attrNames (overlay {} (import <nixpkgs> {}))" --impure
```

### Integration Testing

Test overlays in a temporary shell:

```bash
nix shell --impure --expr '
  let
    pkgs = import <nixpkgs> { 
      overlays = [ (import ./overlays).my-overlay ]; 
    };
  in [ pkgs.my-custom-package ]
'
```

## 🔄 Automatic Loading

The `overlays/default.nix` automatically discovers and loads all overlay directories:

1. Scans current directory for subdirectories
2. Checks each subdirectory has a `default.nix` file
3. Imports each overlay and validates it's a function
4. Returns attribute set of all overlays

This follows the same pattern as the dev-shells system for consistency.

## 🚀 Integration with Flake Outputs

The overlays are integrated into the main flake outputs in `outputs/default.nix`:

```nix
overlays = import (libraries.relativeToRoot "overlays");
```

This provides them as standard flake overlays that can be consumed by other flakes or system configurations.

## 🔗 Related

- [System Outputs](../outputs/README.md)
- [Development Shells](../dev-shells/README.md)
- [Nix Overlays Documentation](https://nixos.org/manual/nixpkgs/stable/#chap-overlays)