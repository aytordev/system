# 📊 System Variables

This directory contains global variables and user-specific configurations used throughout the system. These variables ensure consistency across different parts of the configuration and make it easy to update common values in one place.

## 📁 Directory Structure

```
variables/
├── README.md        # This file
└── default.nix      # Main variables definition
```

## 🎯 Purpose

The `variables` module provides a centralized location for:

- User account information
- System-wide settings
- Common values used across multiple configurations
- Sensitive data (handled securely via sops-nix)

## 🔍 Available Variables

### User Variables

These variables define user-specific settings:

- `username`: System username (e.g., "aytordev")
- `fullname`: User's full name (e.g., "Aytor Vicente Martinez")
- `email`: User's email address (e.g., "me@aytor.dev")

## 🛠 Usage

### Importing Variables

Import the variables in your Nix expressions:

```nix
{ lib, ... }:

let
  # Import the variables
  variables = import ./variables { inherit lib; };
in {
  # Use the variables
  users.users.${variables.username} = {
    isNormalUser = true;
    home = "/home/${variables.username}";
    # ... other user settings
  };
}
```

### Adding New Variables

1. Edit `default.nix` to add new variables:

```nix
{lib}: {
  # Existing variables
  username = "aytordev";
  fullname = "Aytor Vicente Martinez";
  email = "me@aytor.dev";
  
  # New variable example
  hostname = "my-laptop";
  timezone = "Europe/Madrid";
}
```

2. Use the new variable in your configurations:

```nix
{ config, lib, ... }:

let
  variables = import ./variables { inherit lib; };
in {
  # Using the new variables
  networking.hostName = variables.hostname;
  time.timeZone = variables.timezone;
}
```

## 🔒 Security Considerations

- **Sensitive Data**: For sensitive information like passwords or API keys, use `sops-nix` instead of storing them directly in this file.
- **Secrets Management**: See the project's security documentation for handling secrets properly.

## 🔄 Best Practices

1. **Keep It Simple**: Only store values that are used in multiple places.
2. **Documentation**: Always document new variables with comments in `default.nix`.
3. **Type Safety**: Consider adding type annotations for complex variables.
4. **Naming**: Use descriptive, camelCase names for variables.

## 📚 Related Documentation

- [NixOS Manual: Options](https://nixos.org/manual/nixos/stable/options.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [sops-nix Documentation](https://github.com/Mic92/sops-nix)

## 🤝 Contributing

When adding or modifying variables:

1. Document the purpose of each new variable
2. Follow the existing naming conventions
3. Update this README if the variable structure changes
4. Test your changes in a development environment before committing
