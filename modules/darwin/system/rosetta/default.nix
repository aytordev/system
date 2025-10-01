{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.system.rosetta;
in {
  options.system.rosetta = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic Rosetta 2 installation and configuration (auto-enabled when module is imported)";
    };
  };

  config = mkIf cfg.enable {
    # Install Rosetta 2 automatically on Apple Silicon
    system.activationScripts.rosetta = {
      text = ''
        if [[ $(uname -m) == "arm64" ]] && ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
          echo "Installing Rosetta 2..."
          /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        fi
      '';
    };

    # Configure Nix to support x86_64-darwin packages
    nix.extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };
}
