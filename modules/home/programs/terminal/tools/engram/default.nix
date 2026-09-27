{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.engram;

  # Wrap the upstream engram binary so the data directory is intrinsic to the
  # executable. ENGRAM_DATA_DIR exported through home.sessionVariables can be
  # silently lost (hm-session-vars.sh early-returns when its guard variable is
  # already set), and engram would then fall back to its compiled default
  # ~/.engram, creating a second SQLite store. This wrapper is the DEFAULT of
  # the `package` option, so cfg.package is the wrapper itself and every
  # binding below publishes it verbatim. Overriding `package` opts out of the
  # data-directory guarantee; the session variable remains the fallback in
  # that case. The session variable is kept deliberately: the wrapper is the
  # actual guarantee, it stays only as the convenience path for shells and
  # inspection and may be absent in some environments without affecting
  # correctness.
  engramWrapped =
    pkgs.runCommand "engram-wrapped" {
      nativeBuildInputs = [pkgs.makeWrapper];
      meta.mainProgram = "engram";
    } ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe pkgs.aytordev.engram} $out/bin/engram \
        --set ENGRAM_DATA_DIR "${config.xdg.dataHome}/engram" \
        --set ENGRAM_NO_UPDATE_CHECK 1
    '';
in {
  options.aytordev.programs.terminal.tools.engram = {
    enable = lib.mkEnableOption "engram";
    # lib.mkPackageOption cannot express a derivation-valued default (its
    # `default` is an attribute path into pkgs), so the option is declared
    # directly. The module contract only constrains option NAMES, so this is
    # allowed.
    package = lib.mkOption {
      type = lib.types.package;
      default = engramWrapped;
      defaultText = lib.literalExpression "engramWrapped";
      description = "The engram package to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
    home.sessionVariables = {
      ENGRAM_BIN = lib.getExe cfg.package;
      ENGRAM_DATA_DIR = "${config.xdg.dataHome}/engram";
      ENGRAM_NO_UPDATE_CHECK = "1";
    };
  };
}
