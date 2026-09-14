# T27/T28 integration check for the adopted gentle-ai engine adapter.
#
# Proves the package builds and reports `version`, the Home adapter materializes
# only when enabled and owns the engine environment, and the adapter runs on a
# disposable, isolated Engram fixture:
#   - project-name agreement: a writer stamping the git-remote basename resolves;
#   - no `~/.engram` fallback: data only in `$HOME/.engram` is ignored while
#     `ENGRAM_DATA_DIR` points elsewhere;
#   - the documented `ENGRAM_PROJECT` override aligns a disagreeing writer.
# The observed results are written to $out as a machine-readable fixture.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  identity = {
    username = "gentle-ai-check";
    email = "gentle-ai-check@example.test";
    fullName = "Gentle AI Check";
  };
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${identity.username}"
    else "/home/${identity.username}";

  mkHome = {
    enable ? true,
    engramProject ? null,
  }:
    (inputs.self.lib.system.mkHome {
      inherit system;
      inherit (identity) username;
      hostname = "gentle-ai-check";
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
            programs.terminal.tools.gentle-ai = {
              inherit enable engramProject;
            };
          };
          home.stateVersion = "25.11";
        }
      ];
    }).config;

  engineCfg = home: home.aytordev.programs.terminal.tools.gentle-ai;

  enabledHome = mkHome {};
  disabledHome = mkHome {enable = false;};
  pinnedHome = mkHome {engramProject = "pinned-project";};

  enabledCfg = engineCfg enabledHome;
  disabledCfg = engineCfg disabledHome;
  pinnedCfg = engineCfg pinnedHome;

  installed = home: pkg: lib.any (p: p.outPath == pkg.outPath) home.home.packages;

  checks = {
    enabledInstallsEngine = installed enabledHome enabledCfg.package;
    enabledInstallsAdapter = installed enabledHome enabledCfg.adapter;
    disabledInstallsNothing = !(installed disabledHome disabledCfg.package);
    disabledAdapterUndefined = !(builtins.tryEval disabledCfg.adapter).success;
    dataDirMatchesMcpServer = enabledCfg.engramDataDir == "${homeDirectory}/.local/share/engram";
    projectDefaultUnset = enabledCfg.engramProject == null;
    projectOverrideRecorded = pinnedCfg.engramProject == "pinned-project";
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);

  engine = enabledCfg.package;
  inherit (enabledCfg) adapter;
  engram = pkgs.aytordev.engram;
in
  if failed != []
  then throw "gentle-ai-engine regression failures: ${lib.concatStringsSep ", " failed}"
  else
    pkgs.runCommand "gentle-ai-engine-check" {
      nativeBuildInputs = [
        pkgs.jq
        pkgs.git
        engram
      ];
    } ''
      set -eu

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"

      # --- package builds and reports its version -------------------------
      version="$(${engine}/bin/gentle-ai version)"
      echo "engine version: $version"
      [ "$version" = "gentle-ai 2.9.0" ]

      # --- disposable workspace with a git remote -------------------------
      # The engine infers the project from the remote basename
      # (`engram-agreement`), so the writer must stamp the same value.
      WS="$TMPDIR/ws"
      mkdir -p "$WS/openspec"
      (
        cd "$WS"
        git init -q
        git remote add origin https://github.com/aytordev/engram-agreement.git
        printf 'artifact_store: engram\n' > openspec/config.yaml
      )

      # --- isolated Engram database (no ~/.engram fallback) ---------------
      export ENGRAM_DATA_DIR="$TMPDIR/engram-data"
      mkdir -p "$ENGRAM_DATA_DIR"

      ADAPTER="${adapter}/bin/aytordev-sdd"
      ENG="${engram}/bin/engram"

      # Writer stamps the project name the engine infers.
      "$ENG" save "sdd/demo/proposal" "# Proposal for demo" \
        --project engram-agreement --scope project --type architecture >/dev/null

      positive="$(cd "$WS" && "$ADAPTER" status demo --json)"
      echo "$positive" | jq --exit-status \
        '.changeRoot == "engram:sdd/demo" and .artifacts.proposal == "done"' >/dev/null

      # Data living only in $HOME/.engram must be ignored when ENGRAM_DATA_DIR
      # points at a different database.
      empty="$TMPDIR/empty"
      mkdir -p "$empty" "$HOME/.engram"
      HOME="$HOME" ENGRAM_DATA_DIR="$HOME/.engram" "$ENG" save \
        "sdd/fallback/proposal" "# fallback" \
        --project engram-agreement --scope project --type architecture >/dev/null
      noFallback="$(cd "$WS" && HOME="$HOME" ENGRAM_DATA_DIR="$empty" "$ADAPTER" status fallback --json)"
      echo "$noFallback" | jq --exit-status '.changeRoot == null' >/dev/null

      # A writer using the directory basename disagrees with the git-remote
      # inference; the documented ENGRAM_PROJECT override aligns them.
      "$ENG" save "sdd/dirname/proposal" "# dirname" \
        --project ws --scope project --type architecture >/dev/null
      disagree="$(cd "$WS" && "$ADAPTER" status dirname --json)"
      echo "$disagree" | jq --exit-status '.changeRoot == null' >/dev/null
      override="$(cd "$WS" && ENGRAM_PROJECT=ws "$ADAPTER" status dirname --json)"
      echo "$override" | jq --exit-status '.changeRoot == "engram:sdd/dirname"' >/dev/null

      # The adapter rejects a command outside the consumed surface.
      set +e
      "$ADAPTER" review >/dev/null 2>&1
      reviewExit=$?
      set -e
      [ "$reviewExit" -eq 64 ]

      mkdir -p "$out"
      jq --null-input \
        --arg engineVersion "$version" \
        --argjson positive "$positive" \
        --argjson noFallback "$noFallback" \
        --argjson disagree "$disagree" \
        --argjson override "$override" \
        '{
          engineVersion: $engineVersion,
          projectNameAgreement: {
            writer: "engram-agreement",
            inferred: "engram-agreement",
            resolved: $positive.changeRoot
          },
          noHomeFallback: {resolved: $noFallback.changeRoot},
          projectOverride: {
            writer: "ws",
            unresolved: $disagree.changeRoot,
            overrideResolved: $override.changeRoot
          }
        }' > "$out/engram-integration-fixture.json"

      cat "$out/engram-integration-fixture.json"
    ''
