# Home Manager Configuration for aytordev@wang-lin
#
# This file contains user-specific configuration for the 'aytordev' user on the 'wang-lin' host.
# It's part of the system's modular configuration and is imported by the system's home configuration.
#
# This configuration is specific to Darwin (macOS) systems and includes packages and settings
# that should only apply to this user on this specific host.
#
# Version: 2.0.1
# Last Updated: 2025-06-23fa
{
  config,
  lib,
  inputs,
  ...
}: {
  # Home Manager version compatibility
  #
  # Important: This value should not be changed unless you're prepared to perform
  # the necessary migrations. It determines the version of Home Manager to be
  # compatible with.
  home.stateVersion = "25.11";

  # Enable and configure the user module
  user.enable = true;
  # The username for the account
  user.name = inputs.secrets.username;
  # The home directory for the account
  user.home = "/Users/${inputs.secrets.username}";

  # Enable and configure the home module
  home.enable = true;
  # The home files to manage
  home.files = {};
  # The XDG config files to manage
  home.configs = {};

  # Enable my git configuration
  applications.terminal.tools.git.enable = true;
  applications.terminal.tools.git.signingKey = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";

  # Enable my zsh configuration
  applications.terminal.shells.zsh.enable = true;

  # Enable my bash configuration
  applications.terminal.shells.bash.enable = true;

  # Enable my fish configuration
  applications.terminal.shells.fish.enable = true;

  # Enable my nu shell configuration
  applications.terminal.shells.nu.enable = true;

  # Enable my starship configuration
  applications.terminal.tools.starship.enable = true;
  applications.terminal.tools.starship.enableZshIntegration = true;
  applications.terminal.tools.starship.enableFishIntegration = true;
  applications.terminal.tools.starship.enableBashIntegration = true;
  applications.terminal.tools.starship.enableNushellIntegration = true;

  # Enable my fzf configuration
  applications.terminal.tools.fzf.enable = true;

  # Enable my zoxide configuration
  applications.terminal.tools.zoxide.enable = true;

  # Enable my bat configuration
  applications.terminal.tools.bat.enable = true;

  # Example configurations (commented out for reference):
  # ====================================================
  #
  # 1. Install user-specific packages:
  # home.packages = with pkgs; [
  #   git
  #   htop
  #   jq
  # ];
  #
  # 2. Configure Git:
  # programs.git = {
  #   enable = true;
  #   userName = "Aytor Vicente Martinez";
  #   userEmail = "me@aytor.dev";
  #   extraConfig = {
  #     core.editor = "nvim";
  #     pull.rebase = true;
  #   };
  # };
  #
  # 3. Add shell aliases:
  # programs.bash.shellAliases = {
  #   ll = "ls -la";
  #   update = "sudo nixos-rebuild switch";
  # };
}
