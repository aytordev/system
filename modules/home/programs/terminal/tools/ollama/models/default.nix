{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption mkDefault types flatten attrNames;

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

    home.shellAliases = mkIf cfg.shellAliases {
      ollama-update = mkDefault "${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ${cfg.package}/bin/ollama pull {}";
    };
  };
}
