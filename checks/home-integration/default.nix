{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = inputs.secrets.username;
  home = inputs.self.homeConfigurations."${username}@wang-lin".config;
  darwin = inputs.self.darwinConfigurations.wang-lin;
  integratedHome = darwin.config.home-manager.users.${username};
  getLogAlias = config: lib.attrByPath ["home" "shellAliases" "log"] null config;
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
  ];
in
  assert builtins.all (test: test) tests;
    pkgs.runCommand "home-integration-tests" {} ''
      touch "$out"
    ''
