# Pure Python language data. See ./catalog.nix.
{pkgs}: let
  interpreters = {
    "312" = pkgs.python312;
    "313" = pkgs.python313;
    "314" = pkgs.python314;
  };
in {
  name = "python";
  versions = builtins.attrNames interpreters;
  defaultVersion = "313";

  # The interpreter the language is about.
  runtime = version: [interpreters.${version}];

  # A development shell also wants the package runner the other shells use.
  toolchain = version: [interpreters.${version} pkgs.uv];

  editor = {
    # Moved here from the Zed editor module: this language owns these settings.
    zed.languages.Python = {
      # Built-in adapters; project environments supply Python dependencies.
      language_servers = ["ty" "ruff" "!basedpyright" "!pyright" "!pyrefly" "!pylsp"];
      format_on_save = "on";
      code_actions_on_format."source.organizeImports.ruff" = true;
    };

    vscode.extensions = [
      # Pylance is deliberately absent: it is unfree and license-restricted, so
      # adding it is a separate decision.
      pkgs.vscode-extensions.ms-python.python
    ];
  };
}
