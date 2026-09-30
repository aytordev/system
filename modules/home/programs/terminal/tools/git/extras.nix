# Git extras: hunk owns the git pager/difftool wiring (pager.diff/show/log/blame
# and difftool.hunk). git-delta stays installed as a standalone binary only
# (git integration off); difftastic's git integration was inert and is retired.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  cfg = config.aytordev.programs.terminal.tools.git;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution for git-delta: official Sora styles when the family
  # covers the active variant, otherwise styles generated from the palette.
  deltaTheme = import ./delta-theme.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  deltaResolution = deltaTheme.resolve {
    inherit (themeCfg) variant;
    integration = themeCfg.integrations.${themeCfg.name}.delta or null;
  };
  # Delta reuses bat's syntax highlighting, so its `syntax-theme` follows the
  # bat theme the adapter resolved (Sora or the generated one).
  batTheme = lib.attrByPath ["programs" "bat" "config" "theme"] null config;
  deltaOptions =
    {
      dark = !themeCfg.isLight;
      features = mkForce "decorations side-by-side navigate";
      line-numbers = true;
      navigate = true;
      side-by-side = true;
    }
    // deltaTheme.optionsFor {
      resolution = deltaResolution;
      inherit (themeCfg) palette;
    }
    // lib.optionalAttrs (batTheme != null) {syntax-theme = batTheme;};

  gitPackages = with pkgs; [
    git-absorb
    git-filter-repo
    git-lfs
    gitflow
    gitleaks
    gitlint
    tig
  ];
in {
  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = gitPackages;
      programs = {
        delta = {
          enable = true;
          enableGitIntegration = false;
          options = deltaOptions;
        };
        mergiraf = {
          enable = true;
          enableGitIntegration = true;
          enableJujutsuIntegration = true;
        };
      };
    })
    (mkIf (cfg.enable && config.aytordev.programs.terminal.tools.hunk.enable) {
      programs.git.settings = {
        pager = {
          diff = "hunk pager";
          show = "hunk pager";
          log = "hunk pager";
          blame = "hunk pager";
        };
        difftool = {
          prompt = false;
          hunk.cmd = "hunk difftool \"$LOCAL\" \"$REMOTE\" \"$MERGED\"";
        };
      };
    })
  ];
}
