{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.k9s;
in {
  options.aytordev.programs.terminal.tools.k9s = {
    enable = lib.mkEnableOption "k9s";
    package = lib.mkPackageOption pkgs "k9s" {};
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.helmfile
      pkgs.kubecolor
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubelogin
      pkgs.kubernetes-helm
      pkgs.kubeseal
    ];

    programs.k9s = {
      enable = true;
      inherit (cfg) package;

      settings.k9s = {
        liveViewAutoRefresh = true;
        refreshRate = 1;
        maxConnRetry = 3;
        ui = {
          enableMouse = true;
        };
      };
    };

    # Nu-safe single-command aliases reach all shells via home.shellAliases.
    # Use getExe for k/kubectl so the kubecolor wrapper resolves its target
    # deterministically.
    home.shellAliases = {
      k = "${lib.getExe pkgs.kubecolor}";
      kc = "kubectx";
      kn = "kubens";
      ks = "kubeseal";
      kubectl = "${lib.getExe pkgs.kubecolor}";
    };
  };
}
