{
  inputs,
  lib,
  pkgs,
  ...
}: let
  home = inputs.self.lib.system.mkHome {
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "module-contract";
    username = "module-contract";
    modules = [
      {
        home = {
          username = "module-contract";
          homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Users/module-contract"
            else "/home/module-contract";
          stateVersion = "25.11";
        };
      }
    ];
  };
  packageCapabilities = [
    "programs.desktop.bars.sketchybar"
    "programs.desktop.browsers.firefox"
    "programs.desktop.communications.discord"
    "programs.desktop.communications.thunderbird"
    "programs.desktop.communications.vesktop"
    "programs.desktop.editors.vscode"
    "programs.desktop.editors.zed"
    "programs.desktop.launchers.raycast"
    "programs.desktop.security.bitwarden"
    "programs.desktop.window-manager-system.aerospace"
    "programs.terminal.editors.neovim"
    "programs.terminal.emulators.ghostty"
    "programs.terminal.shells.bash"
    "programs.terminal.shells.fish"
    "programs.terminal.shells.nushell"
    "programs.terminal.shells.zsh"
    "programs.terminal.tools.act"
    "programs.terminal.tools.atuin"
    "programs.terminal.tools.bat"
    "programs.terminal.tools.bitwarden-cli"
    "programs.terminal.tools.bottom"
    "programs.terminal.tools.btop"
    "programs.terminal.tools.carapace"
    "programs.terminal.tools.comma"
    "programs.terminal.tools.dircolors"
    "programs.terminal.tools.direnv"
    "programs.terminal.tools.engram"
    "programs.terminal.tools.eza"
    "programs.terminal.tools.fastfetch"
    "programs.terminal.tools.ffmpeg"
    "programs.terminal.tools.fzf"
    "programs.terminal.tools.gentle-ai"
    "programs.terminal.tools.gh"
    "programs.terminal.tools.git"
    "programs.terminal.tools.git-crypt"
    "programs.terminal.tools.hcloud"
    "programs.terminal.tools.herdr"
    "programs.terminal.tools.hunk"
    "programs.terminal.tools.infat"
    "programs.terminal.tools.jjui"
    "programs.terminal.tools.jq"
    "programs.terminal.tools.jujutsu"
    "programs.terminal.tools.k9s"
    "programs.terminal.tools.lazydocker"
    "programs.terminal.tools.lazygit"
    "programs.terminal.tools.lsd"
    "programs.terminal.tools.navi"
    "programs.terminal.tools.nh"
    "programs.terminal.tools.nix-search-tv"
    "programs.terminal.tools.pi"
    "programs.terminal.tools.podman-compose"
    "programs.terminal.tools.rclone"
    "programs.terminal.tools.ripgrep"
    "programs.terminal.tools.ssh"
    "programs.terminal.tools.starship"
    "programs.terminal.tools.tmux"
    "programs.terminal.tools.yazi"
    "programs.terminal.tools.yt-dlp"
    "programs.terminal.tools.zellij"
    "programs.terminal.tools.zoxide"
    "services.jankyborders"
    "services.protonmail-bridge"
  ];
  hasPackageOption = capability:
    lib.hasAttrByPath (["aytordev"] ++ lib.splitString "." capability ++ ["package"]) home.options;
  missingPackageOptions =
    builtins.filter (
      capability: !hasPackageOption capability
    )
    packageCapabilities;
in
  if missingPackageOptions == []
  then
    pkgs.runCommand "module-contract-check" {} ''
      touch "$out"
    ''
  else throw "Capabilities missing a package option: ${lib.concatStringsSep ", " missingPackageOptions}"
