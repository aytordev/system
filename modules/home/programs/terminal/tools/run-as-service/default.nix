{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.run-as-service;
  sessionVariablesFile = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  applyHomeEnvironment = pkgs.writeShellScript "apply-home-environment" ''
    unset __HM_SESS_VARS_SOURCED
    source ${lib.escapeShellArg sessionVariablesFile}
    exec "$@"
  '';
  runAsService = pkgs.writeShellScriptBin "run-as-service" ''
    exec ${lib.getExe' pkgs.systemd "systemd-run"} \
      --slice=app-manual.slice \
      --property=ExitType=cgroup \
      --user \
      --wait \
      -- ${applyHomeEnvironment} "$@"
  '';
in {
  options.aytordev.programs.terminal.tools.run-as-service = {
    enable = lib.mkEnableOption "systemd-run support";
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [runAsService];
  };
}
