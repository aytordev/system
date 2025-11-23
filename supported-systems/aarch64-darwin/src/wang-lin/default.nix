{
  inputs,
  lib,
  libraries,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "wang-lin";
  modules = {
    darwin-modules =
      (map libraries.relativeToRoot [
          "modules/darwin/nix/default.nix"
          "modules/darwin/system/fonts/default.nix"
          "modules/darwin/system/interface/default.nix"
          "modules/darwin/system/input/default.nix"
          "modules/darwin/system/networking/default.nix"
          "modules/darwin/system/rosetta/default.nix"
          "modules/darwin/security/sops/default.nix"
          "modules/darwin/security/sudo/default.nix"
          "modules/darwin/services/openssh/default.nix"
          "modules/darwin/services/protonmail-bridge/default.nix"
          "modules/darwin/tools/homebrew/default.nix"
          "modules/darwin/user/default.nix"
          "modules/darwin/applications/terminal/tools/ssh/default.nix"
        ]
        ++ [
          inputs.sops-nix.darwinModules.sops
        ])
      ++ (map libraries.relativeToRoot [
        "supported-systems/aarch64-darwin/src/wang-lin/system/default.nix"
      ]);
    home-modules =
      (map libraries.relativeToRoot [
        "modules/home/user/default.nix"
        "modules/darwin/home/default.nix"
        # "modules/home/applications/terminal/emulators/warp/default.nix"
        "modules/home/applications/terminal/emulators/ghostty/default.nix"
        "modules/home/applications/terminal/tools/git/default.nix"
        "modules/home/applications/terminal/tools/starship/default.nix"
        "modules/home/applications/terminal/tools/fzf/default.nix"
        "modules/home/applications/terminal/tools/zoxide/default.nix"
        "modules/home/applications/terminal/tools/bat/default.nix"
        "modules/home/applications/terminal/tools/atuin/default.nix"
        "modules/home/applications/terminal/tools/bottom/default.nix"
        "modules/home/applications/terminal/tools/btop/default.nix"
        "modules/home/applications/terminal/tools/carapace/default.nix"
        "modules/home/applications/terminal/tools/ssh/default.nix"
        "modules/home/applications/terminal/tools/comma/default.nix"
        "modules/home/applications/terminal/tools/direnv/default.nix"
        "modules/home/applications/desktop/communications/discord/default.nix"
        "modules/home/applications/desktop/communications/thunderbird/default.nix"
        # "modules/home/applications/desktop/communications/vesktop/default.nix"
        "modules/home/applications/desktop/security/bitwarden/default.nix"
        "modules/home/applications/terminal/tools/bitwarden-cli/default.nix"
        "modules/home/applications/terminal/tools/eza/default.nix"
        "modules/home/applications/terminal/tools/fastfetch/default.nix"
        "modules/home/applications/terminal/tools/gh/default.nix"
        "modules/home/applications/terminal/tools/git-crypt/default.nix"
        "modules/home/applications/terminal/tools/nh/default.nix"
        "modules/home/applications/terminal/tools/jq/default.nix"
        "modules/home/applications/terminal/tools/navi/default.nix"
        "modules/home/applications/terminal/tools/jujutsu/default.nix"
        "modules/home/applications/terminal/tools/lazygit/default.nix"
        "modules/home/applications/terminal/tools/lazydocker/default.nix"
        "modules/home/applications/terminal/tools/ripgrep/default.nix"
        "modules/home/applications/terminal/tools/zellij/default.nix"
        "modules/home/applications/terminal/tools/yazi/default.nix"
        "modules/home/applications/terminal/tools/ollama/default.nix"
        "modules/home/applications/terminal/shells/zsh/default.nix"
        "modules/home/applications/terminal/shells/bash/default.nix"
        "modules/home/applications/terminal/shells/fish/default.nix"
        "modules/home/applications/terminal/shells/nu-shell/default.nix"
        # "modules/home/applications/desktop/bars/sketchybar/default.nix"
        "modules/home/applications/desktop/browsers/chrome/default.nix"
        "modules/home/applications/desktop/browsers/chrome-dev/default.nix"
        "modules/home/applications/desktop/browsers/brave/default.nix"
        "modules/home/applications/desktop/browsers/chromium/default.nix"
        "modules/home/applications/desktop/browsers/firefox/default.nix"
        "modules/home/applications/desktop/editors/vscode/default.nix"
        "modules/home/applications/desktop/editors/antigravity/default.nix"
        "modules/home/applications/desktop/editors/zed/default.nix"
        "modules/home/applications/desktop/launchers/raycast/default.nix"
        "modules/home/applications/desktop/window-manager-system/aerospace/default.nix"
      ])
      ++ (map libraries.relativeToRoot [
        "homes/aarch64-darwin/aytordev@wang-lin/default.nix"
      ]);
  };
  systemArgs =
    modules
    // args
    // {
      hostName = name;
      specialArgs = genSpecialArgs system;
    };
in {
  darwinConfigurations.${name} = libraries.macosSystem systemArgs;
}
