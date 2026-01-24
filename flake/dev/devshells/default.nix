{
  self,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, system, config, ... }:
    let
      shellDefs = import ../../../dev-shells {
        inherit pkgs system;
        inherit (self) inputs;
      };
      mkShell = shell:
        pkgs.mkShell (shell // {
          buildInputs = (shell.packages or []) ++ [ pkgs.pre-commit ];
          shellHook = (shell.shellHook or "") + "\n" + config.pre-commit.installationScript;
        });
      allShells = shellDefs.shells or {};
    in
    {
      devShells = builtins.mapAttrs (_name: mkShell) allShells;
    };
}
