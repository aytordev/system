{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.aytordev.programs.terminal.tools.meridian;
  opencodeEnabled = config.aytordev.programs.terminal.tools.opencode.enable;
in
{
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
        description = "Enable opencode-with-claude plugin integration";
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
    home = {
      packages = [
        pkgs.aytordev.meridian
        pkgs.nodejs_22 # Runtime dep: claude-agent-sdk spawns `node cli.js` as child process
      ];

      # Make opencode-with-claude plugin discoverable via NODE_PATH
      sessionVariables.NODE_PATH = mkIf (opencodeEnabled && cfg.opencode.plugin)
        "${pkgs.aytordev.opencode-with-claude}/lib/node_modules";
    };

    # OpenCode integration: register plugin, configure provider
    programs.opencode.settings = mkIf opencodeEnabled {
      plugin = mkIf cfg.opencode.plugin [ "opencode-with-claude" ];

      model = cfg.opencode.defaultModel;

      provider.anthropic.options = {
        baseURL = "http://${cfg.proxy.host}:${toString cfg.proxy.port}";
        apiKey = "dummy";
      };
    };
  };
}
