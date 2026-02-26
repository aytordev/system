{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.aytordev.services.litellm;
  userHome = config.users.users.${config.aytordev.user.name}.home;
  logDir = "${userHome}/.local/state/litellm";
  configFile = "${userHome}/.config/litellm/config.yaml";
in {
  options.aytordev.services.litellm = {
    enable = mkEnableOption "LiteLLM proxy as launchd agent";

    package = mkOption {
      type = types.package;
      default = pkgs.litellm;
      description = "The LiteLLM package to use";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "LiteLLM proxy bind address";
    };

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "LiteLLM proxy listen port";
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Environment variables for API keys and provider configuration";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    launchd.user.agents.litellm = {
      command = "${cfg.package}/bin/litellm --config ${configFile} --host ${cfg.host} --port ${toString cfg.port}";
      serviceConfig = {
        # Only restart on crash, not unconditionally — allows clean stop
        KeepAlive = {SuccessfulExit = false;};
        RunAtLoad = false;
        StandardOutPath = "${logDir}/litellm.out.log";
        StandardErrorPath = "${logDir}/litellm.err.log";
        EnvironmentVariables =
          {
            LITELLM_TELEMETRY = "False";
          }
          // cfg.environmentVariables;
      };
    };

    # Ensure XDG state directory exists for logs
    system.activationScripts.postActivation.text = lib.mkAfter ''
      mkdir -p "${logDir}"
      chown ${config.aytordev.user.name}:staff "${logDir}"
    '';

    aytordev.system.newsyslog.files.litellm-out = [
      {
        logfilename = "${logDir}/litellm.out.log";
        mode = "644";
        owner = config.aytordev.user.name;
        group = "staff";
        count = 5;
        size = "5120";
        flags = ["Z" "C"];
      }
    ];

    aytordev.system.newsyslog.files.litellm-err = [
      {
        logfilename = "${logDir}/litellm.err.log";
        mode = "644";
        owner = config.aytordev.user.name;
        group = "staff";
        count = 5;
        size = "5120";
        flags = ["Z" "C"];
      }
    ];
  };
}
