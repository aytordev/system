# Pure Go language data. See ./catalog.nix.
{pkgs}: {
  name = "go";

  # No version axis worth choosing: nixpkgs carries a single supported Go
  # toolchain, and the older versioned attributes are missing or removed.
  versions = [];
  defaultVersion = null;

  runtime = _: [pkgs.go];
  toolchain = _: [pkgs.go];

  editor = {
    # Moved here from the Zed editor module: this language owns these settings.
    zed.languages.Go = {
      hard_tabs = true;
      format_on_save = "on";
    };

    vscode.extensions = [pkgs.vscode-extensions.golang.go];
  };
}
