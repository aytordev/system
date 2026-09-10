{
  config,
  lib,
  osConfig ? {},
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
  nanApiKeyPath = "${config.home.homeDirectory}/.config/sops/nan_builders_api_key";
in {
  config = lib.mkIf cfg.enable {
    programs.opencode.settings.provider = {
      nan = lib.mkIf sopsEnabled {
        npm = "@ai-sdk/openai-compatible";
        name = "NaN Builders";
        options = {
          apiKey = "{file:${nanApiKeyPath}}";
          baseURL = "https://api.nan.builders/v1";
        };
        models = {
          "qwen3.6" = {
            name = "Qwen 3.6";
            contextWindow = 262144;
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
          };
          "gemma4" = {
            name = "Gemma 4";
            contextWindow = 262144;
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = ["text"];
            };
          };
          "deepseek-v4-flash" = {
            name = "DeepSeek V4 Flash";
            contextWindow = 500000;
            modalities = {
              input = ["text"];
              output = ["text"];
            };
          };
          "mimo-v2.5" = {
            name = "Xiaomi MiMo V2.5";
            contextWindow = 500000;
            modalities = {
              input = [
                "text"
                "image"
                "audio"
              ];
              output = ["text"];
            };
          };
        };
      };
    };
  };
}
