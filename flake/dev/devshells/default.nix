{
  self,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    let
      shellDefs = import ../../../dev-shells {
        inherit pkgs system;
        inherit (self) inputs;
      };
      mkShell = shell:
        pkgs.mkShell (shell // {
          buildInputs = shell.packages or [];
        });
      allShells = shellDefs.shells or {};
    in
    {
      devShells = builtins.mapAttrs (_name: shell: mkShell shell) allShells;
    };
}
