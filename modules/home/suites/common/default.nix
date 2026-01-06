{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.aytordev) enabled disabled;

  cfg = config.aytordev.suites.common;
  isWSL = osConfig.aytordev.archetypes.wsl.enable or false;

  # Bash-specific aliases (uses bash syntax like $(), f(){}, $VAR)
  bashAliases = {
    # Closure size checking aliases
    ncs-sys = ''f(){ nix build ".#nixosConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#nixosConfigurations.$1.config.system.build.toplevel.outPath") | tail -1; }; f'';
    ncs-darwin = ''f(){ nix build ".#darwinConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#darwinConfigurations.$1.config.system.build.toplevel.outPath") | tail -1; }; f'';
    ncs-home = ''f(){ nix build ".#homeConfigurations.$1.activationPackage" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#homeConfigurations.$1.activationPackage.outPath") | tail -1; }; f'';
    ndu = "nix-du -s=200MB | dot -Tsvg > store.svg ${
      lib.optionalString (!isWSL)
        "; ${if pkgs.stdenv.hostPlatform.isDarwin then "open" else "xdg-open"} store.svg"
    }";
  };
in
{
  options.aytordev.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    home = {
      # Silence login messages in shells
      file = {
        ".hushlogin".text = "";
      };

      sessionVariables = {
        LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
        WGETRC = "${config.xdg.configHome}/wgetrc";
      };

      # Only shell-agnostic aliases in home.shellAliases (applies to all shells including Nushell)
      shellAliases = {
        nixcfg = "nvim ~/aytordev/flake.nix";
      };
    };

    home.packages =
      with pkgs;
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
            fzf = mkDefault enabled;
            git = mkDefault enabled;
            # infat = mkDefault enabled; # TODO: Pending to fix this module.
            jq = mkDefault enabled;
            lsd = mkDefault disabled;
            navi = mkDefault enabled;
            nix-search-tv = mkDefault enabled;
            nh = mkDefault enabled;
            ripgrep = mkDefault enabled;
            run-as-service = mkDefault (if pkgs.stdenv.hostPlatform.isLinux then enabled else disabled);
            ssh = mkDefault enabled;
            starship = mkDefault enabled;
            tmux = mkDefault enabled;
            yazi = mkDefault enabled;
            zellij = mkDefault enabled;
            zoxide = mkDefault enabled;
          };
        };
      };

      system.input.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isDarwin;
    };

    programs = {
      # FIXME: breaks zsh aliases
      # pay-respects = mkDefault enabled;
      bash.shellAliases = bashAliases;
      zsh.shellAliases = bashAliases;
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
