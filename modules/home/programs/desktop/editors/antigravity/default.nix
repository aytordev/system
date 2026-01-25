{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.aytordev.programs.desktop.editors.antigravity;

  defaultSettings = import ./settings.nix {inherit lib pkgs config;};
  finalSettings = lib.recursiveUpdate defaultSettings cfg.userSettings;

  commonExtensions = with pkgs.vscode-extensions; [
    # Kanagawa theme - install manually via marketplace: "metaphore.kanagawa-vscode-color-theme"
    catppuccin.catppuccin-vsc-icons
    github.copilot
    github.copilot-chat
    arrterian.nix-env-selector
    bbenoist.nix
    mkhl.direnv
  ];
in {
  options.aytordev.programs.desktop.editors.antigravity = {
    enable = mkEnableOption "Whether or not to enable google-antigravity";

    package = mkOption {
      type = types.package;
      default = pkgs.antigravity;
      description = "The Antigravity package to use.";
    };

    userSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional settings to merge with the default configuration.";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = commonExtensions;
      description = "List of extensions to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile = {
      "antigravity/User/settings.json".text = builtins.toJSON finalSettings;
    };

    home.activation.antigravityConflictResolution = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ -d "${config.home.homeDirectory}/Library/Application Support/Antigravity/User" ] && [ ! -L "${config.home.homeDirectory}/Library/Application Support/Antigravity/User" ]; then
        echo "Backing up existing Antigravity User directory..."
        mv "${config.home.homeDirectory}/Library/Application Support/Antigravity/User" "${config.home.homeDirectory}/Library/Application Support/Antigravity/User.bak"
      fi
    '';

    home.activation.installAntigravityExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Ensure extensions directory is writable (not a symlink from previous Nix installs)
      if [ -L "${config.home.homeDirectory}/.antigravity/extensions" ]; then
        echo "Removing existing Antigravity extensions symlink..."
        rm "${config.home.homeDirectory}/.antigravity/extensions"
      fi

      mkdir -p "${config.home.homeDirectory}/.antigravity/extensions"

      ${lib.concatMapStringsSep "\n" (ext: ''
          # We use the extension publisher.name as ID.
          # Note: This assumes the package name matches the extension ID or we can derive it.
          # Since we are using nixpkgs extensions, they usually have 'vscode-extension-publisher-name' format or similar.
          # A more robust way for imperative install is just passing the extension VSIX if available or name.
          # However, 'code --install-extension' expects an ID or path.
          # For simplicity in this decoupled mode, we try to install by ID if we can guess it,
          # OR we just rely on the user to install them manually if this is too brittle.
          # BUT the user asked for this.
          # Let's try to find the vsix in the store path.

          for vsix in "${ext}/share/vscode/extensions/"*.vsix; do
            if [ -f "$vsix" ]; then
              echo "Installing extension from $vsix..."
              ${cfg.package}/bin/antigravity --install-extension "$vsix" || true
            fi
          done
        '')
        cfg.extensions}
    '';

    home.file = mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/Antigravity/User".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/antigravity/User";
    };
  };
}
