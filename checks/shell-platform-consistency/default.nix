{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "ci-shell";
  homeDirectory = "/Users/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "ci-shell";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "ci-shell@example.test";
            fullName = "CI Shell";
            inherit homeDirectory;
          };
          suites.common.enable = true;
        };
        home.stateVersion = "25.11";
      }
    ];
  };
in
  if pkgs.stdenv.hostPlatform.isDarwin
  then let
    darwinHomeModule = {inputs, ...}: {
      assertions = [
        {
          assertion = !(inputs ? secrets);
          message = "Reusable Home Manager modules must not receive the private secrets input";
        }
      ];
      aytordev = {
        user = {
          enable = true;
          name = username;
          email = "ci-shell@example.test";
          fullName = "CI Shell";
          inherit homeDirectory;
        };
        suites.common.enable = true;
      };
      home.stateVersion = "25.11";
    };
    darwin = inputs.self.lib.system.mkDarwin {
      system = "aarch64-darwin";
      hostname = "ci-shell";
      inherit username;
      hostModule = null;
      extraSpecialArgs = {inherit username;};
      matchingHomes.ci = {
        inherit username;
        path = darwinHomeModule;
      };
      modules = [
        (
          _: {
            aytordev = {
              user = {
                name = username;
                email = "ci-shell@example.test";
                fullName = "CI Shell";
              };
            };
          }
        )
      ];
    };
    cfg = darwin.config;
    userShell = cfg.users.users.${username}.shell or null;
    namedTests = [
      {
        name = "darwin manages the user account (users.knownUsers)";
        value = builtins.elem username cfg.users.knownUsers or [];
      }
      {
        name = "login shell is zsh";
        value = userShell == pkgs.zsh;
      }
      {
        name = "login shell matches the Home Manager zsh package";
        value = userShell == home.config.programs.zsh.package;
      }
      {
        name = "environment.shells registers the nix zsh";
        value = lib.any (s: lib.hasInfix "/zsh" (toString s)) (cfg.environment.shells or []);
      }
      {
        name = "Home Manager enables zsh";
        value = home.config.aytordev.programs.terminal.shells.zsh.enable;
      }
    ];
  in
    lib.foldl' (
      acc: t: acc && lib.throwIfNot t.value t.name "shell-platform-consistency"
    )
    true
    namedTests
    -> pkgs.runCommand "shell-platform-consistency"
    {
      nativeBuildInputs = [pkgs.coreutils];
    }
    ''
      touch "$out"
    ''
  else
    pkgs.runCommand "shell-platform-consistency-skipped" {} ''
      touch "$out"
    ''
