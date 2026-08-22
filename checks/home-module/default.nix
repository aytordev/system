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
  ollamaHome = mkHome [
    ../../modules/home/programs/terminal/tools/ollama
    {
      aytordev.programs.terminal.tools.ollama = {
        enable = true;
        advancedScripts.enable = true;
        integrations.zed = false;
        modelPresets = ["general"];
        service.enable = true;
      };
    }
  ];
  litellmHome = mkHome [
    ../../modules/home/programs/terminal/tools/litellm
    {
      aytordev.programs.terminal.tools.litellm = {
        enable = true;
        service.enable = true;
        environmentFiles.OPENAI_API_KEY = "/run/secrets/openai-api-key";
      };
    }
  ];
  ollamaPackageNames = map extendedLib.getName ollamaHome.config.home.packages;
  discoveredOllamaModules = builtins.filter (
    modulePath: extendedLib.hasInfix "/ollama" (toString modulePath)
  ) (extendedLib.importModulesRecursive ../../modules/home);
  injectedHome = inputs.self.lib.system.mkHome {
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "injected-host";
    username = "injected-user";
    homeModules = [
      ({lib, ...}: {
        options.testMarker = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        config.testMarker = true;
      })
    ];
    modules = [
      {
        home = {
          username = "injected-user";
          homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Users/injected-user"
            else "/home/injected-user";
          stateVersion = "25.11";
        };
      }
    ];
  };
  tests = [
    (claudeHome.config.programs.claude-code.settings.permissions.defaultMode == "acceptEdits")
    (builtins.length discoveredClaudeModules == 1)
    (extendedLib.hasSuffix "/claude-code" (toString (builtins.head discoveredClaudeModules)))
    (
      ollamaHome.config.aytordev.programs.terminal.tools.ollama.models
      == [
        "llama3.2"
        "mistral"
      ]
    )
    (ollamaHome.options.aytordev.programs.terminal.tools.ollama.integrations ? zed)
    (builtins.elem "ollama-chat" ollamaPackageNames)
    (
      if pkgs.stdenv.hostPlatform.isDarwin
      then ollamaHome.config.launchd.agents ? ollama
      else ollamaHome.config.systemd.user.services ? ollama
    )
    (
      if pkgs.stdenv.hostPlatform.isDarwin
      then litellmHome.config.launchd.agents ? litellm
      else litellmHome.config.systemd.user.services ? litellm
    )
    (!(litellmHome.config.home.sessionVariables ? OPENAI_API_KEY))
    (builtins.elem "ollama-rag" ollamaPackageNames)
    (builtins.elem "ollama-validate" ollamaPackageNames)
    (builtins.elem "ollama-status" ollamaPackageNames)
    (builtins.length discoveredOllamaModules == 1)
    (extendedLib.hasSuffix "/ollama" (toString (builtins.head discoveredOllamaModules)))
    injectedHome.config.testMarker
  ];
in
  assert builtins.all (test: test) tests;
    home.activationPackage
