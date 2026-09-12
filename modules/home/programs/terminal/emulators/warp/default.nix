{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.emulators.warp;
  themeCfg = config.aytordev.theme;

  warpTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeIntegration = themeCfg.integrations.${themeCfg.name}.warp or null;

  themeResolution = warpTheme.resolve {
    inherit (themeCfg) variant;
    integration = themeIntegration;
  };

  generatedTheme = warpTheme.render {
    inherit (themeCfg) palette ansi isLight;
  };

  # Warp scans a fixed themes directory and the user picks a theme in
  # Settings > Appearance; there is no documented config-file selection, so no
  # `theme` setting is written. macOS reads `~/.warp/themes`, Linux reads
  # `${XDG_DATA_HOME:-~/.local/share}/warp-terminal/themes`.
  themeFiles =
    lib.mapAttrs' (name: value: lib.nameValuePair (lib.removePrefix "warp/themes/" name) value)
    (
      warpTheme.entries {
        resolution = themeResolution;
        generatedText = generatedTheme;
      }
    );
in {
  options.aytordev.programs.terminal.emulators.warp = {
    enable = lib.mkEnableOption "Warp terminal emulator";
    package = lib.mkPackageOption pkgs "warp-terminal" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
    # `lib.mkIf` as the value defers the platform check so `pkgs` is not forced
    # while the attribute set is built.
    home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.mapAttrs' (file: value: lib.nameValuePair ".warp/themes/${file}" value) themeFiles
    );
    xdg.dataFile = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) (
      lib.mapAttrs' (file: value: lib.nameValuePair "warp-terminal/themes/${file}" value) themeFiles
    );
  };
}
