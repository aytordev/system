{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    optionalAttrs
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.pi;
  themeCfg = config.aytordev.theme;

  # Generated from the shared palette so the TUI follows aytordev.theme.
  generatedTheme = lib.generators.toJSON {} (import ./theme.nix {inherit (themeCfg) palette;});

  # nan.builders is an OpenAI-compatible provider wired the same way as opencode:
  # the API key is read at runtime from a SOPS-managed file, so no secret lands
  # in this reusable module. Only defined when the host enables SOPS.
  sopsEnabled = osConfig.aytordev.security.sops.enable or false;
  nanApiKeyPath = "${config.home.homeDirectory}/.config/sops/nan_builders_api_key";
  nanProvider =
    if sopsEnabled
    then {
      baseUrl = "https://api.nan.builders/v1";
      api = "openai-completions";
      apiKey = "!cat ${nanApiKeyPath}";
      models = [
        {
          id = "qwen3.6";
          name = "Qwen 3.6";
          contextWindow = 262144;
        }
        {
          id = "gemma4";
          name = "Gemma 4";
          contextWindow = 262144;
        }
        {
          id = "deepseek-v4-flash";
          name = "DeepSeek V4 Flash";
          contextWindow = 500000;
        }
        {
          id = "mimo-v2.5";
          name = "Xiaomi MiMo V2.5";
          contextWindow = 500000;
        }
      ];
    }
    else null;

  # Shared ai-tools context + skills, reused across all coding-agent harnesses.
  aiToolsContext = builtins.readFile (lib.getFile "modules/common/ai-tools/base.md");
  sharedSkills = lib.getFile "modules/common/ai-tools/skills";

  # Pi config directory. Default `~/.pi/agent` is pi's own default. Normalize to
  # an absolute path so home.file targets, PI_CODING_AGENT_DIR and the `skills`
  # setting all agree (pi expands `~` in JSON strings).
  absConfigDir =
    if lib.hasPrefix "~" cfg.piConfigDir
    then "${config.home.homeDirectory}/${lib.removePrefix "~/" cfg.piConfigDir}"
    else cfg.piConfigDir;

  # Deny-by-default rules for the permission gate (deny wins, fallback allow).
  denyRules = {
    permission = {
      path_read = {
        "*" = "allow";
        "~/.ssh/*" = "deny";
        "~/.gnupg/*" = "deny";
        "~/.aws/*" = "deny";
        "~/.kube/*" = "deny";
        "~/.gitconfig" = "deny";
        ".git-credentials" = "deny";
        ".env*" = "deny";
        "*.pem" = "deny";
        "*.key" = "deny";
        "*.jks" = "deny";
        "*.pfx" = "deny";
        "*.p12" = "deny";
        "*.kubeconfig" = "deny";
        "*.tfstate" = "deny";
        "~/.docker/config.json" = "deny";
        "~/.npmrc" = "deny";
      };
      path_write = {
        "*" = "allow";
        "~/.ssh/*" = "deny";
        "~/.gnupg/*" = "deny";
        "~/.aws/*" = "deny";
        "~/.kube/*" = "deny";
        "~/.gitconfig" = "deny";
        ".git-credentials" = "deny";
        ".env*" = "deny";
        "*.pem" = "deny";
        "*.key" = "deny";
        "*.jks" = "deny";
        "*.pfx" = "deny";
        "*.p12" = "deny";
        "*.kubeconfig" = "deny";
        "*.tfstate" = "deny";
        "~/.docker/config.json" = "deny";
        "~/.npmrc" = "deny";
        "package-lock.json" = "deny";
        "pnpm-lock.yaml" = "deny";
        "yarn.lock" = "deny";
      };
      bash = {
        "*" = "allow";
        "sudo *" = "deny";
        "rm -rf *" = "deny";
        "dd *" = "deny";
        "mkfs *" = "deny";
        "shred *" = "deny";
        "git reset --hard *" = "deny";
        "git clean -f*" = "deny";
        "git push --force *" = "deny";
        "git push -f *" = "deny";
        "git push * main" = "deny";
        "git push origin main *" = "deny";
        "gh pr merge *" = "deny";
        "DROP DATABASE *" = "deny";
        "DROP TABLE *" = "deny";
        "TRUNCATE *" = "deny";
        "chmod * ~/.ssh/*" = "deny";
        "chmod * ~/.gnupg/*" = "deny";
      };
    };
  };

  permissionPackage = "@gotgenes/pi-permission-system@29.1.0";
  piPackages = cfg.packages ++ lib.optionals cfg.permissions.enable [permissionPackage];

  # Vendored gentle-pi aesthetic assets (MIT); see vendor/README.md. Deployed
  # as sibling dirs under the pi agent dir so the extensions' `../lib/*.ts`
  # relative imports resolve, and pi auto-discovers extensions/themes by path.
  vendorExtensions = lib.getFile "modules/home/programs/terminal/tools/pi/vendor/extensions";
  vendorLib = lib.getFile "modules/home/programs/terminal/tools/pi/vendor/lib";
  vendorScripts = lib.getFile "modules/home/programs/terminal/tools/pi/vendor/scripts";
  vendorThemes = lib.getFile "modules/home/programs/terminal/tools/pi/vendor/themes";

  # One directory holding both the vendored fallback and the generated theme, so
  # Home Manager deploys themes/ as a single symlink. Declaring individual files
  # inside a store-backed symlink is not possible (the store is read-only).
  generatedThemeFile = pkgs.writeText "aytordev.json" generatedTheme;
  piThemes = pkgs.runCommand "pi-themes" {} ''
    mkdir -p $out
    cp ${vendorThemes}/kanagawa.json $out/kanagawa.json
    cp ${generatedThemeFile} $out/aytordev.json
  '';

  # Build settings.json as a plain attrset (toJSON of a mkMerge marker would
  # serialize the marker, not the merged value).
  baseSettings =
    {
      inherit (cfg) quietStartup;
      inherit (cfg) enableInstallTelemetry;
      inherit (cfg) showCacheMissNotices;
      inherit (cfg) enableSkillCommands;
      inherit (cfg) defaultProjectTrust;
      compaction = {
        enabled = cfg.compaction.enabled;
      };
    }
    // optionalAttrs (cfg.model.defaultProvider != null) {
      defaultProvider = cfg.model.defaultProvider;
    }
    // optionalAttrs (cfg.model.defaultModel != null) {defaultModel = cfg.model.defaultModel;}
    // optionalAttrs (cfg.model.defaultThinkingLevel != null) {
      defaultThinkingLevel = cfg.model.defaultThinkingLevel;
    }
    // optionalAttrs (cfg.model.enabledModels != []) {enabledModels = cfg.model.enabledModels;}
    // optionalAttrs (cfg.theme != null) {inherit (cfg) theme;}
    // optionalAttrs (cfg.tuiMode != null) {inherit (cfg) tuiMode;}
    // optionalAttrs (piPackages != []) {packages = piPackages;}
    // optionalAttrs cfg.skills.enable {skills = ["${absConfigDir}/skills"];};
in {
  options.aytordev.programs.terminal.tools.pi = {
    enable = mkEnableOption "Pi coding agent";
    package = mkPackageOption pkgs "pi-coding-agent" {};

    piConfigDir = mkOption {
      type = types.str;
      default = "~/.pi/agent";
      description = "Pi config directory (maps to PI_CODING_AGENT_DIR).";
    };

    model = {
      defaultProvider = mkOption {
        type = types.nullOr types.str;
        default =
          if sopsEnabled
          then "nan"
          else null;
        description = "Default provider id (pi: defaultProvider). Defaults to nan.builders when SOPS is enabled.";
      };
      defaultModel = mkOption {
        type = types.nullOr types.str;
        default =
          if sopsEnabled
          then "deepseek-v4-flash"
          else null;
        description = "Default model id (pi: defaultModel).";
      };
      defaultThinkingLevel = mkOption {
        type = types.nullOr (
          types.enum [
            "off"
            "minimal"
            "low"
            "medium"
            "high"
            "xhigh"
            "max"
          ]
        );
        default = null;
        description = "Default thinking level.";
      };
      enabledModels = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Models to cycle through (Ctrl+P). Empty = pi default.";
      };
    };

    quietStartup = mkOption {
      type = types.bool;
      default = true;
      description = "Suppress the startup banner.";
    };
    enableInstallTelemetry = mkOption {
      type = types.bool;
      default = false;
      description = "Send install/usage telemetry.";
    };
    showCacheMissNotices = mkOption {
      type = types.bool;
      default = true;
      description = "Surface prompt-cache misses and compaction notices.";
    };
    enableSkillCommands = mkOption {
      type = types.bool;
      default = true;
      description = "Expose skills as slash-commands.";
    };
    defaultProjectTrust = mkOption {
      type = types.enum [
        "ask"
        "always"
        "never"
      ];
      default = "ask";
      description = "Project trust policy (pi: defaultProjectTrust).";
    };
    theme = mkOption {
      type = types.nullOr types.str;
      default =
        if cfg.shell.enable
        then "aytordev"
        else null;
      description = "TUI theme name (defaults to the palette-generated aytordev theme when the gentle shell is enabled).";
    };
    shell.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Deploy the vendored gentle-pi aesthetic extensions + generated theme.";
    };
    tuiMode = mkOption {
      type = types.nullOr (
        types.enum [
          "regular"
          "fullscreen"
        ]
      );
      default = "fullscreen";
      description = "TUI mode (gentle-pi recommends fullscreen).";
    };
    compaction.enabled = mkOption {
      type = types.bool;
      default = true;
      description = "Auto-compact the context window.";
    };

    packages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Pi extension packages (npm:/git:) loaded at runtime.";
    };

    providers = mkOption {
      type = types.nullOr types.attrs;
      default =
        if sopsEnabled
        then {nan = nanProvider;}
        else null;
      description = "Custom providers written to models.json as {<id> = config} (e.g. nan.builders).";
    };

    context.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Write AGENTS.md from the shared ai-tools context.";
    };
    skills.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Link the shared ai-tools skills into pi.";
    };

    permissions = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Deny-by-default permission gate (@gotgenes/pi-permission-system).";
      };
      config = mkOption {
        type = types.attrs;
        default = denyRules;
        description = "Permission rules (deny wins, fallback allow) written to the gate's config.json.";
      };
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra settings merged into settings.json (applied last, so it wins).";
    };

    modelRouting = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "Per-phase model routing written to ~/.pi/gentle-ai/models.json (consumed by the gentle-pi subagent extension, not stock pi).";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
      ];

      file = {
        "${absConfigDir}/settings.json" = {
          text = lib.generators.toJSON {} (lib.recursiveUpdate baseSettings cfg.settings);
        };

        "${absConfigDir}/models.json" = mkIf (cfg.providers != null) {
          text = lib.generators.toJSON {} {
            inherit (cfg) providers;
          };
        };

        "${absConfigDir}/AGENTS.md" = mkIf cfg.context.enable {
          text = aiToolsContext;
        };

        "${absConfigDir}/skills" = mkIf cfg.skills.enable {
          source = sharedSkills;
        };

        "${absConfigDir}/extensions/pi-permission-system/config.json" = mkIf cfg.permissions.enable {
          text = lib.generators.toJSON {} cfg.permissions.config;
        };

        "${config.home.homeDirectory}/.pi/gentle-ai/models.json" = mkIf (cfg.modelRouting != null) {
          text = lib.generators.toJSON {} cfg.modelRouting;
        };

        "${absConfigDir}/extensions/gentle-shell.ts" = mkIf cfg.shell.enable {
          source = "${vendorExtensions}/gentle-shell.ts";
        };
        "${absConfigDir}/extensions/quiet-tools.ts" = mkIf cfg.shell.enable {
          source = "${vendorExtensions}/quiet-tools.ts";
        };
        "${absConfigDir}/extensions/startup-banner.ts" = mkIf cfg.shell.enable {
          source = "${vendorExtensions}/startup-banner.ts";
        };
        "${absConfigDir}/lib" = mkIf cfg.shell.enable {
          source = vendorLib;
        };
        "${absConfigDir}/scripts" = mkIf cfg.shell.enable {
          source = vendorScripts;
        };
        "${absConfigDir}/themes" = mkIf cfg.shell.enable {
          source = piThemes;
        };
      };

      sessionVariables = {
        PI_CODING_AGENT_DIR = absConfigDir;
      };
    };
  };
}
