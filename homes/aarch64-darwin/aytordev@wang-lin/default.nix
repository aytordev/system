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
  applications.terminal.emulators.warp.enable = true;
  applications.terminal.tools.zellij.enable = true;
}
