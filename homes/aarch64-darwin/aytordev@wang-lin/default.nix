{
  config,
  lib,
  inputs,
  ...
}: {
  home.stateVersion = "25.11";
  aytordev.user.enable = true;
  aytordev.user.name = inputs.secrets.username;
  aytordev.user.home = "/Users/${inputs.secrets.username}";
  # aytordev.applications.desktop.bars.sketchybar.enable = true;
  aytordev.applications.desktop.browsers.chrome.enable = true;
  aytordev.applications.desktop.browsers.chrome-dev.enable = true;
  aytordev.applications.desktop.browsers.brave.enable = true;
  aytordev.applications.desktop.browsers.chromium.enable = true;
  aytordev.applications.desktop.browsers.firefox.enable = true;
  applications.desktop.window-manager-system.aerospace.enable = true;
  applications.desktop.communications.discord.enable = true;
  applications.desktop.communications.thunderbird.enable = true;
  # applications.desktop.communications.vesktop.enable = true;
  applications.desktop.editors.vscode.enable = false;
  applications.desktop.editors.antigravity.enable = true;
  applications.desktop.editors.zed.enable = true;
  applications.desktop.launchers.raycast.enable = true;
  aytordev.applications.terminal.tools.git.enable = true;
  aytordev.applications.terminal.tools.git.signingKey = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  aytordev.applications.terminal.shells.zsh.enable = true;
  aytordev.applications.terminal.shells.bash.enable = true;
  aytordev.applications.terminal.shells.fish.enable = true;
  aytordev.applications.terminal.shells.nu.enable = true;
  aytordev.applications.terminal.tools.starship.enable = true;
  aytordev.applications.terminal.tools.starship.enableZshIntegration = true;
  aytordev.applications.terminal.tools.starship.enableFishIntegration = true;
  aytordev.applications.terminal.tools.starship.enableBashIntegration = true;
  aytordev.applications.terminal.tools.starship.enableNushellIntegration = true;
  aytordev.applications.terminal.tools.fzf.enable = true;
  aytordev.applications.terminal.tools.zoxide.enable = true;
  aytordev.applications.terminal.tools.bat.enable = true;
  aytordev.applications.terminal.tools.atuin.enable = true;
  aytordev.applications.terminal.tools.atuin.enableBashIntegration = true;
  aytordev.applications.terminal.tools.atuin.enableFishIntegration = true;
  aytordev.applications.terminal.tools.fastfetch.enable = true;
  aytordev.applications.terminal.tools.atuin.enableZshIntegration = true;
  aytordev.applications.terminal.tools.atuin.enableNushellIntegration = true;
  aytordev.applications.terminal.tools.bottom.enable = true;
  aytordev.applications.terminal.tools.btop.enable = true;
  aytordev.applications.terminal.tools.carapace.enable = true;
  aytordev.applications.terminal.tools.comma.enable = true;
  aytordev.applications.terminal.emulators.ghostty.enable = true;
  aytordev.applications.terminal.emulators.ghostty.theme = "catppuccin-mocha";
  aytordev.applications.terminal.emulators.ghostty.enableThemes = true;
  aytordev.applications.terminal.tools.ssh.enable = true;
  aytordev.applications.terminal.tools.ssh.knownHosts.github.hostNames = ["github.com"];
  aytordev.applications.terminal.tools.ssh.knownHosts.github.user = "git";
  aytordev.applications.terminal.tools.ssh.knownHosts.github.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
  aytordev.applications.terminal.tools.ssh.knownHosts.github.identityFile = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
  aytordev.applications.terminal.tools.ssh.knownHosts.github.identitiesOnly = true;
  aytordev.applications.terminal.tools.ssh.knownHosts.github.port = 22;
  aytordev.applications.terminal.tools.ssh.extraConfig = '''';
  aytordev.applications.terminal.tools.jq.enable = true;
  aytordev.applications.terminal.tools.direnv.enable = true;
  aytordev.applications.terminal.tools.direnv.nix-direnv = true;
  aytordev.applications.terminal.tools.direnv.silent = true;
  aytordev.applications.terminal.tools.eza.enable = true;
  aytordev.applications.terminal.tools.nh.enable = true;
  aytordev.applications.terminal.tools.gh.enable = true;
  aytordev.applications.terminal.tools.git-crypt.enable = true;
  aytordev.applications.terminal.tools.jujutsu.enable = true;
  aytordev.applications.terminal.tools.jujutsu.signByDefault = true;
  aytordev.applications.terminal.tools.lazygit.enable = true;
  aytordev.applications.terminal.tools.lazydocker.enable = true;
  aytordev.applications.terminal.tools.navi.enable = true;
  aytordev.applications.terminal.tools.navi.settings.style.tag.color = "green";
  aytordev.applications.terminal.tools.navi.settings.style.tag.width_percentage = 26;
  aytordev.applications.terminal.tools.navi.settings.style.tag.min_width = 20;
  aytordev.applications.terminal.tools.navi.settings.style.comment.color = "blue";
  aytordev.applications.terminal.tools.navi.settings.style.comment.width_percentage = 42;
  aytordev.applications.terminal.tools.navi.settings.style.comment.min_width = 45;
  aytordev.applications.terminal.tools.navi.settings.style.snippet.color = "white";
  aytordev.applications.terminal.tools.navi.settings.style.snippet.width_percentage = 42;
  aytordev.applications.terminal.tools.navi.settings.style.snippet.min_width = 45;
  aytordev.applications.terminal.tools.ripgrep.enable = true;
  aytordev.applications.terminal.tools.yazi.enable = true;
  # aytordev.applications.terminal.emulators.warp.enable = true;
  aytordev.applications.terminal.tools.zellij.enable = true;
  # Bitwarden password manager
  applications.desktop.security.bitwarden.enable = true;
  applications.desktop.security.bitwarden.enableBrowserIntegration = true;
  applications.desktop.security.bitwarden.enableTrayIcon = true;
  applications.desktop.security.bitwarden.biometricUnlock.enable = true;
  applications.desktop.security.bitwarden.vault.timeout = 30;
  applications.desktop.security.bitwarden.vault.timeoutAction = "lock";
  # Bitwarden CLI is temporarily disabled due to broken package in nixpkgs
  # Using rbw as alternative CLI client
  aytordev.applications.terminal.tools.bitwarden-cli.enable = true;
  aytordev.applications.terminal.tools.bitwarden-cli.shellIntegration.enable = true;
  aytordev.applications.terminal.tools.bitwarden-cli.shellIntegration.enableZshIntegration = true;
  aytordev.applications.terminal.tools.bitwarden-cli.shellIntegration.enableBashIntegration = true;
  aytordev.applications.terminal.tools.bitwarden-cli.shellIntegration.enableFishIntegration = true;
  aytordev.applications.terminal.tools.bitwarden-cli.aliases.enable = true;
  aytordev.applications.terminal.tools.bitwarden-cli.rbw.enable = true;
  aytordev.applications.terminal.tools.bitwarden-cli.settings.apiKey.useSops = true;
  aytordev.applications.terminal.tools.bitwarden-cli.settings.apiKey.clientIdPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_id";
  aytordev.applications.terminal.tools.bitwarden-cli.settings.apiKey.clientSecretPath = "/Users/${inputs.secrets.username}/.config/sops/bitwarden_api_client_secret";

  # Ollama - Local LLM Runner
  # Disabled: Using Homebrew cask version instead for better macOS integration
  aytordev.applications.terminal.tools.ollama.enable = false;
  aytordev.applications.terminal.tools.ollama.acceleration = "metal"; # Use Metal for GPU acceleration on macOS
  aytordev.applications.terminal.tools.ollama.models = [
    "llama3.2"      # General purpose 3B model
    "codellama"     # Code generation
    "mistral"       # 7B general model
  ];
  aytordev.applications.terminal.tools.ollama.service.enable = true;
  aytordev.applications.terminal.tools.ollama.service.autoStart = true;
  aytordev.applications.terminal.tools.ollama.shellAliases = true;
  # Shell aliases are now handled automatically by the module
  aytordev.applications.terminal.tools.ollama.environmentVariables = {
     OLLAMA_NUM_PARALLEL = "2";
     OLLAMA_MAX_LOADED_MODELS = "2";
     OLLAMA_KEEP_ALIVE = "5m";
  };
  # Enable Zed integration through new module structure
  aytordev.applications.terminal.tools.ollama.integrations.zed = true;
  aytordev.applications.terminal.tools.ollama.modelPresets = [ "general" "coding" ];
}
