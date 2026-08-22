{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  baseHome = {
    home = {
      username = "module-test";
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/module-test"
        else "/home/module-test";
      stateVersion = "25.11";
    };
  };
  mkHome = modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        hostname = "module-test";
        username = "module-test";
        osConfig = {};
        lib = extendedLib;
      };
      modules = modules ++ [baseHome];
    };
  home = mkHome [
    inputs.self.homeModules.default
    (
      {
        config,
        lib,
        ...
      }: {
        assertions = [
          {
            assertion = lib.attrByPath ["programs" "opencode" "settings" "lsp"] {} config == {};
            message = "OpenCode LSP settings must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "opencode" "settings" "formatter"] {} config == {};
            message = "OpenCode formatter settings must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "opencode" "settings" "permission"] {} config == {};
            message = "OpenCode permissions must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "opencode" "settings" "mcp"] {} config == {};
            message = "OpenCode MCP settings must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "zellij" "settings" "keybinds"] {} config == {};
            message = "Zellij keybinds must be empty while the aytordev module is disabled";
          }
          {
            assertion = lib.attrByPath ["programs" "zellij" "layouts"] {} config == {};
            message = "Zellij layouts must be empty while the aytordev module is disabled";
          }
        ];
      }
    )
  ];
  claudeHome = mkHome [
    ../../modules/home/programs/terminal/tools/claude-code
    {
      aytordev.programs.terminal.tools.claude-code = {
        enable = true;
        permissionProfile = "autonomous";
      };
    }
  ];
  discoveredClaudeModules = builtins.filter (
    modulePath: extendedLib.hasInfix "/claude-code" (toString modulePath)
  ) (extendedLib.importModulesRecursive ../../modules/home);
  tests = [
    (claudeHome.config.programs.claude-code.settings.permissions.defaultMode == "acceptEdits")
    (builtins.length discoveredClaudeModules == 1)
    (extendedLib.hasSuffix "/claude-code" (toString (builtins.head discoveredClaudeModules)))
  ];
in
  assert builtins.all (test: test) tests;
    home.activationPackage
