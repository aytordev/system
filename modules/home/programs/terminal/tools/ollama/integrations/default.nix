{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types mkDefault elem head;
  cfg = config.aytordev.programs.terminal.tools.ollama;
  integrationsCfg = cfg.integrations;
in {
  options.aytordev.programs.terminal.tools.ollama.integrations = {
    zed = mkOption {
      type = types.bool;
      default = false;
      description = "Configure Zed editor to use local Ollama instance";
    };
  };

  config = mkIf (cfg.enable && integrationsCfg.zed) {
    # Zed editor integration
    programs.zed-editor.userSettings = mkIf (config.programs.zed-editor.enable or false) {
      assistant = {
        default_model = mkDefault {
          provider = "ollama";
          model =
            if (elem "llama3.2" cfg.models)
            then "llama3.2:latest"
            else if (elem "llama3.1" cfg.models)
            then "llama3.1:latest"
            else if (cfg.models != [])
            then "${head cfg.models}:latest"
            else "llama3.2:latest";
        };
        version = mkDefault "2";
      };
      language_models = {
        ollama = mkDefault {
          api_url = "http://127.0.0.1:11434";
        };
      };
    };
  };
}
