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
  applications.terminal.tools.atuin.enableZshIntegration = true;
  applications.terminal.tools.atuin.enableNushellIntegration = true;
  applications.terminal.tools.bottom.enable = true;
  applications.terminal.tools.btop.enable = true;
  applications.terminal.tools.carapace.enable = true;
  applications.terminal.tools.comma.enable = true;
  applications.terminal.tools.ssh.enable = true;
  applications.terminal.tools.ssh.knownHosts = {
    github = {
      hostNames = ["github.com"];
      user = "git";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsKijb0PXKfsAmPu0t0jIsiYqfvhyiwPdrWWIwCSzpJ";
      identityFile = "/Users/${inputs.secrets.username}/.ssh/ssh_key_github_ed25519";
      identitiesOnly = true;
      port = 22;
    };
  };
  applications.terminal.tools.ssh.extraConfig = ''
  '';
  applications.terminal.tools.direnv.enable = true;
  applications.terminal.tools.direnv.nix-direnv = true;
  applications.terminal.tools.direnv.silent = true;
}
