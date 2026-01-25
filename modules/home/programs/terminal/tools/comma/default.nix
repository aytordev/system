{
  config,

  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.aytordev.programs.terminal.tools.comma;
in {
  options.aytordev.programs.terminal.tools.comma = {
    enable = mkEnableOption "comma";
  };
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enable = true;
  };
}
