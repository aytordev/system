{
  lib,
  pkgs,
  ...
}: let
  toLua = import ../../modules/home/programs/desktop/bars/sketchybar/to-lua.nix {inherit lib;};
  payload = ''
    "; os.execute("touch injected-by-lua") --
    second line'';
  generatedLua = pkgs.writeText "generated-values.lua" ''
    local payload = ${toLua payload}
    local values = ${
      toLua {
        string = payload;
        list = [
          payload
          true
          42
        ];
      }
    }
    assert(payload == values.string)
    assert(values.list[1] == payload)
    assert(values.list[2] == true)
    assert(values.list[3] == 42)
  '';
in
  pkgs.runCommand "lua-shell-quoting-tests" {nativeBuildInputs = [pkgs.lua];} ''
      lua ${generatedLua}
      test ! -e injected-by-lua

    payload="it's \$(${pkgs.coreutils}/bin/touch \"\$PWD/injected\")"
    quoted="$(PAYLOAD="$payload" lua -e '
      local shell = dofile("${../../modules/home/programs/desktop/bars/sketchybar/config/helpers/shell.lua}")
      print(shell.quote(os.getenv("PAYLOAD")))
    ')"

    actual="$(${pkgs.bash}/bin/bash -c "printf '%s' $quoted")"
    test "$actual" = "$payload"
    test ! -e injected
    touch "$out"
  ''
