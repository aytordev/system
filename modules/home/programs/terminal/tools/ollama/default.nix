{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib;
let
  cfg = config.aytordev.programs.terminal.tools.ollama;
in
{
  imports = [
    ./utils.nix
    ./models.nix
    ./scripts.nix
    ./integrations.nix
    ./service.nix
    ./advanced-scripts.nix
    ./validate.nix
  ];

  options.aytordev.programs.terminal.tools.ollama = {
    enable = mkEnableOption "Ollama - Run large language models locally";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The Ollama package to use";
    };

    acceleration = mkOption {
      type = types.enum [
        "none"
        "metal"
        "cuda"
        "rocm"
      ];
      default = if pkgs.stdenv.isDarwin then "metal" else "none";
      description = "Hardware acceleration backend to use";
    };

    models = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "llama3.2"
        "codellama"
        "mistral"
        "phi3"
      ];
      description = ''
        List of models to pull automatically when the service starts.
        Models will be downloaded on first run if not already present.
      '';
    };

    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Environment variables to set for the Ollama service";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell aliases for Ollama";
    };
  };

  config = mkIf cfg.enable (
    let
      inherit (config._module.args.ollamaUtils)
        createStatusScript
        createRestartScript
        createLogsScript
        ;
    in
    {
      home.packages =
        with pkgs;
        [ cfg.package ]
        ++ optionals cfg.shellAliases [
          createStatusScript
          createLogsScript
          createRestartScript
        ];

      # Shell aliases
      home.shellAliases = mkIf cfg.shellAliases {
        ollama-models = "ollama list";
        ollama-ps = "ollama ps";
        ai = "ollama run llama3.2";
      };

      # Environment variables
      home.sessionVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
      };
    }
  );
}
