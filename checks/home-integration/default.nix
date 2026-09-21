{
  inputs,
  identity,
  lib,
  pkgs,
  ...
}: let
  inherit (identity) username;
  home = inputs.self.homeConfigurations."${username}@wang-lin".config;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  integratedHome = darwin.config.home-manager.users.${username};
  bitwardenSettings =
    builtins.fromJSON
    home.home.file."Library/Application Support/Bitwarden/data.json".text;
  activationText =
    lib.attrByPath [
      "system"
      "activationScripts"
      "extraActivation"
      "text"
    ] ""
    darwin.config;
  getLogAlias = config: lib.attrByPath ["programs" "bash" "shellAliases" "log"] null config;
  getXdgConfigHome = config: lib.attrByPath ["home" "sessionVariables" "XDG_CONFIG_HOME"] null config;
  tests = [
    home.xdg.enable
    integratedHome.xdg.enable
    (getXdgConfigHome home == home.xdg.configHome)
    (getXdgConfigHome integratedHome == integratedHome.xdg.configHome)
    (getLogAlias home == "command log")
    (getLogAlias integratedHome == "command log")
    (darwin.config.home-manager.backupFileExtension == "hm.old")
    darwin.config.home-manager.verbose
    darwin.config.home-manager.useGlobalPkgs
    darwin.config.home-manager.useUserPackages
    (!lib.hasAttrByPath ["aytordev" "home"] darwin.options)
    (home.programs.nh.flake == "${home.home.homeDirectory}/Developer/system")
    (home.home.shellAliases.nixcfg == "nvim ${home.programs.nh.flake}/flake.nix")
    (
      darwin.config.system.defaults.screencapture.location
      == "${home.home.homeDirectory}/Pictures/screenshots/"
    )
    (!lib.hasInfix "Creating screenshots directory" activationText)
    (!darwin.config.homebrew.onActivation.autoUpdate)
    (!darwin.config.homebrew.onActivation.upgrade)
    (!(builtins.hasAttr "nix/inputs/secrets" darwin.config.environment.etc))
    (home.aytordev.user.name == identity.username)
    (home.aytordev.user.email == identity.email)
    (home.aytordev.user.fullName == identity.fullName)
    bitwardenSettings.enableBrowserIntegration
    bitwardenSettings.biometricUnlock
    (bitwardenSettings.vaultTimeout == 30)
    (bitwardenSettings.vaultTimeoutAction == "lock")
    (!(builtins.any (lib.hasInfix "sketchybar") home.programs.aerospace.settings.after-startup-command))
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-integration-tests" {} ''
      touch "$out"
    ''
