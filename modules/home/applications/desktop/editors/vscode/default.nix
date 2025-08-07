{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.desktop.editors.vscode;
in {
  options.applications.desktop.editors.vscode = {
    enable = mkEnableOption "Whether or not to enable vscode";
    declarativeConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether or not to use declarative configuration for vscode.";
    };
  };

  config = mkIf cfg.enable {
    # Create directory and set permissions
    home.activation.vscodeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Ensure directory exists with correct permissions
      mkdir -p "$HOME/Library/Application Support/Code/User"
      chmod 755 "$HOME/Library/Application Support/Code/User"
      
      # Always copy the settings file to ensure it's up to date
      cp -f ${./settings/default.json} "$HOME/Library/Application Support/Code/User/settings.json"
      
      # Set correct permissions
      chmod 644 "$HOME/Library/Application Support/Code/User/settings.json"
      
      # Verify the file was copied correctly
      if ! cmp -s ${./settings/default.json} "$HOME/Library/Application Support/Code/User/settings.json"; then
        echo "Error: Failed to update VSCode settings"
        exit 1
      fi
    '';

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      # TODO: add extensions not packaged with nixpkgs
      profiles = {
        default = {
          extensions = with pkgs.vscode-extensions; [
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
          ];
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
        };
        Nix = {
          extensions = with pkgs.vscode-extensions; [
            arrterian.nix-env-selector
            bbenoist.nix
            mkhl.direnv
          ];
        };
      };
    };
  };
}
