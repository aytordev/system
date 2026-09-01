{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit
    (lib)
    getExe
    getExe'
    mkDefault
    mkIf
    ;
  inherit (lib.aytordev) enabled disabled;

  cfg = config.aytordev.suites.common;
  isWSL = osConfig.aytordev.archetypes.wsl.enable or false;
  nhFlake = config.aytordev.programs.terminal.tools.nh.flake;
  fastfetchCfg = config.aytordev.programs.terminal.tools.fastfetch;

  bashAliases =
    {
      # Closure size checking aliases
      ncs-sys = ''f(){ nix build ".#nixosConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#nixosConfigurations.$1.config.system.build.toplevel.outPath") | tail -1; }; f'';
      ncs-darwin = ''f(){ nix build ".#darwinConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#darwinConfigurations.$1.config.system.build.toplevel.outPath") | tail -1; }; f'';
      ncs-home = ''f(){ nix build ".#homeConfigurations.$1.activationPackage" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#homeConfigurations.$1.activationPackage.outPath") | tail -1; }; f'';
      ndu = "nix-du -s=200MB | dot -Tsvg > store.svg ${
        lib.optionalString (!isWSL)
        "; ${
          if pkgs.stdenv.hostPlatform.isDarwin
          then "open"
          else "xdg-open"
        } store.svg"
      }";
      gc-check = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\\w+-system|\\{memory|/proc)\"";
      nixnuke = ''
        sudo pkill -9 -f "nix-(daemon|store|build)" 2>/dev/null
        for pid in $(ps -axo pid,user | ${getExe pkgs.gnugrep} -E '[_]?nixbld[0-9]+' | ${getExe pkgs.gawk} '{print $1}'); do
          sudo kill -9 "$pid" 2>/dev/null
        done
        if [ "$(uname)" = "Darwin" ]; then
          sudo launchctl kickstart -k system/org.nixos.nix-daemon
        else
          sudo systemctl restart nix-daemon.service
        fi
      '';
      remove-empty = "${getExe' pkgs.findutils "find"} . -type d -empty -delete";
      print-empty = "${getExe' pkgs.findutils "find"} . -type d -empty -print";
      usage = "${getExe' pkgs.coreutils "du"} -ah -d1 | sort -rn 2>/dev/null";
      psg = "${getExe pkgs.ps} aux | grep";
      hmvar-reload = ''unset __HM_SESS_VARS_SOURCED; source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"'';
    }
    // lib.optionalAttrs fastfetchCfg.enable {
      clear = "clear; ${getExe fastfetchCfg.package}";
    };
  # POSIX-style aliases with ';' or 'command' would break Nushell (a ';' in the
  # value executes a bare command at config.nu load time), so they live on the
  # shells that understand them.
  posixAliases =
    {
      cleanup = "sudo nix-collect-garbage --delete-older-than 3d; nix-collect-garbage -d";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      # Prevent the shell alias from overriding the macOS log command.
      log = "command log";
    };
in {
  options.aytordev.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    home = {
      # Silence login messages in shells
      file =
        {
          ".hushlogin".text = "";
          "Desktop/.keep".text = "";
          "Documents/.keep".text = "";
          "Downloads/.keep".text = "";
          "Music/.keep".text = "";
          "Pictures/.keep".text = "";
          "Videos/.keep".text = "";
        }
        // lib.optionalAttrs (config.aytordev.user.icon != null) {
          ".face".source = config.aytordev.user.icon;
          ".face.icon".source = config.aytordev.user.icon;
          "Pictures/${config.aytordev.user.icon.fileName or (baseNameOf config.aytordev.user.icon)}".source =
            config.aytordev.user.icon;
        };

      sessionVariables = {
        LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
        WGETRC = "${config.xdg.configHome}/wgetrc";
      };

      # Only shell-agnostic aliases in home.shellAliases. These fan out to all
      # shells including Nushell, so each value must be a single command with
      # no ';', '$(' or 'command' (which Nu parses differently).
      shellAliases =
        {
          bloat = "nix path-info -Sh /run/current-system";
          curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          repair = "nix-store --verify --check-contents --repair";
          flake = "nix flake";
          nix = "nix -vL";
          gsed = getExe pkgs.gnused;
          rcp = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1";
          rmv = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1 --remove-sent-files";
          tarnow = "${getExe pkgs.gnutar} -acf ";
          untar = "${getExe pkgs.gnutar} -zxvf ";
          wget = "${getExe pkgs.wget} -c ";
          dfh = "${getExe' pkgs.coreutils "df"} -h";
          duh = "${getExe' pkgs.coreutils "du"} -h";
          home = "cd ~";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";
          dir = "${getExe' pkgs.coreutils "dir"} --color=auto";
          egrep = "${getExe' pkgs.gnugrep "egrep"} --color=auto";
          fgrep = "${getExe' pkgs.gnugrep "fgrep"} --color=auto";
          vdir = "${getExe' pkgs.coreutils "vdir"} --color=auto";
          clr = "clear";
          pls = "sudo";
          myip = "${getExe pkgs.curl} ifconfig.me";
          genpass = "${getExe pkgs.openssl} rand -base64 20";
          sha = "shasum -a 256";
        }
        // lib.optionalAttrs (nhFlake != null) {nixcfg = "nvim ${nhFlake}/flake.nix";};
    };

    home.packages = with pkgs;
      [
        # colorscript outputs
        dwt1-shell-color-scripts
        ncdu
        # NOTE: Typing test
        # smassh
        toilet
        tree
        wikiman
        # Visualize nix store
        nix-du
        graphviz
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pngpaste
      ];

    aytordev = {
      programs = {
        terminal = {
          emulators = {
            ghostty = mkDefault enabled;
            warp = mkDefault disabled;
          };

          shells = {
            bash = mkDefault enabled;
            nushell = mkDefault enabled;
            fish = mkDefault enabled;
            zsh = mkDefault enabled;
          };

          tools = {
            atuin = mkDefault enabled;
            bat = mkDefault enabled;
            bottom = mkDefault enabled;
            btop = mkDefault enabled;
            carapace = mkDefault enabled;
            comma = mkDefault enabled;
            dircolors = mkDefault enabled;
            direnv = mkDefault enabled;
            eza = mkDefault enabled;
            fastfetch = mkDefault enabled;
            ffmpeg = mkDefault enabled;
            fzf = mkDefault enabled;
            git = mkDefault enabled;
            # infat = mkDefault enabled; # TODO: Pending to fix this module.
            jq = mkDefault enabled;
            lsd = mkDefault disabled;
            navi = mkDefault enabled;
            nix-search-tv = mkDefault enabled;
            nh = mkDefault enabled;
            rclone = mkDefault enabled;
            ripgrep = mkDefault enabled;
            run-as-service = mkDefault (
              if pkgs.stdenv.hostPlatform.isLinux
              then enabled
              else disabled
            );
            ssh = mkDefault enabled;
            starship = mkDefault enabled;
            tmux = mkDefault enabled;
            yazi = mkDefault enabled;
            zellij = mkDefault enabled;
            yt-dlp = mkDefault enabled;
            zoxide = mkDefault enabled;
          };
        };
      };

      services = {
        protonmail-bridge.enable = mkDefault pkgs.stdenv.hostPlatform.isDarwin;
      };

      system.input.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isDarwin;
    };

    programs = {
      home-manager.enable = mkDefault true;
      # FIXME: breaks zsh aliases
      # pay-respects = mkDefault enabled;
      bash.shellAliases = bashAliases // posixAliases;
      zsh.shellAliases = bashAliases // posixAliases;
      fish.shellAliases = posixAliases;
      readline = {
        enable = mkDefault true;

        extraConfig = ''
          set completion-ignore-case on
        '';
      };
    };

    xdg.configFile.wgetrc.text = "";
  };
}
