{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.opencode;

  aiTools = import (lib.getFile "modules/common/ai-tools") {inherit lib;};

  primaryAgents = [
    "sdd-orchestrator"
  ];

  buildAgentConfigs = agentConfigs:
    lib.mapAttrs (
      name: agentConfig:
        agentConfig
        // {
          mode =
            if builtins.elem name primaryAgents
            then "primary"
            else "subagent";
        }
    )
    agentConfigs;

  # Hybrid theme resolution: exact official theme when the active family ships
  # one for the active variant, otherwise the palette-generated theme. OpenCode
  # themes are JSON documents selected by name via `tui.theme`.
  opencodeTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeCfg = config.aytordev.theme;

  themeIntegration = themeCfg.integrations.${themeCfg.name}.opencode or null;

  themeResolution = opencodeTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeIntegration;
  };

  generatedTheme = opencodeTheme.render {
    inherit (themeCfg) palette ansi;
  };

  generatedThemeFile = pkgs.writeText "${opencodeTheme.generatedId}.json" (
    builtins.toJSON generatedTheme
  );

  # One directory holding every vendored official theme plus the generated
  # theme, so Home Manager deploys `opencode/themes` as a single directory
  # symlink. The store is read-only, so declaring individual files inside a
  # store-backed symlink is not possible.
  opencodeThemes = pkgs.runCommand "opencode-themes" {} (
    lib.concatStrings [
      "mkdir -p $out\n"
      (lib.concatStrings (
        lib.mapAttrsToList (id: src: "cp ${src} $out/${id}.json\n") opencodeTheme.officialThemes
      ))
      "cp ${generatedThemeFile} $out/${opencodeTheme.generatedId}.json\n"
    ]
  );

  # Ids an explicit override may name: the vendored official themes plus the
  # generated one.
  themeNames = builtins.attrNames opencodeTheme.officialThemes ++ [opencodeTheme.generatedId];

  # Manual override validation: only the vendored official ids and the generated
  # id are materializable, so a bare override (or submodule id) must name one of
  # them.
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated theme, manual pins id, none leaves OpenCode's default.";
      };
      id = mkOption {
        type = types.nullOr (types.enum themeNames);
        default = null;
        description = "Theme id to pin when mode = \"manual\".";
      };
    };
  };
in {
  imports = [
    ./formatters.nix
    ./lsp.nix
    ./mcp.nix
    ./permission.nix
    ./provider.nix
  ];

  options.aytordev.programs.terminal.tools.opencode = {
    enable = mkEnableOption "OpenCode configuration";
    package = lib.mkPackageOption pkgs "opencode" {nullable = true;};

    model = {
      model = mkOption {
        type = types.str;
        default = "anthropic/claude-sonnet-4-5";
        description = "Default model to use";
      };

      provider = mkOption {
        type = types.str;
        default = "anthropic";
        description = "Default provider for model";
      };
    };

    theme = mkOption {
      type = types.nullOr (types.either (types.enum themeNames) themeOverrideType);
      default = null;
      description = ''
        OpenCode theme override. Null follows `aytordev.theme` through the hybrid
        resolver: the family's official theme when it covers the active variant,
        otherwise a theme generated from the active palette. A bare vendored id
        (or `{ mode = "manual"; id = ...; }`) pins a theme; `{ mode = "none"; }`
        leaves OpenCode's own default.
        Available themes: ${builtins.concatStringsSep ", " themeNames}
      '';
    };
  };

  config = mkIf cfg.enable {
    # Deploy the vendored official themes and the generated theme as a single
    # directory symlink; `tui.theme` selects one by name.
    xdg.configFile."opencode/themes" = {
      source = opencodeThemes;
    };

    home.shellAliases = {
      oc = "opencode";
      oc-sonnet = "opencode run -m anthropic/claude-sonnet-4-6";
      oc-opus = "opencode run -m anthropic/claude-opus-4-7";
      oc-haiku = "opencode run -m anthropic/claude-haiku-4-5-20251001";
    };
    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      settings = {
        model = lib.mkDefault cfg.model.model;
        autoshare = false;
        autoupdate = false;

        agent = buildAgentConfigs aiTools.opencode.agentConfigs;
      };

      tui = opencodeTheme.themeEntry themeResolution;

      inherit (aiTools.opencode) agents commands;

      context = builtins.readFile (lib.getFile "modules/common/ai-tools/base.md");

      # OpenCode is now the primary harness for the shared ai-tools skills
      # (Claude Code/Gemini CLI were removed).
      skills = lib.getFile "modules/common/ai-tools/skills";
    };
  };
}
