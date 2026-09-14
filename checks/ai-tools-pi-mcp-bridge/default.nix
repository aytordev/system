# T07 integration check: the Pi MCP bridge must materialize only when Pi is
# enabled and `selection.pi` is non-empty, must expose exactly the selected
# servers, and must pass the fake-stdio-server proof (discovery, call/result
# conversion, failure, cancellation, cleanup).
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "pi-mcp-check";
    email = "pi-mcp-check@example.test";
    fullName = "Pi MCP Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  bridgeKey = "${homeDirectory}/.pi/agent/extensions/mcp-bridge";

  mkHome = {
    pi ? true,
    mcp ? true,
    piSelection ? [],
  }:
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "pi-mcp-check";
      extraSpecialArgs = {inherit identity;};
      modules = [
        {
          aytordev = {
            user = {
              enable = true;
              name = identity.username;
              inherit (identity) email fullName;
              home = homeDirectory;
            };
            programs.terminal.tools = {
              mcp = {
                enable = mcp;
                selection = {
                  opencode = [];
                  pi = piSelection;
                };
              };
              pi.enable = pi;
            };
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  selectedHome = mkHome {piSelection = ["engram" "filesystem" "nixos"];};
  subsetHome = mkHome {piSelection = ["engram"];};
  emptySelectionHome = mkHome {};
  disabledPiHome = mkHome {
    pi = false;
    piSelection = ["engram"];
  };
  disabledMcpHome = mkHome {
    mcp = false;
    piSelection = ["engram"];
  };

  hasBridge = home: builtins.hasAttr bridgeKey home.home.file;
  selectedSource = selectedHome.home.file.${bridgeKey}.source;
  subsetSource = subsetHome.home.file.${bridgeKey}.source;

  bridge = pkgs.callPackage ../../modules/home/programs/terminal/tools/pi/mcp-bridge/package.nix {};
  bridgeSrc = ../../modules/home/programs/terminal/tools/pi/mcp-bridge;

  checks = {
    selectedMaterializes = hasBridge selectedHome;
    emptySelectionEmitsNothing = !hasBridge emptySelectionHome;
    disabledPiEmitsNothing = !hasBridge disabledPiHome;
    disabledMcpEmitsNothing = !hasBridge disabledMcpHome;
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);
in
  if failed != []
  then throw "ai-tools-pi-mcp-bridge regression failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-pi-mcp-bridge-check" {
      nativeBuildInputs = [pkgs.nodejs_22 pkgs.gnugrep];
    } ''
      export NODE_NO_WARNINGS=1
      export HOME="$TMPDIR"

      # Fake-server proof against the pinned SDK closure.
      cp -r ${bridgeSrc} work
      chmod -R u+w work
      rm -rf work/node_modules
      ln -s ${bridge}/lib/node_modules/@aytordev/pi-mcp-bridge/node_modules work/node_modules
      (cd work && node test/proof.mjs) > proof.log 2>&1
      grep --quiet "PROOF OK" proof.log

      # The deployed bridge contains exactly the selected catalog servers.
      grep --quiet '"engram"' ${selectedSource}/servers.ts
      grep --quiet '"filesystem"' ${selectedSource}/servers.ts
      grep --quiet '"nixos"' ${selectedSource}/servers.ts

      # A subset selection starts only the selected server.
      grep --quiet '"engram"' ${subsetSource}/servers.ts
      ! grep --quiet '"filesystem"' ${subsetSource}/servers.ts
      ! grep --quiet '"nixos"' ${subsetSource}/servers.ts

      touch "$out"
    ''
