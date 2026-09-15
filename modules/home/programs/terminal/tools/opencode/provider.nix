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
    programs.opencode.settings = {
      # nan.builders' recommended compaction block for the 1M-token windows.
      compaction = {
        auto = true;
        prune = true;
        reserved = 50000;
      };
      provider = {
        nan = lib.mkIf sopsEnabled {
          npm = "@ai-sdk/openai-compatible";
          name = "NaN Builders";
          options = {
            apiKey = "{file:${nanApiKeyPath}}";
            baseURL = "https://api.nan.builders/v1";
          };
          # nan.builders' blessed OpenCode config (docs/opencode): limit is the
          # schema-valid form (contextWindow is not an OpenCode key — unknown
          # keys silently fall back to OpenCode's assumed window and sessions
          # compact far too early on the 1M models).
          models = {
            "deepseek-v4-flash" = {
              name = "DeepSeek V4 Flash";
              limit = {
                context = 1048575;
                output = 32768;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                ];
                output = ["text"];
              };
            };
            "glm5.3-flash" = {
              name = "GLM 5.3 Flash";
              limit = {
                context = 1048576;
                output = 32768;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                ];
                output = ["text"];
              };
            };
            "qwen3.8-flash" = {
              name = "Qwen 3.8 Flash";
              limit = {
                context = 262144;
                output = 32768;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                ];
                output = ["text"];
              };
            };
            "mimo-v2.5" = {
              name = "Xiaomi MiMo V2.5";
              limit = {
                context = 1048576;
                output = 32768;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                  "audio"
                ];
                output = ["text"];
              };
            };
            "gemma4" = {
              name = "Gemma 4";
              limit = {
                context = 262144;
                output = 65536;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                ];
                output = ["text"];
              };
            };
            "qwen3.6" = {
              name = "Qwen 3.6";
              limit = {
                context = 262144;
                output = 65536;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                ];
                output = ["text"];
              };
            };
          };
        };
      };
    };
  };
}
