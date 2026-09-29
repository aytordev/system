{lib, ...}: let
  terminal = import ../../modules/home/programs/desktop/editors/zed/terminal.nix {};
  capabilities = {
    zellij = {
      enable = true;
      package = "zellij-package";
    };
    tmux = {
      enable = true;
      package = "tmux-package";
    };
  };
  helpers = {
    zellij = "/nix/store/session-test/bin/zellij-session";
    tmux = "/nix/store/session-test/bin/tmux-session";
  };
  profile = import ../../modules/home/programs/desktop/editors/zed/profile.nix {inherit lib;};
  package = {
    type = "derivation";
    name = "zed-test";
    outPath = "/nix/store/zed-test";
    meta.mainProgram = "zeditor";
  };
  terminalShell.program = "/nix/store/session-test/bin/zellij-session";
  preferences = import ../../modules/home/programs/desktop/editors/zed/preferences.nix {
    inherit lib package terminalShell;
  };
  composed =
    profile.defaultLeaves
    (profile.compose {
      ownedSettings = preferences.settings;
    }).settings;
in {
  testZedTerminalSelectionMatrix = {
    expr = map (multiplexer: terminal.shell {inherit multiplexer capabilities helpers;}) ["zellij" "tmux" "system"];
    expected = [{program = helpers.zellij;} {program = helpers.tmux;} "system"];
  };
  testZedTerminalDefaultSelection = {
    expr = terminal.resolve {inherit capabilities;};
    expected = "zellij";
  };
  testZedTerminalMissingCapabilities = {
    expr = map (multiplexer:
      terminal.shell {
        inherit multiplexer;
        # Fallback must not force helper construction when options are missing.
        helpers = throw "Unexpected helper evaluation";
      }) ["zellij" "tmux" "system"];
    expected = ["system" "system" "system"];
  };
  testZedTerminalDisabledCapabilityDoesNotChooseOtherMultiplexer = {
    expr = map (multiplexer:
      terminal.resolve {
        inherit multiplexer;
        capabilities =
          capabilities
          // {
            ${multiplexer} = {
              enable = false;
              package = "disabled";
            };
          };
      }) ["zellij" "tmux"];
    expected = ["system" "system"];
  };
  testZedTerminalNullPackageFallsBack = {
    expr = terminal.resolve {
      multiplexer = "tmux";
      capabilities.tmux = {
        enable = true;
        package = null;
      };
    };
    expected = "system";
  };
  # Exercise the actual owned-preference -> composition -> leaf-default path,
  # not a post-composition terminal override that would bypass that contract.
  testZedTerminalProgramComposesAsDefaultLeaf = {
    expr = composed.terminal.shell;
    expected.program = lib.mkDefault terminalShell.program;
  };
}
