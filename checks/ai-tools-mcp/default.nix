# T06 integration check: explicit MCP selection must project exactly the
# selected servers into OpenCode.
#
# Synthesizes Home Manager compositions with empty, subset, all-selected,
# disabled-client, and disabled-capability fixtures, then asserts the effective
# `programs.opencode.settings.mcp` keys and preserved server semantics.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  identity = {
    username = "mcp-check";
    email = "mcp-check@example.test";
    fullName = "MCP Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  mkHome = {
    opencode ? true,
    mcp ? true,
    opencodeSelection ? [],
  }:
    (inputs.self.lib.system.mkHome {
      system = pkgs.stdenv.hostPlatform.system;
      inherit (identity) username;
      hostname = "mcp-check";
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
                  opencode = opencodeSelection;
                };
              };
              opencode.enable = opencode;
            };
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  effectiveMcp = home: home.programs.opencode.settings.mcp or {};
  sorted = builtins.sort builtins.lessThan;

  emptyHome = mkHome {};
  subsetHome = mkHome {
    opencodeSelection = ["engram"];
  };
  allHome = mkHome {
    opencodeSelection = ["engram" "filesystem" "nixos"];
  };
  disabledClientHome = mkHome {
    opencode = false;
    opencodeSelection = ["engram" "filesystem" "nixos"];
  };
  disabledMcpHome = mkHome {
    mcp = false;
    opencodeSelection = ["engram" "filesystem" "nixos"];
  };

  # An unknown selection must fail the module assertion, so forcing `.config`
  # must throw and `tryEval` must report failure.
  unknownSelectionRejected =
    !(builtins.tryEval (effectiveMcp (mkHome {opencodeSelection = ["not-a-server"];}))).success;

  allMcp = effectiveMcp allHome;

  checks = {
    emptyEmitsNothing = effectiveMcp emptyHome == {};
    subsetIsExact = sorted (builtins.attrNames (effectiveMcp subsetHome)) == ["engram"];
    allIsExact = sorted (builtins.attrNames allMcp) == ["engram" "filesystem" "nixos"];
    staleGithubSocketGone = !(allMcp ? github) && !(allMcp ? socket);
    disabledClientEmitsNothing = effectiveMcp disabledClientHome == {};
    disabledMcpEmitsNothing = effectiveMcp disabledMcpHome == {};
    integrationEnabled = allHome.programs.opencode.enableMcpIntegration;
    engramDirPreserved = allMcp.engram.environment.ENGRAM_DATA_DIR == "${homeDirectory}/.local/share/engram";
    engramArgsPreserved = lib.last allMcp.engram.command == "mcp";
    filesystemArgsPreserved = lib.last allMcp.filesystem.command == "${homeDirectory}/Documents";
    inherit unknownSelectionRejected;
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);

  report = pkgs.writeText "ai-tools-mcp-effective.json" (builtins.toJSON {
    inherit checks;
    effective = {
      empty = effectiveMcp emptyHome;
      subset = effectiveMcp subsetHome;
      all = effectiveMcp allHome;
    };
  });
in
  if failed != []
  then throw "ai-tools-mcp regression failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "ai-tools-mcp-check" {
      nativeBuildInputs = [pkgs.jq];
    } ''
      jq --exit-status '.effective.all | keys == ["engram", "filesystem", "nixos"]' ${report} > /dev/null
      jq --exit-status '.checks | to_entries | all(.value == true)' ${report} > /dev/null
      touch "$out"
    ''
