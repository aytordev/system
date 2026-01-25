{lib, ...}:
with lib; let
  coreAliases = {
    g = "git";
    add = "git add";
    commit = "git commit";
    pull = "git pull";
    push = "git push";
    st = "git status -sb";
    d = "git diff";
    gdiff = "git diff HEAD";
    vdiff = "git difftool HEAD";
  };
in {
  allAliases = lib.foldl' (acc: x: acc // x) {} [
    coreAliases
  ];
  generateGitAliasesFile = aliases: ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "alias ${name}='${value}'") aliases)}
  '';
}
