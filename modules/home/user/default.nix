{
  config,
  lib,
  pkgs,
  inputs,
  username ? null,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    getExe
    getExe'
    ;
  inherit (lib.aytordev) mkOpt enabled;

  cfg = config.aytordev.user;

  home-directory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";

  # Bash-specific aliases (use bash syntax like $(), for, if, source, etc.)
  bashSpecificAliases = {
    gc-check = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\\w+-system|\\{memory|/proc)\"";
    nixnuke = ''
      # Kill nix-daemon and nix processes first
      sudo pkill -9 -f "nix-(daemon|store|build)" 2>/dev/null

      # Find and kill all nixbld processes
      for pid in $(ps -axo pid,user | ${getExe pkgs.gnugrep} -E '[_]?nixbld[0-9]+' | ${getExe pkgs.gawk} '{print $1}'); do
        sudo kill -9 "$pid" 2>/dev/null
      done

      # Restart nix-daemon based on platform
      if [ "$(uname)" = "Darwin" ]; then
        sudo launchctl kickstart -k system/org.nixos.nix-daemon
      else
        sudo systemctl restart nix-daemon.service
      fi
    '';
    remove-empty = ''${getExe' pkgs.findutils "find"} . -type d -empty -delete'';
    print-empty = ''${getExe' pkgs.findutils "find"} . -type d -empty -print'';
    usage = "${getExe' pkgs.coreutils "du"} -ah -d1 | sort -rn 2>/dev/null";
    psg = "${getExe pkgs.ps} aux | grep";
  };
in
{
  options.aytordev.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    email = mkOpt types.str inputs.secrets.useremail "The email of the user.";
    fullName = mkOpt types.str inputs.secrets.userfullname "The full name of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    icon =
      mkOpt (types.nullOr types.package) null
        "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) username "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "aytordev.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "aytordev.user.home must be set";
        }
      ];

      home = {
        file = {
          "Desktop/.keep".text = "";
          "Documents/.keep".text = "";
          "Downloads/.keep".text = "";
          "Music/.keep".text = "";
          "Pictures/.keep".text = "";
          "Videos/.keep".text = "";
        }
        // lib.optionalAttrs (cfg.icon != null) {
          ".face".source = cfg.icon;
          ".face.icon".source = cfg.icon;
          "Pictures/${cfg.icon.fileName or (baseNameOf cfg.icon)}".source = cfg.icon;
        };

        # Only set homeDirectory if cfg.home is not null
        homeDirectory = mkIf (cfg.home != null) (mkDefault cfg.home);

        # Shell-agnostic aliases (work in all shells including Nushell)
        shellAliases = {
          # nix specific aliases
          cleanup = "sudo nix-collect-garbage --delete-older-than 3d; nix-collect-garbage -d";
          bloat = "nix path-info -Sh /run/current-system";
          curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          repair = "nix-store --verify --check-contents --repair";
          flake = "nix flake";
          nix = "nix -vL";
          gsed = "${getExe pkgs.gnused}";

          # File management
          rcp = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1"; # Rsync copy keeping all attributes,timestamps,permissions"
          rmv = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1 --remove-sent-files"; # Rsync move keeping all attributes,timestamps,permissions
          tarnow = "${getExe pkgs.gnutar} -acf ";
          untar = "${getExe pkgs.gnutar} -zxvf ";
          wget = "${getExe pkgs.wget} -c ";
          dfh = "${getExe' pkgs.coreutils "df"} -h";
          duh = "${getExe' pkgs.coreutils "du"} -h";

          # Navigation shortcuts
          home = "cd ~";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";

          # Colorize output
          dir = "${getExe' pkgs.coreutils "dir"} --color=auto";
          egrep = "${getExe' pkgs.gnugrep "egrep"} --color=auto";
          fgrep = "${getExe' pkgs.gnugrep "fgrep"} --color=auto";
          vdir = "${getExe' pkgs.coreutils "vdir"} --color=auto";

          # Misc
          clr = "clear";
          pls = "sudo";
          myip = "${getExe pkgs.curl} ifconfig.me";

          # Cryptography
          genpass = "${getExe pkgs.openssl} rand - base64 20"; # Generate a random, 20-character password
          sha = "shasum -a 256"; # Test checksum
        };

        username = mkDefault cfg.name;
      };

      programs = {
        home-manager = enabled;
        bash.shellAliases = bashSpecificAliases // {
          hmvar-reload = ''__HM_ZSH_SESS_VARS_SOURCED=0 source "/etc/profiles/per-user/${config.aytordev.user.name}/etc/profile.d/hm-session-vars.sh"'';
          clear = "clear; ${getExe config.programs.fastfetch.package}";
        };
        zsh.shellAliases = bashSpecificAliases // {
          hmvar-reload = ''__HM_ZSH_SESS_VARS_SOURCED=0 source "/etc/profiles/per-user/${config.aytordev.user.name}/etc/profile.d/hm-session-vars.sh"'';
          clear = "clear; ${getExe config.programs.fastfetch.package}";
        };
      };
    }
  ]);
}
