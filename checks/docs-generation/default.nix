{
  inputs,
  lib,
  pkgs,
  ...
}: let
  generate = import ../../flake/docs/generate.nix {inherit inputs pkgs;};
  goldenDir = ./golden;
  realHomePath = "${inputs.self.outPath}/homes/aarch64-darwin/aytordev@wang-lin/default.nix";
  realHomeText = builtins.readFile realHomePath;
  lines = builtins.filter (l: builtins.isString l && builtins.match ".*stateVersion.*" l != null) (
    builtins.split "\n" realHomeText
  );
  versionOk =
    if lines == []
    then throw "Could not extract stateVersion from ${realHomePath}."
    else builtins.head (builtins.match ".*stateVersion = \"?([0-9.]+)\"?.*" (builtins.head lines));

  versionCheck =
    if versionOk != generate.stateVersion
    then throw "Docs eval stateVersion (${generate.stateVersion}) diverges from the real home (${versionOk}). Run 'just golden-update' to resync."
    else null;

  # Compact per-option index = the `##` headers of the doc, so no store paths
  # appear and the snapshot stays small. This must match the grep used by
  # flake/docs/default.nix when building packages.docs-options.

  mdOf = name:
    pkgs.runCommand "docs-${name}-header-index" {} ''
      grep '^## ' ${generate.${name}.optionsCommonMark} > $out
    '';
  indices = lib.genAttrs ["darwin" "home"] mdOf;
in
  if pkgs.stdenv.hostPlatform.isDarwin
  then
    builtins.seq versionCheck (
      pkgs.runCommand "docs-generation-check"
      {
        # Gate: force the mdbook site (and therefore the full darwin+home
        # eval) to build inside this check, so CI can't silently break it.
        nativeBuildInputs = [
          inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.docs-html
        ];
      }
      ''
        set -euo pipefail
        mkdir -p "$out/generated"
        ${
          lib.concatMapStringsSep "\n"
          (name: ''
            diff -u "${goldenDir}/${name}.txt" "${indices.${name}}" >/dev/null || {
              echo "ERROR: docs drift for ${name}. Run 'just golden-update' to resync the golden index." >&2
              diff -u "${goldenDir}/${name}.txt" "${indices.${name}}" >&2 || true
              exit 1
            }
          '')
          [
            "darwin"
            "home"
          ]
        }
        touch "$out"
      ''
    )
  else
    pkgs.runCommand "docs-generation-check-skip" {} ''
      touch "$out"
    ''
