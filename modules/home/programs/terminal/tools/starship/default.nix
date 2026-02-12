{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.starship;
  themeCfg = config.aytordev.theme;
  inherit (themeCfg) palette;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
  starshipConfigDir = "${xdgConfigHome}/starship";
  starshipConfigFile = "${starshipConfigDir}/config.toml";

  # Helper: Create language module config
  mkLang = {
    symbol,
    color,
    extraAttrs ? {},
  }:
    {
      inherit symbol;
      format = "[[ $symbol ($version) ](fg:${color})]($style)";
      version_format = "\${raw}";
    }
    // extraAttrs;

  # Format string modules - using lib.concatStrings for maintainability
  formatModules = [
    "($directory)"
    "$os"
    "$localip"
    "$git_branch"
    "$git_status"
    "$fill"
    "$git_metrics"
    # Languages
    "$nodejs"
    "$rust"
    "$golang"
    "$python"
    "$c"
    "$java"
    "$zig"
    "$bun"
    "$lua"
    "$swift"
    "$php"
    "$ruby"
    "$deno"
    # Environment
    "$nix_shell"
    "$docker_context"
    # Status
    "$cmd_duration"
    "$time"
    "$battery"
  ];

  promptModules = [
    "$env_var"
    "$sudo"
    "$jobs"
    "$character"
  ];

  # Palettes extracted for maintainability
  palettes = {
    kanagawa = {
      text = palette.fg.hex;
      red = palette.red.hex;
      green = palette.green.hex;
      yellow = palette.yellow.hex;
      blue = palette.accent.hex;
      magenta = palette.violet.hex;
      teal = palette.cyan.hex;
      peach = palette.orange.hex;
      mauve = palette.accent_dim.hex;
      pink = palette.pink.hex;
      subtext0 = palette.fg_dim.hex;
      subtext1 = palette.fg_reverse.hex;
      overlay0 = palette.bg_gutter.hex;
      overlay1 = palette.bg_visual.hex;
      overlay2 = palette.overlay.hex;
      surface0 = palette.bg_dim.hex;
      surface1 = palette.bg.hex;
      surface2 = palette.bg_gutter.hex;
      base = palette.bg.hex;
      mantle = palette.bg_dim.hex;
      crust = palette.bg_float.hex;
      lavender = palette.blue_bright.hex;
      rosewater = palette.yellow_bright.hex;
      flamingo = palette.red_bright.hex;
      maroon = palette.red_dim.hex;
    };
  };

  # Language module configs using mkLang helper
  languageModules = {
    nodejs = mkLang {
      symbol = "";
      color = "green";
    };
    rust = mkLang {
      symbol = "";
      color = "red";
    };
    golang = mkLang {
      symbol = "";
      color = "teal";
    };
    python = {
      symbol = " ";
      format = "[$symbol$pyenv_prefix($version)( $virtualenv)](fg:peach)";
      version_format = "\${raw}";
    };
    c = mkLang {
      symbol = "";
      color = "blue";
    };
    java = mkLang {
      symbol = "";
      color = "red";
    };
    zig = mkLang {
      symbol = "";
      color = "peach";
    };
    bun = mkLang {
      symbol = "";
      color = "text";
    };
    lua = mkLang {
      symbol = "󰢱 ";
      color = "blue";
    };
    swift = mkLang {
      symbol = "◁ ";
      color = "peach";
    };
    php = mkLang {
      symbol = "";
      color = "peach";
    };
    ruby = mkLang {
      symbol = "◆ ";
      color = "red";
    };
    deno = {
      format = "[[ deno ($version) ](fg:green)]($style)";
      version_format = "\${raw}";
    };
  };

  starshipConfig =
    {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = true;
      command_timeout = 10000;
      scan_timeout = 30;
      palette = "kanagawa_wave";

      format = lib.concatStrings formatModules + "\n" + lib.concatStrings promptModules;

      inherit palettes;

      fill.symbol = " ";

      character = {
        success_symbol = "[ ](fg:green)";
        error_symbol = "[ ](fg:red)";
        vimcmd_symbol = "[N](bold fg:red)";
        vimcmd_replace_one_symbol = "[R](bold fg:peach)";
        vimcmd_replace_symbol = "[R](bold fg:peach)";
        vimcmd_visual_symbol = "[V](bold fg:mauve)";
      };

      username = {
        style_user = "bold fg:blue";
        style_root = "bold fg:red";
        format = "[ $user](fg:$style) ";
        disabled = false;
        show_always = true;
      };

      directory = {
        format = "[$path](bold $style)[$read_only]($read_only_style) ";
        truncation_length = 2;
        style = "fg:blue";
        read_only_style = "fg:blue";
        before_repo_root_style = "fg:blue";
        truncation_symbol = "…/";
        truncate_to_repo = true;
        read_only = "  ";
        home_symbol = "⌂";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      os = {
        format = "[$symbol](fg:text) ";
        disabled = false;
        symbols = {
          Macos = "";
          Linux = "󰌽";
          Windows = "󰍲";
          Ubuntu = "󰕈";
          Debian = "󰣚";
          Arch = "󰣇";
          Fedora = "󰣛";
        };
      };

      cmd_duration = {
        format = " took [ $duration]($style) ";
        style = "bold fg:yellow";
        min_time = 500;
      };

      git_branch = {
        format = "-> [$symbol$branch]($style) ";
        style = "bold fg:mauve";
        symbol = "git:";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "fg:text";
      };

      git_metrics = {
        format = "([+$added]($added_style)) ([-$deleted]($deleted_style)) ";
        added_style = "fg:green";
        deleted_style = "fg:red";
        ignore_submodules = true;
        disabled = false;
      };

      nix_shell = {
        style = "bold fg:blue";
        symbol = "✶";
        format = "[$symbol nix($state)]($style) ";
        impure_msg = "⌽";
        pure_msg = "⌾";
        unknown_msg = "◌";
      };

      docker_context = {
        symbol = " ";
        format = "[$symbol$context]($style) ";
        disabled = true;
      };

      time = {
        disabled = false;
        time_format = "%R";
        format = "[[   $time ](fg:subtext0)]($style)";
      };

      battery = {
        format = "[ $percentage $symbol]($style)";
        full_symbol = "█";
        charging_symbol = "[↑](bold fg:green)";
        discharging_symbol = "↓";
        unknown_symbol = "░";
        empty_symbol = "▃";
        display = [
          {
            threshold = 20;
            style = "bold fg:red";
          }
          {
            threshold = 60;
            style = "fg:mauve";
          }
          {
            threshold = 70;
            style = "fg:yellow";
          }
          {
            threshold = 100;
            style = "fg:green";
          }
        ];
      };

      localip = {
        ssh_only = true;
        format = " ◯[$localipv4](bold fg:pink)";
        disabled = false;
      };

      sudo = {
        format = "[$symbol]($style)";
        style = "bold fg:lavender";
        symbol = "⋈ ";
        disabled = false;
      };

      jobs = {
        format = "[$symbol$number]($style) ";
        style = "fg:text";
        symbol = "[▶](fg:blue)";
      };

      env_var = {
        VIMSHELL = {
          format = "[$env_value]($style)";
          style = "fg:green";
        };
      };
    }
    // languageModules;
in {
  options.aytordev.programs.terminal.tools.starship = {
    enable = lib.mkEnableOption "Starship prompt";

    palette = lib.mkOption {
      type = lib.types.str;
      default = "kanagawa";
      description = "Color palette to use for Starship prompt. Defaults to 'kanagawa' which adapts to the global theme variant.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with ZSH";
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Fish shell";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Bash";
    };

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Starship integration with Nushell";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = starshipConfig // {inherit (cfg) palette;};
      description = "Starship configuration options";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        (pkgs.writeShellScriptBin "starship" ''
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          unset STARSHIP_LOG
          unset STARSHIP_CACHE
          export TMPDIR="${config.xdg.cacheHome}/starship-tmp"
          mkdir -p "$TMPDIR"
          chmod 700 "$TMPDIR"
          exec ${pkgs.starship}/bin/starship "$@"
        '')
      ];

      xdg.configFile."starship/config.toml".source =
        (pkgs.formats.toml {}).generate "starship-config" cfg.settings;

      home.activation.createStarshipTmpDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/starship-tmp"
        $DRY_RUN_CMD chmod 700 "${config.xdg.cacheHome}/starship-tmp"
      '';
    }

    (lib.mkIf cfg.enableZshIntegration {
      programs.zsh.initContent = ''
        if [ -n "$commands[starship]" ]; then
          export STARSHIP_CONFIG="${starshipConfigFile}"
          export STARSHIP_CONFIG_DIR="${starshipConfigDir}"
          export STARSHIP_CACHE="${xdgCacheHome}/starship"
          for dir in "$STARSHIP_CACHE" "$STARSHIP_CONFIG_DIR/modules"; do
            [ ! -d "$dir" ] && mkdir -p "$dir"
          done
          eval "$(${pkgs.starship}/bin/starship init zsh --print-full-init)"
        fi
      '';
    })

    (lib.mkIf cfg.enableFishIntegration {
      programs.fish.interactiveShellInit = ''
        if command -q starship
          set -gx STARSHIP_CONFIG "${starshipConfigFile}"
          set -gx STARSHIP_CONFIG_DIR "${starshipConfigDir}"
          set -gx STARSHIP_CACHE "${xdgCacheHome}/starship"
          for dir in $STARSHIP_CACHE "$STARSHIP_CONFIG_DIR/modules"
            test -d "$dir"; or mkdir -p "$dir"
          end
          ${pkgs.starship}/bin/starship init fish | source
        end
      '';
    })

    (lib.mkIf cfg.enableNushellIntegration {
      programs.nushell.extraConfig = ''
        $env.STARSHIP_CONFIG = "${starshipConfigFile}"
        $env.STARSHIP_CONFIG_DIR = "${starshipConfigDir}"
        $env.STARSHIP_CACHE = "${xdgCacheHome}/starship"
        $env.PROMPT_COMMAND = { || ${pkgs.starship}/bin/starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' }
        $env.PROMPT_COMMAND_RIGHT = { || ${pkgs.starship}/bin/starship prompt --right }
        $env.STARSHIP_SHELL = "nu"
        $env.PROMPT_INDICATOR = { || "" }
        $env.PROMPT_INDICATOR_VI_INSERT = { || "" }
        $env.PROMPT_INDICATOR_VI_NORMAL = { || "" }
        $env.PROMPT_MULTILINE_INDICATOR = { || "" }
      '';
    })

    (lib.mkIf cfg.enableBashIntegration {
      xdg.configFile."bash/conf.d/99-starship.sh".text = ''
        eval "$(starship init bash)"
      '';
    })
  ]);
}
