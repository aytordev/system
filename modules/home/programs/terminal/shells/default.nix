{
  config,
  lib,
  ...
}: let
  shellNames = [
    "bash"
    "fish"
    "nushell"
    "zsh"
  ];
in {
  options.aytordev.programs.terminal.shells = {
    enabledNames = lib.mkOption {
      type = lib.types.listOf (lib.types.enum shellNames);
      readOnly = true;
      description = "Shells enabled through the aytordev shell capabilities.";
    };
  };

  config.aytordev.programs.terminal.shells.enabledNames =
    builtins.filter (
      name: config.aytordev.programs.terminal.shells.${name}.enable or false
    )
    shellNames;
}
