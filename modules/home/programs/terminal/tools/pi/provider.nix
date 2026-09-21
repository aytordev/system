{
  config,
  lib,
  osConfig ? {},
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.pi;
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
  nanApiKeyPath = "${config.home.homeDirectory}/.config/sops/nan_builders_api_key";

  # nan.builders' blessed Pi provider (docs/pi). Pi only READS
  # `~/.pi/agent/models.json` (an immutable, credential-blind snapshot) and the
  # official Gentle AI installer writes settings.json/mcp.json but not this
  # file, while Gentle Shell keeps its routing in `~/.pi/gentle-ai/models.json`.
  # So Nix owns exactly this one provider file and nothing else of the native
  # profile.
  #
  # The API key uses Pi's `!command` config-value form; the secret stays in the
  # SOPS-managed file and never lands in the Nix store.
  #
  # Pi's schema admits only "text"/"image" for `input` (a third value makes Pi
  # refuse the whole file, every provider included), so mimo-v2.5 ships without
  # audio. glm5.3 (premium) is deliberately absent.
  nanProvider = {
    baseUrl = "https://api.nan.builders/v1";
    api = "openai-completions";
    apiKey = "!cat ${nanApiKeyPath}";
    compat = {
      supportsDeveloperRole = true;
    };
    models = [
      {
        id = "deepseek-v4-flash";
        name = "DeepSeek V4 Flash";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 1048575;
        maxTokens = 32768;
      }
      {
        id = "glm5.3-flash";
        name = "GLM 5.3 Flash";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 1048576;
        maxTokens = 32768;
      }
      {
        id = "qwen3.8-flash";
        name = "Qwen 3.8 Flash";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 262144;
        maxTokens = 32768;
      }
      {
        id = "mimo-v2.5";
        name = "Xiaomi MiMo V2.5";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 1048576;
        maxTokens = 32768;
      }
      {
        id = "gemma4";
        name = "Gemma 4";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 262144;
        maxTokens = 65536;
      }
      {
        id = "qwen3.6";
        name = "Qwen 3.6";
        reasoning = true;
        input = [
          "text"
          "image"
        ];
        contextWindow = 262144;
        maxTokens = 65536;
      }
    ];
  };
in {
  options.aytordev.programs.terminal.tools.pi.providers = lib.mkOption {
    type = lib.types.attrs;
    default =
      if sopsEnabled
      then {nan = nanProvider;}
      else {};
    description = ''
      Custom Pi providers written to `~/.pi/agent/models.json` as
      `{providers = {<id> = <config>;};}`. Defaults to the SOPS-backed
      nan.builders provider when SOPS is enabled. This is the only native Pi
      profile file Nix owns; Pi reads it, no upstream component writes it.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkIf (cfg.providers != {}) {
      ".pi/agent/models.json".text =
        lib.generators.toJSON {} {inherit (cfg) providers;};
    };
  };
}
