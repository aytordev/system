{
  inputs,
  lib,
  ...
}: let
  opener = pkgs:
    if pkgs.stdenv.hostPlatform.isDarwin
    then "open"
    else "xdg-open";
in {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    generate = import ./generate.nix {inherit inputs pkgs;};
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    # Docs generation requires nix-darwin, which is the concrete host platform.

    # On Linux these packages exist but no-op, so `nix flake check` on Linux
    # never evaluates darwinSystem.

    packages.docs-options = pkgs.runCommand "docs-options" {} ''
      mkdir -p $out/darwin/index $out/home/index
      touch $out/darwin.md $out/home.md
      touch $out/darwin/index/options.txt $out/home/index/options.txt
      ${lib.optionalString isDarwin ''
        cp ${generate.darwin.optionsCommonMark} $out/darwin.md
        cp ${generate.home.optionsCommonMark} $out/home.md
        grep '^## ' $out/darwin.md > $out/darwin/index/options.txt
        grep '^## ' $out/home.md > $out/home/index/options.txt
      ''}
    '';

    packages.docs-html =
      pkgs.runCommand "docs-html"
      {
        nativeBuildInputs = [
          pkgs.mdbook
          pkgs.python3
        ];
      }
      ''
        mkdir -p $out
        ${lib.optionalString isDarwin ''
                                      src=$(mktemp -d)
                                                mkdir -p "$src/src/darwin" "$src/src/home"
                                                python3 ${./scripts/split-options.py} ${generate.darwin.optionsCommonMark} "$src/src/darwin" Darwin
                                                python3 ${./scripts/split-options.py} ${generate.home.optionsCommonMark} "$src/src/home" Home
                                                cp ${./book.toml} "$src/book.toml"
                                                cp ${./src/index.md} "$src/src/index.md"
                                                # Per-platform landing pages (stubs) so the sidebar tree is real.
                                                printf '%s\n' "# Darwin" "" "Options under \`aytordev.*\` for the nix-darwin system." > "$src/src/darwin.md"
                                                printf '%s\n' "# Home" "" "Options under \`aytordev.*\` for Home Manager." > "$src/src/home.md"
          {
                      printf '%s\n' "- [Introduction](./index.md)"
                      printf '%s\n' "- [Darwin](./darwin.md)"
                      sed -E 's#\[([^]]+)\]\(\./([^)]+)\)#[\1](./darwin/\2)#; s/^- /  - /' "$src/src/darwin/SUMMARY.Darwin" | tail -n +3
                      printf '%s\n' "- [Home](./home.md)"
                      sed -E 's#\[([^]]+)\]\(\./([^)]+)\)#[\1](./home/\2)#; s/^- /  - /' "$src/src/home/SUMMARY.Home" | tail -n +3
                    } > "$src/src/SUMMARY.md"
                                                              rm -f "$src/src/SUMMARY.darwin" "$src/src/SUMMARY.home"
                                                              mdbook build "$src" --dest-dir "$out"
        ''}
        ${lib.optionalString (!isDarwin) "echo \"docs-html not built on Linux; run on a darwin host\" > $out/README"}
      '';
    apps.docs = {
      type = "app";
      meta.description = "Render aytordev option docs for darwin and home manager";
      program = lib.getExe (
        pkgs.writeShellApplication {
          name = "docs";
          text = ''
            echo "Darwin options index: ${config.packages.docs-options}/darwin/index/options.txt"
            echo "Home options index:   ${config.packages.docs-options}/home/index/options.txt"
          '';
        }
      );
    };

    apps.docs-html = {
      type = "app";
      meta.description = "Open the aytordev option docs (mdbook) in your browser";
      program = lib.getExe (
        pkgs.writeShellApplication {
          name = "docs-html";
          text = ''
            index="${config.packages.docs-html}/index.html"
            if [ ! -f "$index" ]; then
              echo "docs-html is only built on darwin; run 'nix build .#packages.aarch64-darwin.docs-html' first." >&2
              exit 1
            fi
            ${opener pkgs} "$index"
          '';
        }
      );
    };
  };
}
