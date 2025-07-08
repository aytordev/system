# Starship Module

A simple and efficient module for integrating the [Starship](https://starship.rs/) prompt with your shell.

## Features

- Easy integration with ZSH
- Customizable prompt configuration
- Git status integration
- Fast and lightweight
- Follows XDG Base Directory specification

## Configuration

Enable the module in your user configuration:

```nix
applications.terminal.tools.starship = {
  enable = true;
  enableZshIntegration = true;  # Enabled by default
  
  # Customize your prompt
  settings = {
    # Your custom Starship configuration
    # See: https://starship.rs/config/
  };
};
```

## Default Configuration

The module comes with a sensible default configuration that includes:

- Clean prompt format with username, hostname, directory, and Git status
- Color-coded Git status indicators
- Truncated paths in the prompt
- Disabled package version display for better performance

## Dependencies

- `starship` - The Starship prompt
- `zsh` (optional) - For ZSH integration

## Integration

The module automatically initializes Starship in your ZSH configuration when `enableZshIntegration` is set to `true`.

## Customization

You can customize the prompt by modifying the `settings` attribute. Refer to the [Starship documentation](https://starship.rs/config/) for all available options.
