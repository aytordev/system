{
  self,
  lib,
}: let
  inherit (self.lib) file module;
in {
  testBoolToNumTrue = {
    expr = module.boolToNum true;
    expected = 1;
  };

  testCapitalizeWord = {
    expr = module.capitalize "hello";
    expected = "Hello";
  };

  testMergeAttrs = {
    expr = file.mergeAttrs [
      {
        a = 1;
        b = 1;
      }
      {
        b = 2;
        c = 3;
      }
    ];
    expected = {
      a = 1;
      b = 2;
      c = 3;
    };
  };

  testMkOptDefault = {
    expr = (module.mkOpt' lib.types.int 5).default;
    expected = 5;
  };
}
