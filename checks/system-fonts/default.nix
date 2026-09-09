{
  inputs,
  pkgs,
  ...
}: let
  extendedLib = inputs.nixpkgs.lib.extend inputs.self.lib.overlay;
  darwin = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs.lib = extendedLib;
    modules = [
      {_module.args.lib = extendedLib;}
      ../../modules/darwin/system/fonts
      {
        aytordev.system.fonts.enable = true;
        nixpkgs.config.allowUnfree = true;
      }
    ];
  };

  countSketchybarFonts = packages:
    builtins.length (
      builtins.filter (package: package.pname == pkgs.sketchybar-app-font.pname) packages
    );
  commonFontCount = countSketchybarFonts darwin.config.aytordev.system.fonts.fonts;
  darwinFontCount = countSketchybarFonts darwin.config.fonts.packages;
in
  assert commonFontCount == 0;
  assert darwinFontCount == 1;
    pkgs.runCommand "system-fonts-tests" {} ''
      touch "$out"
    ''
