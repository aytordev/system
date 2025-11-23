{
  config,
  lib,
  inputs,
  ...
}: {
  home.stateVersion = "25.11";
  user.enable = true;
  user.name = inputs.secrets.username;
  user.home = "/Users/${inputs.secrets.username}";
  home.enable = true;
  home.files = {};
  home.configs = {};
  # applications.desktop.bars.sketchybar.enable = true;
  applications.desktop.browsers.chrome.enable = true;
  applications.desktop.browsers.chrome-dev.enable = true;
  applications.desktop.browsers.brave.enable = true;
  applications.desktop.browsers.chromium.enable = true;
  applications.desktop.browsers.firefox.enable = true;
  applications.desktop.window-manager-system.aerospace.enable = true;
  applications.desktop.communications.discord.enable = true;
  applications.desktop.communications.thunderbird.enable = true;
  # applications.desktop.communications.vesktop.enable = true;
  applications.desktop.editors.vscode.enable = false;
  applications.desktop.editors.antigravity.enable = true;
  applications.desktop.editors.zed.enable = true;
  applications.desktop.launchers.raycast.enable = true;
  applications.terminal.tools.git.enable = true;
  applications.terminal.tools.git.signingKey = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  applications.terminal.shells.zsh.enable = true;
  applications.terminal.shells.bash.enable = true;
  applications.terminal.shells.fish.enable = true;
  applications.terminal.shells.nu.enable = true;
  applications.terminal.tools.starship.enable = true;
  applications.terminal.tools.starship.enableZshIntegration = true;
  applications.terminal.tools.starship.enableFishIntegration = true;
  applications.terminal.tools.starship.enableBashIntegration = true;
  applications.terminal.tools.starship.enableNushellIntegration = true;
  applications.terminal.tools.fzf.enable = true;
  applications.terminal.tools.zoxide.enable = true;
  applications.terminal.tools.bat.enable = true;
  applications.terminal.tools.atuin.enable = true;
  applications.terminal.tools.atuin.enableBashIntegration = true;
  applications.terminal.tools.atuin.enableFishIntegration = true;
  applications.terminal.tools.fastfetch.enable = true;
  applications.terminal.tools.atuin.enableZshIntegration = true;
  applications.terminal.tools.atuin.enableNushellIntegration = true;
  applications.terminal.tools.bottom.enable = true;
  applications.terminal.tools.btop.enable = true;
  applications.terminal.tools.carapace.enable = true;
  applications.terminal.tools.comma.enable = true;
  applications.terminal.emulators.ghostty.enable = true;
  applications.terminal.emulators.ghostty.theme = "catppuccin-mocha";
  applications.terminal.emulators.ghostty.enableThemes = true;
  applications.terminal.tools.ssh.enable = true;
  applications.terminal.tools.ssh.knownHosts.github.hostNames = ["github.com"];
  applications.terminal.tools.ssh.knownHosts.github.user = "git";
  applications.terminal.tools.ssh.knownHosts.github.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
  applications.terminal.tools.ssh.knownHosts.github.identityFile = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  applications.terminal.tools.ssh.knownHosts.github.identitiesOnly = true;
  applications.terminal.tools.ssh.knownHosts.github.port = 22;
  applications.terminal.tools.ssh.extraConfig = '''';
  applications.terminal.tools.jq.enable = true;
  applications.terminal.tools.direnv.enable = true;
  applications.terminal.tools.direnv.nix-direnv = true;
  applications.terminal.tools.direnv.silent = true;
  applications.terminal.tools.eza.enable = true;
  applications.terminal.tools.nh.enable = true;
  applications.terminal.tools.gh.enable = true;
  applications.terminal.tools.git-crypt.enable = true;
  applications.terminal.tools.jujutsu.enable = true;
  applications.terminal.tools.jujutsu.signByDefault = true;
  applications.terminal.tools.lazygit.enable = true;
  applications.terminal.tools.lazydocker.enable = true;
  applications.terminal.tools.navi.enable = true;
  applications.terminal.tools.navi.settings.style.tag.color = "green";
  applications.terminal.tools.navi.settings.style.tag.width_percentage = 26;
  applications.terminal.tools.navi.settings.style.tag.min_width = 20;
  applications.terminal.tools.navi.settings.style.comment.color = "blue";
  applications.terminal.tools.navi.settings.style.comment.width_percentage = 42;
  applications.terminal.tools.navi.settings.style.comment.min_width = 45;
  applications.terminal.tools.navi.settings.style.snippet.color = "white";
  applications.terminal.tools.navi.settings.style.snippet.width_percentage = 42;
  applications.terminal.tools.navi.settings.style.snippet.min_width = 45;
  applications.terminal.tools.ripgrep.enable = true;
  applications.terminal.tools.yazi.enable = true;
  # applications.terminal.emulators.warp.enable = true;
  applications.terminal.tools.zellij.enable = true;
  # Bitwarden password manager
  applications.desktop.security.bitwarden.enable = true;
  applications.desktop.security.bitwarden.enableBrowserIntegration = true;
  applications.desktop.security.bitwarden.enableTrayIcon = true;
  applications.desktop.security.bitwarden.biometricUnlock.enable = true;
  applications.desktop.security.bitwarden.vault.timeout = 30;
  applications.desktop.security.bitwarden.vault.timeoutAction = "lock";
  # Bitwarden CLI is temporarily disabled due to broken package in nixpkgs
  # Using rbw as alternative CLI client
  applications.terminal.tools.bitwarden-cli.enable = true;
  applications.terminal.tools.bitwarden-cli.shellIntegration.enable = true;
  applications.terminal.tools.bitwarden-cli.shellIntegration.enableZshIntegration = true;
  applications.terminal.tools.bitwarden-cli.shellIntegration.enableBashIntegration = true;
  applications.terminal.tools.bitwarden-cli.shellIntegration.enableFishIntegration = true;
  applications.terminal.tools.bitwarden-cli.aliases.enable = true;
  applications.terminal.tools.bitwarden-cli.rbw.enable = true;
  applications.terminal.tools.bitwarden-cli.settings.apiKey.useSops = true;
  applications.terminal.tools.bitwarden-cli.settings.apiKey.clientIdPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_id";
  applications.terminal.tools.bitwarden-cli.settings.apiKey.clientSecretPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_secret";

  # Ollama - Local LLM Runner
  # Disabled: Using Homebrew cask version instead for better macOS integration
  applications.terminal.tools.ollama.enable = false;
  applications.terminal.tools.ollama.acceleration = "metal"; # Use Metal for GPU acceleration on macOS
  applications.terminal.tools.ollama.models = [
    "llama3.2"      # General purpose 3B model
    "codellama"     # Code generation
    "mistral"       # 7B general model
  ];
  applications.terminal.tools.ollama.service.enable = true;
  applications.terminal.tools.ollama.service.autoStart = true;
  applications.terminal.tools.ollama.shellAliases = true;
  # Shell aliases are now handled automatically by the module
  applications.terminal.tools.ollama.environmentVariables = {
     OLLAMA_NUM_PARALLEL = "2";
     OLLAMA_MAX_LOADED_MODELS = "2";
     OLLAMA_KEEP_ALIVE = "5m";
  };
  # Enable Zed integration through new module structure
  applications.terminal.tools.ollama.integrations.zed = true;
  applications.terminal.tools.ollama.modelPresets = [ "general" "coding" ];
}
