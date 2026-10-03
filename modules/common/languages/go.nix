# Pure Go language data. See ./catalog.nix.
{pkgs}: {
  name = "go";

  # No version axis worth choosing: nixpkgs carries a single supported Go
  # toolchain, and the older versioned attributes are missing or removed.
  versions = [];
  defaultVersion = null;

  runtime = _: [pkgs.go];
  toolchain = _: [pkgs.go];

  editor.vscode.extensions = [pkgs.vscode-extensions.golang.go];
}
