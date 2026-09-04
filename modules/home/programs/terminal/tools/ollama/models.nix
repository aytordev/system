{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkDefault
    types
    flatten
    attrNames
    ;

  cfg = config.aytordev.programs.terminal.tools.ollama;

  modelPresets = {
    general = [
      "llama3.2"
      "mistral"
    ];
    coding = [
      "qwen2.5-coder:32b"
      "deepseek-coder"
    ];
    small = [
      "phi3"
      "tinyllama"
    ];
    m3-ultra = [
      "qwen2.5-coder:32b"
      "qwen3:30b-a3b"
      "nomic-embed-text"
    ];
  };
in {
  options.aytordev.programs.terminal.tools.ollama.modelPresets = mkOption {
    type = types.listOf (types.enum (attrNames modelPresets));
    default = [];
    example = ["m3-ultra"];
    description = ''
      Model presets to automatically install.
      Available: general, coding, small, m3-ultra
    '';
  };

  config = mkIf cfg.enable {
    aytordev.programs.terminal.tools.ollama.models = mkDefault (
      flatten (map (preset: modelPresets.${preset}) cfg.modelPresets)
    );

    # As a shell alias this pipeline is silently broken in nushell (the pipes
    # are passed as a single arg) and can't be invoked by agents. Publish it as
    # a bin with its tools declared.
    home.packages = [
      (pkgs.writeShellApplication {
        name = "ollama-update";
        runtimeInputs = [
          cfg.package
          pkgs.gawk
          pkgs.findutils
        ];
        text = ''
          ${lib.getExe cfg.package} list | tail -n +2 | awk '{print $1}' | xargs -I {} ${lib.getExe cfg.package} pull {}
        '';
      })
    ];
  };
}
