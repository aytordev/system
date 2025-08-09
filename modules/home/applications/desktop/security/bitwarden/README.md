# Bitwarden Password Manager Modules

This directory contains NixOS/nix-darwin modules for managing Bitwarden password manager, including both desktop and CLI applications.

## 📦 Available Modules

### Desktop Application
- **Path**: `modules/home/applications/desktop/security/bitwarden`
- **Purpose**: Bitwarden desktop application with GUI for password management
- **Platform**: macOS (via nix-darwin) and Linux

### CLI Tool
- **Path**: `modules/home/applications/terminal/tools/bitwarden-cli`
- **Purpose**: Command-line interface for Bitwarden with shell integrations
- **Platform**: Cross-platform

## 🚀 Features

### Desktop Application Features
- 🔐 Secure password storage and management
- 🌐 Browser integration for auto-fill
- 🔑 Biometric unlock support (Touch ID on macOS)
- 🔄 Auto-sync with Bitwarden servers
- 📱 Cross-device synchronization
- 💼 Vault timeout configuration
- 🎨 Theme customization

### CLI Features
- 🖥️ Full vault access from terminal
- 🔧 Shell integration (Zsh, Bash, Fish, Nushell)
- 📝 Custom aliases for common operations
- 🔐 Session management helpers
- 🤖 Automation-friendly API
- 🔄 rbw integration (optional alternative client)

## 📋 Configuration

### Basic Setup

#### Desktop Application
```nix
{
  applications.desktop.security.bitwarden.enable = true;
  applications.desktop.security.bitwarden.enableBrowserIntegration = true;
  applications.desktop.security.bitwarden.enableTrayIcon = true;
}
```

#### CLI Tool
```nix
{
  applications.terminal.tools.bitwarden-cli.enable = true;
  applications.terminal.tools.bitwarden-cli.shellIntegration.enable = true;
  applications.terminal.tools.bitwarden-cli.aliases.enable = true;
}
```

### Advanced Configuration

#### Desktop with Biometric Unlock
```nix
{
  applications.desktop.security.bitwarden = {
    enable = true;
    enableBrowserIntegration = true;
    biometricUnlock = {
      enable = true;
      requirePasswordOnStart = false;  # Skip password on start if using biometrics
    };
    vault = {
      timeout = 30;  # Lock after 30 minutes
      timeoutAction = "lock";  # "lock" or "logout"
    };
  };
}
```

#### CLI with Custom Server
```nix
{
  applications.terminal.tools.bitwarden-cli = {
    enable = true;
    settings = {
      server = "https://bitwarden.company.com";  # Self-hosted instance
      syncOnLogin = true;
      sessionTimeout = 1800;  # 30 minutes
    };
    shellIntegration = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
```

#### Enable rbw (Alternative CLI Client)
```nix
{
  applications.terminal.tools.bitwarden-cli = {
    enable = true;
    rbw = {
      enable = true;
      pinentry = "pinentry-mac";  # or "pinentry-curses" for terminal
    };
  };
}
```

## 🎯 Usage Examples

### CLI Commands

After enabling the module, you'll have access to these commands:

#### Standard Bitwarden CLI
```bash
# Login to Bitwarden
bw login email@example.com

# Unlock vault (using helper function)
bw-unlock  # Sets BW_SESSION environment variable

# Lock vault
bw-lock

# Get a password
bw get password "GitHub"

# List all items
bw list items

# Create a new login
bw create item login '{"name":"Example","login":{"username":"user","password":"pass"}}'

# Sync vault
bw sync
```

#### With Aliases Enabled
```bash
bwl  # Login
bwu  # Unlock
bws  # Sync
bwg item "GitHub"  # Get item
bwp "GitHub"  # Get password directly
bwc "GitHub"  # Get complete item details
```

#### Using rbw (if enabled)
```bash
# Initial setup
rbw register  # First time only
rbw login

# Daily usage
rbw get github.com  # Get password
rbw get github.com --full  # Get all fields
rbw add example.com --folder Work  # Add new entry
rbw sync  # Sync with server
```

### Desktop Application

The desktop application will be available in your Applications folder (macOS) or application menu (Linux). Features include:

1. **Quick Access**: Use system tray/menu bar icon
2. **Browser Integration**: Install browser extension and connect to desktop app
3. **Keyboard Shortcuts**: 
   - `Cmd/Ctrl + Shift + L` - Auto-fill login
   - `Cmd/Ctrl + Shift + Y` - Open Bitwarden
4. **Touch ID/Biometric**: Enable in settings for quick unlock

## 🔒 Security Best Practices

1. **Strong Master Password**: Use a unique, strong master password
2. **Two-Factor Authentication**: Enable 2FA in your Bitwarden account
3. **Regular Backups**: Export your vault periodically
4. **Session Management**: Always lock/logout when done
5. **API Keys**: Store API keys in secure locations (e.g., using sops-nix)

## 🧩 Integration with Other Modules

### Browser Integration
Works seamlessly with browser modules:
- `applications.desktop.browsers.firefox`
- `applications.desktop.browsers.chrome`
- `applications.desktop.browsers.brave`

### Shell Integration
Automatically integrates with enabled shells:
- `applications.terminal.shells.zsh`
- `applications.terminal.shells.bash`
- `applications.terminal.shells.fish`
- `applications.terminal.shells.nu`

### Secret Management
Can be combined with:
- `darwin.security.sops` for API key storage
- SSH modules for secure key management

## 🐛 Troubleshooting

### Desktop App Issues

**App won't start:**
```bash
# Check logs
tail -f /tmp/bitwarden.*.log

# Reset config
rm -rf ~/.config/Bitwarden
```

**Browser integration not working:**
1. Ensure browser extension is installed
2. Enable integration in Bitwarden settings
3. Restart both browser and Bitwarden app

### CLI Issues

**Session expires quickly:**
```bash
# Increase timeout in configuration
applications.terminal.tools.bitwarden-cli.settings.sessionTimeout = 3600;
```

**Commands not found:**
```bash
# Ensure PATH is correct
which bw
# Should show: /Users/username/.nix-profile/bin/bw

# Reload shell configuration
source ~/.zshrc  # or ~/.bashrc
```

**rbw pinentry issues:**
```bash
# Test pinentry
echo "test" | pinentry-mac

# Use terminal-based pinentry if GUI fails
applications.terminal.tools.bitwarden-cli.rbw.pinentry = "pinentry-curses";
```

## 📚 Resources

- [Bitwarden Official Documentation](https://bitwarden.com/help/)
- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [rbw Documentation](https://github.com/doy/rbw)
- [Browser Extension Guide](https://bitwarden.com/help/getting-started-browserext/)

## 🤝 Contributing

To contribute improvements to these modules:

1. Follow the project's [CONTRIBUTING.md](../../../../../../CONTRIBUTING.md) guidelines
2. Test changes on both macOS and Linux if possible
3. Update this README with new features or options
4. Include examples for new configuration options