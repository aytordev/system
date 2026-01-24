{lib}:
with lib; let
  coreAliases = {
    a = "add";
    ap = "add -p";
    c = "commit --verbose";
    co = "checkout";
    p = "push";
    s = "status -sb";
    st = "stash";
    stl = "stash list";
    d = "diff";
    ds = "diff --stat";
    dc = "diff --cached";
    rao = "remote add origin";
  };
in
  lib.foldl' (acc: x: acc // x) {} [
    coreAliases
  ]
