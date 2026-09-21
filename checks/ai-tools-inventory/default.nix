{
  lib,
  pkgs,
  ...
}: let
  root = ../../modules/common/ai-tools;
  entries = builtins.readDir (root + "/skills");
  names = builtins.attrNames entries;
  expected = ["dotfiles-coder" "nix" "skill-creator" "skill-registry"];
  doc = builtins.readFile (root + "/AGENTS.md");
  rows = lib.filter (line: lib.hasPrefix "| " line && !(lib.hasPrefix "| Name " line)) (lib.splitString "\n" doc);
  documented = map (row: lib.trim (builtins.elemAt (lib.splitString "|" row) 1)) rows;
in
  assert names == expected;
  assert lib.sort builtins.lessThan documented == expected;
  assert lib.all (path: !(builtins.pathExists (root + "/${path}"))) ["default.nix" "agents.nix" "commands.nix" "roles.nix" "registry.nix" "base.md"];
    pkgs.runCommand "ai-tools-inventory-check" {} ''
      touch "$out"
    ''
