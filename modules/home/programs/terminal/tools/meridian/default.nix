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
in {
  imports = [./opencode.nix];

  options.aytordev.programs.terminal.tools.meridian = {
    enable = mkEnableOption ''
      Meridian proxy for Claude Max subscription.
      After enabling, run: claude login
    '';
    package = lib.mkPackageOption pkgs "meridian" {};

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
    home.packages = [cfg.package];
  };
}
