{
  inputs,
  lib,
  ...
}: {
  imports = lib.optional (inputs.treefmt-nix ? flakeModule) inputs.treefmt-nix.flakeModule;

  perSystem = _: {
    treefmt = lib.mkIf (inputs.treefmt-nix ? flakeModule) {
      flakeCheck = true;
      flakeFormatter = true;

      projectRootFile = "flake.nix";

      programs = {
        # Nix
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        # Shell
        shfmt = {
          enable = true;
          indent_size = 4;
        };
        shellcheck.enable = true;

        # Lua
        stylua.enable = true;

        # JSON/YAML/TOML
        taplo.enable = true; # TOML
        yamlfmt.enable = true;
        # jsonfmt via biome or similar if desired, keeping simple for now

        # General
        # prettier.enable = true; # Optional: heavy dependency
      };

      settings = {
        global.excludes = [
          "*.lock"
          "*.png"
          "*.jpg"
          "*.gif"
          "*.webp"
          ".envrc"
          ".direnv/**"
          "**/.git/**"
          "LICENSE"
        ];
      };
    };
  };
}
