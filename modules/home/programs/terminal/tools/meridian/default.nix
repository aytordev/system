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

  cfg = config.aytordev.programs.terminal.tools.meridian;
  opencodeEnabled = config.aytordev.programs.terminal.tools.opencode.enable;
in {
  options.aytordev.programs.terminal.tools.meridian = {
    enable = mkEnableOption ''
      Meridian proxy for Claude Max subscription.
      After enabling, run: claude login
    '';

    proxy = {
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Meridian proxy bind address";
      };

      port = mkOption {
        type = types.port;
        default = 3456;
        description = "Meridian proxy port";
      };
    };

    opencode = {
      plugin = mkOption {
        type = types.bool;
        default = true;
        description = "Enable meridian opencode plugin integration";
      };

      scrubPlugin = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Strip OpenCode identifying fingerprints from the system prompt.
            Prevents Anthropic from detecting third-party clients and routing
            requests to extra usage billing instead of the Max plan.
          '';
        };
      };

      defaultModel = mkOption {
        type = types.str;
        default = "claude-sonnet-4-6";
        description = ''
          Default model when using Meridian proxy.
          Options: claude-opus-4-6, claude-sonnet-4-6, claude-haiku-4-5
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.meridian];

    programs.opencode.settings = mkIf opencodeEnabled {
      plugin = mkIf cfg.opencode.plugin [
        "${pkgs.meridian}/lib/meridian/plugin/meridian.ts"
      ];

      model = cfg.opencode.defaultModel;

      provider.anthropic.options = {
        baseURL = "http://${cfg.proxy.host}:${toString cfg.proxy.port}";
        apiKey = "dummy";
      };
    };

    xdg.configFile."meridian/plugins.json" = mkIf cfg.opencode.scrubPlugin.enable {
      text = builtins.toJSON {
        plugins = [
          {
            path = "${pkgs.aytordev.meridian-plugin-opencode-scrub}/lib/dist/index.js";
            enabled = true;
          }
        ];
      };
    };
  };
}
