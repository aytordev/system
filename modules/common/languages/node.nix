# Pure Node.js language data. See ./catalog.nix.
{pkgs}: let
  runtimes = {
    "22" = pkgs.nodejs_22;
    "24" = pkgs.nodejs_24;
    "26" = pkgs.nodejs_26;
  };
in {
  name = "node";
  versions = builtins.attrNames runtimes;
  defaultVersion = "24";

  runtime = version: [runtimes.${version}];

  # The package managers the other shells use.
  toolchain = version: [runtimes.${version} pkgs.yarn pkgs.pnpm];

  editor.vscode.extensions = [
    # Empty on purpose: the editor already bundles TypeScript and JavaScript
    # support, so this language needs no extension. The key stays declared
    # because a pack reads it unconditionally.
  ];
}
