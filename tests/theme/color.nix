{
  self,
  lib,
}: let
  context = import ./fixtures/context.nix {inherit self lib;};
  inherit (context) themeLib;
in {
  testMkColorOpaque = {
    expr = themeLib.mkColor "#dcd7ba";
    expected = {
      hex = "#dcd7ba";
      raw = "dcd7ba";
      rgb = "rgb(220, 215, 186)";
      sketchybar = "0xffdcd7ba";
    };
  };

  testMkColorAlphaReordersSketchybarChannel = {
    expr = themeLib.mkColor "#12345678";
    expected = {
      hex = "#12345678";
      raw = "12345678";
      rgb = "rgba(18, 52, 86, 0.470588)";
      sketchybar = "0x78123456";
    };
  };

  testTransparentMatchesMkColor = {
    expr = themeLib.transparent == themeLib.mkColor "#00000000";
    expected = true;
  };

  testMkColorRejectsMalformedInput = {
    expr = map (value: (builtins.tryEval (builtins.deepSeq (themeLib.mkColor value) true)).success) [
      "#123"
      "123456"
      "#12345g"
      "#123456789"
    ];
    expected = [
      false
      false
      false
      false
    ];
  };
}
