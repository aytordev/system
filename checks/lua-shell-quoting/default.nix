{ pkgs, ... }:
pkgs.runCommand "lua-shell-quoting-tests" { nativeBuildInputs = [ pkgs.lua ]; } ''
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
