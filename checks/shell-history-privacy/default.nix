{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "shell-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "shell-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "shell@example.test";
            fullName = "Shell User";
            home = homeDirectory;
          };
        };
        home.stateVersion = "25.11";
      }
      {aytordev.suites.common.enable = true;}
      {aytordev.suites.development.enable = true;}
    ];
  };
  inherit (home) config;
  dataHome = "${config.xdg.dataHome}";

  nuEnv =
    config.home.file."${config.programs.nushell.configDir}/env.nu".text
      or config.programs.nushell.envFile.text or "";
  fishInit = config.programs.fish.interactiveShellInit + config.programs.fish.shellInit;

  # Every directory that holds plaintext command history must be sealed 0700
  # through its activation entry (chmod 700 "<dir>"). El entry name matches the
  # module that owns it, so the assertion can point at the right one.
  sealedDirs = [
    {
      entry = "zshSessionDir";
      dir = "${dataHome}/zsh/sessions";
    }
    {
      entry = "fishDirs";
      dir = "${dataHome}/fish";
    }
    {
      entry = "createXdgDirs";
      dir = "${dataHome}/nu";
    }
    {
      entry = "createAtuinDataDir";
      dir = "${dataHome}/atuin";
    }
    {
      entry = "createZoxideDataDir";
      dir = "${dataHome}/zoxide";
    }
  ];
  sealAssertions =
    map (
      s: let
        entryText = config.home.activation.${s.entry}.data or "";
      in {
        assertion = lib.hasInfix "chmod 700" entryText && lib.hasInfix s.dir entryText;
        message = "Activation entry ${s.entry} must seal ${s.dir} with chmod 700";
      }
    )
    sealedDirs;

  tests = [
    {
      assertion = lib.elem "ignorespace" config.programs.bash.historyControl;
      message = "bash historyControl must include ignorespace (space-prefixed secrets)";
    }
    {
      assertion = lib.hasPrefix dataHome config.programs.bash.historyFile;
      message = "bash history must live under the XDG data dir";
    }
    {
      assertion = lib.hasPrefix dataHome config.programs.zsh.history.path;
      message = "zsh history must live under the XDG data dir";
    }
    {
      assertion = !(lib.hasInfix "LC_ALL" fishInit);
      message = "fish must not force LC_ALL per-shell";
    }
    {
      assertion = !(lib.hasInfix "NU_HISTORY" nuEnv);
      message = "nushell env.nu must not set NU_HISTORY (ignored upstream; history resolves to the config dir)";
    }
  ];
  assertions = tests ++ sealAssertions;
in
  builtins.seq (lib.foldl' (_acc: a:
      if !a.assertion
      then throw a.message
      else true)
    true
    assertions)
  (
    pkgs.runCommand "shell-history-privacy" {} ''
      touch "$out"
    ''
  )
