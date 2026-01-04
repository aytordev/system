{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.aytordev.applications.terminal.tools.ollama;

  # Simplified model presets
  modelPresets = {
    general = [
      "llama3.2"
      "mistral"
    ];
    coding = [
      "codellama"
      "deepseek-coder"
    ];
    small = [
      "phi3"
      "tinyllama"
    ];
  };
in
{
  options.aytordev.applications.terminal.tools.ollama.modelPresets = mkOption {
    type = types.listOf (types.enum (attrNames modelPresets));
    default = [ ];
    example = [
      "general"
      "coding"
    ];
    description = "Model presets to automatically install";
  };

  config = mkIf cfg.enable {
    # Add preset models to the main model list
    aytordev.applications.terminal.tools.ollama.models = mkDefault (
      flatten (map (preset: modelPresets.${preset}) cfg.modelPresets)
    );

    # Add basic model management aliases
    home.shellAliases = mkIf cfg.shellAliases {
      ollama-update = mkDefault "${cfg.package}/bin/ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ${cfg.package}/bin/ollama pull {}";
    };
  };
}
