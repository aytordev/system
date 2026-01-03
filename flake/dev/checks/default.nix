{
  self,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    let
      allChecks = import ../../../checks {
        inherit pkgs system self;
        inherit (self) inputs;
      };
    in
    {
      checks = allChecks;
    };
}
